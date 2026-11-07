# Phase 04 Plan 01: Typed ownership chain — Summary

**`src/glibe/desk.gleam` gives the two orphan `config.gleam` lists typed owners, and is the first glibe module built documentation-first / TDD.**

## Accomplishments
- `Desk -> Broker -> Instrument -> Interval` is now expressed in types. Identity is a dict key (`BrokerId`, `AccountId`, `Symbol`), never a field of the owned value; both ids are `opaque`; failed lookups return a 5-variant `LookupError`, never `Error(String)`.
- The module's `////` names this plan by full path. `gleam docs build` puts that link in `package-interface.json` as machine-readable `documentation`.
- R20 in `docs/RULINGS.md` reverses the `REVIEW_ROUND5.md` exclusion of `Desk` / `Broker` / `Account` shells: a `Dict` field is a compile-time consumer, so the type relations ARE the callers. The name is `Desk`, not `Deck`.

## Files Created
- `.planning/phases/04-domain-cleanup/04-01-PLAN.md` — the executable plan.
- `src/glibe/desk.gleam` — 7 types, 18 annotated functions, `////` + `///` on every item. No existing `src/` file was modified.
- `test/desk_test.gleam` — 10 tests with `assert` / `let assert`, written before any body was filled.
- `.planning/phases/04-domain-cleanup/04-01-SUMMARY.md` — this file.

## RED / GREEN measured (Gleam 1.19.2 / OTP 29)
| stage | result |
|---|---|
| skeleton `gleam build` | exit 0, 0 errors, 49 warnings (18 `Todo found`, 29 `Unused function argument`, 2 `Unused private constructor`) |
| skeleton `--warnings-as-errors` | exit 1 — GREEN gate, not a RED-phase requirement |
| `gleam test` before bodies | exit 1, `26 passed, 10 failures`; each new failure prints `todo src/glibe/desk.gleam:line` + its `info:` |
| after bodies | `--warnings-as-errors` 0 / 0 warnings; `gleam test` `36 passed, no failures`; `gleam format --check` 0 |
| `gleam docs build` | 24 modules, 23 still have empty module docs; `glibe/desk` has 32 module-doc lines, 25 documented items, plan link present |
| `sh scripts/guards.sh --all` | exit 0 |

## Decisions Made
- Name `Desk` (trading desk), not `Deck` (pitch/slide deck). `Desk` is also the exact existing name in `glib/src/glib/desk.gleam` — used as an example-level corroboration, not as authority. One owner quote in `glib/.planning/HANDOFF-2026-11-03.md:111` says `Deck` while the AI prose at `:114` says `Desk`; that is a real spelling drift, recorded in R20 and left untouched rather than rewritten. The dashboard is a VIEW in `webclient/`; this type is the MODEL root.
- One module, not four: the ownership chain is one business domain; fragmenting it would create the import-direction problem glib argues about.
- Two `Dict(Interval, …)` fields on `Instrument`, not one merged record: settings are configuration, timeframes are live state, with different lifetimes.
- No new shell guard; the compiler's own `package-interface.json` is the anti-drift check.

## Issues Encountered
- `timeframe.gleam`'s `Timeframe` still carries its own `symbol` and `interval`, so a key and its value can disagree. Recorded as open, not fixed — making it keyless is an architectural change.
- `api/symbol.gleam:1` says "Symbol = Instrument", which now conflicts with the new `Instrument` value type. Recorded as an owner naming decision; nothing renamed.
- Using the existing fat `Symbol` record as a dict key is a compromise; whether to introduce a dedicated `InstrumentId` is undecided.

## Next Step
`config.gleam` still holds `symbols: List(#(String, Symbol))` and `timeframe_settings: List(#(String, TimeframeSettings))` with `list.find` lookups. Migrating those two tables into the new chain is a separate plan and an owner decision — this phase intentionally stopped before touching it.
