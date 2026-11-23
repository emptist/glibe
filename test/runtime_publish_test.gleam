//// RED tests for the publish point. Implements
//// `.planning/phases/03-app-view/03-01-PLAN.md` Task 2.
////
//// These pin the OBSERVABLE promises of `app/runtime.gleam`:
////   - a bar the gate REJECTS produces NO publish request — the view's update
////     relates to AND ONLY to `working_databar_archived()` (owner 2026-11-23);
////   - a bar that is archived produces EXACTLY ONE request, whose bar is the
////     archived head of `databar_list` and whose identity is the inbound keys;
////   - an eye or voice Msg produces NO request;
////   - a missing key produces NO request — no panic, no invented error noun;
////   - `update` returns the new Desk AND the publish command from the SAME step.

import gleam/dict
import gleam/erlang/process
import gleam/list
import gleam/option.{None, Some}
import gleam/time/timestamp
import glibe/api/interval.{IntervalOneMinute}
import glibe/api/sourcebar.{type SourceBar, SourceBarOneMinute}
import glibe/api/symbol
import glibe/app/message.{type Msg, MsgEye, MsgVoice}
import glibe/app/runtime
import glibe/app/wire
import glibe/broker
import glibe/config
import glibe/desk.{type Desk, Desk}
import glibe/id
import glibe/instrument
import glibe/timeframe
import plushie/event

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

fn an_arrival() -> wire.SourceBarArrived {
  wire.SourceBarArrived(
    broker_id: id.string_to_broker_id("broker-1"),
    symbol: symbol.string_to_symbol("BTCUSD"),
    interval: IntervalOneMinute,
    sourcebar: a_sourcebar(),
  )
}

fn an_eye_msg() -> Msg {
  MsgEye(event.Timer(event.TimerEvent("tick", 42)))
}

/// A Desk holding one broker -> one instrument -> one timeframe, so a bar for
/// that identity has somewhere to land.
fn a_desk_with_one_timeframe() -> Desk {
  let tf =
    timeframe.Timeframe(
      growing_target_sourcebar: None,
      working_databar: None,
      databar_list: [],
      growing_yin_leaf: None,
      growing_yang_leaf: None,
      growing_yin_branch: None,
      growing_yang_branch: None,
      yin_branch_list: [],
      yang_branch_list: [],
      yin_leaf_settled: None,
      yang_leaf_settled: None,
    )
  let inst = instrument.Instrument(dict.from_list([#(IntervalOneMinute, tf)]))
  let br =
    broker.Broker(
      instruments: dict.from_list([#(symbol.string_to_symbol("BTCUSD"), inst)]),
      accounts: dict.new(),
    )
  Desk(dict.from_list([#(id.string_to_broker_id("broker-1"), br)]))
}

/// An eye Msg never publishes a bar.
pub fn an_eye_msg_publishes_nothing_test() {
  assert runtime.publish_request(a_desk_with_one_timeframe(), an_eye_msg())
    == None
  Nil
}

/// A voice Msg never publishes a bar.
pub fn a_voice_msg_publishes_nothing_test() {
  assert runtime.publish_request(
      a_desk_with_one_timeframe(),
      MsgVoice(message.VoiceEventPlaceholder),
    )
    == None
  Nil
}

/// A bar for an identity that is NOT in the Desk publishes nothing — no
/// panic, no invented error noun.
pub fn a_missing_key_publishes_nothing_test() {
  let unknown =
    wire.SourceBarArrived(
      broker_id: id.string_to_broker_id("broker-nobody"),
      symbol: symbol.string_to_symbol("BTCUSD"),
      interval: IntervalOneMinute,
      sourcebar: a_sourcebar(),
    )
  assert runtime.publish_request(
      a_desk_with_one_timeframe(),
      message.MsgSourceBarArrived(unknown),
    )
    == None
  Nil
}

/// A bar the GATE REFUSES publishes nothing: it never becomes a working
/// databar, so it never archives, so the view must not move. This is the
/// owner's trigger ruling — *"view的update 跟且仅跟 working_databar_archived()
/// 有关"* — enforced by construction rather than by a later comparison.
///
/// The refusal is the price checker (`api/sourcebar.gleam:225-247`: reject,
/// never repair) — a bar whose high is below its low is not a bar.
pub fn a_rejected_bar_publishes_nothing_test() {
  let unqualified =
    wire.SourceBarArrived(
      broker_id: id.string_to_broker_id("broker-1"),
      symbol: symbol.string_to_symbol("BTCUSD"),
      interval: IntervalOneMinute,
      sourcebar: SourceBarOneMinute(
        timestamp: timestamp.from_unix_seconds(1_499_040_000),
        open: 1.0,
        // high below low: the checker's own refusal.
        high: 0.5,
        low: 2.0,
        close: 1.5,
        volume: 10,
      ),
    )
  assert runtime.publish_request(
      a_desk_with_one_timeframe(),
      message.MsgSourceBarArrived(unqualified),
    )
    == None
  Nil
}

/// A bar that IS archived publishes EXACTLY ONE request, whose bar is the
/// archived head of `databar_list` and whose identity is the inbound keys.
pub fn an_archived_bar_publishes_one_request_test() {
  let arrival = an_arrival()
  let assert Some(request) =
    runtime.publish_request(
      a_desk_with_one_timeframe(),
      message.MsgSourceBarArrived(arrival),
    )
  assert id.broker_id_to_string(request.identity.broker_id) == "broker-1"
  assert symbol.to_string(request.identity.symbol) == "BTCUSD"
  assert request.identity.interval == IntervalOneMinute
  // The archived bar is the HEAD of history, and its idx is the one the
  // pipeline gave it.
  assert request.bar.idx == 0
  Nil
}

/// The step that publishes also moves the model: the archived bar is in the
/// new Desk's `databar_list` head, and the working databar is back to None.
pub fn the_archived_bar_is_in_the_new_desk_test() {
  let arrival = an_arrival()
  let msg = message.MsgSourceBarArrived(arrival)
  // `update` is the public shape; the Desk it returns is the one after the
  // archive.
  let subject = process.new_subject()
  let #(new_desk, _cmd) =
    runtime.update(a_desk_with_one_timeframe(), msg, subject)
  let assert Ok(broker_value) =
    desk.get_broker(new_desk, id.string_to_broker_id("broker-1"))
  let assert Ok(instrument_value) =
    broker.get_instrument(broker_value, symbol.string_to_symbol("BTCUSD"))
  let assert Ok(tf) =
    instrument.get_timeframe(instrument_value, IntervalOneMinute)
  assert tf.working_databar == None
  assert list.first(tf.databar_list) != Error(Nil)
  Nil
}
