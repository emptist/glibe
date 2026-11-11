//// The one stream — standard bars into a `Timeframe`.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-11-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R33 (history and live are ONE stream; the
//// system is already live), R28 (provider shapes standardise themselves),
//// R19 (docs-first), R13 (errors are types), R22 (a name is not the thing),
//// R35 (simplicity is the check), R37 (identity lives in the holder's key).
////
//// **Why this module exists.** The pipe is
//// `api provider / data sources → history + live data → sourcebar_gate →
//// databar_processing → model ↔ view` (R33). `engine.sourcebar_gate` and
//// `engine.databar_processing` are two steps of that pipe, but nothing yet
//// threads a whole sequence of standard bars through both while carrying the
//// `Timeframe` between them. This module is that thread, and it is a PURE
//// VALUE: a list of bars goes in, one recomputed `Timeframe` comes out.
////
//// **History and live are the same stream, not two mechanisms.** A REST
//// kline batch (`binance.fetch_klines`) and a bar delivered by a subscribed
//// real-time source both arrive here as `SourceBar` values. Feeding them in
//// two calls or in one call gives the same value, because there is no clock,
//// cursor or session hidden in the state — `test/replay_test.gleam` pins it.
//// Data moves because a data source is subscribed; with no data this
//// function is never called and the system sleeps and waits (R33). Nothing
//// here wakes anything up, polls, or schedules.
////
//// **Identity is not a field (R37).** The caller selected this `Timeframe`
//// from `Instrument.timeframes` by its `Interval` key, so it passes the
//// interval in. `BrokerId` and `Symbol` were the keys above that. There is
//// deliberately NO `TimeframeAddress`, NO `IncomingBar` and NO
//// `MonitorError`: those were the imperative routing layer R33 withdrew.
////
//// **Errors are values (R13).** A bar the gate refuses is not skipped or
//// repaired; replay stops and reports which position in the stream was
//// refused and why. The reason stays a `SourceBarRejection` — no string is
//// re-parsed downstream.
////
//// **Only the standard bar enters (R28).** A provider keeps its own native
//// shape and its own `to_sourcebar`; by the time a bar reaches this module
//// all provider fields and wire spellings are gone.

import glibe/api/interval.{type Interval}
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection}
import glibe/timeframe.{type Timeframe}

/// **A standard bar was refused at the gate.** `at` is its zero-based
/// position in the stream handed to `replay` — a diagnostic coordinate,
/// NOT an owner's identity (R37). `reason` is the gate's own closed set, so
/// a caller never parses a message to find out what went wrong (R13).
pub type ReplayError {
  BarRejected(at: Int, reason: SourceBarRejection)
}

/// **Advance one `Timeframe` through a sequence of standard bars.**
///
/// The bars are consumed in order. Each goes through `engine.sourcebar_gate`;
/// when that closes a bucket, the closed bar goes through
/// `engine.databar_processing` before the next source bar is read. The
/// returned `Timeframe` is a NEW value — nothing is mutated (R33: every type
/// moves because data moves through it). An empty stream returns the very
/// same value it was given.
///
/// The `Interval` is passed by the caller that selected this `Timeframe`
/// from its `Dict` key; the record itself does not know it (R23 / R37).
/// No broker or symbol is named here for the same reason.
pub fn replay(
  timeframe: Timeframe,
  interval: Interval,
  bars: List(SourceBar),
) -> Result(Timeframe, ReplayError) {
  todo as "04-11 step 4: thread gate then databar_processing through the stream"
}
