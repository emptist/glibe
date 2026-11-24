//// RED→GREEN tests for chart interaction (Phase 06-01, audit B1).
////
//// These pin the OBSERVABLE promises that the old suite faked: a pointer/wheel
//// event CHANGES the widget's viewport and mouse state (not "state unchanged"),
//// and a non-None mouse produces a NON-EMPTY crosshair layer on the real node
//// tree. The old `a_pointer_event_moves_only_the_viewport_test` only asserted
//// that no bar was added — it never checked the viewport, so a dead handler
//// passed. These tests do not repeat that mistake.

import bar_stream_chart
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import glibe/app/dashboard
import plushie/event
import plushie/node.{type Node, type PropValue, StringVal}

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

/// A state with 60 real-ish bars so the viewport has room to zoom/pan.
fn a_state_with_bars(n: Int) -> dashboard.ChartWidgetState {
  let empty =
    dashboard.ChartWidgetState(
      spec: bar_stream_chart.empty(
        bar_stream_chart.Geometry(width: 800.0, height: 400.0),
        bar_stream_chart.PriceScaleLinear,
      ),
      candle_pv: [],
      overlay_pv: [],
      volume_pv: [],
      kdj_pv: [],
      viewport: bar_stream_chart.default_viewport(n),
      mouse: None,
      drag: dashboard.DragIdle,
    )
  do_push_bars(empty, 0, n)
}

fn do_push_bars(
  state: dashboard.ChartWidgetState,
  idx: Int,
  count: Int,
) -> dashboard.ChartWidgetState {
  case idx >= count {
    True -> state
    False ->
      do_push_bars(dashboard.push_one(state, a_chart_bar(idx)), idx + 1, count)
  }
}

fn target(id: String) -> event.EventTarget {
  event.EventTarget(window_id: "dashboard", id:, scope: [], full: "")
}

fn scroll_event(delta_y: Float, x: Float) -> event.Event {
  event.Widget(event.Scroll(
    target: target("dashboard#binance\u{001F}BTCUSDT\u{001F}1m"),
    x: x,
    y: 200.0,
    delta_x: 0.0,
    delta_y: delta_y,
    pointer: event.Mouse,
    modifiers: event.modifiers_none(),
    unit: None,
    captured: False,
  ))
}

fn press_event(x: Float) -> event.Event {
  event.Widget(event.Press(
    target: target("dashboard#binance\u{001F}BTCUSDT\u{001F}1m"),
    x: x,
    y: 200.0,
    button: event.LeftButton,
    pointer: event.Mouse,
    finger: None,
    modifiers: event.modifiers_none(),
    captured: False,
  ))
}

fn move_event(x: Float, y: Float) -> event.Event {
  event.Widget(event.Move(
    target: target("dashboard#binance\u{001F}BTCUSDT\u{001F}1m"),
    x: x,
    y: y,
    pointer: event.Mouse,
    finger: None,
    modifiers: event.modifiers_none(),
    captured: False,
  ))
}

fn release_event(x: Float) -> event.Event {
  event.Widget(event.Release(
    target: target("dashboard#binance\u{001F}BTCUSDT\u{001F}1m"),
    x: x,
    y: 200.0,
    button: event.LeftButton,
    pointer: event.Mouse,
    finger: None,
    modifiers: event.modifiers_none(),
    captured: False,
    lost: None,
  ))
}

fn crosshair_shape_count(state: dashboard.ChartWidgetState) -> Int {
  let node =
    dashboard.chart_node(
      "dashboard#binance\u{001F}BTCUSDT\u{001F}1m",
      dashboard.ChartWidgetProps(
        width: 800.0,
        height: 400.0,
        price_scale: bar_stream_chart.PriceScaleLinear,
      ),
      state,
    )
  count_layer(node, "crosshair")
}

fn count_layer(node: Node, name: String) -> Int {
  let here = case dict_get_string(node.props, "name") {
    Ok(n) if n == name -> list.length(node.children)
    _ -> 0
  }
  here + list.fold(node.children, 0, fn(acc, c) { acc + count_layer(c, name) })
}

fn dict_get_string(
  props: dict.Dict(String, PropValue),
  key: String,
) -> Result(String, Nil) {
  case dict.get(props, key) {
    Ok(StringVal(s)) -> Ok(s)
    _ -> Error(Nil)
  }
}

/// Wheel up (delta_y < 0) zooms IN: visible_count shrinks.
pub fn scroll_up_zooms_in_test() {
  let s0 = a_state_with_bars(60)
  let before = s0.viewport.visible_count
  let #(_, s1) = dashboard.widget_handle_event(scroll_event(-1.0, 400.0), s0)
  assert s1.viewport.visible_count < before
}

/// Wheel down (delta_y > 0) zooms OUT: visible_count grows. Zoom in first so
/// there is room to zoom back out (with all bars visible, clamp pins it at 60).
pub fn scroll_down_zooms_out_test() {
  let s0 = a_state_with_bars(60)
  let #(_, z1) = dashboard.widget_handle_event(scroll_event(-1.0, 400.0), s0)
  let before = z1.viewport.visible_count
  let #(_, s1) = dashboard.widget_handle_event(scroll_event(1.0, 400.0), z1)
  assert s1.viewport.visible_count > before
}

/// Press + left-drag pans to OLDER bars. Zoom in first so there is history to
/// reveal (with all 60 visible, first_visible is pinned at 0 by clamp_viewport).
pub fn press_drag_pans_viewport_test() {
  let s0 = a_state_with_bars(60)
  // Zoom in twice to open up pan room: visible_count shrinks, first_visible > 0.
  let #(_, z1) = dashboard.widget_handle_event(scroll_event(-1.0, 400.0), s0)
  let #(_, z2) = dashboard.widget_handle_event(scroll_event(-1.0, 400.0), z1)
  let before = z2.viewport.first_visible
  let #(_, s1) = dashboard.widget_handle_event(press_event(500.0), z2)
  let #(_, s2) = dashboard.widget_handle_event(move_event(300.0, 200.0), s1)
  let _ = dashboard.widget_handle_event(release_event(300.0), s2)
  assert s2.viewport.first_visible > before
}

/// Pointer move stores mouse coordinates — the old handler left it at None.
pub fn pointer_move_stores_mouse_test() {
  let s0 = a_state_with_bars(60)
  let #(_, s1) = dashboard.widget_handle_event(move_event(123.0, 234.0), s0)
  assert s1.mouse == Some(#(123.0, 234.0))
}

/// The real node tree has a NON-EMPTY crosshair after a pointer move.
/// This is the assertion the old suite never made — and the reason the
/// running window had a 0-shape crosshair layer.
pub fn pointer_move_produces_crosshair_shapes_test() {
  let s0 = a_state_with_bars(60)
  assert crosshair_shape_count(s0) == 0
  let #(_, s1) = dashboard.widget_handle_event(move_event(400.0, 200.0), s0)
  assert crosshair_shape_count(s1) > 0
}
