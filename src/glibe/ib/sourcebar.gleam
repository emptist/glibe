//// IB's OWN external source bar, and the ONLY place IB's period is changed.
//// Implements `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// WORK OF THIS MODULE: hold the shape IB actually serves, and accumulate
//// ONE arriving five-second bar at a time into ONE whole standard bar of
//// each grade the system needs. It does not hold a `Timeframe`, does not
//// write a `DataBar`, does not validate a price and does not compute an
//// indicator.
////
//// WHAT IB SERVES, MEASURED, NOT ASSUMED. IB's own TWS API documentation
//// (`interactivebrokers.com/docs/tws-api/doc/market-data-live/5-second-bars/
//// introduction`): *"reqRealTimeBars will create an active subscription
//// that will return a single bar in real time every five seconds … can only
//// be used with a bar size of 5 seconds"*. The `EClientSocket` reference
//// says *"Currently, only 5 seconds bars are provided"*. `seib/ibtests/
//// reqRealTimeBars.coffee:25-40` passes `barSize = 5` on every request. So
//// the realtime shape is five seconds, and `IbSourceBarFiveSecond` is not
//// an invented grade. Owner 2026-11-13 (verbatim): *"比如Ib来源的实时数据，
//// 你可以查一下到底是不是5s数据，如果是你就需要 IbSourceBarFiveSecond
//// 然后再 ib sourcebar 的模块里面，定义 pub fn five_second_to_one_minute,
//// etc."*
////
//// TYPE RELATION TO `Broker` — the same question owner raised about the
//// first arriving bar: *"只能是broker或api provider（目前两者是重叠关系，
//// 可是的确有不是broker的数据源，所以这是什么type关系？）"*. A data
//// source is the INPUT boundary (R33), NOT a level of `Desk ▸ Broker ▸
//// Instrument ▸ Timeframe`; `Broker` is neither its parent nor its child,
//// and one real institution can hold both roles. `binance/kline.gleam`
//// states the same relation. This module imports no broker.
////
//// NAMING (owner, verbatim): *"基本的构成是 来源+bar名称+时间跨度，是一贯
//// 的"*. `IbSourceBarFiveSecond` = source `Ib` + IB's own bar word
//// `SourceBar` + the span `FiveSecond`, exactly like
//// `BinanceKlineOneHour`. The `Ib` prefix is not decoration: a second
//// source may also call its own bar `SourceBar`, and `SourceBarFiveSecond`
//// alone could not say whose bar it is. The ONE internal standard bar has
//// no source prefix because there is exactly one of it.
////
//// WHY ONE VARIANT. IB's realtime subscription gives ONE grade, so the
//// family has ONE constructor. That is a type-level guarantee, not a
//// convention: every `IbSourceBar` handed to a composition below IS a
//// five-second bar, and no `case` is needed to check it. A finer or a
//// historical IB barSize is a NEW variant added here when that source
//// really serves it (R26 / R28 / R32) — never a grade smuggled into the
//// standard layer.
////
//// WHERE A PERIOD IS CHANGED, AND WHY HERE. Owner 2026-11-13 (verbatim):
//// *"DataBar不需要变体的原因是，不需要转换，转换周期的工作是在SourceBar
//// 层面完成的，sourcebar_gate()之前已经完成了合成工作，或者在
//// sourcebar_gate()中完成合成工作"*; *"通常有些源给你5秒钟的实时数据，
//// 但是不给你1分钟，3分钟，5分钟等等，你就需要自己合成。合成也很简单"*.
//// IB gives no 1-minute, 3-minute or hourly bar on the realtime stream, so
//// THIS module composes them. R50 (owner, verbatim): *"even if it is
//// called, it should be defined in its belonging to module"*. The
//// functions below read and write IB's own bar, so they belong here —
//// even when `instrument.compose_ib_realtime_bar` is their call site.
//// `instrument.gleam` only DISPATCHES by the `Interval` key it holds;
//// `api/sourcebar.gleam` is only the meeting point; `timeframe.gleam`
//// only holds the growing field and never composes (R28 / R37 / R50).
////
//// THE SHAPE THE OWNER ASKED FOR (verbatim, 2026-11-13): *"你现在要设想，
//// 每个5秒你收到一个 IbSourceBarFiveSecond, 然后你怎么样通过累计的方式，
//// 处理他，直至时间点正好到达目标周期，这个你要设计的，其实非常简单，
//// 参考 working_databar 如何工作，设计一个 growing_target_sourcebar"*.
//// So the accumulation works EXACTLY like `Timeframe.working_databar`
//// (R39): ONE value, three states `None → Some(bar) → None`; every
//// arriving bar is dealt with INSIDE that value, and nothing else holds a
//// half-built bar. There is NO list of saved bars, no batch fold, no
//// second accumulator, no actor / clock / poll (R33). The value is named
//// `growing_target_sourcebar` and its type is `Option(SourceBar)` — the
//// ONE internal standard bar, already carrying its target grade as a
//// variant, so no invented container type is needed. A bar that is not
//// finished is simply not emitted: the only way out is the boundary.
////
//// THE THREE STATES, ONE BAR AT A TIME. Each function below is called ONCE
//// per arriving five-second bar and returns
//// `#(finished_target_sourcebar, growing_target_sourcebar)`:
//// ① `None` growing + a bar arrives → start ONE `SourceBar` of the target
////    grade from that bar; finished is `None`;
//// ② `Some(bar)` growing + the bar's instant is still in the SAME UTC grid
////    period → keep the FIRST open, take MAX high, MIN low, the arriving
////    close as the LAST close, ADD its volume; finished is `None`;
//// ③ `Some(bar)` growing + the arriving instant REACHES the target period
////    boundary → emit that whole bar as `Some(finished)`, and set growing
////    back to `None`. The arriving bar opens the next period on the next
////    call, exactly as `working_databar_archived` sets `working_databar`
////    back to `None` (R39).
//// `interval.bucket_ends` (R29) is the UTC unix-second grid that says
//// whether the instant has reached the boundary; the boundary is a
//// PERIOD, never a count of bars.
////
//// WHO HOLDS `growing_target_sourcebar` (owner 2026-11-13, verbatim):
//// *"this field is in timeframe"*. It is `Timeframe.growing_target_sourcebar`,
//// NOT `Timeframe.working_databar`, and NOT a value floating at the input
//// boundary. `instrument.gleam` is the layer that reads and writes it:
//// that layer holds the `Interval` key and knows which timeframe gets
//// which grade, so it dispatches by `case interval` to ONE of the nine
//// functions below. The FUNCTIONS stay in this module (R50) — a call
//// site is not an owner. A `Timeframe` still has NO `interval` field:
//// the target grade is the variant of the growing `SourceBar` itself
//// (R37). R39 struck `fold_sourcebar(working, bar)` for accumulating
//// source bars INSIDE `working_databar`; this is a DIFFERENT field, and
//// only ONE whole finished `SourceBar` is emitted when the UTC grid
//// period is reached. That emission ends BEFORE `sourcebar.to_databar`
//// gives it ONE whole birth, and `databar_processing` receives a
//// `DataBar` whose period will never change again — which is exactly
//// why `DataBar` needs no variant.
////
//// THE TARGET GRADE IS IN THE FUNCTION NAME, NOT IN A PARAMETER. A
//// function called `five_second_to_one_minute` writes a
//// `SourceBarOneMinute`; it takes no `Interval` that a caller could claim
//// and that could disagree with the bars in hand (R23 / R37, owner:
//// *"你的左手不知道他是左还是右"*). The caller's `Interval` stays where it
//// belongs — the key of `Instrument.timeframes` — and meets the bar only
//// as the comparison `sourcebar.interval(bar)` in `sourcebar_gate`. Nine
//// functions below are the nine constructors of `Interval`; that closed
//// set is the whole list, not a guess.
////
//// DESIGN EVIDENCE, NOT A STRUCTURE TO COPY. glib never reached this part
//// — it stopped at the grade family and wrote no fold. seib did write one:
//// `joinNew(aBar, period)` fuses the candles of ONE period, `_fillIn`
//// takes the first open, max high, min low, latest close and summed
//// volume, and `dataflow_base.coffee:176` says *"方便在沒有某級別數據比如
//// hour數據時,採用合成方法形成數據,見joinNew"*. seib is OOP — a mutable
//// `@bar` living across calls — and glibe is pure type / functional: the
//// grade is a variant and the growing bar is a VALUE passed in and
//// returned. No seib class, field or method name is a model here (owner
//// 2026-11-13). `wap` and `count` are IB's own wire fields, kept because
//// R28 requires the native shape preserved; each gains a reader in THIS
//// module when its consumer exists.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.
//// These signatures are the DESIGN THOUGHT made checkable by the compiler,
//// not an implementation (owner 2026-11-13).

