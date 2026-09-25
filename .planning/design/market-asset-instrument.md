# Market/Asset/Instrument/Security/Trading Design — Complete & Verified

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

### Complete Type Hierarchy (Verified)

```
Exchange (Venue identity)
    id: "binance" | "ib" | "nyse" | "coinbase" | "futu"
    name: "Binance" | "Interactive Brokers" | "NYSE" | "Coinbase" | "Futu"
    mic: "XNAS" | "XNYS" | "BINA" | "FUTU"  // ISO 10383 MIC
    ↓
AssetClass (Legal classification)
  Crypto | Equity | ETF | BStock | Future | Option | Currency
    ↓
Asset (Legal entity)
  id: "BTC" | "AAPL" | "TSLA" | "USD" | "CNY" | "HKD"
  name: "Bitcoin" | "Apple Inc." | "Tesla Inc." | "US Dollar"
  class: AssetClass
    ↓
Market (Exchange + AssetClass + Rules)  ← Trading rules live here
  exchange: Exchange
  asset_class: AssetClass
  rules: MarketRules (trading_hours, fees, data_limits, settlement, etc.)
    ↓
Asset (Legal entity)
  id: "BTC" | "AAPL" | "TSLA" | "USD" | "CNY" | "HKD"
  name: "Bitcoin" | "Apple Inc." | "Tesla Inc." | "US Dollar"
  class: AssetClass
    ↓
Symbol (Instrument = what you trade)
  market_id: "binance_spot_crypto" | "ib_equity" | "binance_bstock" | "futu_hk_equity"
  asset_id: "BTC" | "AAPL" | "TSLA"
  market_symbol: "BTCUSDT" | "AAPL" | "TSLAB/USDT" | "00700.HK"
  base_asset: Asset("BTC", "Bitcoin", Crypto) | Asset("USD", "US Dollar", Currency)
  quote_asset: Asset("USDT", "Tether", Crypto) | Asset("USD", "US Dollar", Currency) | Asset("CNY", "Chinese Yuan", Currency)
  available_brokers: ["ib", "futu", "binance"]
  available_data_providers: ["binance", "polygon", "futu", "ib"]
  primary_execution_venue: "binance" | "ib" | "futu"
    ↓
TimeframeSettings (per Symbol + Interval)
  sma_tiny_window_size, sma_small_window_size, ...
  kdj_params, bollinger_params, fractal_params
  branch_exit_leaf_size
    ↓
Timeframe (Runtime state per Symbol + Interval)
  symbol: Symbol
  interval: Interval
  settings: TimeframeSettings
  working_databar: Option(DataBar)
  databar_list: List(DataBar)  // newest-first
  growing_yin_leaf, growing_yang_leaf
  yin_leaf_list, yang_leaf_list
  growing_yin_branch, growing_yang_branch
  yin_branch_list, yang_branch_list
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

### MarketRules (Per Market) — Complete
```gleam
type MarketRules {
  MarketRules(
    trading_hours: TradingHours,           // 24/7, RTH, TwentyFourFive, Custom
    fees: FeeSchedule,                     // maker/taker bps, min_commission, platform_fee_bps
    data_limits: DataRequestLimits,        // max_bars, history_depth, rate_limits
    order_types: List(OrderType),
    leverage_limits: LeverageLimits,
    settlement: SettlementType,            // Instant, TPlus1, TPlus2, CryptoOnChain
    min_order_size: Float,
    price_precision: Int,
    lot_size: Float,
    price_limits: Option<PriceLimits>,     // ±10% for China A-shares
    short_selling_allowed: Bool,           // false for China A-shares
    auction_mechanism: Option<AuctionType>, // Opening, Closing, Both
    margin_model: MarginModel,             // initial/maintenance per symbol
    circuit_breaker: Option<CircuitBreaker>, // price halt rules
    corporate_actions: CorporateActionHandling,
    dividend_handling: DividendHandling,   // "cash", "multiplier_rebase"
  )
}
```

### TradingHours — Complete
```gleam
type TradingHours {
  TwentyFourSeven        // Crypto, BStock
  TwentyFourFive         // Forex 24/5
  RTH { open: String, close: String, timezone: String }  // "09:30", "16:00", "America/New_York"
  Custom(List<Session>)  // China 2-session, HK 2-session
}
type Session { Session(open: String, close: String, timezone: String) }
```

### DataRequestLimits (Per Market)
```gleam
type DataRequestLimits {
  DataRequestLimits(
    max_bars_per_request: Map(Interval, Int),      // {D1: 2520, H1: 5000}
    max_history_days: Map(Interval, Int),          // {D1: 7560, H1: 730}
    rate_limit_req_per_sec: Int,                   // 50
    rate_limit_req_per_min: Int,                   // 100
    max_concurrent_requests: Int,                  // 5
    requires_pagination: Bool,                     // true for IB
    supports_streaming: Bool,                      // WebSocket available
  )
}
```

### Broker / APIProvider / ExecutionVenue
```gleam
type Broker {
  Broker(
    id: String,              // "ib", "futu", "binance", "alpaca"
    name: String,
    supported_markets: List<String>,  // market_ids
    account_types: List<AccountType>,
    capabilities: BrokerCapabilities,
  )
}
type BrokerCapabilities { ... }

