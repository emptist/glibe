//// RED→GREEN tests for the DEMO bar source (03-03-PLAN main injection).
//// The target is a real consumer invariant: every generated bar must pass
//// `sourcebar.validate` (UC-60 — a rejected bar would never archive), be a
//// one-minute standard bar, and come back in the requested count.

import gleam/list
import glibe/api/interval.{IntervalOneMinute}
import glibe/api/sourcebar
import glibe/demo_feed

/// A DEMO bar is a valid one-minute standard SourceBar.
pub fn demo_bar_is_a_valid_one_minute_bar_test() {
  let bar = demo_feed.demo_bar(0)
  assert sourcebar.interval(bar) == IntervalOneMinute
  assert sourcebar.validate(bar) == Ok(bar)
  Nil
}

/// The DEMO sequence has exactly the requested number of bars, all valid.
pub fn demo_sourcebars_count_and_validity_test() {
  let bars = demo_feed.demo_sourcebars(30)
  assert list.length(bars) == 30
  assert list.all(bars, fn(bar) { sourcebar.validate(bar) == Ok(bar) })
  Nil
}

/// Bars are deterministic: the same index gives the same bar (pure, no clock).
pub fn demo_bar_is_deterministic_test() {
  assert demo_feed.demo_bar(7) == demo_feed.demo_bar(7)
  Nil
}