import gleam/option.{type Option}
import gleam/time/timestamp.{type Timestamp}
import glibe/api/sourcebar.{type SourceBar}

/// One IB realtime bar. IB's `realtimeBar` callback gives `time`, `open`,
/// `high`, `low`, `close`, `volume`, `wap` and `count`; all eight are kept.
/// `time` is IB's epoch-seconds folded to an absolute unix `Timestamp`
/// HERE at the boundary (R27 / R9), not a string to be split later.
pub type IbSourceBar {
  IbSourceBarFiveSecond(
    time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
    wap: Float,
    count: Int,
  )
}

/// ONE arriving 5-second bar accumulated toward ONE UTC one-minute period.
/// Reads `growing_target_sourcebar` and this one `arriving` bar; writes
/// `#(finished, growing)` — `Some(SourceBarOneMinute)` and `None` growing
/// only when the instant reaches the boundary, otherwise `None` finished
/// and the accumulated `Some(SourceBarOneMinute)`. `None` growing starts a
/// period with this bar. `sourcebar_gate` reads the finished bar's grade
/// back with `sourcebar.interval`.
pub fn five_second_to_one_minute(
  growing_target_sourcebar: Option(SourceBar),
  arriving: IbSourceBar,
) -> #(Option(SourceBar), Option(SourceBar)) {
  todo as "05-01: accumulate one 5s bar into growing_target_sourcebar; on the UTC one-minute boundary emit SourceBarOneMinute and clear growing"
}