type DataProvider {
  DataProvider(
    id: String,              // "binance", "polygon", "ccxt", "futu", "ib"
    name: String,
    supported_markets: List<String>,
    capabilities: DataProviderCapabilities,
  )
}

type ExecutionVenue {
  ExecutionVenue(
    id: String,              // "nyse", "binance", "futu_internal", "cme"
    name: String,
    mic: String,
    supported_asset_classes: List<AssetClass>,
    settlement: SettlementType,
  )
}
```

### Symbol (Complete)
```gleam
type Symbol {
  Symbol(
    market_id: String,
    asset_id: String,
    market_symbol: String,
    base_asset: Asset,
    quote_asset: Asset,
    available_brokers: List<String>,
    available_data_providers: List<String>,
    primary_execution_venue: String,
  )
}
```

---

## STRATEGY vs TRADING Separation (Explicit)

### The Interface (Only Thing Strategy Sees)

```gleam
// STRATEGY SIDE — Pure, Trading-Agnostic
type DataBar {
  // Pure market data
  date, open, high, low, close, volume
  // Pure indicators
  sma_tiny, sma_small, sma_medium, sma_large
  bb_m, bb_u3, bb_l3, ...
  k, d, j, m
  yin_leaf_cma, yang_leaf_cma
  // Structural facts
  // NO fees, NO margin, NO settlement, NO broker info
}

type Signal {
  signal_type: SignalType,    // Buy/Sell/Hold/Call/Put
  direction: Direction,       // Bullish/Bearish/Neutral
  confidence: Float,          // 0.0 - 1.0
  reason: String,
  // NO order details, NO broker, NO size, NO execution algo
}

type TimeframeSettings { ... }  // Pure indicator params
type Symbol { ... }             // Opaque to strategy
```

### Strategy Side (Deep, Stable) — Only Sees Clean Data

| Module | Responsibility | Imports |
|--------|----------------|---------|
| `signal` | Signal types + generation | `DataBar`, `Signal`, `TimeframeSettings`, `Symbol` |
| `indicators` | SMA, KDJ, Bollinger | `DataBar`, `TimeframeSettings`, `List(DataBar)` |
| `fractal` | Leaf, Branch detection | `DataBar`, `DataLeaf`, `DataBranch` |
| `timeframe` | Timeframe + pipeline | `DataBar`, `TimeframeSettings`, `Symbol` |

**Strategy code NEVER imports:** `Broker`, `MarketRules`, `FeeSchedule`, `SettlementType`, `ExecutionVenue`, `DataProvider`, `BrokerCapabilities`, `MarginModel`, `RiskLimits`

### Trading Side (Shallow, Complex) — Absorbs All Complexity

| Subsystem | Risk | Changes |
|-----------|------|---------|
| **Brokers** | API changes, new venues | High |
| **API Providers** | API changes, limits | High |
| **Market Rules** | Regulatory, fees, limits | Medium |
| **Execution Algos** | Optimization, venues | High |
| **Risk Engine** | Regulatory, models | Medium |
| **Settlement** | Operational, regulatory | Low |
| **Reconciliation** | Operational | Low |

### The Adapter Layer (Trading Side Only)

```gleam
module StrategyAdapter {
  // Strategy side: PURE function (no trading logic)
  fn strategy_signal(databar: DataBar, timeframe: Timeframe, settings: TimeframeSettings) -> Signal

  // Trading side: adapts Signal → Order (all trading logic here)
  fn adapt_signal_to_order(
    signal: Signal,
    symbol: Symbol,
    timeframe: Timeframe,
    broker: Broker,
    account: Account,
    risk_limits: RiskLimits,
    market_rules: MarketRules,
    portfolio: Portfolio,
  ) -> Result(Order, ExecutionError)

