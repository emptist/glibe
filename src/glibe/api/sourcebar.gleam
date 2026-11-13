//// The ONE internal standard bar — a family of nine variants, one per time
//// span. Implements `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// WORK OF THIS MODULE, three reads and writes of `SourceBar` values only:
//// ① hold the family of nine graded standard bars and read a bar's grade
//// back off its variant; ② refuse an unqualified bar; ③ give ONE qualified
//// bar ONE whole birth as a `DataBar`. It does not decode any provider's
//// wire format, does not CHANGE a bar's period, does not read or write a
//// `Timeframe`, and does not compute an indicator.
////
//// WHERE A PERIOD IS CHANGED: NOT here, and never in `Timeframe` or
//// `DataBar`. A data source that does not serve the period the caller needs
//// composes it in ITS OWN module before the bar reaches this type. Owner
//// 2026-11-13 (verbatim): *"比如Ib来源的实时数据，你可以查一下到底是不是
//// 5s数据，如果是你就需要 IbSourceBarFiveSecond 然后再 ib sourcebar 的模块
//// 里面，定义 pub fn five_second_to_one_minute, etc."* — those functions
//// live in `ib/sourcebar.gleam`, not here. R50 (owner, verbatim): *"even if
//// it is called, it should be defined in its belonging to module"*. The
//// standard layer is where every provider MEETS, not where one provider's
//// granularity is repaired (R28).
////
//// WHAT THIS IS NOT: what arrives from a data source is that source's own
//// external bar — `binance/kline.BinanceKline` and
//// `ib/sourcebar.IbSourceBar` are two — not this type. What the system
//// computes on is `databar.DataBar`, also not this type. R28 (owner,
//// verbatim): *"标准sourcebar不需要知道五花八门的外部sourcebar是什么模样，
//// 外来的自己负责标准化"*; each provider keeps its own shape in its own
//// module and defines its own conversion into THIS type. The old shape with
//// one variant per provider was struck: a provider module cannot import a
//// type held here without an import cycle.
////
//// WHY VARIANTS, NOT A FIELD — owner 2026-11-13 (verbatim): *"DataBar不需要
//// 变体的原因是，不需要转换，转换周期的工作是在SourceBar层面完成的，
//// sourcebar_gate()之前已经完成了合成工作，或者在 sourcebar_gate()中完成
//// 合成工作"* and *"等到了 databar_processing 你按到手的都是弄好的 databar,
//// 所以databar无需时间周期变体"*. A variant exists BECAUSE the source-bar
//// layer changes a period and the stream mixes grades; `DataBar` never
//// changes one, so it has none. Earlier words, the same fact — 2026-11-01:
//// *"sourcebar存在利用小段生成大段 sourcebar 的需要，即无法用timeframe隔离，
//// 要混用，所以要变体"*; 2026-10-26: *"校服就是变体，通过类型即可知道是
//// 什么，不需要改变bar到身体，懂吗？"* and *"你甚至可以内容完全一样，什么
//// 都一样，就Type不一样，就错不了，什么代价都没有，什么计算都不需要，编译
//// 器知道你自己错了"*. So there is NO `interval` field: a number could
//// disagree with the bar around it, a variant cannot. The period is IN the
//// type, and only `interval` has to name every grade; every other reader
//// writes `bar.close` and never learns the grade (R13 / R21).
////
//// THE NINE GRADES ARE A CLOSED SET. They are the nine constructors of
//// `api/interval.Interval`, the nine keys of `Instrument.timeframes`, and
//// the nine variants below — one set, three places. A source's finer native
//// granularity (IB's 5 seconds) is NOT a tenth variant: it belongs to that
//// source's own family and is consumed by that source's own composition
//// before a bar of one of these nine grades is written. `DataBar` has none
//// of them.
////
//// DESIGN EVIDENCE, NOT A STRUCTURE TO COPY: glib never reached this part
//// — it stopped at the grade family and wrote no fold. seib did write one:
//// `joinNew(aBar, period)` fuses the candles of ONE period, `_fillIn`
//// takes the first open, max high, min low, latest close and summed volume,
//// and `dataflow_base.coffee:176` says *"方便在沒有某級別數據比如hour數據
//// 時,採用合成方法形成數據,見joinNew"*. That is the DESIGN THOUGHT only.
//// seib is OOP — `@bar`, `this`, a mutable object living across calls —
//// and glibe is pure type / functional: a grade is a variant, and ONE
//// arriving bar is accumulated into ONE `growing_target_sourcebar` value
//// (owner 2026-11-13) passed in and returned, with the three states of
//// `working_databar`. There is no list of saved bars and no object
//// holding a half-built bar. No seib class, field or method name is a
//// model here.
////
//// EACH VARIANT CARRIES THE SAME SIX FIELDS, in the same order and with the
//// same types. No nested record: a record inside a variant would need an
//// invented type and would hide the fields from a boundary that reads them.
//// Adding a tenth span is a new variant plus one arm in `interval` and one
//// in each provider's exit; the compiler's exhaustiveness check is the bill
//// (R13). Naming is `<Type><Span>` — owner's own example
//// `SourceBarOneHour` — with the unit singular because it describes the
//// bar. Owner 2026-11-03 (verbatim) *"all singular minute or hour or day
//// since there are read as a 30 minute bar, the minute is used to describe
//// bar, so it is singular"*.
////
//// WHERE IT GOES: a provider writes one whole bar of one of these grades;
//// `validate` reads its OHLCV and returns either the same bar or a typed
//// refusal (R8); `to_databar` writes a whole `DataBar` from it and the
//// index the caller already holds (R39 / R42). From `DataBar` the path is
//// `timeframe.sourcebar_gate` writing `Timeframe.working_databar`, then
//// `databar_processing`.
////
//// R27 (owner, verbatim): *"date在标准sourcebar中必须时timestamp，unix
//// time"*. A bar's time is an absolute instant, not a date string, not a
//// local wall clock; the provider folded its own epoch at its boundary
//// (R9).
////
//// R33: history and live data are ONE stream. Both arrive here; there is no
//// replay, no rewind, no second batch implementation (R38).
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/time/timestamp.{type Timestamp}
import glibe/api/interval.{type Interval}
import glibe/databar.{type DataBar}

