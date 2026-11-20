//// The leaves — `YinLeaf` / `YangLeaf` and every function that builds or
//// reads one. Implements
//// `.planning/phases/02-domain-stream/02-02-PLAN.md`.
////
//// This module owns `DataLeaf` and the leaf's measurements: a function here
//// constructs a leaf, reads one of its three bars, or computes a value that
//// `timeframe.leaves` writes onto `working_databar`.
//// `timeframe.leaves` reads the
//// `Timeframe.growing_yin_leaf` / `growing_yang_leaf` fields, calls these
//// functions, and writes `yin_leaf_settled` / `yang_leaf_settled` and both
//// growing fields back onto the record. `timeframe.branches` then reads
//// those two settled fields (R40 / R41). This module is upstream of
//// `glibe/timeframe` and never imports it (R50).
////
//// R1 (owner, verbatim): *"a structure doesn't have an end_bar unless it is
//// ended"* — `end_bar` is `Option(DataBar)`, `None` while the leaf grows.
//// R4 (owner, verbatim) names `growing_yin_leaf.start_bar.idx` as the one
//// comparison that recognises a `YangBranch`; `start_bar` is the bar this
//// module writes and `timeframe.branches` reads. R6 (owner, verbatim):
//// *"closing is a length test, never a price test"* — `leaf_size` counts
//// bars, it never compares two prices.
////
//// WHO READS THESE FUNCTIONS: `timeframe.leaves` calls `next_yin_leaf` /
//// `next_yang_leaf` and writes the settled leaf into a field; `timeframe.branches`
//// calls `leaf_size` / `leaf_depth` / `leaf_cma` and `cma_recurrence` to
//// measure the riding leaf and to write its numbers onto the working bar
//// (R39). `timeframe.strategy` reads the corner bar. Each `todo as "..."`
//// says what its body has to write (R19); `gleam build --warnings-as-errors`
//// reports each one until it is written.
////
//// R19 status (2026-11-17): 8 bodies filled — `born_yin/born_yang`,
//// `start_bar/end_bar/corner_bar`, `leaf_size` (R6 idx arithmetic),
//// `cma_recurrence` (R3 forward step), and `leaf_depth` (R3 share of the
//// selected MA, R26 field now landed with its consumer). Three remain:
//// `leaf_cma` needs the twin's mean-reader fields on `DataBar` (not declared
//// in this design), and `next_yin_leaf` / `next_yang_leaf` need the
//// leaf-death/turn criterion that this skeleton's `///` does not specify.
//// Recorded in `docs/PENDING_DECISIONS.md` R.5; none is invented here.

import gleam/int
import gleam/option.{type Option, None, Some}
import glibe/databar.{type DataBar, DataBar}

/// The three bars a leaf is: the bar it opened on, the last bar that
/// belonged to it (`None` until it has ended, R1), and the extreme that moves
/// while it grows. `timeframe.leaves` writes all three; `timeframe.branches`
/// reads `start_bar` for recognition (R4) and `corner_bar` for the branch's
/// own `start_bar` (R4 / R5).
pub type DataLeaf {
  /// A yin leaf. `timeframe.leaves` holds it in `growing_yin_leaf`.
  YinLeaf(start_bar: DataBar, end_bar: Option(DataBar), corner_bar: DataBar)
  /// A yang leaf. `timeframe.leaves` holds it in `growing_yang_leaf`.
  YangLeaf(start_bar: DataBar, end_bar: Option(DataBar), corner_bar: DataBar)
}

/// A yin leaf born on this bar. `timeframe.leaves` calls it when
/// `growing_yin_leaf` is `None` and writes the result into that field. The
/// leaf starts and corners on that one whole bar and has no `end_bar` (R1).
pub fn born_yin(databar: DataBar) -> DataLeaf {
  YinLeaf(start_bar: databar, end_bar: None, corner_bar: databar)
}

/// A yang leaf born on this bar — the mirror of `born_yin`.
/// `timeframe.leaves` writes it into `growing_yang_leaf` (R1 / R2).
pub fn born_yang(databar: DataBar) -> DataLeaf {
  YangLeaf(start_bar: databar, end_bar: None, corner_bar: databar)
}

/// The bar a leaf opened on. `timeframe.branches` compares
/// `working_databar.idx` with `growing_yin_leaf.start_bar.idx` (R4);
/// `timeframe.strategy` reads the branch's `start_bar` that came from here.
pub fn start_bar(leaf: DataLeaf) -> DataBar {
  case leaf {
    YinLeaf(start_bar:, ..) -> start_bar
    YangLeaf(start_bar:, ..) -> start_bar
  }
}

/// The last bar that belonged to this leaf, or `None` while it grows (R1).
/// `timeframe.leaves` writes it from `last_bar` when the leaf settles.
pub fn end_bar(leaf: DataLeaf) -> Option(DataBar) {
  case leaf {
    YinLeaf(end_bar:, ..) -> end_bar
    YangLeaf(end_bar:, ..) -> end_bar
  }
}

/// The leaf's moving extreme. `timeframe.branches` takes a newly recognised
/// branch's `start_bar` from the settled leaf's `corner_bar` (R4 / R5).
pub fn corner_bar(leaf: DataLeaf) -> DataBar {
  case leaf {
    YinLeaf(corner_bar:, ..) -> corner_bar
    YangLeaf(corner_bar:, ..) -> corner_bar
  }
}