/// ONE arriving 5-second bar accumulated toward ONE UTC three-minute
/// period; on the boundary it emits ONE whole `SourceBarThreeMinute`.
pub fn five_second_to_three_minute(
  growing_target_sourcebar: Option(SourceBar),
  arriving: IbSourceBar,
) -> #(Option(SourceBar), Option(SourceBar)) {
  todo as "05-01: accumulate one 5s bar into growing_target_sourcebar; on the UTC three-minute boundary emit SourceBarThreeMinute and clear growing"
}

/// ONE arriving 5-second bar accumulated toward ONE UTC fifteen-minute
/// period; on the boundary it emits ONE whole `SourceBarFifteenMinute`.
pub fn five_second_to_fifteen_minute(
  growing_target_sourcebar: Option(SourceBar),
  arriving: IbSourceBar,
) -> #(Option(SourceBar), Option(SourceBar)) {
  todo as "05-01: accumulate one 5s bar into growing_target_sourcebar; on the UTC fifteen-minute boundary emit SourceBarFifteenMinute and clear growing"
}

/// ONE arriving 5-second bar accumulated toward ONE UTC thirty-minute
/// period; on the boundary it emits ONE whole `SourceBarThirtyMinute`.
pub fn five_second_to_thirty_minute(
  growing_target_sourcebar: Option(SourceBar),
  arriving: IbSourceBar,
) -> #(Option(SourceBar), Option(SourceBar)) {
  todo as "05-01: accumulate one 5s bar into growing_target_sourcebar; on the UTC thirty-minute boundary emit SourceBarThirtyMinute and clear growing"
}

/// ONE arriving 5-second bar accumulated toward ONE UTC one-hour period;
/// on the boundary it emits ONE whole `SourceBarOneHour`.
pub fn five_second_to_one_hour(
  growing_target_sourcebar: Option(SourceBar),
  arriving: IbSourceBar,
) -> #(Option(SourceBar), Option(SourceBar)) {
  todo as "05-01: accumulate one 5s bar into growing_target_sourcebar; on the UTC one-hour boundary emit SourceBarOneHour and clear growing"
}

/// ONE arriving 5-second bar accumulated toward ONE UTC four-hour period;
/// on the boundary it emits ONE whole `SourceBarFourHour`.
pub fn five_second_to_four_hour(
  growing_target_sourcebar: Option(SourceBar),
  arriving: IbSourceBar,
) -> #(Option(SourceBar), Option(SourceBar)) {
  todo as "05-01: accumulate one 5s bar into growing_target_sourcebar; on the UTC four-hour boundary emit SourceBarFourHour and clear growing"
}

/// ONE arriving 5-second bar accumulated toward ONE UTC one-day period;
/// on the boundary it emits ONE whole `SourceBarOneDay`.
pub fn five_second_to_one_day(
  growing_target_sourcebar: Option(SourceBar),
  arriving: IbSourceBar,
) -> #(Option(SourceBar), Option(SourceBar)) {
  todo as "05-01: accumulate one 5s bar into growing_target_sourcebar; on the UTC one-day boundary emit SourceBarOneDay and clear growing"
}

/// ONE arriving 5-second bar accumulated toward ONE UTC one-week period;
/// on the boundary it emits ONE whole `SourceBarOneWeek`.
pub fn five_second_to_one_week(
  growing_target_sourcebar: Option(SourceBar),
  arriving: IbSourceBar,
) -> #(Option(SourceBar), Option(SourceBar)) {
  todo as "05-01: accumulate one 5s bar into growing_target_sourcebar; on the UTC one-week boundary emit SourceBarOneWeek and clear growing"
}

/// ONE arriving 5-second bar accumulated toward ONE UTC one-month period;
/// on the boundary it emits ONE whole `SourceBarOneMonth`.
pub fn five_second_to_one_month(
  growing_target_sourcebar: Option(SourceBar),
  arriving: IbSourceBar,
) -> #(Option(SourceBar), Option(SourceBar)) {
  todo as "05-01: accumulate one 5s bar into growing_target_sourcebar; on the UTC one-month boundary emit SourceBarOneMonth and clear growing"
}
