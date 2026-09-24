# Market/Asset/Instrument/Security Design — Reviewed

## Research Summary: How Major Systems Handle This

| System | Symbol/Instrument | Asset | Market/Exchange | Security/Metadata | Key Pattern |
|--------|-------------------|-------|-----------------|-------------------|-------------|
| **QuantConnect/LEAN** | `Symbol` (immutable ID) | `Security` object | `Market` enum | `Security` holds ALL models: Fee, Slippage, Fill, Margin, Volatility | One `Security` per `Symbol`, holds ALL models |
| **CCXT** | `'BTC/USDT'` (spot), `'BTC/USDT:USDT'` (perp) | Implicit | Exchange ID (104) | No metadata in client | Unified client, no backtesting |
| **Backtrader** | DataFeed + string | Implicit | Broker/Store per exchange | In Strategy/Indicators | Pluggable feeds/brokers, event-driven |
| **BTQuant** | String + Feed | Implicit | Store/Feed per exchange | In Strategy | Pluggable feeds/brokers |
| **QuantConnect Multi-Asset** | `Symbol` | `Security` | `Market` enum | `Security` holds models | Portfolio = collection of Securities |
| **ESX (Exchange)** | Symbol (MIC-based) | Asset | Exchange (self) | Central order book | Full exchange stack |
| **MariaAlpha** | Symbol string | Implicit | Venue config | In Risk/Execution | Live execution, SOR, Risk |
| **TradingGoose** | Canonical ticker + MIC | Asset | MIC (ISO 10383) | SymbolMapper per broker | Canonical ID + broker mapper |

---

## Key Design Principles from Industry

### 1. Symbol = Unique Tradeable Instrument
- **QuantConnect**: `Symbol` is immutable, packs security type, market, strike, expiry, option style into 64-bit
- **TradingGoose**: Canonical ticker + MIC (ISO 10383), immutable ID stays constant while ticker can change
- **CCXT**: Simple string `'BTC/USDT'` or `'BTC/USDT:USDT'` for perp

### 2. Security = All Models for One Symbol (QuantConnect pattern)
```csharp
// LEAN Security object per symbol
Security {
  Symbol symbol;
  FeeModel feeModel;
  SlippageModel slippageModel;
  FillModel fillModel;
  MarginModel marginModel;
  VolatilityModel volatilityModel;
  PriceModel priceModel;
  Data data;                    // Market data
  Holdings holdings;            // Position tracking
  Cache cache;                  // Temp storage
}
```
**All models live on Security, not scattered.**

### 3. Asset vs Instrument
- **Asset** = legally defined thing (`BTC`, `AAPL`, `TSLA`)
- **Instrument/Symbol** = asset on specific venue (`BTCUSDT` on Binance, `AAPL` on IB, `TSLAB/USDT` on Binance BStock)

### 4. Exchange/Market = Venue + Rules
- **Exchange** = identity (`Binance`, `IB`, `NYSE`)
- **Market** = Exchange + rules for specific asset class (Binance-Spot-Crypto, IB-Equity, Binance-BStock)
- **MIC (ISO 10383)** = standard for exchange identification

### 5. Pluggable Architecture (Backtrader/LEAN/CCXT)
- Feeds pluggable (CCXT, IB, Yahoo, CSV, DB)
- Brokers pluggable (IB, CCXT, Alpaca, Paper)
- Strategies pluggable
- Execution algorithms pluggable

---

## Our Design — Validated Against Industry

### Hierarchy (Bottom-Up)

