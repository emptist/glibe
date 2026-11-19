# Phase 04 Plan 06 — Summary

**A standard bar's time is unix time. Provider bars stay native and standardise
themselves.** Owner rulings R27 / R28 / R29, plus R13 / R19 / R22 / R23 / R26.

## What changed

- `gleam_time 1.11.0` added (one Hex package, Erlang target, no npm).
- `api/sourcebar.gleam`: `SourceBar(timestamp: Timestamp, open, high, low,
  close, volume)`; `SourceBarTimeError` closed set; `unix_timestamp` converts
  epoch milliseconds / RFC3339 / unlabelled ISO (UTC at that adapter) or
  rejects. `validate` unchanged. `decode_bar` serves one concrete JSON line
  format, not a universal provider shape.
- `api/interval.gleam`: `bucket_ends(Interval, Timestamp)` is unix-second
  remainder arithmetic. `clock_of` / `minute_of` / string splitting deleted.
- `binance/kline.gleam`: native `Kline` with **all twelve** REST fields;
  `decode_klines -> List(Kline)`; `to_sourcebar` is this provider's conversion;
  `parse_number` fixes `float.parse("100") == Error(Nil)` at the wire edge.
- `binance/binance.gleam`: `fetch_klines` is the exit to the standard model;
  `BinanceError.BarTimeError(SourceBarTimeError)` keeps the reason.
- `engine.gleam`, `databar.gleam`, `export/csv.gleam`: `timestamp` throughout;
  RFC3339 formatting only at the output edge.
- Tests: new `test/sourcebar_time_test.gleam` (6), updated `glibe_test.gleam`
  and `interval_test.gleam`; two obsolete `normalize_date` tests removed.

## Direction correction

The first draft defined a `BarClock` "wall-clock reading" and argued against
`Timestamp` via R26. R27 voided it; the module and its tests were deleted with
no alias, compat layer or deprecated copy. R28 then required native provider
shapes/names; R29 recorded the DST/market-calendar debt.

## Measured

RED 54 passed / 11 `todo` failures (0 compile errors). GREEN
`gleam build --warnings-as-errors` 0/0, `gleam test` **58 passed**,
`gleam format --check src test` 0, `sh scripts/guards.sh --all` 0,
`gleam docs build` 0. `package-interface.json` carries `04-06-PLAN` links on
every touched module. Core mirror `cmp` 0; no reverse references to the
temporary decisions file.

## Deliberately not done

`tzif` 2.0.0 (+ `zones` / `tzif_loader`) is the verified Gleam IANA library,
but is **not** a dependency yet. `ibOptions/tradingtime.py:24`
`pytz.timezone('US/Eastern')` and `simple_auto_trading.py:132`
`astimezone(eastern)` show the shape. US 09:30 open / DST / non-UTC bucket
grids get their own plan when a US-equity consumer exists (R26 / R29).
Day/week/month buckets still answer `True` (04-02 debt).