  // Pure trading logic
  fn size_position(signal: Signal, account: Account, risk: RiskLimits) -> Float
  fn select_broker(symbol: Symbol, available: List<Broker>) -> Broker
  fn select_execution_algo(order: Order, market: Market) -> ExecutionAlgo
  fn apply_risk_checks(order: Order, risk: RiskLimits) -> Result(Order, RiskError)
}
```

---

## Architecture: Subsystem Isolation

```
src/glibe/
├── strategy/              # STRATEGY SIDE (Deep, Stable, Pure)
│   ├── signal.gleam       # Signal types + generation
│   ├── indicators/        # SMA, KDJ, Bollinger
│   ├── fractal/           # Leaf, Branch detection
│   ├── timeframe.gleam    # Timeframe + pipeline
│   └── databar.gleam      # DataBar (clean)
│
├── trading/               # TRADING SIDE (Shallow, Complex)
│   ├── broker/            # Broker, BrokerCapabilities
│   ├── api_provider/      # DataProvider, capabilities
│   ├── execution/         # ExecutionVenue, Order, Algos
│   ├── market/            # Market, MarketRules, Symbol
│   ├── risk/              # RiskEngine, RiskLimits, VaR
│   ├── settlement/        # Settlement, Reconciliation
│   ├── adapter/           # StrategyAdapter (Signal → Order)
│   └── reconciliation/    # Reconciliation, Audit
│
├── api/                   # SHARED TYPES (Minimal, Stable)
│   ├── symbol.gleam       # Symbol (opaque to strategy)
│   ├── databar.gleam      # DataBar (clean)
│   ├── signal.gleam       # Signal (clean)
│   └── timeframe.gleam    # Timeframe (opaque)
```

---

## Boundary Rule (Invariant)

> **Any change in Trading Side MUST NOT require changes in Strategy Side code.**

- Strategy code NEVER imports: `Broker`, `MarketRules`, `FeeSchedule`, `SettlementType`, `ExecutionVenue`, `DataProvider`, `BrokerCapabilities`, `MarginModel`, `RiskLimits`
- Strategy code ONLY imports: `DataBar`, `Signal`, `Timeframe`, `Symbol` (opaque), `TimeframeSettings`
- All trading complexity absorbed in `StrategyAdapter` layer

---

## Verified Types — Phase 1 Implementation Order

| Type | File | Status | Depends On |
|------|------|--------|------------|
| `AssetClass` | `api.gleam` | ✅ Ready | — |
| `Exchange` | `api.gleam` | ✅ Ready | — |
| `Asset` | `api.gleam` | ✅ Ready | `AssetClass` |
| `MarketRules` | `api.gleam` | ✅ Ready | `TradingHours`, `FeeSchedule`, `DataRequestLimits`, `LeverageLimits`, `SettlementType`, `PriceLimits`, `AuctionType`, `MarginModel`, `CircuitBreaker` |
| `Market` | `api.gleam` | ✅ Ready | `Exchange`, `AssetClass`, `MarketRules` |
| `Symbol` | `api.gleam` | ✅ Ready | `Asset`, `Market` |
| `TimeframeSettings` | `indicators.gleam` | ✅ Exists | — |
| `TradingHours` | `api.gleam` | ✅ Ready | — |
| `FeeSchedule` | `api.gleam` | ✅ Ready | — |
| `DataRequestLimits` | `api.gleam` | ✅ Ready | — |
| `TradingHours` (TwentyFourFive) | `api.gleam` | ✅ Ready | — |
| `PriceLimits`, `AuctionType`, `CircuitBreaker` | `api.gleam` | ⏳ Phase 2 | — |
| `Broker`, `DataProvider`, `ExecutionVenue` | `trading/` | ⏳ Phase 2 | — |
| `Security`, `FeeModel`, `SlippageModel`, `FillModel`, `MarginModel` | `trading/` | ⏳ Phase 2 | — |

---

## Config System — Single Source of Truth: `config.gleam`

**Decision: No JSON config files.** Gleam IS the config — type-safe, human-readable, version-controlled.

**Rationale:**
- Trading systems need runtime config changes without recompilation → use `config/local.gleam` overrides
- Different environments (dev/staging/prod) → separate override files
- Non-developers modify trading params → simple Gleam records, IDE autocomplete
- Secrets handled separately → environment variables (never in code)
- Gleam IS config: type-safe, IDE autocomplete, refactor-safe, no JSON parsing

**Architecture:**
```
src/glibe/config.gleam          # Single source of truth (committed)
config/
├── local.gleam                  # Gitignored, per-environment overrides
└── secrets.gleam                # Gitignored, never committed (API keys, etc.)
```

### Config Structure (Gleam Records)

```gleam
// In src/glibe/config.gleam - Single source of truth

