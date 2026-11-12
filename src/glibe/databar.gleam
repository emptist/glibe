//// The system's bar. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: `Timestamp`, `Signal`.
//// WRITES: `DataBar`, the value held in `Timeframe.working_databar` and in
//// `Timeframe.databar_list`.
////
//// R39 (owner, verbatim): *"数据来到我们的系统，合格的sourcebar变成working
//// databar，从头到尾所有运算处理决策都在这个databar working中完成，之后他
//// 就被working databar archieved，这就是整个的系统，没有任何旁门左道。"*
//// So one DataBar is born whole from ONE qualified SourceBar, and every
//// indicator / leaf / branch / strategy result is written ON this bar.
//// There is no bucket accumulator, no second bar, no side door.
////
//// R42: the birth belongs to the SOURCE (`sourcebar.to_databar` is the one
//// conversion); this module holds the TYPE only. R27: `timestamp` is a
//// `gleam_time.Timestamp`, an absolute unix instant, never a date string.
//// R28: OHLCV are what the standard layer consumes with unified meaning.
////
//// R47: this module holds the TYPE only because its birth belongs to the
//// source (`sourcebar.to_databar`) and every computed result is written ON
//// this bar by the pipeline steps in `timeframe.gleam` — a concrete reader
//// and writer for every field. An empty type is not made legitimate by
//// having a `///` doc, nor by calling its lack of behaviour "by design":
//// each doc sentence must name a value and who reads or writes it.
//// Computed fields arrive one at a time with their real consumer (R26/R32),
//// so listing them now would transcribe the old implementation.

import gleam/time/timestamp.{type Timestamp}
import glibe/trading/signal.{type Signal}

/// One bar of the system. `idx` is the bar's index, starting at 0; R1 / R4
/// record `working_databar.idx` and `start_bar.idx` in the recognition rule.
/// It is not a count of anything here. `signal` is the decision written on
/// this very bar (`"buy"` / `"sell"` / `""`, R10 / R11; every decision is
/// made IN the working databar, R39). Everything computed in
/// `databar_processing` lands on this bar.
pub type DataBar {
  DataBar(
    idx: Int,
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
    signal: Signal,
  )
}
