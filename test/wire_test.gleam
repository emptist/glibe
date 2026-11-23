//// RED tests for the typed wire boundary. Implements
//// `.planning/phases/03-app-view/03-01-PLAN.md` Task 2.
////
//// These pin the OBSERVABLE promises of `app/wire.gleam`:
////   - a `SourceBarArrived` round-trips through its `CustomWidget` event with
////     every field equal (the `Dynamic` boundary is BEAM-native identity — no
////     hand-written codec, no string parsing; R58);
////   - a `ChartPushRequest` round-trips through its event, and the event's
////     target names the chart's stable widget ID;
////   - a CustomWidget of ANOTHER kind is not decoded as ours (it falls through
////     to `MsgEye` in `message.from_event`);
////   - two different identity triples give two different stable IDs, and one
////     gives the same ID twice (the ID is a function of the identity).
////
//// The rules are ported from frozen glib's wire discipline (R47: one module
//// writes and reads the same kind) and from `plushie/event.gleam:230`, where
//// `WidgetEvent.CustomWidget(kind, target, value, data)` really exists.

import gleam/dynamic
import gleam/option.{None, Some}
import gleam/time/timestamp
import glibe/api/interval.{IntervalOneMinute}
import glibe/api/sourcebar.{type SourceBar, SourceBarOneMinute}
import glibe/api/symbol
import glibe/app/wire
import glibe/databar.{type DataBar, DataBar}
import glibe/id
import glibe/trading/signal
import plushie/event

/// A source bar with distinctive values, so an assertion can tell the round
/// trip apart from a default-constructed value.
fn a_sourcebar() -> SourceBar {
  SourceBarOneMinute(
    timestamp: timestamp.from_unix_seconds(1_499_040_000),
    open: 1.0,
    high: 2.0,
    low: 0.5,
    close: 1.5,
    volume: 10,
  )
}

/// A data bar with one distinctive value per field.
fn a_data_bar(idx: Int) -> DataBar {
  DataBar(
    idx: idx,
    timestamp: timestamp.from_unix_seconds(1_499_040_000),
    open: 1.0,
    high: 2.0,
    low: 0.5,
    close: 1.5,
    volume: 10,
    signal: signal.SignalNoSignal,
    sma_tiny: 1.1,
    sma_small: 1.2,
    sma_medium: 1.3,
    sma_large: 1.4,
    sma_huge: 1.5,
    bb_m: 1.3,
    bb_u3: 1.8,
    bb_l3: 0.9,
    bb_u2: 1.7,
    bb_u1: 1.6,
    bb_l1: 1.0,
    bb_l2: 1.1,
    sigma_n: 0,
    sigma_mean: 0.0,
    sigma_m2: 0.0,
    k: 50.0,
    d: 50.0,
    j: 50.0,
    m: 50.0,
    kdj_h: 2.0,
    kdj_l: 0.5,
    kdj_h_idx: 0,
    kdj_l_idx: 0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
  )
}

/// A payload with a distinctive value in every field.
fn an_arrival() -> wire.SourceBarArrived {
  wire.SourceBarArrived(
    broker_id: id.string_to_broker_id("broker-1"),
    symbol: symbol.string_to_symbol("BTCUSD"),
    interval: IntervalOneMinute,
    sourcebar: a_sourcebar(),
  )
}

/// A chart identity for one (broker, symbol, interval).
fn an_identity() -> wire.ChartIdentity {
  wire.ChartIdentity(
    broker_id: id.string_to_broker_id("broker-1"),
    symbol: symbol.string_to_symbol("BTCUSD"),
    interval: IntervalOneMinute,
  )
}

/// The inbound payload survives the CustomWidget event with every field equal:
/// identity AND the bar itself. This is the whole point of the typed boundary —
/// a caller that decodes it gets the value, not a spelling to re-parse.
pub fn sourcebar_event_round_trip_test() {
  let arrived = an_arrival()
  let event = wire.sourcebar_event(arrived)
  let assert Some(back) = wire.sourcebar_from_event(event)
  assert id.broker_id_to_string(back.broker_id) == "broker-1"
  assert symbol.to_string(back.symbol) == "BTCUSD"
  assert back.interval == IntervalOneMinute
  assert back.sourcebar == a_sourcebar()
  Nil
}

/// The two kinds are different kinds: a chart push is NOT decoded as a source
/// bar. This is the closed set doing its job (R13).
pub fn the_two_kinds_do_not_cross_test() {
  let request =
    wire.ChartPushRequest(identity: an_identity(), bar: a_data_bar(7))
  let event = wire.chart_push_event(request)
  assert wire.sourcebar_from_event(event) == None
  Nil
}

/// The chart push survives its event, and the event's target names the chart's
/// stable widget ID — so the runtime routes it to exactly one widget.
pub fn chart_push_event_round_trip_test() {
  let request =
    wire.ChartPushRequest(identity: an_identity(), bar: a_data_bar(7))
  let event = wire.chart_push_event(request)
  let assert Some(#(stable_id, bar)) = wire.chart_push_from_event(event)
  assert stable_id == wire.chart_widget_id(request.identity)
  assert bar.idx == 7
  assert bar.close == 1.5
  Nil
}

/// The stable ID is a FUNCTION of the identity: the same triple gives the same
/// ID every time (the runtime keys the widget registry by it), and two
/// different triples give two different IDs (two widgets, not one).
pub fn stable_id_is_a_function_of_the_identity_test() {
  let other_symbol =
    wire.ChartIdentity(
      broker_id: id.string_to_broker_id("broker-1"),
      symbol: symbol.string_to_symbol("ETHUSD"),
      interval: IntervalOneMinute,
    )
  let other_broker =
    wire.ChartIdentity(
      broker_id: id.string_to_broker_id("broker-2"),
      symbol: symbol.string_to_symbol("BTCUSD"),
      interval: IntervalOneMinute,
    )
  assert wire.chart_widget_id(an_identity())
    == wire.chart_widget_id(an_identity())
  assert wire.chart_widget_id(an_identity())
    != wire.chart_widget_id(other_symbol)
  assert wire.chart_widget_id(an_identity())
    != wire.chart_widget_id(other_broker)
  Nil
}

/// The two wire kinds have two different kind strings, and neither is empty —
/// the kind is what tells the two apart on the wire.
pub fn the_two_kinds_have_two_different_strings_test() {
  assert wire.kind_string(wire.WireSourceBarArrived)
    != wire.kind_string(wire.WireChartPush)
  assert wire.kind_string(wire.WireSourceBarArrived) != ""
  assert wire.kind_string(wire.WireChartPush) != ""
  Nil
}

/// A CustomWidget of a kind that is NOT ours is not decoded as ours. This is
/// the closed-set decoder `message.from_event`: an unknown kind stays an eye
/// event, and no input is dropped.
pub fn an_unknown_kind_is_not_decoded_as_ours_test() {
  let event =
    event.Widget(event.CustomWidget(
      kind: "some_other_library_kind",
      target: event.EventTarget(
        window_id: "dashboard",
        id: "",
        scope: [],
        full: "",
      ),
      value: dynamic.nil(),
      data: dynamic.nil(),
    ))
  assert wire.sourcebar_from_event(event) == None
  assert wire.chart_push_from_event(event) == None
  Nil
}
