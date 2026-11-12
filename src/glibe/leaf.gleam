//// The leaves — `YinLeaf` and `YangLeaf`, the two twins every bar belongs
//// to, grown one bar at a time as a fresh value each bar.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-13-PLAN.md` §5 (upstream
//// contracts). This module is an UPSTREAM of `glibe/timeframe`: the
//// pipeline's `leaves` step calls `init_*` / `next_*` / `leaf_cma` for the
//// working bar and writes the growing twins plus the pair that settled on
//// this bar into the record. A leaf NAMES bars; it never imports or threads
//// the `Timeframe` that holds them — that is why no cycle exists, and why
//// `engine.gleam`'s "split to break a cycle" reason was false.
////
//// The `////` above is a retrofit of the missing module doc (R19); the
//// definitions below are the existing, tested ones.

// The leaves — the two twins every bar belongs to, grown one bar at a time as
// a fresh value each bar. A leaf judges on the `sma_tiny` series, NOT the raw
// `high`/`low`: a yin leaf dies on a new HIGH `sma_tiny` and corners on a new
// LOW; a yang leaf mirrors it.
//
// **A leaf names bars; it carries no copy of their values.** Three bars: where
// it starts, where it ends, and where it corners. Every value the leaf is
// judged on is a field of one of those bars, read in O(1).
//
// **A leaf that has not ended has no `end_bar`.** *"a structure doesn't have an
// `end_bar` unless it is ended"* [user 2026-10-03]. A growing leaf's end is not
// a stored thing — it is the working bar, which is why `data_leaf_size` is told
// which bar that is. The alternative is a sentinel: a bar of zeros standing in
// for "nothing has happened yet", and a sentinel is a number that lies.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import glibe/databar.{type DataBar}

// ============================================================================
// Public Types
// ============================================================================

pub type DataLeaf {
  YinLeaf(start_bar: DataBar, end_bar: Option(DataBar), corner_bar: DataBar)
  YangLeaf(start_bar: DataBar, end_bar: Option(DataBar), corner_bar: DataBar)
}

// ============================================================================
// Accessors
// ============================================================================

pub fn leaf_start_bar(leaf: DataLeaf) -> DataBar {
  case leaf {
    YinLeaf(start_bar:, ..) -> start_bar
    YangLeaf(start_bar:, ..) -> start_bar
  }
}

/// **The bar the leaf last belonged to — and only a settled leaf has one.**
pub fn leaf_end_bar(leaf: DataLeaf) -> Option(DataBar) {
  case leaf {
    YinLeaf(end_bar:, ..) -> end_bar
    YangLeaf(end_bar:, ..) -> end_bar
  }
}

/// The one extreme that moves: the new low for a yin leaf, the new high for a
/// yang one. A leaf born this bar has `corner_bar` == `start_bar`.
pub fn leaf_corner_bar(leaf: DataLeaf) -> DataBar {
  case leaf {
    YinLeaf(corner_bar:, ..) -> corner_bar
    YangLeaf(corner_bar:, ..) -> corner_bar
  }
}

/// **How many bars the leaf spans** — a cardinality, both ends inclusive, so a
/// one-bar leaf has size 1. A growing leaf names no end, so the bar in hand
/// closes it: *"when you need the length of a growing thing, you use its
/// `start_bar.idx` and the `working_databar.idx`"* [user 2026-10-03].
pub fn data_leaf_size(leaf: DataLeaf, databar: DataBar) -> Int {
  case leaf_end_bar(leaf) {
    Some(end) -> end.idx - leaf_start_bar(leaf).idx + 1
    None -> databar.idx - leaf_start_bar(leaf).idx + 1
  }
}

/// **The leaf's depth** — corner to top, as a share of that top, so a
/// 700-dollar asset's leaf can be put next to a 60,000-dollar one's. Which end
/// is the top follows from the death rule and not from a test: a yin leaf dies
/// on the first bar above its start, so while it lives nothing in it is higher
/// — the top of a yin leaf is its `start_bar`, and its corner is the low.
pub fn leaf_depth(leaf: DataLeaf) -> Float {
  case leaf {
    YinLeaf(start_bar:, corner_bar:, ..) ->
      { start_bar.sma_tiny -. corner_bar.sma_tiny } /. start_bar.sma_tiny
    YangLeaf(start_bar:, corner_bar:, ..) ->
      { corner_bar.sma_tiny -. start_bar.sma_tiny } /. corner_bar.sma_tiny
  }
}

