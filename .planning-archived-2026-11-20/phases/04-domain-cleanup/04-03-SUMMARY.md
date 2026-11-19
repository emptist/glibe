# Phase 04 Plan 03: One name, one entity, one owner — Summary

**The name is not the thing; the parameter block is not an entity; one
`Instrument` has one dictionary. The circle is deleted, not adapted.**

Rulings: `docs/RULINGS.md` **R22 / R23 / R24 / R25** (2026-11-09).
Plan: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`.

## The four answers to the owner's questions

1. **"Symbol never is Instrument"** — correct, and glibe had it wrong.
   `api/symbol.gleam` declared `Symbol = Instrument = Asset on specific Market`
   and carried nine fields describing the traded thing. All nine were unread.
   Gone: no alias, no deprecated copy, no compatibility layer. `Symbol` is now
   an opaque name with a two-function text codec; `Instrument` is a keyless
   value under that name.
2. **"你所举例，是不是glibe的？是不是…绕圈子？"** — yes, and yes. The example
   was `config.gleam`'s two `List(#(String, …))` tables, the `"BTCUSDT_H1"`
   composite key, `list.find` accessors, a second `Dict(Interval,
   TimeframeSettings)` beside `Dict(Interval, Timeframe)`, three up-arrow fields
   on `Timeframe`, and an extra `settings` argument on `databar_processing`.
   All deleted. `Desk ▸ Broker ▸ Instrument ▸ Interval ▸ Timeframe` is now the
   only structure; `AppConfig.desk` is a typed `Desk` value.
   **`TimeframeSettings`**: not a domain entity, never named by the owner, an
   AI stand-in (glib's own `32-01-PLAN.md:223-225` admits *"a stand-in each"*).
   It is a 12-number parameter block whose only home is `Timeframe.settings` —
   the shape glib landed as `Timeframe(settings: IntervalSettings, …)`.
3. **"web层架构…你通过写demo对比测试决定"** — R24: mine, not an owner ruling.
   The demo comparison is written into the 04-03 plan's follow-up work with
   measurable criteria. No framework adopted here.
4. **"CPU…T+1…跟狗屁H4 M1什么的是一个性质吗？"** — no. R25 keeps `TPlus1` /
   `TPlus2` and states the discriminator: recognised professional term vs
   exchange wire spelling. R21 is not weakened.

## Measured (docs-first / TDD, R19)

| phase | value |
|---|---|
| RED | `gleam test` **exit 1**, 41 compile errors: 16 `Unknown module value`, 9 `Incorrect arity`, 9 `Type mismatch`, 4 `Unknown record field`, 1 `Unknown type for record access`, 2 `Unknown variable` |
| GREEN build | `gleam build --warnings-as-errors` **exit 0**, 0 warnings |
| GREEN tests | **50 passed, no failures** (was 44) |
| `gleam format --check src test` | exit 0 |
| `sh scripts/guards.sh --all` | exit 0 (7 fixture cases) |
| `gleam docs build` | exit 0; all 6 touched modules carry the `04-03-PLAN` link and R22/R23 in `package-interface.json` |
| module docs | empty `documentation` down from 19 to **15** of 24 |

## Files Created / Changed

- Created: `04-03-PLAN.md`, this SUMMARY, `test/symbol_test.gleam` (4 tests).
- Rewritten: `src/glibe/api/symbol.gleam`, `src/glibe/indicator_settings.gleam`,
  `src/glibe/timeframe.gleam`, `src/glibe/desk.gleam`,
  `src/glibe/config.gleam` (131 lines of composite-string tables removed),
  `src/glibe/engine.gleam`, `test/desk_test.gleam`.
- Extended: `test/glibe_test.gleam` (typed `Desk` config test + gate-interval
  test), `docs/RULINGS.md` (R22–R25 + R20/R21 status notes), `README.md`
  (current type shapes and engine signatures), `.planning/ROADMAP.md`,
  `docs/STATE.md`, `docs/DESIGN.md`; the temporary decisions-first work doc
  was cleared to zero open items.
- Historical records deliberately NOT rewritten: `REVIEW_*.md`,
  `session-ses_*.md`, `.workbuddy/memory/` logs, completed 04-01 / 04-02 plans
  (each got a dated status note instead).

## Explicitly out of scope (honest debt)

- `exchanges` / `assets` / `markets` config tables still use `String` keys.
- `Instrument` has no `Market` field yet (glib's landed shape has one); adding
  the `Market` level to glibe's chain is a separate architectural change.
- `bucket_ends` `date: String` → `gleam_time.Timestamp`; five `*_from_string`
  + `panic` codecs; day/week/month buckets still end on every bar (the new
  gate test deliberately uses `IntervalFourHour` to avoid that debt).
- Web-layer demo comparison (R24) — the next piece of work, mine to do.
