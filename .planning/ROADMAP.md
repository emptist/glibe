# Roadmap: glibe - Multi-API Trading Library

## Milestones

### v1.0 - Core Stream Processing (In Progress)
- Phase 1: Stream Processing Core ✅ (indicators, leaves, branches, timeframe)
- Phase 2: Binance Live Feed Integration (Not Started)
- Phase 3: Tests & Verification (Not Started)

### v1.1 - IB API Wrapper (Planned)
- Phase 4: IB Client Portal API via Elixir

### v1.2 - Strategy & Trading Separation (Planned)
- Phase 5: Strategy side (signal, adapter)
- Phase 6: Trading side (brokers, execution, risk)

### v1.3 - Integration & Examples (Planned)
- Phase 7: End-to-end examples

---

## Phase 1: Stream Processing Core ✅
**Goal**: Pure Gleam indicator pipeline with SMA, KDJ, Bollinger, Leaf/Branch detection

### Completed
- Types split: `api/` (SourceBar, Interval, MarketType, Asset, Market, Symbol, Rules), `databar.gleam`, `indicators.gleam`
- SMA series (Tiny/Small/Medium/Large) with 3-case incremental logic
- KDJ oscillator (LLV/HHV + SMA for K/D/M)
- Bollinger Bands (selected SMA centre, σ from window, Fibonacci ratios)
- Indicator pipeline: SMA×4 → KDJ → Bollinger
- Leaf detection: Yin/Yang leaves with CMA
- Branch detection: Yin/Yang branches with 9 laws
- Timeframe pipeline: sourcebar_gate → indicators → leaves → branches → strategy → runtime_test → accept
- Config.gleam: Single source of truth with string-based parsing for AssetClass, TradingHours, SettlementType, AuctionType, CircuitBreaker

### Files
- `src/glibe/api/asset.gleam` — Asset, AssetRef, AssetClass, asset_class_from_string
- `src/glibe/api/rules.gleam` — MarketRules, TradingHours, SettlementType, etc. + parsers
- `src/glibe/api/exchange.gleam` — Exchange, MarketType
- `src/glibe/api/symbol.gleam` — Symbol with market_id, asset_id, base/quote assets
- `src/glibe/api/market.gleam` — Market = Exchange + AssetClass + Rules
- `src/glibe/api/sourcebar.gleam` — SourceBar + JSON decode
- `src/glibe/api/interval.gleam` — Interval (D1, H1, W1, MO1, MIN1, MIN15, MIN30)
- `src/glibe/indicators.gleam` — TimeframeSettings, SmaSeries, SmaForBbm
- `src/glibe/sma.gleam` — SMA incremental logic
- `src/glibe/kdj.gleam` — KDJ oscillator
- `src/glibe/bollinger.gleam` — Bollinger Bands
- `src/glibe/leaf.gleam` — Yin/Yang leaf detection
- `src/glibe/branch.gleam` — Yin/Yang branch detection (9 laws)
- `src/glibe/databar.gleam` — DataBar type
- `src/glibe/timeframe.gleam` — Timeframe + full pipeline
- `src/glibe/indicator_settings.gleam` — Indicator settings
- `src/glibe/indicator.gleam` — Indicator runner
- `src/glibe/config.gleam` — AppConfig + default_config

### Verification
- ✅ `gleam build` succeeds with zero warnings

---

## Phase 2: Binance Live Feed Integration 📋
**Goal**: Connect Binance klines (Crypto + BStock) to Timeframe pipeline

### Remaining Tasks
1. **Update `binance.gleam`** — Return `SourceBar` with `Symbol` context, handle Crypto + BStock symbols
2. **Update `timeframe.gleam`** — Replace `symbol: String` with `symbol: Symbol`, use `Market` instead of `MarketType`
3. **Create integration module** — `binance_timeframe.gleam` that feeds klines into Timeframe
4. **Binance WebSocket streaming** — Real-time klines via WebSocket (future)

### Files
- `src/glibe/binance/binance.gleam` — Extend for Crypto + BStock symbols
- `src/glibe/binance/types.gleam` — SourceBar, Interval (already exists)
- `src/glibe/binance_timeframe.gleam` — New: Binance → Timeframe integration
- `src/glibe/timeframe.gleam` — Update to use Symbol + Market

### Dependencies
- Phase 1 (core types and pipeline)

### Verification
- [ ] Binance klines (BTCUSDT, TSLAB/USDT) → Timeframe → indicators → leaves → branches
- [ ] `gleam build` succeeds

---

## Phase 3: Tests & Verification 📋
**Goal**: Comprehensive test coverage and TradingView CSV verification

