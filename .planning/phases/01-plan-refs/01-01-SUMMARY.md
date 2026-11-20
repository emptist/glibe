# 01-01 — Repoint dangling plan references (SUMMARY)

Date: 2026-11-21. Executed per plan `01-01-PLAN.md`. No bodies, tests, types,
signatures or dependencies changed — verified by `git diff`: every changed line
in `src/` is a `////` comment line.

## Reference count

24 `////` reference lines across 19 active modules, all pointing at paths moved
by the 2026-11-20 archive (`git mv` of 45 files to `.planning-archived-2026-11-20/`).

## Mapping used (constraint → new home)

| Archived target | Count | New target | Why |
|---|---|---|---|
| `05-01-PLAN.md` (doc-tdd mother plan) | 12 | `.planning/BRIEF.md` | completed domain-core modules (id, account, desk, broker, instrument, symbol, interval, api/sourcebar, ib/sourcebar, binance/kline, databar, trading/signal): the doc-tdd process itself is now described in BRIEF, no further phase work |
| `05-01-PLAN.md` | 1 | `02-01-PLAN.md` | `timeframe` — its 4 step `todo`s are plan 02-01's work |
| `05-01-PLAN.md` | 2 | `02-02-PLAN.md` | `leaf`, `branch` — their helper `todo`s are plan 02-02's work |
| `06-07-CONFIG.md` + `06-06-STREAM-INDICATORS.md` | 2 (1 module) | `02-01-PLAN.md` | config parameters and the O(n²) ban are carried by plan 02-01; O(n²) source kept as `glib/docs/DESIGN.md:1427` |
| `06-01-PLAN.md` + `06-02-CHALLENGES.md §B` | 2 (1 module) | `03-01-PLAN.md` | `message`: the open-Event→closed-Msg gate constraint is restated in the plan; §B section number dropped (no such section in new tree) |
| `06-01-PLAN.md` + `06-05-TRIGGER-RULING.md` | 2 (1 module) | `03-01-PLAN.md` | `runtime`: trigger ruling carried by plan 03-01 + `docs/RULINGS.md` |
| `06-01-PLAN.md` + `06-02-CHALLENGES.md §D/§G` + `06-05-TRIGGER-RULING.md` | 3 (1 module) | `03-02-PLAN.md` + `03-01-PLAN.md` | `dashboard`: view-design plan is 03-02; trigger ruling is 03-01. §D/§G numbers dropped (no such sections in new tree); their constraints remain in the module `////` and in the frozen glib sources the plan cites |

## Constraints relocated (not deleted)

- `06-06` O(n²) ban → kept inline as `glib/docs/DESIGN.md:1427` in `config.gleam`'s `////`.
- `06-05` trigger ruling → carried by `03-01-PLAN.md` + `docs/RULINGS.md` (both `dashboard` and `runtime` now say so).
- `06-02 §B` (Event→Msg gate) → restated in `message.gleam` `////` and plan 03-01.
- `06-02 §D/§G` (view = Desk projection, stable-ID widgets, no model-list搬运) → already fully written in `dashboard.gleam` `////` (lines 6-50); section numbers removed because the new tree has no §-numbered challenges doc. No technical content lost.

## Verification (real exit codes)

- `gleam format --check` → 0
- `gleam check` → 0 (warning set unchanged: 19 todo + 40 unused-skeleton baseline, all pre-existing)
- `gleam test` → 0, 64 passed
- `gleam docs build` → 0; `build/dev/docs/glibe/package-interface.json` carries all 5 new-tree paths, zero archived paths
- every cited `.planning/*.md` path exists on disk (5 distinct files, all OK)
- `grep '\.planning-archived' src` → empty

## Plan defect found (recorded, not silently worked around)

Plan `01-01-PLAN.md` Task 2 `<verify>` uses regex `\.planning/phases/0[1-6]-`,
which also matches the new-tree paths `02-…` and `03-…`; run literally it fails
even when all pointers are correct. The correct check is "every cited path
exists on disk + no `.planning-archived` ref", which is what was executed and
passed above. Noted here rather than editing the already-committed plan.
