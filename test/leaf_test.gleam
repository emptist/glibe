//// RED tests for the two leaf-life helpers `next_yin_leaf` / `next_yang_leaf`.
//// Implements `.planning/phases/02-domain-stream/02-02-PLAN.md` Task 1.
////
//// Rules ported from frozen glib `leaf.gleam:207-247` (leaf law 3, seib
//// `anotherFish`): a yin leaf dies on a new HIGH `sma_tiny` and corners on a
//// new LOW; a yang leaf is the mirror. The death threshold is the leaf's own
//// start value, read off the bar the leaf holds — no list is walked. A leaf
//// that settles ends at `last_bar` (the killing bar belongs to the newborn).

import gleam/option
import gleam/time/timestamp
import gleeunit
import glibe/databar.{type DataBar, DataBar}
import glibe/leaf
import glibe/trading/signal

pub fn main() {
  gleeunit.main()
}

/// A DataBar with a chosen idx / sma_tiny; every other field neutral. The
/// sma_tiny is all the leaf-life rule reads (plus idx, carried unchanged).
fn bar_at(idx: Int, sma_tiny: Float) -> DataBar {
  DataBar(
    idx: idx,
    timestamp: timestamp.from_unix_seconds(1_499_040_000 + idx),
    open: 0.0,
    high: 0.0,
    low: 0.0,
    close: sma_tiny,
    volume: 0,
    signal: signal.SignalNoSignal,
    sma_tiny: sma_tiny,
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
    k: 0.0,
    d: 0.0,
    j: 0.0,
    m: 0.0,
    kdj_h: 0.0,
    kdj_h_idx: 0,
    kdj_l: 0.0,
    kdj_l_idx: 0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
  )
}

/// A yin leaf dies on a new HIGH sma_tiny above its start: the old leaf settles
/// ending at `last_bar` (not the killing bar), and a new one is born on the
/// killing bar with start = corner = that bar.
pub fn next_yin_leaf_dies_on_new_high_test() {
  let start = bar_at(0, 10.0)
  let corner = bar_at(1, 9.0)
  let yin = leaf.YinLeaf(start, option.None, corner)
  let killing = bar_at(2, 11.0)
  let last_bar = bar_at(1, 9.0)
  let #(settled, growing) = leaf.next_yin_leaf(killing, yin, last_bar)
  let assert option.Some(old) = settled
  assert leaf.end_bar(old) == option.Some(last_bar)
  assert leaf.start_bar(old) == start
  assert leaf.corner_bar(old) == corner
  // newborn starts and corners on the killing bar, no end
  assert leaf.start_bar(growing) == killing
  assert leaf.corner_bar(growing) == killing
  assert leaf.end_bar(growing) == option.None
  Nil
}

/// A yin leaf that makes a new LOW moves its corner to the bar, keeps its start
/// and stays growing (no settle).
pub fn next_yin_leaf_moves_corner_on_new_low_test() {
  let start = bar_at(0, 10.0)
  let corner = bar_at(1, 9.0)
  let yin = leaf.YinLeaf(start, option.None, corner)
  let lower = bar_at(2, 8.0)
  let #(settled, growing) = leaf.next_yin_leaf(lower, yin, bar_at(1, 9.0))
  assert settled == option.None
  assert leaf.start_bar(growing) == start
  assert leaf.corner_bar(growing) == lower
  assert leaf.end_bar(growing) == option.None
  Nil
}

/// Between the thresholds (sma_tiny neither above start nor below corner), the
/// yin leaf carries both bars unchanged.
pub fn next_yin_leaf_holds_when_no_extreme_test() {
  let start = bar_at(0, 10.0)
  let corner = bar_at(1, 9.0)
  let yin = leaf.YinLeaf(start, option.None, corner)
  let middle = bar_at(2, 9.5)
  let #(settled, growing) = leaf.next_yin_leaf(middle, yin, bar_at(1, 9.0))
  assert settled == option.None
  assert leaf.start_bar(growing) == start
  assert leaf.corner_bar(growing) == corner
  Nil
}

/// A yang leaf is the mirror: it dies on a new LOW sma_tiny, corners on a new
/// HIGH. Same settle/rebirth shape with the polarities swapped.
pub fn next_yang_leaf_dies_on_new_low_test() {
  let start = bar_at(0, 10.0)
  let corner = bar_at(1, 11.0)
  let yang = leaf.YangLeaf(start, option.None, corner)
  let killing = bar_at(2, 9.0)
  let last_bar = bar_at(1, 11.0)
  let #(settled, growing) = leaf.next_yang_leaf(killing, yang, last_bar)
  let assert option.Some(old) = settled
  assert leaf.end_bar(old) == option.Some(last_bar)
  assert leaf.start_bar(old) == start
  assert leaf.corner_bar(old) == corner
  assert leaf.start_bar(growing) == killing
  assert leaf.corner_bar(growing) == killing
  assert leaf.end_bar(growing) == option.None
  Nil
}

/// A yang leaf that makes a new HIGH moves its corner; stays growing.
pub fn next_yang_leaf_moves_corner_on_new_high_test() {
  let start = bar_at(0, 10.0)
  let corner = bar_at(1, 11.0)
  let yang = leaf.YangLeaf(start, option.None, corner)
  let higher = bar_at(2, 12.0)
  let #(settled, growing) = leaf.next_yang_leaf(higher, yang, bar_at(1, 11.0))
  assert settled == option.None
  assert leaf.start_bar(growing) == start
  assert leaf.corner_bar(growing) == higher
  Nil
}
