//// RED tests for the two branch-life helpers `next_yang_branch` /
//// `next_yin_branch`. Implements `.planning/phases/02-domain-stream/
//// 02-02-PLAN.md` Task 1.
////
//// Rules ported from frozen glib `branch.gleam:346-424`: a branch is born on
//// recognition from the just-settled leaf's `corner_bar`; an existing branch
//// closes when the riding leaf's `leaf_size >= branch_exit_leaf_size` (a length
//// test, never a price test — R6); otherwise it is carried UNCHANGED. Closing
//// fills both late bars: `end_bar` = where it died (riding leaf's start),
//// `exit_bar` = the bar it was found dead on.

import gleam/option
import gleam/time/timestamp
import gleeunit
import glibe/branch
import glibe/databar.{type DataBar, DataBar}
import glibe/leaf
import glibe/trading/signal

pub fn main() {
  gleeunit.main()
}

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

/// A yang branch is born on recognition from the settled leaf's corner_bar,
/// with databar as enter_bar and no late bars.
pub fn next_yang_branch_born_on_recognition_test() {
  let prev = leaf.YinLeaf(bar_at(0, 10.0), option.None, bar_at(1, 9.0))
  let databar = bar_at(2, 9.5)
  let #(exited, growing) =
    branch.next_yang_branch(
      option.None,
      databar,
      option.Some(prev),
      prev,
      True,
      3,
    )
  assert exited == option.None
  let assert option.Some(b) = growing
  assert branch.start_bar(b) == leaf.corner_bar(prev)
  assert branch.enter_bar(b) == databar
  assert branch.end_bar(b) == option.None
  assert branch.exit_bar(b) == option.None
  Nil
}

/// Without recognition, no branch is born.
pub fn next_yang_branch_no_birth_without_recognition_test() {
  let prev = leaf.YinLeaf(bar_at(0, 10.0), option.None, bar_at(1, 9.0))
  let #(exited, growing) =
    branch.next_yang_branch(
      option.None,
      bar_at(2, 9.5),
      option.Some(prev),
      prev,
      False,
      3,
    )
  assert exited == option.None
  assert growing == option.None
  Nil
}

/// A growing yang branch closes when the riding leaf reaches exit_size: end_bar
/// is the riding leaf's start (where it died), exit_bar is this bar (found dead).
pub fn next_yang_branch_closes_on_leaf_size_test() {
  let b =
    branch.YangBranch(
      start_bar: bar_at(0, 10.0),
      enter_bar: bar_at(1, 10.0),
      end_bar: option.None,
      exit_bar: option.None,
    )
  // riding leaf starts at idx 1; databar idx 5 -> leaf_size = 5 (>= 3)
  let riding = leaf.YinLeaf(bar_at(1, 10.0), option.None, bar_at(2, 9.0))
  let databar = bar_at(5, 8.0)
  let #(exited, growing) =
    branch.next_yang_branch(
      option.Some(b),
      databar,
      option.None,
      riding,
      False,
      3,
    )
  let assert option.Some(closed) = exited
  assert branch.end_bar(closed) == option.Some(leaf.start_bar(riding))
  assert branch.exit_bar(closed) == option.Some(databar)
  assert growing == option.None
  Nil
}

/// Below exit_size the growing branch is carried UNCHANGED (not rebuilt).
pub fn next_yang_branch_carried_while_growing_test() {
  let b =
    branch.YangBranch(
      start_bar: bar_at(0, 10.0),
      enter_bar: bar_at(1, 10.0),
      end_bar: option.None,
      exit_bar: option.None,
    )
  // riding starts idx 1; databar idx 2 -> leaf_size = 2 (< 3)
  let riding = leaf.YinLeaf(bar_at(1, 10.0), option.None, bar_at(2, 9.0))
  let #(exited, growing) =
    branch.next_yang_branch(
      option.Some(b),
      bar_at(2, 9.5),
      option.None,
      riding,
      False,
      3,
    )
  assert exited == option.None
  assert growing == option.Some(b)
  Nil
}

/// The yin branch is the polarity mirror of the yang branch (glib 386-424):
/// born on recognition from a settled yang leaf, closes on the same length test.
pub fn next_yin_branch_born_and_closes_test() {
  let prev = leaf.YangLeaf(bar_at(0, 10.0), option.None, bar_at(1, 11.0))
  let born_databar = bar_at(2, 10.5)
  let #(exited, growing) =
    branch.next_yin_branch(
      option.None,
      born_databar,
      option.Some(prev),
      prev,
      True,
      3,
    )
  assert exited == option.None
  let assert option.Some(b) = growing
  assert branch.start_bar(b) == leaf.corner_bar(prev)
  assert branch.enter_bar(b) == born_databar

  // now grow and close it: riding yang leaf starts idx 1, databar idx 5
  let riding = leaf.YangLeaf(bar_at(1, 10.0), option.None, bar_at(2, 11.0))
  let close_bar = bar_at(5, 12.0)
  let #(closed, still) =
    branch.next_yin_branch(
      option.Some(b),
      close_bar,
      option.None,
      riding,
      False,
      3,
    )
  let assert option.Some(finished) = closed
  assert branch.end_bar(finished) == option.Some(leaf.start_bar(riding))
  assert branch.exit_bar(finished) == option.Some(close_bar)
  assert still == option.None
  Nil
}
