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
//// ONE CLOSED SET, THREE PLACES. The nine constructors below ARE the nine
//// variants of `api/sourcebar.SourceBar` and the nine target grades a
//// provider must be able to write. A provider that serves them all
//// (Binance) maps one-to-one; a provider that serves only a finer native
//// granularity (IB's five seconds) writes one composition function per
//// constructor in ITS OWN module (`ib/sourcebar.five_second_to_*`). That
//// finer native span is a variant of THAT source's bar, never a tenth
//// `Interval` and never a tenth standard `SourceBar` variant. Owner
//// 2026-11-13: *"转换周期的工作是在SourceBar层面完成的"*, so the change
//// happens before a `DataBar` exists and `DataBar` needs no variant.
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

/// Whether an absolute instant closes ONE period of this interval on the
/// UTC unix-second grid (R27 / R29). A provider's composition reads it on
/// the ONE arriving five-second bar to say whether that instant has reached
/// the target period boundary: `ib/sourcebar.five_second_to_one_minute`
/// and its eight siblings are that reader, dispatched by
/// `instrument.compose_ib_realtime_bar` through the key held here, and
/// this grid is why their boundary is a PERIOD and not a count of bars.
/// It is NOT a test of
/// whether `Timeframe.working_databar` has closed — R39 leaves no
/// accumulating bar there. No calendar, no offset, no system clock.
pub fn bucket_ends(interval: Interval, instant: Timestamp) -> Bool {
  todo as "05-01: UTC unix-second grid; market calendar is a later debt"
}
