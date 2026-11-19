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
import glibe/app/message
import glibe/desk.{type Desk}
import plushie/event.{type Event}
import plushie/node.{type Node}
import plushie/widget.{type WidgetDef}

/// 06-02 B1/B2: the gate maps the OPEN framework Event into OUR closed Msg.
/// on_event is total `Event -> Msg`; Msg is exhaustive (no catch-all).
pub fn on_event_shape_test() {
  let _gate: fn(Event) -> message.Msg = message.from_event
  Nil
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
