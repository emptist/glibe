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
//// R47 (readers/writers): `step` reads the inbound payload, runs the chain,
//// writes a new `Desk` and one `ChartPushRequest`; `publish.request` writes that
//// request to the publisher's Subject; the publisher reads it and hands it to
//// main's dispatch closure.
////
//// WHERE THE PUBLISH CHANNEL COMES FROM (R58): the `Subject` is created ONCE
//// in main and **captured by this module's update closure** — it is NOT carried
//// inside `SourceBarArrived`. The reason is measured, not preferred:
//// `plushie.start(app, opts)` creates the `Instance` AFTER the App is built
//// (`plushie/plushie.gleam:191-279`), so the `Instance` cannot be captured at
//// wiring time; a `Subject` created before the App CAN. So the Subject is the
//// late-binding cell, and the `Instance` stays in the publisher process. This is
//// the same shape as frozen glib's `ingest.feed(timeframe, bar, publish)`
//// (`glib/src/glib/trading/ingest.gleam:57-71`), where the owner bakes the
//// publish closure at the composition root instead of threading it per bar.
////
//// R19 status (2026-11-23): bodies filled — `app` captures the publisher,
//// `step` routes Desk -> Broker -> Instrument -> Timeframe and returns the one
//// publish request, `publish_request` exposes that point, `update` turns the
//// request into the publish command. RED -> GREEN via `test/publish_test.gleam`
//// and `test/runtime_publish_test.gleam`.

import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import glibe/app/dashboard
import glibe/app/message.{type Msg, MsgSourceBarArrived}
import glibe/app/publish
import glibe/app/wire
import glibe/broker
import glibe/config
import glibe/desk
import glibe/instrument
import glibe/timeframe
import plushie/app.{type App}
import plushie/command.{type Command}

/// Build the app from its four MVU parts, with the publish channel captured at
/// WIRING time. `on_event` is the closed-set decoder from the OPEN framework Event to our
/// CLOSED Msg (06-02 B1/B2); `message.from_event` is that decoder. One App only —
/// never one App per chart (03-00 FINDINGS G).
///
/// The publisher is a **parameter**, not a field of the inbound payload (R58):
/// `plushie.start` creates the `Instance` after this App is built, so the
/// Instance cannot be captured here — but a `Subject` created before this call
/// can, and that is what carries the effect out to the process that holds the
/// Instance.
pub fn app(publisher: Subject(wire.ChartPushRequest)) -> App(desk.Desk, Msg) {
  app.application(
    init,
    fn(desk_value: desk.Desk, msg: Msg) { update(desk_value, msg, publisher) },
    dashboard.view,
    message.from_event,
  )
}

/// The empty one Desk — the system's single Value at boot (R33 / R50).
pub fn init() -> #(desk.Desk, Command(Msg)) {
  #(desk.Desk(dict.new()), command.none())
}

/// Pure projection of one Msg to the publish it would cause. No effect, no
/// widget knowledge. Exposed so the publish point can be asserted directly.
///
/// **This is the trigger point** (owner 2026-11-23: *"view的update 跟且仅跟
/// `working_databar_archived()` 有关"*): a request exists exactly when the
/// pipeline ran to the archive. A bar the sourcebar_gate REJECTS never archives, so it
/// never publishes — no head comparison, no dedup (SYSTEM_MODEL.md:1364).
pub fn publish_request(
  desk_value: desk.Desk,
  msg: Msg,
) -> Option(wire.ChartPushRequest) {
  step(desk_value, msg).1
}

/// The pure core: locate by identity keys, run sourcebar_gate → processing → archive,
/// write the new Desk back through each owner's own pair, and return the one
/// archived bar from `databar_list` head. No effect, no chart state.
///
/// Each level calls ITS OWN read/write pair (R50), and each pair replaces only
/// its own key — so the levels "update to their own paces" (owner 2026-11-23):
/// one arriving bar replaces the Timeframe it belongs to, the Instrument that
/// holds it, the Broker that holds that, and the Desk that holds that — and
/// nothing else moves.
fn step(
  desk_value: desk.Desk,
  msg: Msg,
) -> #(desk.Desk, Option(wire.ChartPushRequest)) {
  case msg {
    MsgSourceBarArrived(payload) ->
      case route(desk_value, payload) {
        Ok(#(new_desk, request)) -> #(new_desk, Some(request))
        Error(_) -> #(desk_value, None)
      }
    _ -> #(desk_value, None)
  }
}

/// Read down to the Timeframe this bar belongs to, run the pipeline, and write
/// back up. Each level's `_at` reader births the empty record on a miss (R64),
/// so an identity's FIRST bar creates its whole chain; only a bar the
/// sourcebar_gate refuses is `Error(Nil)` — no panic, no invented error noun.
fn route(
  desk_value: desk.Desk,
  payload: wire.SourceBarArrived,
) -> Result(#(desk.Desk, wire.ChartPushRequest), Nil) {
  // The three birth points (R65 §3 / R69 §3): read the value under the inbound
  // key, or write that level's constructor directly at the point of need
  // (R64). The `put_*` chain at the end of this function is what persists them
  // (R50). An empty Desk therefore grows from its first bar.
  let broker = desk.broker_at(desk_value, payload.broker_id)
  let instrument = broker.instrument_at(broker, payload.symbol)
  let timeframe = instrument.timeframe_at(instrument, payload.interval)
  use settings <- result.try(
    result.map_error(config.for_interval_default(payload.interval), fn(_) {
      Nil
    }),
  )
  // The sourcebar_gate is where "this bar is not ours" is decided. A rejected bar never
  // becomes a working databar, so it never archives — and so it never
  // publishes.
  use sourcebar_gated <- result.try(
    result.map_error(
      timeframe.sourcebar_gate(timeframe, payload.sourcebar),
      fn(_) { Nil },
    ),
  )
  let processed = timeframe.databar_processing(sourcebar_gated, settings)
  case list.first(processed.databar_list) {
    // The archive is the LAST step of the pipeline, so the head IS the bar that
    // was just archived (C2: read the history head after the archive).
    Error(_) -> Error(Nil)
    Ok(bar) -> {
      let new_instrument =
        instrument.put_timeframe(instrument, payload.interval, processed)
      let new_broker =
        broker.put_instrument(broker, payload.symbol, new_instrument)
      let new_desk = desk.put_broker(desk_value, payload.broker_id, new_broker)
      let request =
        wire.ChartPushRequest(
          identity: wire.ChartIdentity(
            broker_id: payload.broker_id,
            symbol: payload.symbol,
            interval: payload.interval,
          ),
          bar: bar,
        )
      Ok(#(new_desk, request))
    }
  }
}

/// The presentation event loop. For a data-arrival Msg: call `step`; if it
/// published, return the typed request command. Eye / voice Msgs follow their
/// own boundaries and do NOT push a bar. The returned Desk and the request come
/// from the SAME `step`.
///
/// The publisher arrives as this function's PARAMETER, not inside the inbound
/// payload (R58): the channel is an app-level capability captured at wiring
/// time, exactly like `settings` is a pipe-call argument (R40-A).
pub fn update(
  desk_value: desk.Desk,
  msg: Msg,
  publisher: Subject(wire.ChartPushRequest),
) -> #(desk.Desk, Command(Msg)) {
  let #(new_desk, published) = step(desk_value, msg)
  case published {
    Some(request) -> #(new_desk, publish.request(publisher, request))
    None -> #(new_desk, command.none())
  }
}
