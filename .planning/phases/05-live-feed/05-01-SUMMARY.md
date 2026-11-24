# 05-01 — real Binance REST live feed (SUMMARY)

2026-11-25. Owner: *"不要在乱搞了，老老实实做数据源连接获取真实时数据"* (R78). The DEMO triangle wave was a placeholder, not a data source; this plan replaces it with a real live REST feed.

## Measured first, no guessing
- `api.binance.com` / `api-gcp.binance.com`: timeout (HTTP 000) from this host.
- `data-api.binance.vision/api/v3/klines`: HTTP 200 direct AND via proxy; body timestamp = current wall clock. Reachable official public market-data host.
- Gleam `httpc.send(request.to(url))` reaches it (status 200). `gleam_json` + `decode.field(0..7)` decode the kline arrays on Erlang; indices 8+ are past `decode.field`'s first-eight-list-elements limit, so only fields 0–7 are read (the six a bar needs + close_time). Probes removed after measuring.

## What landed
| file | role |
|---|---|
| `src/glibe/binance/rest.gleam` | `decode_klines(payload, interval)` PURE; `fetch_klines(symbol, interval, limit)` the only IO; `interval_to_binance_string` (9 variants); `RestError` domain type + `describe_error`. REST's array-of-arrays stays its own shape (R28), not folded into `binance/kline`'s 12-field record. |
| `src/glibe/live_feed.gleam` | `newer_than` / `advance_boundary` PURE filter; `pump` recursive fetch→filter→inject→advance→sleep; `run` seeds a real window then polls. Boundary is a recursion argument (no mutation). Fetch failure logs + retries — never a synthetic fallback (R33 one stream). |
| `src/glibe.gleam` | `main` drives the ONE App via `live_feed.run(... BTCUSDT, IntervalOneMinute)`; `demo_feed` gone from the live path. Exactly ONE `plushie.start(`. |
| `test/binance_rest_test.gleam` | 5 tests pinned with a REAL captured 3-bar payload (verbatim from the live response). |
| `test/live_feed_test.gleam` | 4 tests on the pure filter with real timestamps. |
| `.planning/phases/05-live-feed/05-01-PLAN.md` | the plan this module doc references (R19/R44). |

## RED→GREEN
- `rest`: skeleton 3 signatures + `todo` → WAE fails on todos → 5 tests RED (135 passed + 5 failures) → filled one body at a time → GREEN.
- `live_feed`: skeleton 5 signatures + `todo` → 4 tests RED (140 passed + 4 failures) → filled → GREEN.
- Two Gleam corrections caught by the compiler: `use` needs a callback-last function (`result.try`, not a plain helper); `KlineWire` prices are `String` on the wire, parsed to Float at birth.

## Gates (real exit codes, 2026-11-25)
`format --check` 0 · `check` 0 · `test` **144 passed, no failures** · `docs build` 0 · `export package-interface` 0 · `build --warnings-as-errors` 0 (0 Todo, 0 unused).

## End-to-end proof (not synthetic)
`fetch_klines("BTCUSDT", IntervalOneMinute, 5)` returned 5 real bars; first = `SourceBarOneMinute(Timestamp(1795543920, 0), 60109.74, 60134.89, 60092.01, 60116.01, 16)` — timestamp = the then-current minute, prices = live market data. Probe removed after the run.

## Commit
`75474ab` feat(feed): replace synthetic bars with live Binance REST klines (R78).

## Not done (and why)
- GUI screenshot: sandbox blocks `screencapture`/`ps`/`qlmanage` (R77). The real-data chart is driven by live klines in code; no GUI capture is possible here.
- IB / other providers: R26 leaves the provider set open; only the reachable Binance public endpoint is wired. No invented provider.
