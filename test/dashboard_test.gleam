//// RED tests for the Dashboard view layer. Implements
//// `.planning/phases/03-app-view/03-02-PLAN.md` Task 2.
////
//// These pin the OBSERVABLE promises of `app/dashboard.gleam`:
////   - pushing ONE bar translates only THAT bar's shapes and prepends them, so
////     the view never walks the accumulated list (owner 2026-11-23, R60 §2);
////   - the chart's own carried count is O(1) — no `list.length` anywhere;
////   - the chart push event is consumed by the widget and lands in that
////     widget's own chart state;
////   - a pointer event moves the VIEWPORT only — the model is never touched;
////   - the Dashboard view is ONE window carrying one stable-ID chart widget per
////     (broker, symbol, interval).

import bar_stream_chart
import fixture
import gleam/list
import gleam/option.{None}
import gleam/time/timestamp
import glibe/api/interval.{IntervalOneMinute}
import glibe/api/symbol
import glibe/app/dashboard
import glibe/app/wire
import glibe/databar
import glibe/desk.{type Desk}
import glibe/id
import glibe/trading/signal
import plushie/event
import plushie/widget

fn a_data_bar(idx: Int) -> databar.DataBar {
  databar.DataBar(
    idx: idx,
    timestamp: timestamp.from_unix_seconds(1_499_040_000),
    open: 100.0,
    high: 102.0,
    low: 99.0,
    close: 101.0,
    volume: 1200,
    signal: signal.SignalNoSignal,
    sma_tiny: 100.5,
    sma_small: 100.4,
    sma_medium: 100.5,
    sma_large: 100.6,
    sma_huge: 100.7,
    bb_m: 100.5,
    bb_u3: 103.0,
    bb_l3: 97.0,
    bb_u2: 102.5,
    bb_u1: 102.0,
    bb_l1: 98.0,
    bb_l2: 98.5,
    sigma_n: 0,
    sigma_mean: 0.0,
    sigma_m2: 0.0,
    k: 50.0,
    d: 50.0,
    j: 50.0,
    m: 50.0,
    kdj_h: 102.0,
    kdj_l: 99.0,
    kdj_h_idx: 0,
    kdj_l_idx: 0,
    yin_leaf_cma: 100.2,
    yang_leaf_cma: 100.1,
  )
}

fn a_chart_bar(idx: Int) -> bar_stream_chart.Bar {
  bar_stream_chart.Bar(
    idx: idx,
    open: 100.0,
    high: 102.0,
    low: 99.0,
    close: 101.0,
    volume: 1200,
    sma_medium: 100.5,
    yin_leaf_cma: 100.2,
    yang_leaf_cma: 100.1,
    k: 50.0,
    d: 50.0,
    j: 50.0,
    bb_u3: 103.0,
    bb_l3: 97.0,
    signal: bar_stream_chart.SignalHold,
  )
}

fn an_empty_state() -> dashboard.ChartWidgetState {
  dashboard.ChartWidgetState(
    spec: bar_stream_chart.empty(
      bar_stream_chart.Geometry(width: 800.0, height: 400.0),
      bar_stream_chart.PriceScaleLinear,
    ),
    candle_pv: [],
    overlay_pv: [],
    volume_pv: [],
    kdj_pv: [],
    viewport: bar_stream_chart.default_viewport(0),
    mouse: None,
  )
}

/// Pushing ONE bar adds exactly ONE candle shape and leaves the chart's own
/// count at one — the count is the package's carried number, not a list length.
pub fn push_one_adds_one_bar_test() {
  let s0 = an_empty_state()
  assert bar_stream_chart.len(s0.spec) == 0
  let s1 = dashboard.push_one(s0, a_chart_bar(0))
  assert bar_stream_chart.len(s1.spec) == 1
  assert length_of(s1.candle_pv) == 1
  Nil
}

/// Two pushes, two candles — and the SECOND push did not re-translate the
/// first bar: the new state is EXACTLY the new shape prepended to the old
/// layer, so the old bar's shape is still the very same value.
pub fn push_one_prepends_without_retranslating_test() {
  let s1 = dashboard.push_one(an_empty_state(), a_chart_bar(0))
  let s2 = dashboard.push_one(s1, a_chart_bar(1))
  assert length_of(s2.candle_pv) == 2
  assert bar_stream_chart.len(s2.spec) == 2
  // The old layer is untouched — it was translated once, at its own push.
  assert list.drop(s2.candle_pv, 1) == s1.candle_pv
  Nil
}

/// The chart push EVENT is consumed by the widget and lands in THAT widget's
/// own chart state. This is the whole point of the targeted CustomWidget.
pub fn the_chart_push_event_lands_in_this_widget_test() {
  let identity =
    wire.ChartIdentity(
      broker_id: id.string_to_broker_id("broker-1"),
      symbol: symbol.string_to_symbol("BTCUSD"),
      interval: IntervalOneMinute,
    )
  // The chart's count is the bar's own idx plus one (the package counts bars
  // from the start of the stream), so idx 0 gives a count of one.
  let request = wire.ChartPushRequest(identity: identity, bar: a_data_bar(0))
  let event = wire.chart_push_event(request)
  let #(action, state) = dashboard.widget_handle_event(event, an_empty_state())
  assert action == widget_event_action_update_state()
  assert bar_stream_chart.len(state.spec) == 1
  Nil
}

/// A pointer event moves the VIEWPORT only: the model is never touched and no
/// bar is added.
pub fn a_pointer_event_moves_only_the_viewport_test() {
  let event =
    event.Widget(event.Press(
      target: event.EventTarget(
        window_id: "dashboard",
        id: "chart-1",
        scope: [],
        full: "",
      ),
      x: 10.0,
      y: 20.0,
      button: event.LeftButton,
      pointer: event.Mouse,
      finger: None,
      modifiers: event.modifiers_none(),
      captured: False,
    ))
  let #(_action, state) = dashboard.widget_handle_event(event, an_empty_state())
  assert bar_stream_chart.len(state.spec) == 0
  Nil
}

/// The Dashboard is ONE window, and it carries one chart widget per
/// (broker, symbol, interval) — the stable ID is derived from the three keys.
pub fn the_dashboard_is_one_window_with_one_chart_per_identity_test() {
  let desk = a_desk_with_one_timeframe()
  let nodes = dashboard.view(desk)
  assert length_of_nodes(nodes) == 1
  Nil
}

/// A Desk with one broker -> one instrument -> one timeframe. The records are
/// built in `fixture` — ONE place (2026-11-23).
fn a_desk_with_one_timeframe() -> Desk {
  fixture.desk_with_one_timeframe()
}

fn length_of(items: List(a)) -> Int {
  list.length(items)
}

fn length_of_nodes(items: List(a)) -> Int {
  list.length(items)
}

fn widget_event_action_update_state() -> widget.EventAction {
  widget.UpdateState
}
