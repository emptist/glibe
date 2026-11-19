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
import gleam/dict
import gleam/option
import gleam/time/timestamp
import glibe/app/dashboard
import glibe/app/message.{MsgEye, MsgSourceBarArrived, MsgVoice}
import glibe/app/runtime
import glibe/databar as glibe_databar
import glibe/desk.{type Desk, Desk}
import glibe/trading/signal
import plushie/app.{type App}
import plushie/command.{type Command}
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

/// 06-05 C1/C2: the MVU loop holds exactly ONE Desk (no shadow chart/bar state)
/// and its trigger is the archive step, not a Msg payload carrying a bar. The
/// signatures are pinned so a drift (e.g. Model = #(Desk, Charts)) fails here.
pub fn runtime_mvu_shape_test() {
  let _app: fn() -> App(Desk, message.Msg) = runtime.app
  let _init: fn() -> #(Desk, Command(message.Msg)) = runtime.init
  let _update: fn(Desk, message.Msg) -> #(Desk, Command(message.Msg)) =
    runtime.update
  Nil
}

/// The empty Desk at boot holds no brokers — the one Value, built with no
/// shadow and no constructor taking an invented parameter (R42 / R49 / R50).
pub fn runtime_init_is_empty_desk_test() {
  let #(desk, _) = runtime.init()
  assert desk == Desk(dict.new())
  Nil
}

fn chart_bar(idx: Int) -> Bar {
  bar_stream_chart.Bar(
    idx: idx,
    open: 100.0,
    high: 102.0,
    low: 99.0,
    close: 101.0,
    volume: 1200,
    sma_medium: 100.5,
    yin_leaf_cma: 100.2,
    yang_leaf_cma: 101.1,
    k: 50.0,
    d: 50.0,
    j: 50.0,
    bb_u3: 103.0,
    bb_l3: 97.0,
    signal: bar_stream_chart.SignalHold,
  )
}

fn empty_chart_state() -> dashboard.ChartWidgetState {
  dashboard.ChartWidgetState(
    chart: bar_stream_chart.empty(
      bar_stream_chart.Geometry(width: 800.0, height: 600.0),
      bar_stream_chart.PriceScaleLinear,
    ),
    viewport: bar_stream_chart.default_viewport(0),
    mouse: option.None,
  )
}

/// 06-05 "single bar update": push_one pushes exactly ONE bar into the widget's
/// own incremental chart. Against the todo body this panics = RED. Two pushes
/// advance the carried count by one each; the state's chart is the only thing
/// changed — no bar list is stored in the model (06-02 G3).
pub fn push_one_increments_chart_test() {
  let s0 = empty_chart_state()
  assert bar_stream_chart.len(s0.chart) == 0
  let s1 = dashboard.push_one(s0, chart_bar(0))
  assert bar_stream_chart.len(s1.chart) == 1
  let s2 = dashboard.push_one(s1, chart_bar(1))
  assert bar_stream_chart.len(s2.chart) == 2
  Nil
}

/// 06-06: the DataBar -> chart.Bar boundary copies all eight measurement
/// fields one-for-one and maps the 3-value Signal to the chart's 6-value shape
/// (NoSignal -> Hold). Against the todo body this panics = RED.
pub fn data_bar_to_chart_bar_maps_fields_test() {
  let db =
    glibe_databar.DataBar(
      idx: 3,
      timestamp: timestamp.from_unix_seconds(1_499_040_000),
      open: 100.0,
      high: 105.0,
      low: 98.0,
      close: 103.0,
      volume: 500,
      signal: signal.SignalBuy,
      sma_tiny: 99.0,
      sma_medium: 101.5,
      yin_leaf_cma: 100.2,
      yang_leaf_cma: 102.3,
      k: 70.0,
      d: 60.0,
      j: 80.0,
      bb_u3: 104.0,
      bb_l3: 96.0,
    )
  let b = dashboard.data_bar_to_chart_bar(db)
  assert b.idx == 3
  assert b.open == 100.0
  assert b.high == 105.0
  assert b.low == 98.0
  assert b.close == 103.0
  assert b.volume == 500
  assert b.sma_medium == 101.5
  assert b.yin_leaf_cma == 100.2
  assert b.yang_leaf_cma == 102.3
  assert b.k == 70.0
  assert b.d == 60.0
  assert b.j == 80.0
  assert b.bb_u3 == 104.0
  assert b.bb_l3 == 96.0
  assert b.signal == bar_stream_chart.SignalBuy
  Nil
}

/// NoSignal maps to the chart's no-marker Hold value (glib SignalType shape).
pub fn data_bar_to_chart_bar_no_signal_is_hold_test() {
  let db =
    glibe_databar.DataBar(
      idx: 0,
      timestamp: timestamp.from_unix_seconds(1_499_040_000),
      open: 0.0,
      high: 0.0,
      low: 0.0,
      close: 0.0,
      volume: 0,
      signal: signal.SignalNoSignal,
      sma_tiny: 0.0,
      sma_medium: 0.0,
      yin_leaf_cma: 0.0,
      yang_leaf_cma: 0.0,
      k: 0.0,
      d: 0.0,
      j: 0.0,
      bb_u3: 0.0,
      bb_l3: 0.0,
    )
  assert dashboard.data_bar_to_chart_bar(db).signal
    == bar_stream_chart.SignalHold
  Nil
}
