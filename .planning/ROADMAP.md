# Roadmap: glibe

## Overview

Re-baselined 2026-11-20. The old roadmap (`.planning-archived-2026-11-20/ROADMAP.md`) tracked the abandoned Elixir/Finch + JS-web design. This roadmap tracks only the pure-BEAM design in `BRIEF.md`. Phases restart at 01 because this is a new planning tree after archive; ordering follows the existing code's dependency chain, not a guess.

## Milestones

- 🚧 **v1.0 BEAM core** — Phases 01–03 (in progress). Domain core + app MVU + view publish path.

## Phases

- [ ] **Phase 01: Plan-reference integrity** — repoint every active module's `////` plan reference from the archived tree to a plan in this tree.
- [ ] **Phase 02: Domain stream completion** — fill `timeframe`'s four steps (`indicator`/`leaves`/`branches`/`strategy`) and the `leaf`/`branch` todos with O(1) stream bodies.
- [x] **Phase 03: App view publish path** — DONE 2026-11-23: the typed wire boundary, the publisher, `runtime.update`/`publish_request` (publishing only when the gate accepted, i.e. only after `working_databar_archived`), the Dashboard widget/view bodies (shapes translated at PUSH time; the view is O(1) assembly), and the composition root `src/glibe.gleam` (one `plushie.start`, one named channel, one publisher process). Gates: WAE 0 (0 Todo, 0 unused), 126 tests passed.
- [x] **Phase 04: Full gate green** — DONE 2026-11-23 as part of Phase 03: `gleam build --warnings-as-errors` exits **0** (0 Todo + 0 unused, from 21 + 57), `gleam test` 126 passed / 0 failures, docs and export verified.

## Phase Details

### Phase 01: Plan-reference integrity
**Goal**: after archiving 45 old plan files, no active `src/` module names a plan path that no longer exists — R19's `//// → plan` contract holds.
**Depends on**: nothing (first phase, corrective).
**Plans**: 1 plan.

Plans:
- [ ] 01-01: audit all `////`/`///` plan references in `src/**/*.gleam`; repoint each to a new-tree plan; verify no path names `.planning-archived-*` or a missing file.

### Phase 02: Domain stream completion
**Goal**: the working databar finishes all its fields through the one `Desk → Desk` pipe; indicators use O(1) stream recurrence, never O(n²) batch recompute.
**Depends on**: Phase 01 (plan refs), `config.gleam` (already landed).
**Plans**: 2 plans.

Plans:
- [ ] 02-01 (indicator step done 2026-11-23; `leaves`/`branches`/`strategy` remain R.5 open): fill the four `timeframe` step bodies (`indicator` → `leaves` → `branches` → `strategy`), each `fn(Timeframe) -> Timeframe`, consuming `IntervalSettings` as a parameter.
- [ ] 02-02 (4 of 8 helpers filled 2026-11-23; 3 registered R.5): fill the `leaf` (3) and `branch` (5) remaining todos against real consumers, with the stream algorithms sourced from frozen glib implementation.

### Phase 03: App view publish path
**Goal**: `runtime.update` drives the domain pipe and publishes exactly once at `working_databar_archived`, reading the just-archived bar from `databar_list` head; no second model, no shadow, no bar-list搬运.
**Depends on**: Phase 02 (fields must be complete to project).
**Plans**: 2 plans.

Plans:
- [ ] 03-01 (owner corrected 2026-11-23: the "carrier gap / owner decision" was my invention — RETRACTED, decision queue back to 0): fill `runtime.update` with the identity-key route → gate → `databar_processing` → archive → head-bar → push into the target chart held in the app model (MVU per try_plushie; not runtime-held widget state). This is ordinary in-plan work, not blocked.
- [ ] 03-02 (owner corrected 2026-11-23: "view blocked on widget-set" was based on the same retracted invented design — RETRACTED): fill `dashboard` widget/view bodies (`WidgetDef`, `SpecShape → Node` translation, per-(broker,symbol,interval) stable-ID composition) so `view(Desk) -> List(Node)` renders the Dashboard window. Design already recorded in 06-02 §G + `dashboard.gleam ////`.

### Phase 04: Full gate green
**Goal**: no skeleton warnings remain; docs and package interface match code.
**Depends on**: Phases 01–03.
**Plans**: 1 plan.

Plans:
- [ ] 04-01: run all five gates; confirm `--warnings-as-errors` 0 warnings; verify `package-interface.json` links each module to its plan; no dangling design concepts in prose docs.

## Progress

| Phase | Plans Complete | Status | Completed |
|---|---|---|---|
| 1. Plan-reference integrity | 1/1 | Done | 01-01 done 2026-11-21 (24 plan refs repointed, archived paths zero, full gate green) |
| 2. Domain stream completion | 1/2 | In progress | 02-02 done 2026-11-23 (4 helpers filled, 3 registered R.5); 02-01 indicator done, 3 steps still R.5 open |
| 3. App view publish path | 0/2 | Not started | - |
| 4. Full gate green | 0/1 | Not started | - |
