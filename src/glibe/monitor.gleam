//// One addressed market bar advances exactly one `Timeframe`.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-08-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R13 (errors are types), R19 (docs-first / TDD),
//// R20 (`Desk ▸ Broker ▸ Instrument ▸ Timeframe`), R22 (a name is not the
//// thing named), R23 (identity is a key, never a field), R26 (no speculative
//// relations), R27 / R28 (the standard bar carries no provider identity),
//// R31 (BEAM parallelism is `process.spawn` + a typed `Subject`),
//// R32 (the structure is a garden: one `Desk`, every `Timeframe` leaf alive).
////
//// **What was missing.** The chain `Desk ▸ Broker ▸ Instrument ▸ Interval ▸
//// Timeframe` already expresses many instruments, each with many intervals,
//// and `config.default_config()` builds six independent `Timeframe` states.
//// But a bar ARRIVING from a provider had no address: `binance.fetch_klines`
//// returns `List(SourceBar)` and leaves the `symbol` / `interval` of its own
//// request behind, while `engine.sourcebar_gate` is handed a `Timeframe` and
//// an `Interval` by the caller. Nothing stopped a BTCUSDT bar from being fed
//// into SPY's hourly engine. This module is the typed boundary where that
//// pairing happens once.
////
//// **Why the address has three parts.** `BrokerId` because the same `Symbol`
//// under two brokers names two different instruments; `Symbol` because that
//// is the key in `Broker.instruments`; `Interval` because a kline stream is
//// requested per interval, and it is the key in `Instrument.timeframes`.
//// One `IncomingBar` advances ONE `Timeframe` — it is NOT fanned out to every
//// interval of its instrument. Monitoring N instruments × M intervals is N×M
//// LIVE leaves, each isolated from the others (R32).
////
//// **Why a wrapper type.** The standard `SourceBar` is deliberately free of
//// provider identity (R27 / R28); the identity belongs to the request that
//// produced it. `IncomingBar` pairs the two at the ingest boundary and is
//// the unit a spawned BEAM process or a replay step carries. Neither
//// `SourceBar` nor `Timeframe` gains a field.
////
//// **Pure, not a scheduler.** `advance` returns a NEW `Desk`; it starts no
//// process, opens no socket and holds no clock (R31). The structure is a
//// garden (R32): ONE `Desk`, and every `Timeframe` in an `Instrument`'s
//// `Dict(Interval, Timeframe)` is alive, processing its own bars and making
//// its own trading decisions. `process.spawn` + a typed `Subject` is the
//// whole BEAM primitive for that; there are no N `Desk` copies to merge.
//// `probes/parallel-bars/` measured exactly such copies, so its "0 of 6"
//// conclusion is void (R32). A new real thing is one new field in an
//// existing type, placed by asking what it belongs to; no `Market` / `Asset`
//// / `Exchange` relation is invented here (R26).

import gleam/option.{None, Some}
import gleam/result
import glibe/api/interval.{type Interval}
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection}
import glibe/api/symbol.{type Symbol}
import glibe/desk.{type BrokerId, type Desk}
import glibe/engine

/// The address of ONE live `Timeframe` inside a `Desk`. Three typed keys in
/// the order the ownership chain is walked — no composite `"BTCUSDT_H1"`
/// string (R23), and no `String` standing in for any of them.
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
  use #(settled, gated) <- result.try(
    engine.sourcebar_gate(timeframe, address.interval, incoming.bar)
    |> result.map_error(fn(rejection) { BarRejected(address, rejection) }),
  )
  let advanced = case settled {
    Some(bar) -> engine.databar_processing(gated, bar)
    None -> gated
  }
  let instrument = desk.put_timeframe(instrument, address.interval, advanced)
  let broker = desk.put_instrument(broker, address.symbol, instrument)
  Ok(desk.put_broker(desk, address.broker, broker))
}
