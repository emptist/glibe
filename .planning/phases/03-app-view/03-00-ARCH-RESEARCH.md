---
phase: 03-app-view
type: research
topic: Desk-only model 下把归档单 DataBar 送进 View 层 chart widget 的 plushie 0.6.0 机制
---

<session_initialization>
Before beginning research, verify today's date with `date +%Y-%m-%d`.
Use that date for "current/latest" judgements. This research pins the LOCAL
installed SDK, not the newest published docs: `build/packages/plushie_gleam/`
must report `version = "0.6.0"` before any API claim is made.
</session_initialization>

<research_objective>
Research how Phase 03 must be architected BEFORE touching any `.gleam` file.
Purpose: resolve the one remaining design gap — with `Desk` as the ONLY model
and `chart` strictly a View concern, what is the exact plushie 0.6.0 mechanism
that carries the single archived `DataBar` from `working_databar_archived`
into the correct stable-ID chart widget state — then rewrite 03-01/03-02
against that finding.
Scope: authoritative-owner rulings + frozen glib design records + installed
plushie 0.6.0 source + try_plushie as counterexample + bar_stream_chart API.
Output: `03-00-ARCH-FINDINGS.md` with a recommendation, a rejected-options
table, exact `file:line` evidence, and an explicit confidence level.
</research_objective>

<research_scope>
<include>
- **Owner authority (highest)**: `docs/RULINGS.md` 2026-11-20 trigger ruling
  (C1 only publish point / C2 history head / C3 no second set / C4 structure
  not drawn), 2026-11-19 08:35 (Dashboard naming, widget-state design, no
  model list into view), R33/R50 (one top-level `Desk`), the 2026-11-23
  correction that `chart` is View and MUST NOT become a `Desk`/`Timeframe`
  field. Cite literal words; never turn a contextual sentence into a global
  rule (cross-project MEMORY.md correction 2026-11-21).
- **Frozen glib design (read-only)**: `../glib/docs/SYSTEM_MODEL.md:236-258`,
  `:330-355`, `:487-489`, `:527`, `:617-639`, `:770`, `:1238-1364`;
  `.planning-archived-2026-11-20/phases/06-app-architecture/06-02-CHALLENGES.md`
  §G1–G4; `06-05-TRIGGER-RULING.md` C1–C4. These are the owner-recorded
  design, not proposals. glib code is read-only and is not authority for
  view plumbing (different library).
- **Installed plushie 0.6.0 API (interface contract)**: every claim must cite
  `build/packages/plushie_gleam/src/...:line`. Specifically:
  1. `widget.gleam` `WidgetDef` + `RegistryEntry` + `make_entry` +
     `render_placeholder` + `derive_registry` — where widget state lives and
     which operations can write it.
  2. `widget.gleam` `dispatch_through_widgets` / `build_handler_chain` /
     `walk_chain` / `handle_widget_timer` — how an event reaches the exact
     widget, what `Ignored|Consumed|Emit|UpdateState` do, and how the runtime
     re-renders after a state change.
  3. `event.gleam` `Event` (12 variants), `WidgetEvent.CustomWidget`
     (`:230`), `EventTarget` (`:553`), `make_target` (`:580`).
  4. `plushie.gleam` `Instance` opaque (`:146`), `dispatch_event` (`:376`),
     `start` (`:194`); `runtime.gleam` `InternalEvent` (`:72`, `:774`) and
     `handle_event` (`:2085`).
  5. `command.gleam` `Command` constructors (`None`, `Done`, `Async`,
     `Stream`, `SendAfter`, `Renderer`), `app.gleam` `application` (`:143`).
  6. `plushie/testing/widget_harness.gleam` / `testing/backend/mock.gleam` —
     whether widget state changes can be tested WITHOUT launching a renderer.
- **Enumerate and evaluate ALL candidate mechanisms** for the archived-bar →
  widget-state step, each with a source line proving acceptance or rejection:
  - `CustomWidget` event + `plushie.dispatch_event(instance, event)` routed by
    stable `EventTarget` → `widget.handle_event` → `UpdateState`.
  - `command.Done` / `command.SendAfter` mapping back into `update` (check:
    does this reach widget state at all, or only `update`?).
  - `view(desk)` passing the bar via widget `props` only (check: can `view`
    write widget state? can a pure view accumulate shapes?).
  - `command.Renderer(NativeCommand(...))` (check: native renderer widgets vs
    custom Gleam widget registry — different namespaces?).
  - widget `subscriptions` timer (check: poll is forbidden by R33/trigger).
  - moving `Chart` into the app model or a second View-side model (check:
    owner 2026-11-23 + R33/R50 + `test/app_shape_test.gleam` pin).
  - an external process/ETS map of charts (check: second copy / R50).
  - calling `widget.Registry` APIs directly from app code (check: exported?
    who owns the registry? does the runtime overwrite it each cycle?).
- **Instance availability**: determine how the publisher obtains the
  `Instance` without putting it in the `Desk` model — inspect try_plushie
  `window_switch.gleam:151-184` (named process holds Instance,
  `dispatch_event` from outside) and check whether glibe's `main`/wiring
  module exists yet; if it does not, record that the publisher is wiring
  work, NOT a new architecture decision.
- **Typed bar payload**: `CustomWidget.data: Dynamic` is unavoidable if that
  route is chosen. Evaluate `gleam/dynamic.from` + a single typed decoder at
  the widget boundary against Gleam core §0 "never use Dynamic" and §11
  "no Dynamic at FFI boundary"; decide whether the payload should be the
  chart `Bar`, the domain `DataBar`, or only an identity signal.
