//// The bar the streaming system works with — a `SourceBar` born whole, plus
//// the indicators computed on it.
////
//// Plans: `.planning/phases/04-domain-cleanup/04-06-PLAN.md`,
//// `.planning/phases/04-domain-cleanup/04-13-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R27 (a bar's time is a unix-time `Timestamp`),
//// R39 (one qualified source bar becomes ONE whole working databar), R13
//// (a closed set is a type).
////
//// **Birth belongs to the SOURCE, not to the bar.** `sourcebar.to_databar`
//// in `glibe/api/sourcebar.gleam` is the one conversion. Owner 2026-10-12,
//// recorded in `glib/src/glib/timeframe.gleam:25`: a raw bar becoming a
//// `DataBar` is the source's law, not the bar's and not a pipeline step;
//// phase 42 deleted the `fold` half — *"a bar is born whole on arrival, and
//// a source bar that repeats the bar in hand is not a second half of
//// anything"*. glibe had put the conversion here as `of_sourcebar` and kept
//// a `fold_sourcebar` bucket accumulator beside it. Both are gone (R39):
//// this module holds ONLY the shape of a `DataBar`, and importing it one way
//// from `sourcebar.gleam` keeps the dependency a DAG.
////
//// `timestamp` is an absolute instant, not a provider's date spelling. It is
//// formatted only at the output edge (`export/csv.gleam`).
////
//// Every field here is a measurement something computed. A bar carries no
//// verdict except the `Signal` a strategy wrote on it, and no leaf index it
//// cannot name. Fields that no step ever wrote were removed — an uncomputed
//// number printed is a lie the reader cannot tell from a zero.

import gleam/time/timestamp.{type Timestamp}
import glibe/trading/signal.{type Signal}

/// One bar of the working stream. `idx` is its position in `databar_list`
/// (0 = the first bar), fixed at birth by `sourcebar.to_databar`.
pub type DataBar {
  DataBar(
    idx: Int,
    // global position in databar_list (0 = oldest settled bar)
    timestamp: Timestamp,
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