```
TimeframeSettings (per symbol + interval)
    ↓
Symbol (Instrument) ← what you trade
    market_id: "binance_spot" | "ib_equity" | "binance_bstock"
    asset_id: "BTC" | "AAPL" | "TSLA"
    market_symbol: "BTCUSDT" | "AAPL" | "TSLAB/USDT"
    base_asset: Asset("BTC", "Bitcoin", Crypto)
    quote_asset: Asset("USDT", "Tether", Crypto)
    ↓
Market (Exchange + Rules for asset class)
    exchange: Exchange("binance", "Binance")
    asset_class: AssetClass (Crypto, Equity, BStock, Future, Option)
    rules: MarketRules
    base_currency: "USDT" | "USD"
    quote_currency: "USDT" | "USD"
    ↓
Exchange (Venue identity)
    id: "binance" | "ib" | "nyse" | "coinbase"
    name: "Binance" | "Interactive Brokers" | "NYSE"
    mic: "XNAS" | "XNYS" | "BINA"  // ISO 10383 MIC
    ↓
AssetClass (Legal classification)
  Crypto | Equity | ETF | BStock | Future | Option
    ↓
Asset (Legal entity)
  id: "BTC" | "AAPL" | "TSLA"
  name: "Bitcoin" | "Apple Inc." | "Tesla Inc."
  class: AssetClass
```

### Security Object (Per Symbol) — QuantConnect Pattern
```gleam
type Security {
  Security(
    symbol: Symbol,
    fee_model: FeeModel,
    slippage_model: SlippageModel,
    fill_model: FillModel,
    margin_model: MarginModel,
    volatility_model: VolatilityModel,
    // ... other models
  )
}
```

### MarketRules (Per Market)
```gleam
type MarketRules {
  MarketRules(
    trading_hours: TradingHours,      // 24/7, RTH, custom sessions
    fees: FeeSchedule,                // maker/taker bps
    order_types: List(OrderType),
    leverage_limits: LeverageLimits,
    settlement: SettlementType,       // Instant, T+1, T+2, OnChain
    min_order_size: Float,
    price_precision: Int,
    lot_size: Float,
  )
}
```

### TradingHours
```gleam
type TradingHours {
  TwentyFourSeven
  RTH { open: String, close: String, timezone: String }  // "09:30", "16:00", "America/New_York"
  Custom(List<Session>)
}
```

---

## Settings.json Structure (Validated)

```json
{
  "exchanges": {
    "binance": {
      "id": "binance",
      "name": "Binance",
      "mic": "BINA",
      "markets": {
        "spot_crypto": {
          "asset_class": "Crypto",
          "base_currency": "USDT",
          "rules": { "trading_hours": "24/7", "settlement": "Instant", ... }
        },
        "bstock": {
          "asset_class": "BStock",
          "base_currency": "USDT",
          "rules": { "trading_hours": "24/7", "dividend_handling": "multiplier", ... }
        }
      }
    },
    "ib": {
      "id": "ib",
      "name": "Interactive Brokers",
      "mic": "IBKR",
      "markets": {
        "equity": {
          "asset_class": "Equity",
          "base_currency": "USD",
          "rules": { "trading_hours": "RTH", "settlement": "T+2", ... }
        }
      }
    }
  },
  "assets": {
    "BTC": { "id": "BTC", "name": "Bitcoin", "class": "Crypto" },
    "AAPL": { "id": "AAPL", "name": "Apple Inc.", "class": "Equity" },
    "TSLA": { "id": "TSLA", "name": "Tesla Inc.", "class": "BStock" }
  },
  "symbols": {
    "BTCUSDT": { "market": "binance_spot_crypto", "asset": "BTC", "market_symbol": "BTCUSDT" },
    "AAPL": { "market": "ib_equity", "asset": "AAPL", "market_symbol": "AAPL" },
    "TSLAB/USDT": { "market": "binance_bstock", "asset": "TSLA", "market_symbol": "TSLAB/USDT" }
  },
  "timeframe_settings": {
    "BTCUSDT_H1": { "sma_tiny": 7, ... },
    "TSLAB_USDT_D1": { "sma_tiny": 7, ... }
  }
}
```

---

## Timeframe Holds Symbol + Settings

```gleam
type Timeframe {
  Timeframe(
    symbol: Symbol,              // BTCUSDT on Binance-Spot
    interval: Interval,          // H1, D1, etc.
    settings: TimeframeSettings, // indicator params for this symbol+interval
    // state fields...
  )
}
```

