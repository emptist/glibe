//// The ONE bar this system computes on, and the reads of its own values.
//// Implements `.planning/BRIEF.md`.
////
//// WORK OF THIS MODULE: hold `DataBar`, read the values it carries, and be
//// the one place those values are named. It does not compute an indicator,
//// settle a leaf or branch, decide a strategy, or archive a bar — those
//// belong to `timeframe`, `leaf`, `branch` and `trading/signal`. Its birth
//// belongs to the source: `sourcebar.to_databar` is the one conversion
//// (R39 / R42).
////
//// THE COMPLETE MEASUREMENT SET (owner 2026-11-23: *"所有技术指标，glib有的，
//// 你不能残缺不全"*): this bar carries EVERY field frozen glib's
//// `databar.gleam:40-77` computes — the five SMA series, the seven Bollinger
//// lines, the Welford σ state, all four KDJ values (K/D/J/M), the cached RSV
//// extremes and the YinLeaf / YangLeaf CMAs — not just the eight the chart
//// happens to draw. A field the chart does not consume is still a measurement
//// the model owns; "chart 不消费" is never a reason to omit one. The chart
//// projection (`dashboard.data_bar_to_chart_bar`) is a downstream reader, not
//// the reason a field exists.
////
//// WHO WRITES: `sourcebar.to_databar` writes one whole bar from ONE
//// qualified `SourceBar` (R39); `timeframe.strategy` writes `signal` onto
//// the working bar with a record update (R10 / R11); each indicator step
//// writes its result onto the same bar as its consumer appears (R26 / R32).
//// WHO READS: `idx` is read by `leaf.leaf_size`,
//// `branch.recognised_this_bar` (R1 / R4) and `timeframe.bars_listed`;
//// `timestamp` is read by `interval.sourcebar_closed` (R27 / R29); `signal`
//// is read by the view projection of the archived bar (R33 / R30); OHLCV
//// are read by the indicator step (R28 / R39).
////
//// R39 (owner, verbatim): *"数据来到我们的系统，合格的sourcebar变成working
//// databar，从头到尾所有运算处理决策都在这个databar working中完成，之后他
//// 就被working databar archieved，这就是整个的系统，没有任何旁门左道。"*
//// One bar, born whole, computed on, archived. No `SourceBar` accumulator, no
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
//// changes a `DataBar`'s period. A source that lacks an interval accumulates
//// ONE arriving bar at a time into `Timeframe.growing_target_sourcebar`,
//// dispatched by `instrument.compose_ib_realtime_bar` by its `Interval`
//// key to ONE of `ib/sourcebar.five_second_to_*`. That accumulation ends
//// before `sourcebar.to_databar` gives this bar its one whole birth.
//// So this type is ONE record, not a family, and holds no `interval`
//// field: its `Timeframe` is one interval's stream and the interval is the
//// key in `Instrument.timeframes` (R23 / R37; owner: *"你的左手不知道他是
//// 左还是右"*). `Timeframe.working_databar` is NOT an accumulator (R39).
////
//// R27: `timestamp` is a `gleam_time.Timestamp`, an absolute unix value,
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
    /// The five simple moving averages — the exact field set of frozen glib
    /// `databar.gleam:41-45`. `sma_tiny` is the series the YinLeaf / YangLeaf
    /// rides (R3, owner verbatim *"CMA 当然同样是选定均线的均值呀"*):
    /// `leaf.leaf_depth` and
    /// `branch.move_between` read it off the two bars a structure names. All
    /// five are WRITTEN by `timeframe.indicator` (O(1) add-arriving /
    /// subtract-leaving, glib `sma.gleam:60-108`); each is READ back on the next
    /// bar off the head of `databar_list` as the carried mean of its own window.
    /// `bb_m` selects one of the five via `config.sma_for_bbm`. R46 deleted the
    /// WINDOW-SIZE settings, not these fields. `sourcebar.to_databar` seeds all
    /// five at birth with a neutral 0.0.
    sma_tiny: Float,
    sma_small: Float,
    sma_medium: Float,
    sma_large: Float,
    sma_huge: Float,
    /// Bollinger Bands — the seven lines of frozen glib `databar.gleam:47-53`.
    /// `bb_m` is not recomputed here: it is the selected SMA centre
    /// (`sma_of(working, settings.sma_for_bbm)`); the outer u3/l3 are the
    /// `bb_multiplier·σ` edges (l3 floored before interpolation, glib
    /// `bollinger.gleam:199-225`) and u2/u1/l1/l2 are the 0.618/0.382 blends.
    /// WRITER: `timeframe.indicator`. READER: `indicator.single_bar_test`
    /// enforces the strict l3≤l2≤l1≤m≤u1≤u2≤u3 order; the chart consumes the
    /// two outer lines through `dashboard.data_bar_to_chart_bar`. Born 0.0.
    bb_m: Float,
    /// See `bb_m` — outer upper edge, the centre plus `bb_multiplier·σ`.
    bb_u3: Float,
    /// See `bb_m` — outer lower edge, floored to a positive fraction of the
    /// centre when it would fall to or below zero (glib `band_floor_ratio`).
    bb_l3: Float,
    /// See `bb_m` — upper inner line at 0.618·u3 + 0.382·m.
    bb_u2: Float,
    /// See `bb_m` — upper inner line at 0.382·u3 + 0.618·m.
    bb_u1: Float,
    /// See `bb_m` — lower inner line at 0.382·l3 + 0.618·m.
    bb_l1: Float,
    /// See `bb_m` — lower inner line at 0.618·l3 + 0.382·m.
    bb_l2: Float,
    /// Welford moving-window state for σ, carried bar to bar so
    /// `timeframe.indicator` updates it in O(1) (glib `bollinger.gleam:69-71`;
    /// R26/R32 — the indicator step is its real consumer). WRITER:
    /// `timeframe.indicator` on this bar; READER: `timeframe.indicator` on the
    /// next bar, off the HEAD of `databar_list` (never a full-window fold).
    /// Born neutral at `sourcebar.to_databar` and never read by the chart.
    sigma_n: Int,
    /// See `sigma_n` — the running mean of the closes in the σ window.
    sigma_mean: Float,
    /// See `sigma_n` — the running sum of squared deviations (Welford M2).
    sigma_m2: Float,
    /// KDJ oscillator — K, D, J and M of frozen glib `databar.gleam:60-63`.
    /// WRITER: `timeframe.indicator` (RSV from cached extremes, one alpha for
    /// K/D, J = 3K−2D, M the rolling mean of K — glib `kdj.gleam:15-72`).
    /// K/D/J are READ by the chart through `dashboard.data_bar_to_chart_bar`;
    /// M is the carried mean of K, read off the head of `databar_list` on the
    /// next bar for the O(1) `sma_stream` recurrence. Born 0.0.
    k: Float,
    d: Float,
    j: Float,
    /// See `k` — the mean of the last `kdj_m_period` K values (glib
    /// `kdj.gleam:50-63`), the fourth KDJ line; not drawn by the chart.
    m: Float,
    /// Cached highest-high of this bar's KDJ window and the idx carrying it.
    /// WRITER / READER: `timeframe.indicator` — the next bar rescans only when
    /// the bar leaving the window was this extreme (glib `kdj.gleam:74-114`,
    /// amortised O(1)). Born neutral; never read by the chart.
    kdj_h: Float,
    /// See `kdj_h` — the idx of the bar that set the cached high.
    kdj_h_idx: Int,
    /// Cached lowest-low of this bar's KDJ window and the idx carrying it.
    /// WRITER / READER: `timeframe.indicator`; mirror of `kdj_h`.
    kdj_l: Float,
    /// See `kdj_l` — the idx of the bar that set the cached low.
    kdj_l_idx: Int,
    /// The YinLeaf / YangLeaf CMAs of frozen glib `databar.gleam:76-77` (the
    /// four `inner_*` were retired there — Question 31 — and are not revived
    /// here). WRITER: `timeframe.leaves` via `leaf.leaf_cma` (R3: the mean of
    /// the selected `sma_tiny` series, not of price). READER: the chart through
    /// `dashboard.data_bar_to_chart_bar`, and the next bar's `leaf_cma` as the
    /// carried mean of the same YinLeaf / YangLeaf. Born 0.0.
    yin_leaf_cma: Float,
    yang_leaf_cma: Float,
  )
}

/// `DataBar.idx`. `leaf.leaf_size` and `branch.recognised_this_bar` read it
/// (R1 / R4); `timeframe.bars_listed` reads this value off the HEAD bar of
/// `databar_list` and returns `idx + 1` — it does not count the List (R39).<**human:here you should be careful: the bars_listed if is used anywhere, the funtion should be defined not to count but to calculate by the first one's idx in the databar_list, that is the idx + 1.**>
pub fn idx(databar: DataBar) -> Int {
  let DataBar(idx:, ..) = databar
  idx
}

/// `DataBar.timestamp`. `interval.sourcebar_closed` reads it against the UTC
/// unix-second grid (R27 / R29); it is never a spelling to be parsed.
pub fn timestamp(databar: DataBar) -> Timestamp {
  let DataBar(timestamp:, ..) = databar
  timestamp
}

/// `DataBar.signal`. The decision `timeframe.strategy` wrote on this bar
/// (R10 / R11) is read by the view projection after archiving (R33 / R30).
pub fn signal(databar: DataBar) -> Signal {
  let DataBar(signal:, ..) = databar
  signal
}
