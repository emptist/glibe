//// The one effect carrier between `runtime.update` and the plushie runtime.
//// Implements `.planning/phases/03-app-view/03-01-PLAN.md`.
////
//// WHY THIS MODULE EXISTS: `update` is pinned to
//// `fn(Desk, Msg) -> #(Desk, Command(Msg))` and must stay pure; plushie
//// commands cannot reach widget state (`Command.Done`/`SendAfter` only re-enter
//// `update`, `Renderer` goes to the native wire). The ONLY legal path to a
//// chart widget is a `CustomWidget` event injected with
//// `plushie.dispatch_event`, which needs the `Instance`. Main owns that
//// Instance; this module owns the typed `Subject` hop to it.
////
//// READS: `ChartPushRequest` from `app/wire.gleam`. WRITES: a `Command(Msg)`
//// that sends that value to main's publisher, and a receive loop that calls a
//// `dispatch` closure supplied by main. This module never sees an `Instance`,
//// a `Chart`, or a `Desk`, and holds no second copy of model state (R50).
////
//// R47 (who writes / who reads): `runtime.update` writes a request to the
//// Subject inside `MsgSourceBarArrived`; `serve` reads it and hands it to
//// main's dispatch closure; main writes the resulting CustomWidget event.
//// The tag is derived from the chart ID + bar index so two archived bars for
//// the same chart cannot cancel each other (plushie cancels same-tag tasks).

import gleam/dynamic
import gleam/erlang/process.{type Subject}
import plushie/command.{type Command}

import glibe/app/wire.{type ChartPushRequest}

/// Turn one archived-bar request into a background command. The command's work
/// is only a typed message send; decoding and event construction stay in main.
pub fn request(
  publisher: Subject(ChartPushRequest),
  request: ChartPushRequest,
) -> Command(msg) {
  todo as "03-01: command.task sending request on a per-(chart,bar idx) tag"
}

/// Receive requests until the app exits. `dispatch` is supplied by main and is
/// the ONLY closure that holds the Instance. No timer, no poll, no state copy.
pub fn serve(
  publisher: Subject(ChartPushRequest),
  dispatch: fn(ChartPushRequest) -> Nil,
) -> Nil {
  todo as "03-01: receive_forever, dispatch, recurse"
}

// The tag must be unique per archived bar: plushie cancels a running task that
// uses the same tag, which would silently drop consecutive bars of one chart.
fn task_tag(request: ChartPushRequest) -> String {
  todo as "03-01: stable wire chart id + ':' + bar.idx"
}

// Keep the Dynamic boundary in one place: the command's work must return Dynamic.
fn nil_value() -> dynamic.Dynamic {
  dynamic.nil()
}