- **Stable ID correctness**: derive from R23/R37 identity keys; verify how
  `WidgetDef` node IDs become registry keys (`widget_key(window_id,
  scoped_id)`) and what `EventTarget` fields must be set so
  `build_handler_chain` finds exactly that widget. A wrong ID is a silent
  no-op — prove the match with source lines.
- **try_plushie audit**: `src/try_plushie.gleam:773-794` (three
  `plushie.start`), `ChartModel` holding chart, `ingest_bar`, and
  gl-center `references/beam-plushie-concurrency-measured.md` §3.3/§4.1/§5.6.
  Record what is reusable (event injection, IR adapter) and what is NOT
  (one App per chart; per-chart model).
- **bar_stream_chart boundary**: `push`/`push_generating`/`shapes` are the
  only inputs; no batch/replay/load-list; Chart opaque. Confirm the local
  path dependency and version 1.2.1 in `gleam.toml`/`../bar_stream_chart`.

<exclude>
- Editing ANY `.gleam` file, including `////` / `///` comments. No code-file
  documentation until a rewritten PLAN.md explicitly instructs it.
- Adding/retracting owner rulings, filing new items in
  `docs/PENDING_DECISIONS.md`, or asking the owner to choose an architecture
  that the recorded design already settles.
- Implementing `runtime.update` / `dashboard` bodies or RED tests — those
  belong to the rewritten 03-01/03-02 execution plans.
- Using 「叶子」 for anything other than `YinLeaf`/`YangLeaf` (R33), using
  `Qn` without `2` for O(n²), inventing new nouns, or copying Python/pandas
  structure (R34).
- JS target, webclient, hand-written `.erl`/`.mjs`, N App layouts.
</exclude>

<sources>
Primary, in authority order:
- Owner literal words in `docs/RULINGS.md` (full paths + dated sections)
- Frozen read-only `../glib/docs/SYSTEM_MODEL.md`, `DESIGN.md`,
  `../glib/.planning/**` (design records only, never glib code as view spec)
- glibe archived design `.planning-archived-2026-11-20/phases/06-app-architecture/`
- Installed SDK source `build/packages/plushie_gleam/src/plushie/**`
- Reference评述 `~/.workbuddy/skills/gl-center/references/beam-plushie-concurrency-measured.md`
- Counterexample `../try_plushie/src/**`
- Own library `../bar_stream_chart/src/bar_stream_chart.gleam`
No web search needed for API facts: the pinned 0.6.0 source is authoritative
for this project. If a claim cannot be shown with a local `file:line`, mark it
as inference and do not use it as a plan assumption.
</sources>
</research_scope>

<verification_checklist>
□ Enumerate EVERY candidate mechanism listed above; none silently dropped.
□ Every "cannot / only / must" claim carries an exact `file:line` or owner
  quote. Absence claims ("no Custom at top level", "no batch API") carry the
  grep that returned empty plus the positive variant that does exist.
□ Verify precedence: owner > frozen design record > official SDK source >
  try_plushie > my inference. Contradictions are recorded, not smoothed over.
□ Confirm the installed SDK version is 0.6.0 before quoting any line number.
□ Re-read `docs/RULINGS.md` 2026-11-19 08:35 item 3: try_plushie = proof the
  library works, NOT a design to copy. Do not repeat the "carrier gap" error
  in either direction (do not invent a decision; do not force chart into
  model).
□ Check the negative claim "chart is View" against the owner's 2026-11-23
  correction and 06-02 §G2; both must be represented.
</verification_checklist>

<research_quality_assurance>
- completeness: all authority layers read; all candidates evaluated.
- blind spots: ask "did I check whether `update` can reach widget state at
  all?"; "did I check whether a pure `view` can accumulate?"; "did I check
  how the registry survives re-render?"; "did I check who holds Instance?".
- critical claims: "the only way" needs a source line AND a rejected-alternatives
  table; otherwise downgrade to inference.
</research_quality_assurance>

<incremental_output>
Create `03-00-ARCH-FINDINGS.md` with the template skeleton first, then append
each finding as it is verified. Finalize Summary / Recommendation / Metadata
last. Do not write one giant final draft.
</incremental_output>

<output>
Create `.planning/phases/03-app-view/03-00-ARCH-FINDINGS.md` with:
1. Summary — the single mechanism recommended, in 2-3 paragraphs.
2. Recommendations — primary + rejected alternatives (each with `file:line`).
3. Key Findings — authority layers; installed SDK facts; candidate matrix;
   stable-ID contract; typed payload; testing without renderer; try_plushie
   audit; bar_stream_chart boundary.
4. Code Examples — only snippets copied from verified source, each with its
   `file:line`; no invented Gleam.
5. Metadata — confidence level, dependencies, open questions, assumptions,
   quality report separating verified from inferred claims.
FINDINGS.md is not a decision queue. If something truly needs the owner,
state exactly what was checked and why it is unresolved — do not file a
choice card.
</output>

<success_criteria>
- Every scope question answered with an evidence line or marked inference.
- Every candidate mechanism has an accept/reject verdict with source line.
- A single recommended path is stated precisely enough to rewrite 03-01 and
  03-02 without further architecture questions.
- No `.gleam` file was modified while producing this research.
</success_criteria>