/// A leaf born on `bar` — start and corner on that bar, no end yet.
pub fn init_yin_leaf(bar: DataBar) -> DataLeaf {
  YinLeaf(start_bar: bar, end_bar: None, corner_bar: bar)
}

pub fn init_yang_leaf(bar: DataBar) -> DataLeaf {
  YangLeaf(start_bar: bar, end_bar: None, corner_bar: bar)
}

// ============================================================================
// Growth — one bar at a time
// ============================================================================

/// **Grow the yin leaf over `databar`.** Returns `#(settled, growing)`;
/// `settled` is `Some` only on the bar the leaf dies.
///
/// **The death threshold is the leaf's own start value**, and that is a law,
/// not an optimisation: the leaf dies on the first bar above the highest of its
/// bars, so a bar that would raise that highest kills the leaf instead of
/// joining it — the highest of a living yin leaf is always the `sma_tiny` of
/// its `start_bar`. That value is read off a bar the leaf already holds; no
/// list is walked.
///
/// **`last_bar` is named, not derived.** The killing bar belongs to the
/// newborn, so the settled leaf ends one bar before the bar that killed it. The
/// caller has that bar in hand.
pub fn next_yin_leaf(
  databar: DataBar,
  leaf: DataLeaf,
  last_bar: DataBar,
) -> #(Option(DataLeaf), DataLeaf) {
  case databar.sma_tiny >. leaf_start_bar(leaf).sma_tiny {
    True -> #(
      Some(YinLeaf(leaf_start_bar(leaf), Some(last_bar), leaf_corner_bar(leaf))),
      init_yin_leaf(databar),
    )
    False ->
      case databar.sma_tiny <. leaf_corner_bar(leaf).sma_tiny {
        True -> #(None, YinLeaf(leaf_start_bar(leaf), None, databar))
        False -> #(
          None,
          YinLeaf(leaf_start_bar(leaf), None, leaf_corner_bar(leaf)),
        )
      }
  }
}

/// The mirror of `next_yin_leaf` — a yang leaf dies on a new LOW `sma_tiny`
/// and corners on a new HIGH.
pub fn next_yang_leaf(
  databar: DataBar,
  leaf: DataLeaf,
  last_bar: DataBar,
) -> #(Option(DataLeaf), DataLeaf) {
  case databar.sma_tiny <. leaf_start_bar(leaf).sma_tiny {
    True -> #(
      Some(YangLeaf(leaf_start_bar(leaf), Some(last_bar), leaf_corner_bar(leaf))),
      init_yang_leaf(databar),
    )
    False ->
      case databar.sma_tiny >. leaf_corner_bar(leaf).sma_tiny {
        True -> #(None, YangLeaf(leaf_start_bar(leaf), None, databar))
        False -> #(
          None,
          YangLeaf(leaf_start_bar(leaf), None, leaf_corner_bar(leaf)),
        )
      }
  }
}

// ============================================================================
// The leaf CMA
// ============================================================================

/// **The running mean of `sma_tiny` over the leaf's own bars.**
///
/// It averages the ma, not the price — *"CMA 当然同样是选定均线的均值呀"* [user
/// 2026-09-15]: feeding it `close` is mimo's error. It is the forward
/// recurrence `(cma_old × N_old + raw) / (N_old + 1)` with
/// `N_old = databar.idx − start_bar.idx`, so it costs one step instead of a
/// walk over every bar the leaf has lived.
///
/// A leaf born this bar has no settled bars of its own, so its cma is that
/// bar's own value — never `0.0`.
pub fn leaf_cma(
  databar: DataBar,
  databar_list: List(DataBar),
  leaf: DataLeaf,
) -> Float {
  let start_idx = leaf_start_bar(leaf).idx
  let raw = databar.sma_tiny
  case start_idx == databar.idx {
    True -> raw
    False -> {
      let assert Ok(previous) = list.first(databar_list)
      let held = int.to_float(databar.idx - start_idx)
      case leaf {
        YinLeaf(_, _, _) ->
          { previous.yin_leaf_cma *. held +. raw } /. { held +. 1.0 }
        YangLeaf(_, _, _) ->
          { previous.yang_leaf_cma *. held +. raw } /. { held +. 1.0 }
      }
    }
  }
}
