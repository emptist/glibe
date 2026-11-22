//// The MVU event loop that drives the one `Desk`. Implements
//// `.planning/phases/03-app-view/03-01-PLAN.md`; the trigger ruling (owner
//// 2026-11-20) is carried by `docs/RULINGS.md` and that plan. Read those before
//// changing any signature here.
////
//// MODEL = the ONE `Desk` (R33 / R50). No second copy, no shadow: this module
//// does not hold chart state, broker lists or a bar buffer. The `Chart` an
//// individual (broker, symbol, interval) accumulates is presentation-derived
//// state owned by that widget's state under its stable node ID (06-02 G2); it
//// is never written back into `Desk`. Owner 2026-11-23, verbatim: *"chart 作为
//// View 你要把它变成 Desk model 的一部分？？？？你的编程是体育老师教的吗"*.
//// The earlier "app model holds the charts" text in this file was RETRACTED and
//// removed by 03-01; do not restore it.
////
//// THE ONLY PUBLISH POINT = `timeframe.working_databar_archived` (owner
//// 2026-11-20, C1/C2). WHY: the model is the WHOLE chain of types under the one
//// `Desk` and EACH LEVEL'S FIELDS are filled at a different step — bar at
//// `sourcebar_gate`, SMA/band/KDJ at `indicator`, leaf CMAs at `leaves`,
//// branch fields at `branches`, signal at `strategy` (glib SYSTEM_MODEL.md:236-242).
//// While `working_databar` is `Some`, those fields are half-built: THE MODEL IS
//// INCOMPLETE, SO THERE IS NOTHING COMPLETE TO PROJECT INTO A VIEW. Only
//// `working_databar_archived` finishes every field, moves the bar into
//// `databar_list` head, and clears `working_databar` back to `None`. ONLY THEN
//// does this module read the just-archived bar from `databar_list` head and
//// hand it to `app/wire.ChartPushRequest`. A bar never travels from a Msg
//// payload straight to a widget.
////
//// THIS IS NOT A SCHEDULER (R33). `step` is a pure `Desk -> Desk` mechanics
//// driver: it calls the existing level-by-level read / write pairs (R50 —
//// desk → broker → instrument → timeframe, each level calls its OWN pair) and
//// the pure domain functions already in `timeframe`. No actor, clock, poll or
//// timer lives here. The returned `Command` is only a typed message send to
//// main's publisher (03-01); domain recompute itself is not an effect.
////
//// R47 (readers/writers): main writes `SourceBarArrived.publisher`; `step`
//// reads it, runs the chain, writes a new `Desk` and one `ChartPushRequest`;
//// `publish.request` writes that request to main's publisher process.
////
//// R19 status (2026-11-23): 03-01 skeleton. `app` and `init` keep their
//// already-green bodies; `publish_request`, `step` and `update` are `todo`
//// until their RED tests are written and filled, in that order.

import gleam/dict
import gleam/list
import gleam/option.{type Option, None}
import gleam/result
import glibe/api/sourcebar
import glibe/app/dashboard
import glibe/app/message.{type Msg, MsgEye, MsgSourceBarArrived, MsgVoice}
import glibe/app/publish
import glibe/app/wire.{type ChartPushRequest, ChartIdentity}
import glibe/broker.{type Broker, get_instrument, put_instrument}
import glibe/config
import glibe/desk.{type Desk, Desk, get_broker, put_broker}
import glibe/instrument.{type Instrument, get_timeframe, put_timeframe}
import glibe/timeframe
import plushie/app.{type App}
import plushie/command.{type Command}

/// Build the app from its four MVU parts. `on_event` is the gate from the OPEN
/// framework Event to our CLOSED Msg (06-02 B1/B2); `message.from_event` is that
/// gate. One App only — never one App per chart (03-00 FINDINGS G).
pub fn app() -> App(Desk, Msg) {
  app.application(init, update, dashboard.view, message.from_event)
}

/// The empty one Desk — the system's single Value at boot (R33 / R50).
pub fn init() -> #(Desk, Command(Msg)) {
  #(Desk(dict.new()), command.none())
}

/// Pure projection of one Msg to the publish it would cause. No effect, no
/// widget knowledge. Exposed so the publish point can be asserted directly.
pub fn publish_request(desk_value: Desk, msg: Msg) -> Option(ChartPushRequest) {
  todo as "03-01: step(desk_value, msg).1"
}

/// The pure core: locate by identity keys, run gate → processing → archive,
/// write the new Desk back through each owner's own pair, and return the one
/// archived bar from `databar_list` head. No effect, no chart state.
fn step(desk_value: Desk, msg: Msg) -> #(Desk, Option(ChartPushRequest)) {
  todo as "03-01: route Desk -> Broker -> Instrument -> Timeframe; archive; head"
}

/// The presentation event loop. For a data-arrival Msg: call `step`; if it
/// published, return the typed request command using the Subject carried in
/// the inbound payload. Eye / voice Msgs follow their own boundaries and do
/// NOT push a bar. The returned Desk and the request come from the SAME `step`.
pub fn update(desk_value: Desk, msg: Msg) -> #(Desk, Command(Msg)) {
  todo as "03-01: let #(new_desk, published) = step(..); publish.request or none"
}
