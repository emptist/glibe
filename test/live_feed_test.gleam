//// RED→GREEN tests for the live feed's pure filtering. Implements Task 3 of
//// `.planning/phases/05-live-feed/05-01-PLAN.md`.
////
//// The "frequent read, finite accept" rule is pinned without network: a
//// boundary timestamp and a batch of real kline bars decide which bars are
//// injected. No bar is re-injected, so the chart never draws a candle twice.

import gleam/option.{None, Some}
import gleam/string
import gleam/time/timestamp
import glibe/api/sourcebar.{type SourceBar, SourceBarOneMinute}
import glibe/live_feed

fn bar_at(epoch_seconds: Int) -> SourceBar {
  SourceBarOneMinute(
    timestamp: timestamp.from_unix_seconds(epoch_seconds),
    open: 100.0,
    high: 101.0,
    low: 99.0,
    close: 100.5,
    volume: 10,
  )
}

/// With no boundary seen yet, the whole batch passes, in its own order.
pub fn no_boundary_passes_all_test() {
  let bars = [bar_at(100), bar_at(200), bar_at(300)]
  assert live_feed.newer_than(bars, None) == bars
  Nil
}

/// Only bars strictly after the boundary pass; the equal one is refused.
pub fn only_newer_bars_pass_test() {
  let bars = [bar_at(100), bar_at(200), bar_at(300)]
  assert live_feed.newer_than(bars, Some(timestamp.from_unix_seconds(200)))
    == [bar_at(300)]
  Nil
}

/// A batch entirely at or before the boundary yields nothing (no re-inject).
pub fn no_new_bars_yields_empty_test() {
  let bars = [bar_at(100), bar_at(200)]
  assert live_feed.newer_than(bars, Some(timestamp.from_unix_seconds(200)))
    == []
  Nil
}

/// The boundary advances to the newest accepted bar; a batch with nothing
/// new leaves it unchanged.
pub fn boundary_advances_to_newest_test() {
  let bars = [bar_at(100), bar_at(300), bar_at(200)]
  assert live_feed.advance_boundary(bars, None)
    == Some(timestamp.from_unix_seconds(300))
  assert live_feed.advance_boundary(
      [bar_at(100)],
      Some(timestamp.from_unix_seconds(300)),
    )
    == Some(timestamp.from_unix_seconds(300))
  Nil
}

/// A running feed's log line shows the real count and the newest bar's UTC+8
/// wall-clock time (epoch 1795543920 = 2026-11-25T02:12:00+08:00, verified).
pub fn describe_live_shows_count_and_utc8_time_test() {
  let line =
    live_feed.describe_live(
      60,
      Some(timestamp.from_unix_seconds(1_795_543_920)),
    )
  assert string.contains(line, "60 real bars")
  assert string.contains(line, "2026-11-25T02:12:00+08:00")
  Nil
}
