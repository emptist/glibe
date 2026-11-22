//// The ONE internal standard bar — a family of nine variants, one per time
//// span. Implements `.planning/BRIEF.md`.
////
//// WORK OF THIS MODULE, three reads and writes of `SourceBar` values only:
//// ① hold the family of nine standard bar variants and read a bar's interval
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
//// type, and only `interval` has to name every variant; every other reader
//// writes `sourcebar.close` and never learns the interval (R13 / R21).
////
//// THE NINE INTERVAL VARIANTS ARE A CLOSED SET. They are the nine constructors of
//// `api/interval.Interval`, the nine keys of `Instrument.timeframes`, and
//// the nine variants below — one set, three places. A source's finer native
//// granularity (IB's 5 seconds) is NOT a tenth variant: it belongs to that
//// source's own family and is consumed by that source's own composition
//// before a bar of one of these nine grades is written. `DataBar` has none
//// of them.
////
//// DESIGN EVIDENCE, NOT A STRUCTURE TO COPY: glib never reached this part
//// — it stopped at the interval-variant family and wrote no fold. seib did write one:
//// `joinNew(aBar, period)` fuses the candles of ONE period, `_fillIn`
//// takes the first open, max high, min low, latest close and summed volume,
//// and `dataflow_base.coffee:176` says *"方便在沒有某級別數據比如hour數據
//// 時,採用合成方法形成數據,見joinNew"*. That is the DESIGN THOUGHT only.
//// seib is OOP — `@bar`, `this`, a mutable object living across calls —
//// and glibe is pure type / functional: an interval is carried by a variant, and ONE
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
//// time"*. A bar's time is an absolute `Timestamp`, not a date string, not
//// a local wall clock; the provider folded its own epoch at its boundary
//// (R9).
////
//// R33: history and live data are ONE stream. Both arrive here; there is no
//// second path or separate batch treatment (R38).
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/time/timestamp.{type Timestamp}
import glibe/api/interval.{type Interval}
import glibe/databar.{type DataBar, DataBar}
import glibe/trading/signal

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

/// <** human: better use labeled args, while avoiding a bar instead of sourcebar
/// pub fn interval(of sourcbar: SourceBar) -> Interval {
///   ...
/// }
/// **>
/// Which interval a bar is — read FROM its variant, never from a field.
/// `timeframe.sourcebar_gate` reads it to compare the interval of the bar a
/// provider just wrote with the `Interval` key the caller holds for
/// `Instrument.timeframes` (R23 / R37). This is a READ of the interval, not a
/// way to build a bar: a provider's converter takes the interval from its own
/// bar's variant, and a provider's composition takes the target from its
/// own function name, never from a caller's claim. This function must name
/// every variant, so a tenth span is an `Inexhaustive patterns` error here
/// (R13).
pub fn interval(of sourcebar: SourceBar) -> Interval {
  case sourcebar {
    SourceBarOneMinute(..) -> interval.IntervalOneMinute
    SourceBarThreeMinute(..) -> interval.IntervalThreeMinute
    SourceBarFifteenMinute(..) -> interval.IntervalFifteenMinute
    SourceBarThirtyMinute(..) -> interval.IntervalThirtyMinute
    SourceBarOneHour(..) -> interval.IntervalOneHour
    SourceBarFourHour(..) -> interval.IntervalFourHour
    SourceBarOneDay(..) -> interval.IntervalOneDay
    SourceBarOneWeek(..) -> interval.IntervalOneWeek
    SourceBarOneMonth(..) -> interval.IntervalOneMonth
  }
}

/// The price checker (owner's word). A qualified bar passes unchanged; an
/// unqualified one is refused with a typed reason — reject, never repair
/// (R8). This is the ONLY door (R38). Its six fields are reachable on every
/// variant without a `case`. The bar it reads is already of its final
/// interval: a checker never changes a period.
pub fn validate(sourcebar: SourceBar) -> Result(SourceBar, SourceBarRejection) {
  // R8 reject-never-repair. The six fields are on all nine variants, so they
  // are reachable without a case. The single-constructor refusal is deliberate
  // (R26): a finer reason waits for a real consumer.
  case
    sourcebar.open <. 0.0
    || sourcebar.high <. 0.0
    || sourcebar.low <. 0.0
    || sourcebar.close <. 0.0
    || sourcebar.high <. sourcebar.low
    || sourcebar.high <. sourcebar.open
    || sourcebar.high <. sourcebar.close
    || sourcebar.low >. sourcebar.open
    || sourcebar.low >. sourcebar.close
    || sourcebar.volume < 0
  {
    True -> Error(SourceBarRejectionUnqualified)
    False -> Ok(sourcebar)
  }
}

/// Birth of the working databar: ONE qualified `SourceBar` becomes ONE whole
/// `DataBar` (R39); the source's law, not the bar's, and no fold accumulator.
/// `idx` is the index the caller holds from `timeframe.bars_listed`; the
/// six fields are read straight off the variant. The `Interval` stays with
/// the caller as the key of `Instrument.timeframes` (R23 / R37) — this
/// function writes a bar, never a timeframe's name. Composition ended in
/// the provider's module BEFORE this birth: the `SourceBar` handed here has
/// already closed, and its period is never asked again (owner 2026-11-13).
/// `databar_processing` thereafter reads and writes `working_databar`,
/// not this `SourceBar`.
pub fn to_databar(sourcebar: SourceBar, idx: Int) -> DataBar {
  DataBar(
    idx: idx,
    timestamp: sourcebar.timestamp,
    open: sourcebar.open,
    high: sourcebar.high,
    low: sourcebar.low,
    close: sourcebar.close,
    volume: sourcebar.volume,
    signal: signal.SignalNoSignal,
    // R3: every measured field is computed later by databar_processing; a bar
    // is born whole with a neutral seed, never a fabricated mean (R46 removed
    // the settings, not these fields). Owner 2026-11-23: glib's complete
    // indicator set is carried here, not only the eight the chart draws.
    // Five SMA series (glib databar.gleam:41-45).
    sma_tiny: 0.0,
    sma_small: 0.0,
    sma_medium: 0.0,
    sma_large: 0.0,
    sma_huge: 0.0,
    // Seven Bollinger lines (glib databar.gleam:47-53).
    bb_m: 0.0,
    bb_u3: 0.0,
    bb_l3: 0.0,
    bb_u2: 0.0,
    bb_u1: 0.0,
    bb_l1: 0.0,
    bb_l2: 0.0,
    // O(1) recurrence state for timeframe.indicator (R26/R32): neutral at
    // birth; the first indicator step seeds sigma from the first close and
    // the KDJ cache from the first bar's own high/low (glib bollinger/kdj).
    sigma_n: 0,
    sigma_mean: 0.0,
    sigma_m2: 0.0,
    // KDJ oscillator K/D/J/M (glib databar.gleam:60-63).
    k: 0.0,
    d: 0.0,
    j: 0.0,
    m: 0.0,
    // Cached KDJ RSV extremes (glib databar.gleam:68-71).
    kdj_h: 0.0,
    kdj_h_idx: 0,
    kdj_l: 0.0,
    kdj_l_idx: 0,
    // The YinLeaf / YangLeaf CMAs (glib databar.gleam:76-77).
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
  )
}
