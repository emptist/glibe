//// The interval — one bar's width, and the only thing that knows when a bar's
//// width has run out.
////
//// Plans: `.planning/phases/04-domain-cleanup/04-02-PLAN.md`,
//// `.planning/phases/04-domain-cleanup/04-06-PLAN.md`,
//// `.planning/phases/04-domain-cleanup/04-10-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R13 (closed sets are types), R19 (docs-first),
//// R21 (full constructor names), R27 (standard bar time is unix time),
//// R37 (identity is a key, not a field).
////
//// **R37 (2026-11-10)**: `Interval` is the KEY of `Instrument.timeframes`,
//// never a field of `Timeframe`. Owner 10:37, verbatim: *"你的左手不知道他是
//// 左还是右，同样，Timeframe不应该知道他是什么interval"*. The holder names
//// what it owns. `test/level_judgement_test.gleam` asserts that equal
//// `Timeframe` values under two different keys remain equal (04-10 plan).
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
//// **Why nine variants.** Before plan 04-02 the closed set had seven, while
//// `config.gleam` named an eighth, four-hour interval as a `String`. A
//// `String` cannot be checked against a closed set, so the compiler could not
//// see the mismatch at all. Three-minute and four-hour spans are now values of
//// the type; adding a constructor makes exhaustiveness checking name every
//// place that must learn about it — `all`, `to_string`, `from_string`,
//// `bucket_ends`, and the Binance adapter. That is the mechanism, not a grep.
////
//// **The bucket test now takes a `Timestamp` (R27).** It used to split a
//// `date: String` with `string.split`, then quietly answer `False` when the
//// split failed — the fallback that let epoch-milliseconds flow through
//// forever. The provider's `to_sourcebar` has already converted the wire
//// label to unix time, so this function is **integer arithmetic on unix
//// seconds**: no calendar, no offset, no string, no parser. A market whose
//// bucket grid is not UTC-aligned needs an IANA time-zone rule at its adapter
//// (daylight saving included), not a change to this closed set.

import gleam/time/timestamp.{type Timestamp}

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
/// `instant` is the standard bar's unix time (R27). A bucket ends on the
/// unix-second grid: a three-minute one at `seconds % 180 == 0`, a four-hour
/// one at `% 14400 == 0`. Sub-daily grids are therefore UTC-aligned by
/// construction; an exchange whose session grid follows a local, DST-shifting
/// clock is a market rule to be expressed at that provider's adapter, not a
/// `String` to be split here.
///
/// Daily, weekly and monthly buckets keep their existing `True` behaviour,
/// recorded as design debt in plan 04-02.
pub fn bucket_ends(interval: Interval, instant: Timestamp) -> Bool {
  let #(seconds, _nanoseconds) =
    timestamp.to_unix_seconds_and_nanoseconds(instant)
  case interval {
    IntervalOneMinute -> True
    IntervalThreeMinute -> seconds % 180 == 0
    IntervalFifteenMinute -> seconds % 900 == 0
    IntervalThirtyMinute -> seconds % 1800 == 0
    IntervalOneHour -> seconds % 3600 == 0
    IntervalFourHour -> seconds % 14_400 == 0
    IntervalOneDay -> True
    IntervalOneWeek -> True
    IntervalOneMonth -> True
  }
}
