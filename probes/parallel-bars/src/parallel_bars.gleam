//// N addressed bars, N BEAM processes, no actor, no supervisor, no lock.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-09-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R19 (docs-first / TDD), R26 (no speculative
//// relations), R27 / R28 (the standard bar carries no provider identity),
//// R31 (Erlang / BEAM concurrency is `process.spawn` + a typed `Subject`).
////
//// **What this measures.** Owner 2026-11-09: *"gleam语言呀，是天然多线程，
//// 好像不需要actor那些东西 … 非常简单啊非常自然。因为他是一个一个严格的
//// value，完全不住在内存里，所以根本没有那些复杂的补救措施需要做"*.
//// `monitor.advance` is already a pure step from one `Desk` to a new `Desk`.
//// The question is not whether many bars can run at once — the official
//// `gleam_erlang/process.spawn` + typed `Subject` is three lines — but what
//// the N returned `Desk` values MEAN. Each is a partial view: it advanced
//// exactly one address and left the other five at their original state.
//// There is no shared memory to lock, but there is an OWNERSHIP decision:
//// either one owner folds the steps into one `Desk`, or each address owns its
//// own `Timeframe`. That is a data-flow shape, not a synchronisation device.
////
//// **Scope.** Erlang / BEAM only (owner 2026-11-09 06:09: *"你去看什么
//// javascript target完全不对路，我们是erlang 和 BEAM专属项目"*). This probe
//// imports no `gleam_otp` module, starts no actor and no supervisor, and
//// uses no lock, mutex, ETS or FFI. Nothing here is production code.

import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/time/timestamp
import glibe/api/interval
import glibe/api/sourcebar.{type SourceBar}
import glibe/api/symbol
import glibe/config
import glibe/desk
import glibe/monitor

/// One reply from ONE spawned BEAM process: which address it computed,
/// which process did the work, and the pure result it produced.
/// `worker` is a `Pid`, not a name or a string — the compiler cannot confuse
/// it with a bar, a subject or another reply.
pub type StepReply {
  StepReply(
    address: monitor.TimeframeAddress,
    worker: process.Pid,
    outcome: Result(desk.Desk, monitor.MonitorError),
  )
}

/// One well-formed bar with a recognisable close. The timestamp goes through
/// the same wire conversion the provider adapters use (R27).
fn quote(instant: timestamp.Timestamp, close: Float) -> SourceBar {
  sourcebar.SourceBar(
    timestamp: instant,
    open: close -. 0.5,
    high: close +. 1.0,
    low: close -. 1.0,
    close: close,
    volume: 10,
  )
}

/// Pair one bar with its three typed keys, once, at the ingest boundary.
fn addressed(
  broker: String,
  name: String,
  iv: interval.Interval,
  bar: SourceBar,
) -> monitor.IncomingBar {
  monitor.IncomingBar(
    address: monitor.TimeframeAddress(
      broker: desk.broker_id(broker),
      symbol: symbol.from_string(name),
      interval: iv,
    ),
    bar: bar,
  )
}

/// The six configured `Timeframe` addresses, each paired with one well-formed
/// bar. Every bar is valid on its own; only the ADDRESS differs.
pub fn sample_arrivals() -> List(monitor.IncomingBar) {
  let assert Ok(instant) = sourcebar.unix_timestamp("2024-01-15 09:00:00")
    as "the probe's fixed instant parses through the wire conversion"
  [
    addressed(
      "binance",
      "BTCUSDT",
      interval.IntervalOneHour,
      quote(instant, 100.0),
    ),
    addressed(
      "binance",
      "BTCUSDT",
      interval.IntervalOneDay,
      quote(instant, 101.0),
    ),
    addressed("ib", "SPY", interval.IntervalOneHour, quote(instant, 300.0)),
    addressed("ib", "SPY", interval.IntervalOneDay, quote(instant, 301.0)),
    addressed(
      "futu",
      "SPY_FUTU",
      interval.IntervalOneHour,
      quote(instant, 400.0),
    ),
    addressed(
      "futu",
      "SPY_FUTU",
      interval.IntervalOneDay,
      quote(instant, 401.0),
    ),
  ]
}

/// Collect exactly `remaining` replies from the caller-owned subject.
/// A timeout is a `Result`, not a `panic`: a silent worker is a measurement.
fn collect(
  from replies: process.Subject(StepReply),
  remaining remaining: Int,
  gathered gathered: List(StepReply),
) -> Result(List(StepReply), Nil) {
  case remaining {
    0 -> Ok(list.reverse(gathered))
    _ ->
      case process.receive(from: replies, within: 5000) {
        Ok(reply) -> collect(replies, remaining - 1, [reply, ..gathered])
        Error(Nil) -> Error(Nil)
      }
  }
}

/// Run every arrival in its OWN BEAM process and collect all typed replies.
/// One `Subject` owned by the caller receives them; `Error(Nil)` means a
/// worker did not answer within the timeout.
pub fn advance_in_parallel(
  initial: desk.Desk,
  arrivals: List(monitor.IncomingBar),
) -> Result(List(StepReply), Nil) {
  let replies: process.Subject(StepReply) = process.new_subject()
  list.each(arrivals, fn(incoming) {
    process.spawn(fn() {
      let outcome = monitor.advance(initial, incoming)
      process.send(
        replies,
        StepReply(
          address: incoming.address,
          worker: process.self(),
          outcome: outcome,
        ),
      )
    })
  })
  collect(from: replies, remaining: list.length(arrivals), gathered: [])
}

/// Apply every arrival to ONE `Desk`, in arrival order. This is the
/// single-owner shape: no merging of partial `Desk` values is needed.
pub fn advance_in_order(
  initial: desk.Desk,
  arrivals: List(monitor.IncomingBar),
) -> desk.Desk {
  list.fold(over: arrivals, from: initial, with: fn(so_far, incoming) {
    // A refused bar writes nothing back; the probe's bars are all valid.
    result.unwrap(monitor.advance(so_far, incoming), so_far)
  })
}

/// A readable name for an address, for the probe's printed report only.
pub fn describe(address: monitor.TimeframeAddress) -> String {
  desk.broker_id_to_string(address.broker)
  <> "/"
  <> symbol.to_string(address.symbol)
  <> "/"
  <> interval.to_string(address.interval)
}

/// Print the measured process ids and the isolation result.
pub fn main() -> Nil {
  let initial = config.default_config().desk
  let arrivals = sample_arrivals()
  let assert Ok(replies) = advance_in_parallel(initial, arrivals)
    as "every spawned worker answers within the timeout"
  let workers = list.map(replies, fn(reply) { reply.worker })
  io.println(
    "04-09 | "
    <> int.to_string(list.length(arrivals))
    <> " addressed bars, "
    <> int.to_string(list.length(list.unique(workers)))
    <> " distinct BEAM processes, 0 actor / 0 supervisor / 0 lock",
  )
  list.each(replies, fn(reply) {
    io.println("  " <> describe(reply.address))
    let _ = echo reply.worker
    Nil
  })
  let ordered = advance_in_order(initial, arrivals)
  let matching =
    list.length(
      list.filter(replies, fn(reply) {
        case reply.outcome {
          Ok(partial) -> partial == ordered
          Error(_) -> False
        }
      }),
    )
  io.println(
    "  partial Desks equal to the single-owner fold: "
    <> int.to_string(matching)
    <> " / "
    <> int.to_string(list.length(replies)),
  )
  Nil
}
