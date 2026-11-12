//// The ONE internal standard bar. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: `Timestamp`.
//// WRITES: `SourceBar` and `SourceBarRejection`; `DataBar` at its birth.
////
//// R27 (owner, verbatim): *"date在标准sourcebar中必须时timestamp，unix
//// time"*. A bar's time is an absolute instant, not a date string, not a
//// local wall clock. R28 (owner, verbatim): *"binance的kline包含很多特殊
//// 字段，其他提供商不提供，比如ib不提供那些字段，所以他们两家的sourcebar
//// 绝对不同，要保留原生态，并且各自标准化"*. The provider's native shape
//// stays in the provider module; `to_sourcebar` is each provider's one exit,
//// and THIS type is the only meeting point. The standard layer absorbs no
//// provider-specific names and parses no strings.
////
//// R38: *"合格的sourcebar"* — a bar that is not qualified is refused at the
//// gate. R13: a refusal is a closed-set type, never `Error(String)`. R8
//// (reject, never repair) already gives the checks that belong here: a bar
//// whose own numbers disagree is refused with the reason, never repaired
//// into agreement; high >= low >= 0, volume >= 0, high the highest of the
//// four and low the lowest. Their individual rejection reasons are added
//// as constructors when their real consumer exists (R26 / R32), and the
//// compiler then lists every `case` that must grow (R13 / R21).
////
//// R33: history and live data are ONE stream. Both arrive here; there is no
//// replay, no rewind, no second batch implementation (R38).
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/time/timestamp.{type Timestamp}
import glibe/databar.{type DataBar}

/// The internal standard bar: an absolute instant plus OHLCV. Not any
/// provider's native structure and not a union of their wire fields.
pub type SourceBar {
  SourceBar(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
}

/// Why a bar was refused at the gate. One constructor per real check; a
/// check that has no consumer yet has no constructor (R26), and adding one
/// makes every incomplete `case` a compile error (R13).
pub type SourceBarRejection {
  /// The bar did not qualify. Owner's word: 不合格的 sourcebar.
  SourceBarRejectionUnqualified
}

/// The price checker (owner's word). A qualified bar passes unchanged; an
/// unqualified one is refused with a typed reason — reject, never repair
/// (R8). This is the ONLY door (R38).
pub fn validate(bar: SourceBar) -> Result(SourceBar, SourceBarRejection) {
  todo as "05-01: a qualified bar passes; a typed rejection otherwise"
}

/// Birth of the working databar. ONE qualified SourceBar becomes ONE whole
/// DataBar (R39); the source's law, not the bar's, and no fold accumulator.
pub fn to_databar(bar: SourceBar, idx: Int) -> DataBar {
  todo as "05-01: one whole bar born at the source boundary"
}
