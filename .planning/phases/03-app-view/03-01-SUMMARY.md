# 03-01 — runtime.update publish path (SUMMARY — PARTIAL: Task 1 done, Task 2/3 BLOCKED)

Date: 2026-11-23. Executed per plan `03-01-PLAN.md`. No signature or body changed;
only `src/glibe/app/runtime.gleam`'s `////` and the `update` todo text were updated
to carry the source-measured carrier finding. Gate still green (86 passed).

## Task 1 (DONE): the carrier question, answered from plushie 0.6.0 SOURCE

Plan Task 1 asked: "Determine the real carrier from plushie 0.6.0, not invention;
if plushie genuinely lacks the carrier, say so with the file:line that proves it."
The pinned package is `plushie_gleam` 0.6.0 (`manifest.toml`); source read from
`build/packages/plushie_gleam/`. Finding: **there is no carrier, at TWO ends.**

- **Entry — the Msg carries no routing keys.** `src/glibe/app/message.gleam:67-69`
  defines `SourceBarArrived` with the single placeholder constructor
  `SourceBarArrivedPlaceholder`; there is no `BrokerId` / `Symbol` / `Interval`
  on it. `update` therefore cannot even select a target `Timeframe`. `MsgVoice`
  is likewise a placeholder (`:60-62`). These were left as placeholders by the
  earlier doc-first stage precisely because the carrier was unresolved.
- **Exit — app `update` cannot reach widget state.** plushie's
  `app.application` signature is
  `update: fn(model, msg) -> #(model, Command(msg))`
  (`build/packages/plushie_gleam/src/plushie/app.gleam:143-148`): it receives the
  MODEL only, never a widget's state. A chart's accumulated state lives inside
  its `WidgetDef`, mutable only through
  `handle_event: fn(Event, state) -> #(EventAction, state)`
  (`plushie/widget.gleam:68-89`, field docs :71-77).
- **No command pushes a bar into a widget.** `Command(msg)` variants
  (`plushie/command.gleam:20-51`): `None / Batch / Done(value, mapper) /
  Async / Stream / Cancel / SendAfter / Exit / Renderer`. `Done` and
  `command.dispatch(Dynamic, mapper)` (`:291`) deliver the value back into the
  APP's `update` via the mapper — NOT into a widget. The `RendererCommand`
  variants are widget/window/system ops; none carries a `DataBar` into a chart.
- **No typed wire into `handle_event` either.** `Event` has exactly 12 variants
  (`plushie/event.gleam:33-58`: Widget/Key/Window/Timer/Async/Stream/Effect/
  System/Ime/ModifiersChanged/Error/Session) and **no `Custom`**. This matches
  the frozen owner ruling 06-02 B3 (archived
  `.planning-archived-2026-11-20/phases/06-app-architecture/06-02-CHALLENGES.md:41-44`):
  *"本地 0.6.0 包全树无 Custom 变体 … shared-actor 广播若要用 Custom，须先核对包版本"*.

**Answer recorded in the module:** `runtime.gleam`'s `////` KNOWN GAP section now
carries all four file:line facts above; the `update` todo text names the block.
No `event.Custom` or any carrier was invented — exactly as Task 1 requires.

## Task 2 / Task 3 (BLOCKED — owner-level architecture decision)

The publish-point invariant that Tasks 2–3 would pin ("no publish before archive,
exactly one after, bar from `databar_list` head") cannot be implemented or tested
through `runtime.update` while both carrier ends are absent:
- without keys on `SourceBarArrived`, there is no target to route to;
- without a widget carrier, the archived bar read from `databar_list` head has
  nowhere to go (app `update` cannot touch widget state; Event has no Custom).

This is NOT an implementation detail I may fill by inference. It is the exact
question owner left open (06-02 B3) and the KNOWN GAP the skeleton declared.
Per create-plans deviation rule 4 ("major structural changes → stop and ask")
and owner's own instruction (*"遇到不能决断的危险事件，需要问我"*), `update` and
the runtime update test stay as todo. **Owner ruling needed** on how identity keys
and the archived bar reach the widget under pinned plushie 0.6.0. Options are for
owner to decide; none is assumed here.

## What is DONE and committed in Phase 03 so far
- Task 1 carrier finding, source-measured, written into `runtime.gleam` `////`.
- (Phase 02, prior commits) `dashboard.push_one` + `data_bar_to_chart_bar`
  already filled and tested — the widget-side receive half exists; only the
  app→widget delivery carrier is missing.

## Gate (real exit codes, after the doc change)
- `gleam format --check` → 0; `gleam check` → 0; `gleam test` → 0, **86 passed**.

## Open
- `docs/PENDING_DECISIONS.md`: register the carrier as an owner decision item
  (first real decision-queue entry), with the file:line evidence above.
- 03-02 (`dashboard` widget/view bodies) does NOT depend on the carrier: `view`
  projects `Desk`, `push_one` is already filled. It can proceed independently —
  proposed as the next executable work.
