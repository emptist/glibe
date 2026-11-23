# Roadmap: glibe

## Overview

Re-baselined 2026-11-20. The old roadmap (`.planning-archived-2026-11-20/ROADMAP.md`) tracked the abandoned Elixir/Finch + JS-web design. This roadmap tracks only the pure-BEAM design in `BRIEF.md`. Phases restart at 01 because this is a new planning tree after archive; ordering follows the existing code's dependency chain, not a guess.

## Milestones

- ✅ **v1.0 BEAM core** — Phases 01–04 (complete 2026-11-24). Domain core + app MVU + view publish path + full gate green.

## Phases

- [x] **Phase 01: Plan-reference integrity** — DONE 2026-11-21: all active `////` plan references repointed into this tree (24 refs), zero archived paths.
- [x] **Phase 02: Domain stream completion** — DONE 2026-11-23: `timeframe`'s four steps and the `leaf`/`branch` helpers filled with O(1) stream bodies; deferred refinements recorded as R.5 history, not open gates.
- [x] **Phase 03: App view publish path** — DONE 2026-11-23: the typed wire boundary, the publisher, `runtime.update`/`publish_request` (publishing only when the gate accepted, i.e. only after `working_databar_archived`), the Dashboard widget/view bodies (shapes translated at PUSH time; the view is O(1) assembly), and the composition root `src/glibe.gleam` (one `plushie.start`, one named channel, one publisher process). Gates: WAE 0 (0 Todo, 0 unused), 126 tests passed.
- [x] **Phase 04: Full gate green** — DONE 2026-11-24 (04-01-SUMMARY): six gates re-measured at real exit 0 after a clean rebuild — `format --check` 0 · `check` 0 · `test` **132 passed** · `docs build` 0 · `export package-interface` 0 · `build --warnings-as-errors` 0 (0 Todo + 0 unused). All 7 `////` plan paths in source and generated interface resolve to this tree; zero archived paths.

## Phase Details

### Phase 01: Plan-reference integrity
**Goal**: after archiving 45 old plan files, no active `src/` module names a plan path that no longer exists — R19's `//// → plan` contract holds.
**Depends on**: nothing (first phase, corrective).
**Plans**: 1 plan.

Plans:
- [x] 01-01: audit all `////`/`///` plan references in `src/**/*.gleam`; repoint each to a new-tree plan; verify no path names `.planning-archived-*` or a missing file. DONE 2026-11-21 (01-01-SUMMARY).

### Phase 02: Domain stream completion
**Goal**: the working databar finishes all its fields through the one `Desk → Desk` pipe; indicators use O(1) stream recurrence, never O(n²) batch recompute.
**Depends on**: Phase 01 (plan refs), `config.gleam` (already landed).
**Plans**: 2 plans.

Plans:
- [x] 02-01 (DONE 2026-11-23, 02-01-SUMMARY): the four `timeframe` step bodies (`indicator` → `leaves` → `branches` → `strategy`), each `fn(Timeframe) -> Timeframe`, consuming `IntervalSettings`; later refinements (carried indicator fields, settings pipe arg, 4 leaf lists) landed and are recorded in `docs/STATE.md` / RULINGS.
- [x] 02-02 (DONE 2026-11-23, 02-02-SUMMARY): the `leaf` and `branch` helpers filled against real consumers with O(1) stream algorithms from frozen glib; naming fixes (`start_end_move`, `enter_exit_move`, R51) landed.

### Phase 03: App view publish path
**Goal**: `runtime.update` drives the domain pipe and publishes exactly once at `working_databar_archived`, reading the just-archived bar from `databar_list` head; no second model, no shadow, no bar-list搬运.
**Depends on**: Phase 02 (fields must be complete to project).
**Plans**: 3 plans.

Plans:
- [x] 03-01 (DONE 2026-11-23, 03-01-SUMMARY): `runtime.update` with the identity-key route → gate → `databar_processing` → archive → head-bar → publish request. Post-Phase-03, R74 added birth-on-first-bar at the three owning levels so an empty Desk can process a bar.
- [x] 03-02 (DONE 2026-11-23, 03-02-SUMMARY): `dashboard` widget/view bodies (`WidgetDef`, `SpecShape → Node` translation, per-(broker,symbol,interval) stable-ID composition); `view(Desk) -> List(Node)` is O(1) assembly, shapes translated at PUSH time.
- [x] 03-03 (DONE 2026-11-23, 03-03-SUMMARY): the composition root `src/glibe.gleam` — one `plushie.start`, one named publish channel, one publisher process (the App holds no second model).

### Phase 04: Full gate green
**Goal**: no skeleton warnings remain; docs and package interface match code.
**Depends on**: Phases 01–03.
**Plans**: 1 plan.

Plans:
- [x] 04-01 (DONE 2026-11-24, 04-01-SUMMARY): run all five gates; confirm `--warnings-as-errors` 0 warnings; verify `package-interface.json` links each module to its plan; no dangling design concepts in prose docs.

## Progress

| Phase | Plans Complete | Status | Completed |
|---|---|---|---|
| 1. Plan-reference integrity | 1/1 | Done | 01-01 done 2026-11-21 (24 plan refs repointed, archived paths zero, full gate green) |
| 2. Domain stream completion | 2/2 | Done | 02-01 + 02-02 done 2026-11-23; four timeframe steps + leaf/branch helpers filled with O(1) stream bodies |
| 3. App view publish path | 3/3 | Done | 03-01 + 03-02 + 03-03 done 2026-11-23 (wire/publisher/runtime view bodies + composition root) |
| 4. Full gate green | 1/1 | Done | 04-01 done 2026-11-24: six gates exit 0 (132 tests, WAE 0), all plan links resolve |

All four phases complete (7/7 plans have a SUMMARY). Later post-roadmap work — R74 three-level birth, R75 threading comparison, R76 no-repeat-analysis rule — is recorded in `docs/RULINGS.md` / `docs/STATE.md`, not as new phases.