/// The internal standard bar. One variant per time span; the variant IS the
/// period, so no field names one. Not any provider's native structure and
/// not a union of their wire fields.
pub type SourceBar {
  SourceBarOneMinute(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
  SourceBarThreeMinute(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
  SourceBarFifteenMinute(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
  SourceBarThirtyMinute(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
  SourceBarOneHour(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
  SourceBarFourHour(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
  SourceBarOneDay(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
  SourceBarOneWeek(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
  SourceBarOneMonth(
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

/// Which interval a bar is — read FROM its variant, never from a field.
/// `timeframe.sourcebar_gate` reads it to compare the grade of the bar a
/// provider just wrote with the `Interval` key the caller holds for
/// `Instrument.timeframes` (R23 / R37). This is a READ of the grade, not a
/// way to build a bar: a provider's converter takes the grade from its own
/// bar's variant, and a provider's composition takes the target from its
/// own function name, never from a caller's claim. This function must name
/// every variant, so a tenth span is an `Inexhaustive patterns` error here
/// (R13).
pub fn interval(bar: SourceBar) -> Interval {
  todo as "05-01: case over the nine variants, one Interval each"
}

/// The price checker (owner's word). A qualified bar passes unchanged; an
/// unqualified one is refused with a typed reason — reject, never repair
/// (R8). This is the ONLY door (R38). Its six fields are reachable on every
/// variant without a `case`. The bar it reads is already of its final
/// grade: a checker never changes a period.
pub fn validate(bar: SourceBar) -> Result(SourceBar, SourceBarRejection) {
  todo as "05-01: a qualified bar passes; a typed rejection otherwise"
}

/// Birth of the working databar: ONE qualified `SourceBar` becomes ONE whole
/// `DataBar` (R39); the source's law, not the bar's, and no fold accumulator.
/// `idx` is the index the caller holds from `timeframe.bars_listed`; the
/// six fields are read straight off the variant. The `Interval` stays with
/// the caller as the key of `Instrument.timeframes` (R23 / R37) — this
/// function writes a bar, never a timeframe's name. Composition ended in
/// the provider's module BEFORE this birth, so the bar handed to
/// `databar_processing` is finished and its period is never asked again
/// (owner 2026-11-13).
pub fn to_databar(bar: SourceBar, idx: Int) -> DataBar {
  todo as "05-01: one whole bar born at the source boundary"
}
