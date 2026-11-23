//// RED tests for the `Move` type and `move.move_between`. Implements
//// `.planning/phases/02-domain-stream/02-02-PLAN.md` Task 3.
////
//// These pin the OBSERVABLE promises of the measurement:
////   - `move_between` returns a `Move` whose three fields are the magnitude
////     (a SHARE of the level it opened on, on `sma_tiny` — never price, R3),
////     the duration (a bar count, both ends inclusive, R6), and the per-bar
////     rate (magnitude / duration).
////   - The value NAMES its three numbers, so a caller reading only a type
////     signature can tell them apart (owner 2026-11-23: *"从move这个名字完全
////     看不出他 return的东西……但是这正好说明，命名太差了"*).
////   - The rules are ported from frozen glib `branch.gleam:229-236`
////     (`move_between`), which returned the same three numbers unnamed.

import gleam/time/timestamp
import glibe/databar.{type DataBar, DataBar}
import glibe/move
import glibe/trading/signal

/// A bar with a chosen idx and sma_tiny; everything else neutral. Same fixture
/// name and shape as the other domain tests (`bar_at`), so a value states only
/// what the assertion relies on.
fn bar_at(idx: Int, sma: Float) -> DataBar {
  DataBar(
    idx: idx,
    timestamp: timestamp.from_unix_seconds(1_499_040_000 + idx),
    open: sma,
    high: sma,
    low: sma,
    close: sma,
    volume: 0,
    signal: signal.SignalNoSignal,
    sma_tiny: sma,
    sma_small: sma,
    sma_medium: sma,
    sma_large: sma,
    sma_huge: sma,
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
    kdj_l: 0.0,
    kdj_h_idx: 0,
    kdj_l_idx: 0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
  )
}

/// `move_between` measures the span between two bars: magnitude as a SHARE of
/// the level it opened on (100 -> 125 over sma_tiny is 0.25, not 25), duration
/// as a bar count with both ends included (idx 0..4 is 5 bars), and the
/// per-bar rate (0.25 / 5 = 0.05).
pub fn move_between_names_its_three_numbers_test() {
  let m = move.move_between(bar_at(0, 100.0), bar_at(4, 125.0))
  assert m.magnitude == 0.25 as "share, not difference: (125-100)/100"
  assert m.duration == 5 as "both ends included: idx 0..4"
  assert m.per_bar == 0.05 as "rate: 0.25/5"
  Nil
}

/// A DOWNWARD move is a negative share, and a single-bar move has duration 1
/// (its two bars are the same bar counted both ends).
pub fn move_between_negative_and_single_bar_test() {
  let down = move.move_between(bar_at(0, 100.0), bar_at(3, 80.0))
  assert down.magnitude == -0.2 as "a fall is a negative share"
  assert down.duration == 4
  assert down.per_bar == -0.05

  let one = move.move_between(bar_at(7, 50.0), bar_at(7, 50.0))
  assert one.magnitude == 0.0
  assert one.duration == 1 as "one bar counted at both ends is one bar"
  assert one.per_bar == 0.0
  Nil
}

/// The type NAMES its three numbers, so a value can be read apart by field
/// rather than by position — the defect owner named: from the old
/// `#(Float, Float, Float)` no caller could tell the three apart.
pub fn move_fields_are_distinguishable_test() {
  let move.Move(magnitude:, duration:, per_bar:) =
    move.move_between(bar_at(2, 200.0), bar_at(9, 240.0))
  assert magnitude == 0.2
  assert duration == 8
  assert per_bar == 0.025
  Nil
}

/// `None` is never needed here: both bars are IN HAND, so the measurement
/// always exists — the absence lives one level up, in the branch windows
/// (`branch.start_end_move` / `branch.enter_exit_move`), where one end of a
/// move does not exist yet (R1).
pub fn move_between_needs_no_option_test() {
  let m = move.move_between(bar_at(0, 10.0), bar_at(1, 12.0))
  assert m.magnitude == 0.2
  assert m.duration == 2
  assert m.per_bar == 0.1
  Nil
}

/// The measurement is a plain value: two moves with the same numbers are equal
/// by field, so a caller may compare them without unpacking positions.
pub fn move_is_compared_by_its_fields_test() {
  let a = move.move_between(bar_at(0, 100.0), bar_at(4, 125.0))
  let b = move.move_between(bar_at(0, 100.0), bar_at(4, 125.0))
  assert a == b
  let c = move.move_between(bar_at(0, 100.0), bar_at(4, 130.0))
  assert a != c
  Nil
}
