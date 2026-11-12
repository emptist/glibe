//// The closed set that keys `Instrument.timeframes`. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: `gleam_time.Timestamp`.
//// WRITES: `Interval`, the key of `Instrument.timeframes:
//// Dict(Interval, Timeframe)` (R23 / R37).
////
//// R37: the interval is the name the HOLDER gives, so it is a Dict key and
//// never a field of `Timeframe`. Owner: *"你的左手不知道他是左还是右"*.
//// R21: constructors are spelled out with the type name; owner's own list:
//// *"what is D1/H1/H4? … such as IntervalOneDay, IntervalFourHour, and so
//// on."* Wire codes like `"1h"` live ONLY in the codec / adapter.
//// R13: adding a constructor makes every incomplete `case` a compile error.
////
//// R29: `bucket_ends` is a UTC unix-second grid. An exchange whose grid is
//// not UTC-aligned (US equities open 09:30 Eastern, one hour earlier in
//// summer) is a market-calendar debt: when a consumer for that market
//// exists it belongs to that market's rules with `tzif`, never to a fixed
//// offset here. R30: the web view's local wall clock is an OUTPUT-side
//// projection; it never changes this grid.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/time/timestamp.{type Timestamp}

/// The intervals. Constructors carry the type name and spell the value out
/// in full (R21); exchange wire codes are not model names.
pub type Interval {
  /// One minute.
  IntervalOneMinute
  /// Three minutes.
  IntervalThreeMinute
  /// Fifteen minutes.
  IntervalFifteenMinute
  /// Thirty minutes.
  IntervalThirtyMinute
  /// One hour.
  IntervalOneHour
  /// Four hours.
  IntervalFourHour
  /// One day.
  IntervalOneDay
  /// One week.
  IntervalOneWeek
  /// One month.
  IntervalOneMonth
}

/// The exchange wire spelling. Boundary data, never a constructor name.
pub fn to_string(interval: Interval) -> String {
  todo as "05-01: model name to wire code"
}

/// Read a wire spelling. Failure has nothing to say, so the error is `Nil`
/// (core §6); this is a codec, not a validation layer.
pub fn from_string(name: String) -> Result(Interval, Nil) {
  todo as "05-01: wire code to model name"
}

/// Whether an absolute instant closes a bucket of this interval, on the UTC
/// unix-second grid (R27 / R29). No calendar, no offset, no system clock.
pub fn bucket_ends(interval: Interval, instant: Timestamp) -> Bool {
  todo as "05-01: UTC unix-second grid; market calendar is a later debt"
}
