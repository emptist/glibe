//// The ONE bar this system computes on, and the reads of its own values.
//// Implements `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// WORK OF THIS MODULE: hold `DataBar`, read the values it carries, and be
//// the one place those values are named. It does not compute an indicator,
//// settle a leaf or branch, decide a strategy, or archive a bar — those
//// belong to `timeframe`, `leaf`, `branch` and `trading/signal`. Its birth
//// belongs to the source: `sourcebar.to_databar` is the one conversion
//// (R39 / R42).
////
//// WHO WRITES: `sourcebar.to_databar` writes one whole bar from ONE
//// qualified `SourceBar` (R39); `timeframe.strategy` writes `signal` onto
//// the working bar with a record update (R10 / R11); each indicator step
//// writes its result onto the same bar as its consumer appears (R26 / R32).
//// WHO READS: `idx` is read by `leaf.leaf_size`,
//// `branch.recognised_this_bar` (R1 / R4) and `timeframe.bars_listed`;
//// `timestamp` is read by `interval.bucket_ends` (R27 / R29); `signal` is
//// read by the view projection of the archived bar (R33 / R30); OHLCV are
//// read by the indicator step (R28 / R39).
////
//// R39 (owner, verbatim): *"数据来到我们的系统，合格的sourcebar变成working
//// databar，从头到尾所有运算处理决策都在这个databar working中完成，之后他
//// 就被working databar archieved，这就是整个的系统，没有任何旁门左道。"*
//// One bar, born whole, computed on, archived. No bucket accumulator, no
//// second bar, no side door. Computed fields arrive on this type one at a
//// time with their real consumers (R26 / R32).
////
//// WHY NO TIME-SPAN VARIANTS — owner 2026-11-13 (verbatim): *"DataBar不需要
//// 变体的原因是，不需要转换，转换周期的工作是在SourceBar层面完成的，
//// sourcebar_gate()之前已经完成了合成工作，或者在 sourcebar_gate()中完成
//// 合成工作"*; *"通常有些源给你5秒钟的实时数据，但是不给你1分钟，3分钟，
//// 5分钟等等，你就需要自己合成。合成也很简单。等到了 databar_processing
//// 你按到手的都是弄好的 databar, 所以databar无需时间周期变体"*. A
//// variant exists to CARRY a period change, and NO function in this system
//// changes a `DataBar`'s period. A source that lacks a grade accumulates
//// ONE arriving bar at a time into `Timeframe.growing_target_sourcebar`,
//// dispatched by `instrument.compose_ib_realtime_bar` by its `Interval`
//// key to ONE of `ib/sourcebar.five_second_to_*`. That accumulation ends
//// before `sourcebar.to_databar` gives this bar its one whole birth.
//// So this type is ONE record, not a family, and holds no `interval`
//// field: its `Timeframe` is one interval's stream and the interval is the
//// key in `Instrument.timeframes` (R23 / R37; owner: *"你的左手不知道他是
//// 左还是右"*). `Timeframe.working_databar` is NOT an accumulator (R39).
////
//// R27: `timestamp` is a `gleam_time.Timestamp`, an absolute unix instant,
//// never a date string. R28: OHLCV are what the standard layer consumes
//// with unified meaning.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

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

/// `DataBar.idx`. `leaf.leaf_size` and `branch.recognised_this_bar` read it
/// (R1 / R4); `timeframe.bars_listed` counts the archived bars by it (R39).
pub fn idx(databar: DataBar) -> Int {
  todo as "05-01: read the index of this bar"
}

/// `DataBar.timestamp`. `interval.bucket_ends` reads it against the UTC
/// unix-second grid (R27 / R29); it is never a spelling to be parsed.
pub fn timestamp(databar: DataBar) -> Timestamp {
  todo as "05-01: read the absolute instant of this bar"
}

/// `DataBar.signal`. The decision `timeframe.strategy` wrote on this bar
/// (R10 / R11) is read by the view projection after archiving (R33 / R30).
pub fn signal(databar: DataBar) -> Signal {
  todo as "05-01: read the decision carried by this bar"
}
