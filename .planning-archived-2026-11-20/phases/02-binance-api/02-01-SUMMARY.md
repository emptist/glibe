# Phase 02-binance-api Summary

## Completed: 2026-09-21

### What Was Built

**Types (`src/glibe/binance/types.gleam`)**
- `SourceBar`: date, open, high, low, close, volume
- `Interval`: D1, H1, W1, MO1, MIN1, MIN15, MIN30
- `interval_to_binance_string()`: maps to Binance format (1d, 1h, 1w, 1M, 1m, 15m, 30m)
- `decode_klines()`: parses Binance JSON array format to `List(SourceBar)`

**Pure Gleam HTTP Client (`src/glibe/binance/binance.gleam`)**
- Uses `gleam_httpc` + `gleam/http/request`
- Base URL: `https://testnet.binance.vision` (production blocked in this env)
- `fetch_klines(symbol, interval, limit)` → `Result(List(SourceBar), BinanceError)`
- `fetch_ticker(symbol)` → `Result(String, BinanceError)`
- `fetch_exchange_info()` → `Result(String, BinanceError)`
- `BinanceError`: `HttpError(Int, String)` | `JsonError`

**Test (`src/binance_test.gleam`)**
- Fetches BTCUSDT 1h klines (10 bars)
- Prints first bar with OHLCV

### Key Decisions

1. **No Erlang FFI** — Pure Gleam using `gleam_httpc`
2. **No curl** — `httpc.send(request.new() |> set_host(...) |> set_path(...) |> set_query(...))`
3. **Testnet by default** — `testnet.binance.vision` works in restricted environments
4. **Proper error handling** — `HttpError` with status code, `JsonError` for decode failures
5. **Request builder pattern** — Idiomatic `gleam/http/request` API

### Verification

- ✅ `gleam build` succeeds (no warnings)
- ✅ `gleam run -m binance_test` returns 10 bars with correct OHLCV
- ✅ Pure Gleam, no shell-outs, no Erlang FFI files
- ✅ Ready for Phase 3 (stream processing integration)

### Files Created
- `src/glibe/binance/types.gleam`
- `src/glibe/binance/binance.gleam`
- `src/binance_test.gleam`

### Files Removed
- `src/glibe/binance/binance_ffi.erl` (curl shell-out + hand-rolled JSON)

### Dependencies Added
```toml
gleam_httpc = ">= 5.0.0 and < 6.0.0"
gleam_http  = ">= 4.4.0 and < 5.0.0"
```