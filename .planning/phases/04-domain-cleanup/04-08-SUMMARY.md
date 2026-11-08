# Phase 04 Plan 08 — Summary

**One addressed market bar advances exactly one `Timeframe`.** The static
ownership chain was already complete; the arrival of a bar was not. Work under
R13 / R19 / R20 / R22 / R23 / R26 / R27 / R28. **Not a new owner ruling**: the
owner asked whether the type structure could monitor many instruments × many
intervals at once and said to continue if not.

## Measured before

- `src/glibe/desk.gleam:74-94` and `src/glibe/config.gleam:75-101`: 3 brokers ×
  3 instruments × 2 intervals = six independent `Timeframe` states. Multiple
  instruments with multiple intervals was already a typed, isolated fact.
- `src/glibe/api/sourcebar.gleam:56-65`: `SourceBar` has no provider identity
  (correct, R27 / R28).
- `src/glibe/binance/binance.gleam:50-54`: `fetch_klines` returned
  `List(SourceBar)`; the request's `symbol` / `interval` were gone.
- `src/glibe/engine.gleam:65-69`: `sourcebar_gate` receives a `Timeframe` and
  an `Interval` from the caller; nothing checks the bar belongs to them.
- `sourcebar.validate` / `sourcebar_gate` returned `Result(..., String)`.

## What changed

- New `src/glibe/monitor.gleam`: `TimeframeAddress`, `IncomingBar`,
  `MonitorError`, and the pure
  `advance(desk, incoming) -> Result(Desk, MonitorError)`.
- `SourceBarRejection` in `api/sourcebar.gleam` replaces five `Error("…")`
  arms; `engine.sourcebar_gate` propagates it. No new check, no changed
  behaviour, no compatibility string.
- `binance.fetch_klines` takes a `Symbol` instead of a `String` (R22); its
  return type is unchanged, and no provider↔broker relation was invented
  (R26).
- New `test/monitor_test.gleam`: six tests, written before the bodies.

## Deliberately not done

No actor / subscription / stream / replay CLI / `gleam_otp` dependency (Stage
F), no `Market` / `Asset` / `Exchange` relation (R26), no field on `SourceBar`
or `Timeframe` (R23 / R27 / R28), no fan-out of one bar to all intervals, and
no new shell guard.

## Measured after

RED 58 passed / 6 `todo` failures (0 compile errors, 3 skeleton warnings).
GREEN `gleam build --warnings-as-errors` 0/0, `gleam test` **64 passed**,
`gleam format --check src test` 0, `sh scripts/guards.sh --all` 0,
`gleam docs build` 0. `package-interface.json` carries `04-08-PLAN.md` on
`glibe/monitor`, `glibe/api/sourcebar`, `glibe/engine` and
`glibe/binance/binance`.