/// How many bars this leaf spans. `timeframe.branches` passes the bar in
/// hand because a growing leaf has no `end_bar` (R1), and compares this
/// count with `branch_exit_leaf_size` to close a branch (R5 / R6).
/// No price is read here.
pub fn leaf_size(leaf: DataLeaf, databar: DataBar) -> Int {
  // R6: a length test, never a price test; two idx subtracted, both ends
  // included. A growing leaf has no end_bar (R1), so the bar in hand is its
  // last bar. No walk of databar_list.
  let DataBar(idx: start_idx, ..) = start_bar(leaf)
  let last_idx = case end_bar(leaf) {
    Some(end) -> {
      let DataBar(idx: i, ..) = end
      i
    }
    None -> databar.idx
  }
  last_idx - start_idx + 1
}

/// The leaf's magnitude as a share, read off `start_bar` and `corner_bar`.
/// A view projection reads it for a settled leaf (R20 / R30); it is a
/// measurement, not the closing decision — that is `leaf_size` (R6).
pub fn leaf_depth(leaf: DataLeaf) -> Float {
  // R3: the top of a yin leaf is its start (the corner is the low); a yang
  // leaf mirrors it. Both are read off the two bars the leaf already names,
  // so nothing walks a series. A share, not a difference, so a 100-dollar
  // leaf sits next to a 60,000-dollar one.
  case leaf {
    YinLeaf(start_bar:, corner_bar:, ..) -> {
      let DataBar(sma_tiny: top, ..) = start_bar
      let DataBar(sma_tiny: corner, ..) = corner_bar
      { top -. corner } /. top
    }
    YangLeaf(start_bar:, corner_bar:, ..) -> {
      let DataBar(sma_tiny: floor, ..) = start_bar
      let DataBar(sma_tiny: top, ..) = corner_bar
      { top -. floor } /. top
    }
  }
}

/// One step of a leaf's running mean (R3). `leaf_cma` calls it with the
/// leaf's `start_bar.idx` and two field readers. READS `databar.idx` and
/// the previous bar's mean off the HEAD of `databar_list` (newest first,
/// O(1)); WRITES one `Float`. The List is never walked. A leaf born this
/// bar returns that bar's own raw value, never a zero sentinel (R3).
pub fn cma_recurrence(
  databar: DataBar,
  databar_list: List(DataBar),
  start_idx: Int,
  prev_cma_of: fn(DataBar) -> Float,
  raw_of: fn(DataBar) -> Float,
) -> Float {
  // R3: N_old = idx - start_idx is the number of bars already held. Born on
  // this bar (N_old = 0) returns its own raw value, never 0.0. Otherwise the
  // previous mean is read off the HEAD of the newest-first list (O(1)); the
  // list is never walked.
  let DataBar(idx: idx, ..) = databar
  let held = idx - start_idx
  case held {
    0 -> raw_of(databar)
    _ ->
      case databar_list {
        [] -> raw_of(databar)
        [previous, ..] -> {
          let numerator =
            prev_cma_of(previous) *. int.to_float(held) +. raw_of(databar)
          let denominator = int.to_float(held + 1)
          numerator /. denominator
        }
      }
  }
}

/// The leaf's running mean on this bar, of the selected moving average and
/// NOT of the price (R3, owner, verbatim: *"CMA 当然同样是选定均线的均值
/// 呀"*). `timeframe.leaves` calls it for both growing twins and writes
/// the result onto `working_databar` (R39); `cma_recurrence` is its one
/// step, with `leaf.start_bar.idx` as `start_idx`.
pub fn leaf_cma(
  databar: DataBar,
  databar_list: List(DataBar),
  leaf: DataLeaf,
) -> Float {
  todo as "05-01: pick the twin's mean reader and call cma_recurrence on the head of databar_list"
}

/// One bar of a yin leaf's life. `timeframe.leaves` reads
/// `growing_yin_leaf` and `working_databar`, then writes both returned
/// values back: `settled` into `yin_leaf_settled`, `growing` into
/// `growing_yin_leaf`. `settled` is `Some` only on the bar the leaf dies;
/// `last_bar` is the last bar that belonged to the old leaf, because the
/// killing bar belongs to the newborn (R1 / R5).
pub fn next_yin_leaf(
  databar: DataBar,
  leaf: DataLeaf,
  last_bar: DataBar,
) -> #(Option(DataLeaf), DataLeaf) {
  todo as "05-01: settle with end_bar last_bar, birth the next leaf on databar, move corner_bar otherwise"
}

/// The mirror of `next_yin_leaf` for a yang leaf. `timeframe.leaves` writes
/// the two returned values into `yang_leaf_settled` / `growing_yang_leaf`
/// (R2); `last_bar` has the same owner as there (R1 / R5).
pub fn next_yang_leaf(
  databar: DataBar,
  leaf: DataLeaf,
  last_bar: DataBar,
) -> #(Option(DataLeaf), DataLeaf) {
  todo as "05-01: settle with end_bar last_bar, birth the next leaf on databar, move corner_bar otherwise"
}
