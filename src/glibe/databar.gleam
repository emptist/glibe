/// The bar the streaming system works with — computed from SourceBar + indicators.
/// Used by timeframe, SMA, KDJ, Bollinger, Leaf, Branch.
///
/// Every field here is a measurement something computed. A bar carries no
/// verdict (those are derived in `trading/strategy`); it carries no leaf index
/// it cannot name (those come back when a bar can name the leaf it sits in).
/// Fields that no step ever wrote were removed — an uncomputed number printed
/// is a lie the reader cannot tell from a zero.
import gleam/float
import glibe/api/sourcebar.{type SourceBar}
import glibe/trading/signal.{type Signal, NoSignal}

pub type DataBar {
  DataBar(
    idx: Int,
    // global position in databar_list (0 = oldest settled bar)
    date: String,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
    // SMA series
    sma_tiny: Float,
    sma_small: Float,
    sma_medium: Float,
    sma_large: Float,
    sma_huge: Float,
    // Bollinger Bands
    bb_m: Float,
    bb_u3: Float,
    bb_l3: Float,
    bb_u2: Float,
    bb_u1: Float,
    bb_l1: Float,
    bb_l2: Float,
    // Welford σ recurrence carried on the bar (plan 31-02 §3); read by
    // bollinger.sigma/1 and extended O(1) by the next bar. Added to complete
    // the Welford port, which referenced them but never declared them.
    sigma_n: Int,
    sigma_mean: Float,
    sigma_m2: Float,
    // KDJ oscillator
    k: Float,
    d: Float,
    j: Float,
    m: Float,
    // Amortised-constant LLV/HHV extremes (plan 31-04, UC-64)
    kdj_h: Float,
    kdj_h_idx: Int,
    kdj_l: Float,
    kdj_l_idx: Int,
    // Leaf CMA — running mean of sma_tiny over the leaf the bar sits in
    yin_leaf_cma: Float,
    yang_leaf_cma: Float,
    // Strategy signal — a closed set, so a type (RULINGS.md R13)
    signal: Signal,
  )
}

/// **A source bar becomes the first bar of a bucket.** All indicators start at
/// their neutral seed so the first accepted bar of a run is honest, not a zero
/// masquerading as a measurement.
pub fn of_sourcebar(bar: SourceBar, idx: Int) -> DataBar {
  DataBar(
    idx:,
    date: bar.date,
    open: bar.open,
    high: bar.high,
    low: bar.low,
    close: bar.close,
    volume: bar.volume,
    sma_tiny: 0.0,
    sma_small: 0.0,
    sma_medium: 0.0,
    sma_large: 0.0,
    sma_huge: 0.0,
    bb_m: 0.0,
    bb_u3: 0.0,
    bb_l3: 0.0,
    bb_u2: 0.0,
    bb_u1: 0.0,
    bb_l1: 0.0,
    bb_l2: 0.0,
    sigma_n: 0,
    sigma_mean: 0.0,
    sigma_m2: 0.0,
    k: 50.0,
    d: 50.0,
    j: 50.0,
    m: 50.0,
    kdj_h: bar.high,
    kdj_h_idx: idx,
    kdj_l: bar.low,
    kdj_l_idx: idx,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
    signal: NoSignal,
  )
}

/// **Fold a source bar into the one already open.** The bucket keeps its first
/// open, grows its high and low, takes the latest close, and adds the volume.
/// Nothing about the indicators changes here — they are computed once the bucket
/// closes, on the final bar.
pub fn fold_sourcebar(working: DataBar, bar: SourceBar) -> DataBar {
  DataBar(
    ..working,
    date: bar.date,
    high: float.max(working.high, bar.high),
    low: float.min(working.low, bar.low),
    close: bar.close,
    volume: working.volume + bar.volume,
  )
}
