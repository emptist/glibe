//// RED tests for the closed Msg decoder and the publisher effect. Implements
//// `.planning/phases/03-app-view/03-01-PLAN.md` Task 2.
////
//// These pin the OBSERVABLE promises of `app/message.gleam` and
//// `app/publish.gleam`:
////   - `message.from_event` maps OUR CustomWidget kind to `MsgSourceBarArrived`
////     and leaves every other event as `MsgEye` — no input is dropped, and
////     there is no catch-all over OUR closed `Msg` (R13);
////   - `publish.request` delivers exactly one request to the Subject;
////   - `publish.serve` forwards each request to the dispatch closure and keeps
////     serving.
////
//// The rules are ported from frozen glib's wire discipline (R47: one module
//// writes and reads the same kind) and from the BEAM's own `process` module.
////
//// THE SUBJECT IS A **NAMED** ONE (`process.named_subject`), measured: a
//// `process.new_subject()` is OWNED by the process that made it, and
//// `process.receive` PANICS on a non-named subject owned by another process
//// (`gleam_erlang/process.gleam:226-238`). The publisher runs in its own
//// process, so the channel between it and `update` must be a named subject.

import gleam/dynamic
import gleam/erlang/process.{type Subject}
import gleam/time/timestamp
import glibe/api/interval.{IntervalOneMinute}
import glibe/api/sourcebar.{type SourceBar, SourceBarOneMinute}
import glibe/api/symbol
import glibe/app/message.{type Msg, MsgEye, MsgSourceBarArrived}
import glibe/app/publish
import glibe/app/wire
import glibe/databar
import glibe/id
import glibe/trading/signal
import plushie/command
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

fn an_identity() -> wire.ChartIdentity {
  wire.ChartIdentity(
    broker_id: id.string_to_broker_id("broker-1"),
    symbol: symbol.string_to_symbol("BTCUSD"),
    interval: IntervalOneMinute,
  )
}

fn a_data_bar(idx: Int) -> databar.DataBar {
  databar.DataBar(
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

/// Our CustomWidget sourcebar kind becomes `MsgSourceBarArrived` — the ONE
/// closed variant that carries a bar. The payload survives it intact.
pub fn our_sourcebar_kind_becomes_the_sourcebar_msg_test() {
  let event = wire.sourcebar_event(an_arrival())
  let msg = message.from_event(event)
  let assert MsgSourceBarArrived(payload) = msg
  assert id.broker_id_to_string(payload.broker_id) == "broker-1"
  assert symbol.to_string(payload.symbol) == "BTCUSD"
  assert payload.interval == IntervalOneMinute
  Nil
}

/// An ordinary eye event stays an eye event: the decoder does not swallow it.
pub fn an_eye_event_stays_an_eye_msg_test() {
  let event = event.Timer(event.TimerEvent("tick", 42))
  let msg = message.from_event(event)
  let assert MsgEye(eye) = msg
  assert eye == event.Timer(event.TimerEvent("tick", 42))
  Nil
}

/// A CustomWidget of ANOTHER kind stays an eye event — no input is dropped and
/// no kind is guessed.
pub fn another_custom_widget_kind_stays_an_eye_msg_test() {
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
  let msg = message.from_event(event)
  let assert MsgEye(_) = msg
  Nil
}

/// `publish.request` delivers exactly ONE request to the Subject — the effect
/// carrier proven without an `Instance`.
pub fn publish_request_delivers_exactly_one_test() {
  let #(subject, collector) = a_registered_publisher()
  let request =
    wire.ChartPushRequest(identity: an_identity(), bar: a_data_bar(7))
  let cmd = publish.request(subject, request)
  run_command(cmd)
  let assert Ok(received) = process.receive(collector, 2000)
  assert received == request
  Nil
}

/// `publish.serve` forwards each request to the dispatch closure and keeps
/// serving: two requests, two dispatches, in order.
pub fn publish_serve_forwards_every_request_test() {
  let #(subject, collector) = a_registered_publisher()
  let one = wire.ChartPushRequest(identity: an_identity(), bar: a_data_bar(1))
  let two = wire.ChartPushRequest(identity: an_identity(), bar: a_data_bar(2))
  process.send(subject, one)
  process.send(subject, two)
  let assert Ok(first) = process.receive(collector, 2000)
  let assert Ok(second) = process.receive(collector, 2000)
  assert first == one
  assert second == two
  Nil
}

/// The dispatch closure is called with the request itself — the publisher
/// never rewrites it.
pub fn publish_serve_hands_the_request_over_unchanged_test() {
  let #(subject, collector) = a_registered_publisher()
  let request =
    wire.ChartPushRequest(identity: an_identity(), bar: a_data_bar(9))
  process.send(subject, request)
  let assert Ok(received) = process.receive(collector, 2000)
  assert received.bar.idx == 9
  Nil
}

/// Start a publisher process on a named subject and register the name FOR IT,
/// so a send to that name reaches it. The collector is an UNNAMED subject owned
/// by THIS process: `process.send` to an unnamed subject has no ownership check
/// (only `receive` does), so the publisher can hand each request over and the
/// test can receive it. Returns the two subjects.
fn a_registered_publisher() -> #(
  Subject(wire.ChartPushRequest),
  Subject(wire.ChartPushRequest),
) {
  let publish_name = process.new_name(prefix: "glibe.test.chart_push")
  let publish_subject = process.named_subject(publish_name)
  let collect_subject = process.new_subject()
  let pid =
    process.spawn(fn() {
      publish.serve(publish_subject, fn(request) {
        process.send(collect_subject, request)
      })
    })
  let assert Ok(_) = process.register(pid, publish_name)
  #(publish_subject, collect_subject)
}

/// Run a `Command` that carries one Async task: execute its work in this
/// process so the effect is observable without a renderer.
fn run_command(cmd: command.Command(Msg)) -> Nil {
  case cmd {
    command.Async(work, _) -> {
      let _ = work()
      Nil
    }
    _ -> Nil
  }
}
