//// The interval — one bar's width, and the only thing that knows when a bar's
//// width has run out.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-02-PLAN.md`.
//// Ruling: `docs/RULINGS.md` R13 (closed sets are types), R19 (docs-first).
////
//// **One class, one module.** `Interval` and everything that is a question
//// about an interval live here: the codec the settings file is written in, and
//// the bucket-end test that decides whether a source bar closes the bar in
//// hand. The bucket test used to sit in `timeframe.gleam` next to the
//// `Timeframe` record; it touches no field of that record, and its absence
//// from there is what `scripts/no_timeframe_mixture.sh` enforces.
////
//// **The settings spelling lives here, once** — `to_string` is the name
//// `config.gleam` is written in. Binance spells the same interval differently,
//// and that is the adapter's vocabulary, not the type's: it stays in
//// `binance/`.
////
//// **Why nine variants.** Before this plan the closed set had seven, while
//// `config.gleam` named an eighth, four-hour interval as a `String`. A
//// `String` cannot be checked against a closed set, so the compiler could not
//// see the mismatch at all. Three-minute and four-hour spans are now values of
//// the type; adding a constructor makes exhaustiveness checking name every
//// place that must learn
//// about it — `all`, `to_string`, `from_string`, `bucket_ends`, and the Binance
//// adapter. That is the mechanism, not a grep.
////
//// **Still open, deliberately:** `bucket_ends` takes `date: String`. The
//// root-law fix is `gleam_time.Timestamp` at the ingest boundary
//// (`api/sourcebar.gleam`), which is a separate boundary plan. This module
//// does not invent a private time type to hide that debt.

import gleam/int
import gleam/string

/// **The closed set of time spans the system can reason about.** No `String`
/// may stand in for one of these. Adding a constructor forces every `case` in
/// the codebase to answer for it.
pub type Interval {
  /// 1 minute
  IntervalOneMinute
  /// 3 minutes
  IntervalThreeMinute
  /// 15 minutes
  IntervalFifteenMinute
  /// 30 minutes
  IntervalThirtyMinute
  /// 1 hour
  IntervalOneHour
  /// 4 hours
  IntervalFourHour
  /// 1 day
  IntervalOneDay
  /// 1 week
  IntervalOneWeek
  /// 1 month
  IntervalOneMonth
}

/// **Every interval the system cares about.** This is the one list; the codec
/// and the bucket-end test each cover every value in it.
pub fn all() -> List(Interval) {
  [
    IntervalOneMinute,
    IntervalThreeMinute,
    IntervalFifteenMinute,
    IntervalThirtyMinute,
    IntervalOneHour,
    IntervalFourHour,
    IntervalOneDay,
    IntervalOneWeek,
    IntervalOneMonth,
  ]
}

/// The name as it is written in the settings file.
pub fn to_string(interval: Interval) -> String {
  case interval {
    IntervalOneMinute -> "1m"
    IntervalThreeMinute -> "3m"
    IntervalFifteenMinute -> "15m"
    IntervalThirtyMinute -> "30m"
    IntervalOneHour -> "1h"
    IntervalFourHour -> "4h"
    IntervalOneDay -> "1d"
    IntervalOneWeek -> "1w"
    IntervalOneMonth -> "1M"
  }
}

/// The other direction — a settings file and a command line both need it.
/// An unknown spelling is `Error(Nil)`, never a `panic`.
pub fn from_string(name: String) -> Result(Interval, Nil) {
  case name {
    "1m" -> Ok(IntervalOneMinute)
    "3m" -> Ok(IntervalThreeMinute)
    "15m" -> Ok(IntervalFifteenMinute)
    "30m" -> Ok(IntervalThirtyMinute)
    "1h" -> Ok(IntervalOneHour)
    "4h" -> Ok(IntervalFourHour)
    "1d" -> Ok(IntervalOneDay)
    "1w" -> Ok(IntervalOneWeek)
    "1M" -> Ok(IntervalOneMonth)
    _ -> Error(Nil)
  }
}

// ============================================================================
// The bucket end — does this source bar close the bar in hand?
// ============================================================================

/// **True when the source bar that just arrived is the last of its bucket.**
///
/// The date is the one `sourcebar.normalize_date` handed over, so it is an
/// ISO-8601 timestamp (`"2024-01-15 09:30:00"`, `"2024-01-15T09:30:00"`) or a
/// bare date. The provider's epoch-milliseconds never reach this function.
///
/// Sub-daily buckets are aligned to the hour: a three-minute bucket ends at
/// `00, 03, 06, …`; a four-hour one at `00:00, 04:00, 08:00, …`. Daily,
/// weekly and monthly buckets keep their existing `True` behaviour, recorded
/// as design debt in plan 04-02.
pub fn bucket_ends(interval: Interval, date: String) -> Bool {
  case interval {
    IntervalOneMinute -> True
    IntervalThreeMinute -> bucket_ends_minutes(date, 3)
    IntervalFifteenMinute -> bucket_ends_minutes(date, 15)
    IntervalThirtyMinute -> bucket_ends_minutes(date, 30)
    IntervalOneHour -> bucket_ends_minutes(date, 60)
    IntervalFourHour -> bucket_ends_hours(date, 4)
    IntervalOneDay -> True
    IntervalOneWeek -> True
    IntervalOneMonth -> True
  }
}

/// A sub-daily bucket ends on the interval's own step: an hourly one on minute
/// `00`, a 15-minute one on `00`, `15`, `30`, `45`.
fn bucket_ends_minutes(date: String, step: Int) -> Bool {
  case minute_of(date) {
    Ok(minute) -> minute % step == 0
    // A timestamp the parser cannot read is not a bucket end. Folding the bar
    // in is the safe answer: it loses no data, it only waits.
    Error(Nil) -> False
  }
}

/// A multi-hour bucket ends on the hour-aligned grid: a four-hour one at
/// `00:00`, `04:00`, `08:00`, … An hourly bucket needs only the minute; this
/// one needs the hour too, so the private reader returns both fields.
fn bucket_ends_hours(date: String, step: Int) -> Bool {
  case clock_of(date) {
    Ok(#(hour, minute)) -> minute == 0 && hour % step == 0
    // An unreadable timestamp is not a bucket end: fold the bar in and wait.
    Error(Nil) -> False
  }
}

/// The hour and minute fields of an ISO-8601 timestamp, however the date and
/// the time are separated. Both `"2024-01-15 09:30:00"` and
/// `"2024-01-15T09:30:00"` read `#(9, 30)`; a bare `"2024-01-15"` reads none.
fn clock_of(date: String) -> Result(#(Int, Int), Nil) {
  let time_part = case string.split(date, " ") {
    [_date, time] -> time
    [one] ->
      case string.split(one, "T") {
        [_date, time] -> time
        _ -> ""
      }
    _ -> ""
  }
  case string.split(time_part, ":") {
    [hour, minute, ..] ->
      case int.parse(hour), int.parse(minute) {
        Ok(h), Ok(m) -> Ok(#(h, m))
        _, _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

/// The minute field of a timestamp. A bare date has no minute at all.
fn minute_of(date: String) -> Result(Int, Nil) {
  case clock_of(date) {
    Ok(#(_hour, minute)) -> Ok(minute)
    Error(Nil) -> Error(Nil)
  }
}
