# Phase 04 Plan 02: Every time span is an `Interval` — Summary

**The `String` that named a four-hour interval is gone. It is now a value of `Interval`, and every constructor has a full, prefixed name (R21).**

## Accomplishments
- `Interval` is a **9-variant closed set**: `IntervalOneMinute`, `IntervalThreeMinute`, `IntervalFifteenMinute`, `IntervalThirtyMinute`, `IntervalOneHour`, `IntervalFourHour`, `IntervalOneDay`, `IntervalOneWeek`, `IntervalOneMonth`. Exhaustiveness checking named every place that had to learn the two new values.
- **14** `List(#(String, Int))` per-interval limit tables in `config.gleam` became `Dict(Interval, Int)`. The old `"H4"` key was not representable by the 7-variant type; it is now `interval.IntervalFourHour` and the compiler checks it.
- `rules.DataRequestLimits` gained two typed accessors returning `Result(Int, LimitError)` with `NoBarLimit(Interval)` / `NoHistoryLimit(Interval)` — no `Error(String)`, no `Option`, no `list.find`.
- **R21 naming ruled mid-cycle** (owner 2026-11-08): short exchange wire codes as type constructors are banned. Wire spellings (`"1m"`, `"4h"`) remain only in the codec / Binance adapter. The thinking core's own §0 example had the same violation and was corrected; the git mirror is `cmp`-equal.
- Three-minute buckets end on `minute % 3 == 0`; four-hour buckets on `minute == 0 && hour % 4 == 0`. One private `clock_of` reader returns both fields.

## RED / GREEN measured (Gleam 1.19.2 / OTP 29)
| stage | result |
|---|---|
| skeleton `gleam build` | exit 0, **0 errors / 14 warnings** (10 `Todo found`, 4 `Unused function argument`) |
| skeleton `--warnings-as-errors` | exit 1 — GREEN gate, not a RED requirement |
| `gleam test` before bodies | **37 passed / 7 failures**, each printing `todo <file>:<line>` + `info:` |
| after bodies | `--warnings-as-errors` 0 / **0 warnings**; `gleam test` **44 passed, no failures**; `gleam format --check` 0 |
| `sh scripts/guards.sh --all` | exit 0 (7 fixture cases) |
| `gleam docs build` | 24 modules, **19 still have empty module docs**; the 4 touched modules have `////` docs and the plan path in `package-interface.json` |

## Files Created / Changed
- Created: `.planning/phases/04-domain-cleanup/04-02-PLAN.md`, this SUMMARY, `test/interval_test.gleam` (8 tests, written before bodies).
- Changed: `src/glibe/api/interval.gleam`, `src/glibe/api/rules.gleam`, `src/glibe/config.gleam`, `src/glibe/binance/kline.gleam`, `test/glibe_test.gleam`, `test/desk_test.gleam`.
- Docs: `docs/RULINGS.md` R21, `docs/PENDING_DECISIONS.md` §5 closed, `README.md`, `docs/DESIGN.md`, `.planning/ROADMAP.md`, `docs/gleam-thinking-core-to-memory.md`.
- Outside git: `gleam-language` skill core, workflows and the runnable `docs-first-probe` (rebuilt green: 2 passed, 0 warnings, format clean).

## Decisions Made
- **Prefix + singular unit** (`IntervalOneDay`, `IntervalFourHour`), following the owner's exact examples. Wire codes stay at the boundary.
- Two `Dict(Interval, Int)` fields, not one: bars-per-request and history-days have different meanings and lifetimes.
- Four-hour buckets align to `00/04/08/…` on the hour. Recorded as an engineering decision in the plan, not hidden in code.
- **Historical docs are not rewritten** (`REVIEW_*.md`, session logs, memory logs, completed phase plans). They are records of the tree at the time; R21 says so.

## Issues Encountered
- A `case #(a, b)` produced a `Redundant tuple` warning; the compiler suggested multi-subject `case`, which is now used.
- Chained record access in a test needed explicit type annotations (`Market`, `DataRequestLimits`); `Some` needed importing.
- The blind mechanical rename briefly made historical lines claim the old code used long names; those lines were rewritten as explicit records of the replaced shape.

## Next Step
`config.gleam`'s `symbols` and `timeframe_settings` tables still use composite String keys (`"BTCUSDT_H1"`) and `list.find`. Migrating them into `glibe/desk.gleam` is one of the two **owner rulings** still open. The `Symbol` / `Instrument` naming conflict is the other. Neither was decided here.
