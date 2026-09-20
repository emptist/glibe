# Roadmap: glibe - Multi-API Trading Library

## Milestones

### v1.0 - IB API Wrapper (Complete)
Phase 1: Foundation & IB Connection ✅

### v1.1 - Binance API Support
Phase 2: Binance REST API (klines, ticker, exchange info) - Code complete, network blocked

### v1.2 - Stream Processing
Port glib indicators and pipeline

### v1.3 - Strategy & AI
Port glib trading logic and AI modules

---

## Phase 1: Foundation & IB Connection ✅
**Status**: Complete
- IB Client Portal Gateway connection via curl FFI
- Auth status, accounts working
- Clean Gleam API with Dynamic returns

---

## Phase 2: Binance API Support
**Goal**: Public REST API for market data (klines, ticker, exchange info)

### Tasks
1. ✅ Port SourceBar type from glib
2. ✅ Create Erlang FFI for Binance HTTP calls (httpc/curl)
3. ✅ Create Gleam Binance API module
4. ⏸ Test: fetch klines for BTCUSDT — **Network blocked** (api.binance.com timeout)

### Files
- `src/glibe/binance/types.gleam` — SourceBar, Interval types
- `src/glibe/binance/binance_ffi.erl` — Erlang FFI using curl
- `src/glibe/binance/binance.gleam` — Gleam public API
- `src/binance_test.gleam` — Integration test

### Verification
- [x] `gleam build` succeeds
- [ ] Fetch BTCUSDT 1h klines returns bars — **Blocked by network**

---

## Phase 3: Stream Processing (Future)
Port glib indicators: SMA, Bollinger, KDJ, Fractal

---

## Phase 4: Strategy & AI (Future)
Port glib trading logic

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. IB Foundation | 1/1 | Complete | 2026-09-18 |
| 2. Binance API | 1/1 | Code complete, network blocked | - |
| 3. Stream Processing | 0/1 | Not started | - |
| 4. Strategy & AI | 0/1 | Not started | - |