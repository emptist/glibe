# Phase 04 Plan 05 — adopt R24 A: summary (2026-11-09)

**R24's recommendation is built. The product now has a thin Mist + Wisp BEAM
web layer serving the real `Desk`, with zero hand-written JS.**

## Decision and authority

R24 (*"web层架构当然是你通过写demo对比测试决定用哪一个呀"*) makes the framework
choice the AI's work. The three measured demos of phase 04-04 recommended A.
This plan is the adoption step `docs/DESIGN.md` and `04-04-SUMMARY.md` said it
waited for. No owner ruling was asked for or added; the decisions document
stays at zero items.

## What landed

- `gleam.toml` / `manifest.toml`: `mist >= 6.0.3 < 7`, `wisp >= 2.2.2 < 3`.
  Root stays `target = "erlang"`; `webclient/` is still the only JS-target
  package (R15 / R18); no npm dependency, no new package, no path dependency.
- `src/glibe/web/server.gleam`:
  - `Route` — a closed set `RouteDeskPage | RouteDeskJson | RouteNotFound`.
    A path `String` never stands in for an endpoint (R13, R21).
  - `route`, `desk_to_json`, `page`, `handle_request`, `main`, plus private
    encoders/renderers — every one with `///` documentation.
  - The payload is `config.default_config().desk`: `BrokerId`, `Symbol` and
    `Interval` become display strings **only at this text boundary**. No
    `SettledBar` fixture, no `"BTCUSDT_H1"` composite key, no invented view
    model (R22 / R23).
  - `main` lives in this module and is run with
    `gleam run -m glibe/web/server` on port 8610, so the root library keeps no
    global `main` slot for Stage F's replay CLI.
- `test/web_server_test.gleam`: written before the bodies. Four tests cover
  the closed route set, the JSON chain, the HTML chain, and **real Wisp
  requests** built with `wisp/simulate.request` — status and body included,
  not just string helpers.

## Measured RED → GREEN

| phase | result |
|---|---|
| RED | `gleam test` exit 1 — **50 passed, 4 failures**, all four at `todo as "…"` bodies |
| GREEN | `gleam test` **54 passed / 0 failures**; `gleam build --warnings-as-errors` 0; `gleam format --check src test` 0; `sh scripts/guards.sh --all` 0; `gleam docs build` 0 |
| doc drift | `build/dev/docs/glibe/package-interface.json` → `glibe/web/server` documentation carries `04-05-PLAN`; 20 doc lines. Empty module docs 15 / 25. |

## Real HTTP run

`gleam run -m glibe/web/server`, then HTTP GETs on port 8610:

- `GET /` → **200**, 371 bytes, contains `<table`, `BTCUSDT`, `futu`.
- `GET /desk` → **200**, 236 bytes, valid JSON:
  `{"brokers":[{"id":"binance","instruments":[{"symbol":"BTCUSDT","intervals":["1h","1d"]}]},{"id":"futu",…{"symbol":"SPY_FUTU"…},{"id":"ib",…{"symbol":"SPY"…}]}`
- `GET /nope` → **404**.
- Port 8610 released after the run; no BEAM child left listening.

## Debt, recorded not hidden

- No chart library, no real SPA interaction, no streaming, no load test. The
  generated `webclient.mjs` was measured for importability in 04-04, not wired
  into a canvas here.
- HTML escaping of arbitrary untrusted strings is not implemented; the values
  rendered are literals in `config.gleam`.
- `/desk` exposes the ownership chain's **structure**, not `Timeframe` state
  (bars, leaves, branches). A bar endpoint waits for a real bar consumer.
- `bucket_ends(date: String)` → `gleam_time.Timestamp` remains a separate
  boundary plan, already named in `api/interval.gleam`'s module doc.

## Commit order (one logical concern per commit, landed as each step finished)

`c623336` plan → `bbe5824` deps → `db5d6f4` documented skeleton + tests (RED)
→ `2b218f5` bodies (GREEN) → stable docs + memory (this change set).