pub type AppConfig {
  AppConfig(
    version: Int,
    exchanges: List(#(String, Exchange)),
    assets: List(#(String, Asset)),
    markets: List(#(String, Market)),
    symbols: List(#(String, Symbol)),
    timeframe_settings: List(#(String, TimeframeSettings))
  )
}

// Override layer (gitignored)
config/
├── local.gleam        # fn local_overrides(base: AppConfig) -> AppConfig
└── secrets.gleam      # fn secrets() -> Secrets (API keys, never committed)
```

### Config Loader Pattern

```gleam
// In config.gleam
pub fn load_config() -> AppConfig {
  let base = default_config()
  let with_local = local_overrides(base)      // Reads config/local.gleam if exists
  let with_secrets = apply_secrets(with_local) // Reads config/secrets.gleam if exists
  with_secrets
}
```

### Environment Overrides

```gleam
// config/local.gleam (gitignored)
pub fn local_overrides(base: AppConfig) -> AppConfig {
  // Development overrides
  base
  |> update_exchange("binance", fn(e) { Exchange(..e, base_url: Some("https://testnet.binance.vision")) })
  |> update_market("binance_spot_crypto", fn(m) { Market(..m, rules: MarketRules(..m.rules, data_limits: DataRequestLimits(..m.rules.data_limits, rate_limit_req_per_sec: 10))) })
}

// config/secrets.gleam (gitignored, NEVER COMMITTED)
pub fn secrets() -> Secrets {
  Secrets(
    binance_api_key: "PROD_KEY",
    binance_api_secret: "PROD_SECRET"
  )
}
```

### Production Deployment

```bash
# Build includes config.gleam (defaults)
# Deploy copies config/local.gleam + config/secrets.gleam to server
# Or use environment variables for secrets:
#   BINANCE_API_KEY=xxx BINANCE_API_SECRET=xxx gleam run
```

---

## Phase 1 Scope (Binance Live Feed — Now)

## Phase 1 Scope (Binance Live Feed — Now)

### Implement in `api.gleam` (Replace `MarketType`)
1. `AssetClass` enum: `Crypto`, `Equity`, `ETF`, `BStock`, `Future`, `Option`, `Currency`
2. `Exchange` struct: `id`, `name`, `mic`
3. `TradingHours`: `TwentyFourSeven`, `TwentyFourFive`, `RTH`, `Custom`
4. `FeeSchedule`: `maker_bps`, `taker_bps`, `min_commission`, `platform_fee_bps`
5. `DataRequestLimits`: `max_bars_per_request`, `max_history_days`, `rate_limit_*`, `requires_pagination`, `supports_streaming`
6. `MarketRules`: all fields above
7. `Exchange`: `id`, `name`, `mic`
8. `Market`: `exchange`, `asset_class`, `rules`
9. `Asset`: `id`, `name`, `class`
9. `Symbol`: all fields above
10. `TimeframeSettings`: (already in `indicators.gleam`)

### Update `timeframe.gleam`
- Replace `symbol: String` with `symbol: Symbol`
- Pipeline unchanged: `sourcebar_gate` → `databar_processing` (indicators → leaves → branches → strategy → runtime_test → accept)

### Update `binance.gleam`
- Return `SourceBar` with `Symbol` context
- Handle Crypto + BStock symbols

---

## Self-Challenge Questions (Answered)

1. **Is `Security` needed now?** No — no execution. Phase 2.
2. **Do we need `MIC` now?** No — single exchange (Binance). Phase 2.
3. **Is `AssetClass` enough?** `BStock` distinct enough. `Currency` added for Forex.
5. **Should `Symbol` include interval?** No — `Timeframe` = Symbol + Interval.
6. **Where `branch_exit_leaf_size`?** `TimeframeSettings` per Symbol+Interval.
6. **BStock dividends?** `MarketRules.dividend_handling = "multiplier_rebase"`.
7. **BStock convert to real?** `MarketRules.convert_hours = "US_RTH"`.
8. **BStock withholding?** `MarketRules.withholding_tax = 0.30`.
9. **Futu China A-shares?** `price_limits`, `short_selling_allowed=false`, `auction_mechanism`, `Custom` trading hours.
10. **Futu Forex?** `AssetClass.Currency`, `TwentyFourFive` hours, `Settlement.TPlus2`, high leverage.
11. **Same SPY on IB vs Futu?** Different `Market` → different `MarketRules` (fees, data limits, broker).
12. **Strategy isolation?** Strategy only sees `DataBar`, `Signal`, `Symbol` (opaque). Trading side handles all broker/market/execution complexity.

---

## Next Steps

1. **Review this document** — final challenge
2. **Implement Phase 1 types** in `api.gleam` (replace `MarketType`)
3. **Update `Timeframe`** to hold `Symbol` instead of `symbol: String`
3. **Update `binance.gleam`** to return `SourceBar` with `Symbol` context
4. **Test** with Binance klines → Timeframe pipeline
5. **Write tests** for indicator math, leaf/branch invariants

---

## References

- QuantConnect LEAN: `Security` object, `Symbol`, `Market` enum
- CCXT: 104 exchanges, unified symbol format
- Backtrader: Pluggable feeds/brokers, event-driven
- TradingGoose: Canonical ticker + MIC (ISO 10383), `ISymbolMapper`
- ESX: Full exchange stack, event-driven microservices
- MariaAlpha: Live execution, SOR, risk, multi-venue
- ESX: Event-driven microservices, Kafka, full exchange stack