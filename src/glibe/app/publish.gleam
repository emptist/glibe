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
//// Subject; `serve` reads it and hands it to main's dispatch closure; main
//// writes the resulting CustomWidget event.
////
//// THE SUBJECT MUST BE **NAMED** (measured): a `process.new_subject()` is
//// owned by the process that created it, and `process.receive` PANICS on a
//// non-named subject owned by another process
//// (`gleam_erlang/process.gleam:226-238`). The publisher runs in its OWN
//// process, so the channel between it and `update` is a named subject
//// (`process.named_subject`) — anybody may send to it and the owner may
//// receive from it.
////
//// The tag is derived from the chart ID + bar index so two archived bars for
//// the same chart cannot cancel each other (plushie cancels same-tag tasks).

import gleam/dynamic
import gleam/erlang/process.{type Subject}
import gleam/int
import plushie/command.{type Command}

import glibe/app/wire

/// Turn one archived-bar request into a background command. The command's work
/// is only a typed message send; decoding and event construction stay in main.
pub fn request(
  publisher: Subject(wire.ChartPushRequest),
  request: wire.ChartPushRequest,
) -> Command(msg) {
  // The command's work is ONLY a typed message send; decoding and event
  // construction stay in main. The tag is unique per archived bar, because
  // plushie CANCELS a running task that reuses a tag — consecutive bars of
  // one chart would otherwise drop each other.
  command.task(
    fn() {
      process.send(publisher, request)
      nil_value()
    },
    task_tag(request),
  )
}

/// Receive requests until the app exits. `dispatch` is supplied by main and is
/// the ONLY closure that holds the Instance. No timer, no poll, no state copy.
pub fn serve(
  publisher: Subject(wire.ChartPushRequest),
  dispatch: fn(wire.ChartPushRequest) -> Nil,
) -> Nil {
  // Receive forever: there is no "no more bars" state to stop on — the app
  // stops, and this process goes with it. No timer, no poll, no state copy.
  let request = process.receive_forever(publisher)
  dispatch(request)
  serve(publisher, dispatch)
}

// The tag must be unique per archived bar: plushie cancels a running task that
// uses the same tag, which would silently drop consecutive bars of one chart.
fn task_tag(request: wire.ChartPushRequest) -> String {
  // The stable chart id plus the archived bar's index: two bars of one chart
  // never share a tag, so plushie's same-tag cancellation can never drop a bar.
  wire.chart_widget_id(request.identity)
  <> ":"
  <> int.to_string(request.bar.idx)
}

// Keep the Dynamic boundary in one place: the command's work must return Dynamic.
fn nil_value() -> dynamic.Dynamic {
  dynamic.nil()
}