### Tasks
1. **Unit tests** — SMA incremental logic, KDJ math, Bollinger math
2. **Leaf/Branch invariant tests** — 9 branch laws, index ordering
3. **Property tests** — Timeframe state consistency after N bars
4. **Integration test** — Binance data → Timeframe → CSV export
5. **TradingView verification** — Compare CSV output with Pine Script

### Files
- `test/glebe_stream_test.gleam` — Stream processing tests
- `test/glebe_indicators_test.gleam` — Indicator math tests
- `test/glebe_leaf_branch_test.gleam` — Leaf/Branch invariant tests
- `test/glebe_binance_test.gleam` — Binance integration test

### Dependencies
- Phase 2 (Binance integration)

### Verification
- [ ] `gleam test` passes all tests
- [ ] CSV output matches TradingView Pine Script reference

---

## Phase 4: IB API Wrapper (v1.1) 📋
**Goal**: IB Client Portal API via Elixir ibkr_api library

### Tasks
1. **Enable `ibkr.gleam` FFI** — Fix websockex incompatibility or use alternative
2. **Implement `Glibe.Ibkr` Elixir module** — Auth, accounts, positions, orders, market data, historical data
3. **Gleam FFI bindings** — Type-safe Erlang interop
4. **Gleam public API** — `ibkr.gleam` with Result types

### Files
- `src/glibe/ib/ibkr.ex` — Elixir wrapper
- `src/glibe/ib/ibkr.gleam` — Gleam public API (currently disabled)

### Dependencies
- None (independent)

### Verification
- [ ] Gateway auth status returns `authenticated: true`
- [ ] Account data, positions, orders retrievable
- [ ] Market data snapshots work
- [ ] Historical data retrievable
- [ ] Order placement works

---

## Phase 5: Strategy & Trading Separation (v1.2) 📋
**Goal**: Clean architecture boundary between pure strategy logic and trading complexity

### Tasks
1. **Strategy side modules** — `signal.gleam`, `indicators/`, `fractal/`, `timeframe.gleam`, `databar.gleam`
2. **Trading side modules** — `broker/`, `api_provider/`, `execution/`, `market/`, `risk/`, `settlement/`
3. **Adapter layer** — `StrategyAdapter` (Signal → Order)
4. **Security object** — Per-symbol model container (QuantConnect pattern)

### Files
- `src/glibe/strategy/*.gleam`
- `src/glibe/trading/*.gleam`
- `src/glibe/api/*.gleam` (shared minimal types)

### Dependencies
- Phase 1 (core types), Phase 4 (IB client)

### Verification
- [ ] Strategy code never imports trading types
- [ ] Adapter correctly converts Signal → Order

---

## Phase 6: Integration & Examples (v1.3) 📋
**Goal**: End-to-end examples and documentation

### Tasks
1. **IB example** — IB data → indicators → signals
2. **Binance example** — Binance data → indicators → signals
3. **Integration tests** — Full pipeline tests
4. **Documentation** — README, API docs

### Files
- `src/ib_example.gleam`
- `src/binance_example.gleam`
- `test/` — integration tests

### Dependencies
- Phase 3 (tests), Phase 5 (strategy/trading)

### Verification
- [ ] Examples run successfully
- [ ] All tests pass

---

## Architecture Summary

| Layer | Technology | Status |
|-------|------------|--------|
| Core Types | Gleam (`api/`) | ✅ |
| Indicators | Gleam (SMA, KDJ, Bollinger) | ✅ |
| Fractal | Gleam (Leaf, Branch) | ✅ |
| Timeframe Pipeline | Gleam | ✅ |
| Config | Gleam (`config.gleam`) | ✅ |
| Binance Client | Gleam (`gleam_httpc`) | 🔄 Needs integration |
| IB Client | Elixir (`ibkr_api` + Finch) | 📋 FFI disabled |
| Business Logic | Gleam (pure) | 📋 |
| Visualization | Phoenix LiveView + Lightweight Charts | ✅ Compiles |

---

## Progress Summary

| Phase | Status | Completed |
|-------|--------|-----------|
| 1. Stream Processing Core | Complete | 2026-09-25 |
| 2. Binance Live Feed Integration | Not Started | - |
| 3. Tests & Verification | Not Started | - |
| 4. IB API Wrapper | Not Started | - |
| 5. Strategy/Trading Separation | Not Started | - |
| 6. Integration & Examples | Not Started | - |

---

## Key Improvements Made (2026-09-25)

1. **Zero Gleam warnings** — Fixed panic-as-function, unused imports, detached doc comments
2. **Zero Phoenix warnings** — Fixed unused imports, duplicate @doc, missing @impl
3. **Config.gleam** — Single source of truth with string-based variant parsing
4. **AssetClass/TradingHours/etc. parsing** — String-based parsers for config
5. **Phoenix app** — LiveView + Lightweight Charts compiles clean