---

## What We Need NOW (Binance Integration)

| Component | Need Now? | Notes |
|-----------|-----------|-------|
| `Exchange`, `Market`, `Asset`, `AssetClass` types | ✅ Yes | For Binance + BStock |
| `Symbol` type | ✅ Yes | Core identifier |
| `MarketRules` | ✅ Yes | Binance 24/7 vs IB RTH |
| `Security` object | ⏳ Later | When we add execution/risk |
| `FeeModel`/`SlippageModel` | ⏳ Later | When we add execution |
| `MIC` codes | ⏳ Later | When multi-exchange |
| `ISymbolMapper` | ⏳ Later | When multi-broker |

---

## Decision: What to Implement Now

### Phase 1 (Now - Binance Live Feed)
1. **AssetClass** enum (Crypto, Equity, BStock, Future, Option)
2. **Exchange** struct (id, name, mic)
3. **Market** struct (exchange, asset_class, rules, base/quote currency)
4. **Symbol** struct (market_id, asset_id, market_symbol, base/quote asset)
5. **MarketRules** struct (trading_hours, fees, order_types, settlement, precision)
6. **TradingHours** enum (TwentyFourSeven, RTH, Custom)
7. **FeeSchedule** struct
8. **TimeframeSettings** per symbol+interval (already exists)

### Phase 2 (When IB + Multi-Exchange)
- Full `Security` object with models
- `FeeModel`, `SlippageModel`, `FillModel` traits
- Multi-currency cashbook
- MIC codes + `ISymbolMapper` per broker

### Phase 3 (Advanced)
- Multi-venue SOR
- Portfolio-level risk
- Corporate actions (splits, dividends for BStock)

---

## Validation Checklist

- [ ] Symbol uniquely identifies what we trade
- [ ] Asset is legally standardized thing
- [ ] Market = Exchange + Rules for asset class
- [ ] Exchange has MIC code (ISO 10383)
- [ ] AssetClass is legal classification
- [ ] Settings per Symbol+Interval (not per Market)
- [ ] Same asset on different exchanges = different Symbols
- [ ] All models live on Security (per Symbol)
- [ ] Settings.json structure matches types
- [ ] Timeframe holds Symbol + Settings

---

## Next Steps

1. **Review this document** — challenge every type, every field
2. **Confirm Phase 1 scope** — what we implement for Binance live feed
3. **Implement Phase 1 types** in `api.gleam` (replace `MarketType`)
3. **Update `Timeframe`** to hold `Symbol` instead of `symbol: String`
4. **Update `binance.gleam`** to return `SourceBar` with `Symbol` context
5. **Test** with Binance klines → Timeframe pipeline

---

## Self-Challenge Questions

1. **Is `Security` needed now?** No — no execution yet. Can wait.
2. **Do we need `MIC` now?** No — single exchange (Binance). Can wait.
3. **Is `AssetClass` enough or need `AssetSubClass`?** `BStock` is distinct enough as class.
4. **Should `Symbol` include interval?** No — `Timeframe` = Symbol + Interval.
5. **Where does `branch_exit_leaf_size` live?** `TimeframeSettings` per Symbol+Interval.
6. **How to handle BStock dividends?** `MarketRules.dividend_handling = "multiplier_rebase"`.
7. **BStock convert to real share?** `MarketRules.convert_hours = "US_RTH"`.
8. **BStock withholding tax?** `MarketRules.withholding_tax = 0.30`.

---

## References

- QuantConnect LEAN: `Security` object, `Symbol`, `Market` enum
- CCXT: 104 exchanges, unified symbol format
- Backtrader: Pluggable feeds/brokers, event-driven
- TradingGoose: Canonical ticker + MIC (ISO 10383), `ISymbolMapper`
- ESX: Full exchange stack, event-driven microservices
- MariaAlpha: Live execution, SOR, risk, multi-venue
- ESX: Event-driven microservices, Kafka, full exchange stack