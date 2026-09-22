# Roadmap: glibe - Multi-API Trading Library

## Milestones

### v1.0 - IB API Wrapper (Complete)
Phase 1: Foundation & IB Connection ✅

### v1.1 - Binance API Support (Complete)
Phase 2: Binance REST API ✅

### v1.2 - Stream Processing (Not Started)
Phase 3: Port glib indicators and pipeline

### v1.3 - Strategy & AI
Phase 4: Port glib trading logic and AI modules

### v1.4 - Integration
Phase 5: End-to-end testing, examples

---

## Phase 1: Foundation & IB Connection ✅
**Goal**: Clean project setup with working IB gateway connection via Elixir ibkr_api

### Tasks
1. Clean up old socket implementation files
2. Create Elixir wrapper `Glibe.Ibkr` using `ibkr_api` library (Finch, proper connection pooling, SSL)
3. Create Gleam FFI bindings to Elixir module
4. Create Gleam public API module (`ibkr.gleam`)
5. Test: connect to gateway, verify auth status

### Files
- `src/glibe/ib/ibkr.ex` — Elixir wrapper using ibkr_api
- `src/glibe/ib/ibkr.gleam` — Gleam public API with FFI to Elixir
- Removed: old socket files (`connection.gleam`, `connection_ffi.erl`, `encoder.gleam`, `encoder_ffi.erl`, `decoder.gleam`, `decoder_ffi.erl`, `protocol.gleam`, `types.gleam`, `client.gleam`, `ib_example.gleam`)

### Verification
- [x] `gleam build` succeeds
- [x] Gateway auth status returns `authenticated: true`
- [x] Uses proper HTTP client (Finch) with connection pooling, not curl

---

## Phase 2: Binance API Support ✅
**Goal**: Public REST API for market data (klines, ticker, exchange info)

### Tasks
1. Port SourceBar type from glib
2. Create pure Gleam HTTP client using `gleam_httpc` + `gleam/http/request`
3. Create Gleam Binance API module
4. Test: fetch klines for BTCUSDT (using testnet.binance.vision)

### Files
- `src/glibe/binance/types.gleam` — SourceBar, Interval types
- `src/glibe/binance/binance.gleam` — Gleam public API using gleam_httpc
- `src/binance_test.gleam` — Integration test
- Removed: `src/glibe/binance/binance_ffi.erl` (curl shell-out)

### Verification
- [x] `gleam build` succeeds
- [x] Fetch BTCUSDT 1h klines returns bars with correct OHLCV
- [x] Uses testnet.binance.vision (production API blocked in this environment)
- [x] Pure Gleam HTTP client, no Erlang FFI shell-outs

---

## Phase 3: Stream Processing 📋
**Goal**: Port all indicator modules from glib

### Tasks
1. Port `types.gleam` — SourceBar, DataBar, Order, Position, AccountSummary
2. Port `stream/stream_types.gleam` — StreamConfig, BarState, indicator states
3. Port `stream/pipeline.gleam` — bar processing pipeline
4. Port `stream/sma.gleam`, `bollinger.gleam`, `kdj.gleam` — indicators
5. Port `stream/fractal.gleam` — fractal analysis
6. Port `stream/data_bar.gleam` — DataBar construction
7. Port `stream/live.gleam` — LiveSession
8. Port `fractal.gleam` — fractal helpers

### Files
- All `src/glibe/stream/*.gleam` (to be created)
- `src/glibe/fractal.gleam` (to be created)
- `src/glibe/types.gleam` (core types)
- `src/glibe/stream/stream_types.gleam` (to be created)

### Dependencies
- Phase 2 (Binance API for live data)

### Verification
- [ ] All stream tests pass
- [ ] Pipeline processes bars correctly
- [ ] Integration: Binance data → indicators → signals

---

## Phase 4: Strategy & AI 📋
**Goal**: Port trading logic and AI modules

### Tasks
1. Port `trading/strategy.gleam`
2. Port `execution/compute.gleam`
3. Port `execution/risk_manager.gleam`
4. Port `execution/market_time.gleam`
5. Port `execution/trading_state.gleam`
6. Port all `ai/*.gleam` modules
7. Port `binance_api.gleam`

### Files
- `src/glibe/trading/*.gleam`
- `src/glibe/execution/*.gleam`
- `src/glibe/ai/*.gleam`
- `src/glibe/binance_api.gleam`

### Dependencies
- Phase 3 (stream processing)

### Verification
- [ ] Strategy tests pass
- [ ] Binance API works

---

## Phase 5: Integration & Examples 📋
**Goal**: End-to-end testing and documentation

### Tasks
1. Create example: IB data → indicators → signals
2. Create example: Binance data → indicators → signals
3. Write integration tests
4. Add documentation

### Files
- `src/ib_example.gleam`
- `src/binance_example.gleam`
- `test/` — integration tests

### Dependencies
- Phase 3 (strategy), Phase 4 (IB client)

### Verification
- [ ] Examples run successfully
- [ ] All tests pass

---

## Progress Summary

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. IB Foundation | 1/1 | Complete | 2026-09-21 |
| 2. Binance API | 1/1 | Complete | 2026-09-21 |
| 3. Stream Processing | 0/1 | Not started | - |
| 4. Strategy & AI | 0/1 | Not started | - |
| 5. Integration | 0/1 | Not started | - |

---

## Architecture Summary

| Layer | Technology | Status |
|-------|------------|--------|
| IB API Client | Elixir (`ibkr_api` + Finch) | ✅ |
| IB FFI Bridge | Gleam `@external(erlang, "Elixir.Glibe.Ibkr", ...)` | ✅ |
| Binance API Client | Gleam (`gleam_httpc` + `gleam/http/request`) | ✅ |
| Business Logic | Gleam (pure) | 📋 |
| Stream Processing | Gleam (to be ported from glib) | 📋 |

**Key improvements made:**
- Removed all `os:cmd("curl")` shell-outs
- Removed hand-rolled JSON encoding in Erlang
- IBKR: Uses official `ibkr_api` Elixir library with Finch connection pooling
- Binance: Uses `gleam_httpc` with proper TLS, timeouts, error handling
- Both APIs return typed `Result` types with proper error variants