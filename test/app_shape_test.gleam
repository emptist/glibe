//// Shape tests for the app layer. Implements
//// `.planning/phases/06-app-architecture/06-01-PLAN.md`; design rationale in
//// `.planning/phases/06-app-architecture/06-02-CHALLENGES.md` §B/§D/§G.
////
//// These bind each app contract to an explicit type: a drift in the view/model
//// boundary fails to COMPILE here. In particular `push_one_shape_test` pins
//// "one bar in, never a list" (06-02 G3) — there is no signature taking a
//// List(Bar), so carrying the model's bar list into the view is not
//// representable. Real assertions arrive with the bodies (R19).

import bar_stream_chart.{type Bar}
import glibe/app/dashboard
import glibe/app/message.{MsgEye, MsgSourceBarArrived, MsgVoice}
import glibe/desk.{type Desk}
import plushie/event.{type Event, Timer, TimerEvent}
import plushie/node.{type Node}
import plushie/widget.{type WidgetDef}

/// 06-02 B1/B2: the gate maps the OPEN framework Event into OUR closed Msg.
/// on_event is total `Event -> Msg`; Msg is exhaustive (no catch-all).
pub fn on_event_shape_test() {
  let _gate: fn(Event) -> message.Msg = message.from_event
  Nil
}

/// First real assertion of the app layer (R19 step 5→6): the gate maps an
/// Event to `MsgEye` carrying that SAME event. No Eq on Event/Msg, so pattern
/// match the payload. Against the `todo` body this panics = RED; filling the
/// one-line body makes it GREEN. One representative Event is enough: the body
/// is total over all twelve constructors (documented B1/B2), not a per-arm map.
pub fn from_event_wraps_event_test() {
  let wire = Timer(TimerEvent("tick", 42))
  case message.from_event(wire) {
    MsgEye(Timer(TimerEvent(tag, timestamp))) -> {
      assert tag == "tick" as "tag preserved through the gate"
      assert timestamp == 42 as "timestamp preserved through the gate"
    }
    MsgEye(_) -> panic as "the same Event variant must be carried"
    MsgVoice(_) -> panic as "renderer wire events never produce MsgVoice"
    MsgSourceBarArrived(_) ->
      panic as "renderer wire events never produce MsgSourceBarArrived"
  }
}

/// 06-02 G2/G3: the chart accepts ONE bar, never a list. This annotation is the
/// compiler-enforced proof that "move model lists into view" has no entry point.
pub fn push_one_shape_test() {
  let _push: fn(dashboard.ChartWidgetState, Bar) -> dashboard.ChartWidgetState =
    dashboard.push_one
  Nil
}

/// 06-02 G2: each timeframe is a widget with opaque state + small props (no bar
/// list in props). The runtime threads the state across renders.
pub fn chart_widget_def_shape_test() {
  // Bind the CONSTRUCTOR, do not call it (calling would run the todo body).
  let _def: fn() ->
    WidgetDef(dashboard.ChartWidgetState, dashboard.ChartWidgetProps) =
    dashboard.chart_widget_def
  Nil
}

/// R20 / 06-02 D1: the view layer is the Dashboard, a projection of the one
/// Desk. Signature pinned as `Desk -> List(Node)` (plushie view shape).
pub fn dashboard_view_shape_test() {
  let _view: fn(Desk) -> List(Node) = dashboard.view
  Nil
}
