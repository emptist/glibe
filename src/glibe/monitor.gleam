//// HISTORICAL (04-08) — this layer is NOT part of the owner's design (R33).
////
//// Plan: `.planning/phases/04-domain-cleanup/04-08-PLAN.md` (superseded).
//// Rulings: `docs/RULINGS.md` R33, R19 (docs-first / TDD), R20 / R23 (the
//// ownership chain), R27 / R28 (the standard bar carries no provider
//// identity), R26 (no speculative relations).
////
//// **Why it is historical.** Owner 2026-11-10: *"什么monitor.advance 哪有
//// 这些type，你的设计思路停留在非Gleam非functional非type的其他语言
//// 和架构体系中"*. The system is already live: data arrives from a subscribed
//// real-time source and moves through
//// `sourcebar_gate → databar_processing → model ↔ view`; **every type is
//// live because data moves through it**, and `Desk` is the ONE top-level
//// Value. Wrapping a bar as an addressed message and writing a function to
//// "advance" a Value is imperative scheduling brought in from another
//// architecture — not this design. `leaf` / 叶子 means `YinLeaf` and
//// `YangLeaf` only; it never named a `Timeframe`.
////
//// **The code below is kept exactly as written, unchanged.** `monitor.advance`,
//// `TimeframeAddress`, `IncomingBar` and `MonitorError` are retained as a
//// dated record of work done and as passing tests; their disposition
//// (delete or rework) is the owner's call. Until then they are NOT a basis
//// for the structure, and no mechanism may be built on top of them. R31's
//// concurrency framing and R32's "every `Timeframe` leaf is alive" wording
//// are void under R33. A new real thing is one new field in an existing
//// type, placed by asking what it belongs to; no `Market` / `Asset` /
//// `Exchange` relation is invented here (R26).

import gleam/result
import glibe/api/interval.{type Interval}
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection}
import glibe/api/symbol.{type Symbol}
import glibe/desk.{type BrokerId, type Desk}

// 04-13 adaptation only: `engine.gleam` was an AI-invented split and is gone;
// the two top-level data-treating functions live in `glibe/timeframe`. This
// historical module's design ruling (R33) is unchanged.
import glibe/timeframe as tf

/// The address of ONE `Timeframe` inside a `Desk`. Three typed keys in
/// the order the ownership chain is walked — no composite `"BTCUSDT_H1"`
/// string (R23), and no `String` standing in for any of them.
/// Historical: this type is not part of the design (R33, see module doc).
pub type TimeframeAddress {
  TimeframeAddress(broker: BrokerId, symbol: Symbol, interval: Interval)
}

/// One bar as it ARRIVES: the standard bar plus the identity of the request
/// that fetched it. A `SourceBar` on its own never says which instrument it
/// belongs to (R27 / R28); this is the one place that fact is attached.
pub type IncomingBar {
  IncomingBar(address: TimeframeAddress, bar: SourceBar)
}

/// Why one addressed step could not run. Both variants carry the address, so
/// the caller knows WHICH of the many monitored timeframes failed. The
/// lower-level `desk.LookupError` / `SourceBarRejection` is a value, not a
/// message to be parsed later (R13).
pub type MonitorError {
  /// The address names no configured broker, instrument or interval.
  AddressNotMonitored(TimeframeAddress, desk.LookupError)
  /// The bar itself was refused at the gate; that `Timeframe` is unchanged.
  BarRejected(TimeframeAddress, SourceBarRejection)
}

/// Advance the ONE `Timeframe` named by `incoming.address` by one source bar.
/// A closed bucket runs through `databar_processing`; an open bucket only
/// leaves a `working_databar`. Either way the returned `Desk` differs from the
/// argument ONLY at that address. On error nothing is written: the caller's
/// `Desk` is untouched because this function is pure.
pub fn advance(
  desk: Desk,
  incoming: IncomingBar,
) -> Result(Desk, MonitorError) {
  let address = incoming.address
  use broker <- result.try(
    desk.get_broker(desk, address.broker)
    |> result.map_error(fn(error) { AddressNotMonitored(address, error) }),
  )
  use instrument <- result.try(
    desk.get_instrument(broker, address.symbol)
    |> result.map_error(fn(error) { AddressNotMonitored(address, error) }),
  )
  use timeframe <- result.try(
    desk.get_timeframe(instrument, address.interval)
    |> result.map_error(fn(error) { AddressNotMonitored(address, error) }),
  )
  use gated <- result.try(
    tf.sourcebar_gate(timeframe, address.interval, incoming.bar)
    |> result.map_error(fn(rejection) { BarRejected(address, rejection) }),
  )
  let advanced = tf.databar_processing(gated)
  let instrument = desk.put_timeframe(instrument, address.interval, advanced)
  let broker = desk.put_instrument(broker, address.symbol, instrument)
  Ok(desk.put_broker(desk, address.broker, broker))
}
