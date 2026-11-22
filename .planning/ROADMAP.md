# Roadmap: glibe

## Overview

Re-baselined 2026-11-20. The old roadmap (`.planning-archived-2026-11-20/ROADMAP.md`) tracked the abandoned Elixir/Finch + JS-web design. This roadmap tracks only the pure-BEAM design in `BRIEF.md`. Phases restart at 01 because this is a new planning tree after archive; ordering follows the existing code's dependency chain, not a guess.

## Milestones

- 🚧 **v1.0 BEAM core** — Phases 01–03 (in progress). Domain core + app MVU + view publish path.

## Phases

- [ ] **Phase 01: Plan-reference integrity** — repoint every active module's `////` plan reference from the archived tree to a plan in this tree.
- [ ] **Phase 02: Domain stream completion** — fill `timeframe`'s four steps (`indicator`/`leaves`/`branches`/`strategy`) and the `leaf`/`branch` todos with O(1) stream bodies.
- [ ] **Phase 03: App view publish path** — fill `runtime.update` and the `dashboard` widget/view bodies so a view update happens only on `working_databar_archived`.
- [ ] **Phase 04: Full gate green** — bring `--warnings-as-errors` to 0 warnings with every skeleton body filled; docs/export verified.

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
- [ ] 03-01: fill `runtime.update` with the identity-key route → gate → `databar_processing` → archive → head-bar → stable-ID chart push sequence; resolve the carrier question from actual plushie 0.6.0 capability, not invention.
- [ ] 03-02: fill `dashboard` widget/view bodies (`WidgetDef`, `SpecShape → Node` translation, per-(broker,symbol,interval) stable-ID composition) so `view(Desk) -> List(Node)` renders the Dashboard window.

### Phase 04: Full gate green
**Goal**: no skeleton warnings remain; docs and package interface match code.
**Depends on**: Phases 01–03.
**Plans**: 1 plan.

Plans:
- [ ] 04-01: run all five gates; confirm `--warnings-as-errors` 0 warnings; verify `package-interface.json` links each module to its plan; no dangling design concepts in prose docs.

## Progress

| Phase | Plans Complete | Status | Completed |
|---|---|---|---|
| 1. Plan-reference integrity | 0/1 | Not started | - |
| 2. Domain stream completion | 1/2 | In progress | 02-02 done 2026-11-23 (4 helpers filled, 3 registered R.5); 02-01 indicator done, 3 steps still R.5 open |
| 3. App view publish path | 0/2 | Not started | - |
| 4. Full gate green | 0/1 | Not started | - |
