//// The MVU event loop that drives the one `Desk`. Implements
//// `.planning/phases/03-app-view/03-01-PLAN.md`; the trigger ruling (owner
//// 2026-11-20) is carried by that plan and `docs/RULINGS.md`. Read those before
//// changing any signature here.
////
//// MODEL = the ONE `Desk` (R33 / R50). No second copy, no shadow: this module
//// does not hold chart state, broker lists or a bar buffer. The `Chart` an
//// individual (broker, symbol, interval) accumulates is presentation-derived
//// state owned by that widget's state under its stable node ID (06-02 G2); it
//// is never written back into `Desk`.
////
//// THE ONLY PUBLISH POINT = `timeframe.working_databar_archived` (owner
//// 2026-11-20, C1/C2). WHY: the model is the WHOLE chain of types under the one
//// `Desk` and EACH LEVEL'S FIELDS are filled at a different step — bar at
//// `sourcebar_gate`, SMA/band/KDJ at `indicator`, leaf CMAs at `leaves`,
//// branch fields at `branches`, signal at `strategy` (glib SYSTEM_MODEL.md:236-242).
//// While `working_databar` is `Some`, those fields are half-built: THE MODEL IS
//// INCOMPLETE, SO THERE IS NOTHING COMPLETE TO PROJECT INTO A VIEW. Owner's words:
//// "working_databar 如果还在工作，就不能更新 view，因为事情没有做完，model 不完整，
//// 怎么更新 view？" Only `working_databar_archived` finishes every field, moves the
//// bar into `databar_list` head, and clears `working_databar` back to `None`.
//// `None` at chart time IS the guarantee — "nothing is half-built here; everything
//// you are about to draw is finished" (SYSTEM_MODEL.md:487-489). ONLY THEN does
//// update read the just-archived bar from `databar_list` head and hand it to the
//// target chart widget. A bar never travels from a Msg payload straight to a
//// widget. glib authority: SYSTEM_MODEL.md:250-258/487-489/527/1344/1356 —
//// "one writer, one door, no dedup"; "the model changes at working_databar_archived()
//// and the view follows"; bars drawn from `databar_list` (history only).
//// Full field-completion table: 06-05-TRIGGER-RULING.md §C1.
////
//// THIS IS NOT A SCHEDULER (R33). update is a pure Desk-out mechanics driver:
//// it calls the existing level-by-level read / write pairs (R50 — desk →
//// broker → instrument → timeframe, each level calls its OWN pair) and the
//// pure domain functions already in `timeframe`. No actor, clock, poll or
//// timer lives here. The `Command` returned is plushie's effect token
//// (06-02 C1); domain recompute itself is not an effect.
////
//// READS: `Desk` + `Msg` (from `app/message.gleam`). WRITES: a new `Desk`
//// through the level-owned read / write pairs; returns a `Command(Msg)`.
////
//// KNOWN GAP — CARRIER (03-01 Task 1, resolved from plushie 0.6.0 SOURCE, no
//// invention; re-checked 2026-11-23). TWO independent breaks block the
//// `update` body, both measured in the pinned package:
////   1. ENTRY: `Msg`'s `SourceBarArrived` is still a placeholder
////      (`app/message.gleam:67-69`) and carries NO identity keys, so update
////      cannot route a message to a target (BrokerId, Symbol, Interval).
////   2. EXIT: plushie's app `update` is `fn(model, msg) -> #(model,
////      Command(msg))` (`plushie/app.gleam:143-148`); it receives the MODEL,
////      never a widget's state. A chart's accumulated state is held BY THE
////      RUNTIME inside its `WidgetDef`, reachable only through
////      `handle_event: fn(Event, state) -> #(EventAction, state)`
////      (`plushie/widget.gleam:68-89`). The only app→widget command that
////      carries a value is `command.dispatch(Dynamic, mapper)`
////      (`plushie/command.gleam:291`), and it delivers back into the APP's
////      `update`, not into a widget. `command.Renderer` variants carry widget
////      /window ops only — none pushes a bar into chart state.
////   3. `Event` has 12 variants and NO `Custom`
////      (`plushie/event.gleam:33-58`) — pinned 0.6.0 matches the frozen glib
////      ruling 06-02 B3 ("0.6.0 全树无 Custom 变体 … shared-actor 广播若要用
////      Custom，须先核对包版本", archived `06-02-CHALLENGES.md:41-44`). So
////      there is no typed wire from a BEAM-side bar into a widget's
////      `handle_event` either.
//// CONSEQUENCE: the archived bar CAN be read off `databar_list` head in the
//// model, but delivering it to a widget's chart state has NO carrier in
//// plushie 0.6.0's public API. This is an owner-level architecture decision
//// (create-plans deviation rule 4; owner "遇到不能决断的危险事件需要问我"),
//// never something to fabricate an `event.Custom` for. `update` stays `todo`
//// until owner rules on the carrier. This skeleton fixes ONLY the confirmed
//// MVU shape.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/dict
import glibe/app/dashboard
import glibe/app/message.{type Msg}
import glibe/desk.{type Desk, Desk}
import plushie/app.{type App}
import plushie/command.{type Command}

/// Build the app from its four MVU parts. `on_event` is the gate from the OPEN
/// framework Event to our CLOSED Msg (06-02 B1/B2); `from_event` already filled.
pub fn app() -> App(Desk, Msg) {
  app.application(init, update, dashboard.view, message.from_event)
}

/// The empty one Desk — the system's single Value at boot (R33 / R50).
pub fn init() -> #(Desk, Command(Msg)) {
  #(Desk(dict.new()), command.none())
}

/// The presentation event loop. For a data-arrival Msg: locate the target
/// timeframe by its identity keys through the level-owned read pairs; run
/// `sourcebar_gate` -> `databar_processing` -> archive. DO NOT touch the view
/// while `working_databar` is `Some`: fields across the levels are half-built
/// and the model is incomplete (06-05 C1 field table). Only after the archive
/// clears `working_databar` to `None` — the ONE publish point — read the
/// just-archived bar from `databar_list` head and hand it to that timeframe's
/// chart widget. Eye / voice Msgs follow their own boundaries and do NOT push
/// a bar. See 06-05 C1/C2.
pub fn update(desk: Desk, msg: Msg) -> #(Desk, Command(Msg)) {
  todo as "03-01: route by identity keys -> gate -> databar_processing -> archive -> read databar_list head -> push to widget; BLOCKED on owner carrier ruling — Msg has no keys (message.gleam:67-69) and plushie 0.6.0 update cannot reach widget state (app.gleam:143-148, widget.gleam:68-89, event.gleam:33-58 no Custom)"
}
