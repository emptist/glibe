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
//// R29: `sourcebar_closed` is a UTC unix-second grid. An exchange whose
//// grid is not UTC-aligned (US equities open 09:30 Eastern, one hour
//// earlier in summer) is a market-calendar debt: when a consumer for that
//// market exists it belongs to that market's rules with `tzif`, never to a
//// fixed offset here. R30: the web view's local wall clock is an
//// OUTPUT-side projection; it never changes this grid.
////
//// NAMING (owner 2026-11-15): the noun comes from the `SourceBar` Type,
//// the verb is `close`, and neither is `bucket` / `ends` / `started`. The
//// difference from `timeframe.working_databar_archived` is a difference
//// of VALUES: a `SourceBar` closes when its period completes, while
//// `working_databar` was already closed on entry and is archived when the
//// computation assigned to it is done. Owner's verbatim words are in
//// `docs/RULINGS.md` (2026-11-15 执行注记).
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

/// The closed set of all nine intervals, in the enum's declaration order.
/// This list is the one assertion about the system's interval set (glib
/// `interval.gleam:84-86`); config's completeness check and the round-trip test
/// read it. Adding a constructor makes `to_string` / `from_string` / `sourcebar_closed`
/// fail to compile until every arm names it, which is what keeps this list honest.
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

/// The exchange wire spelling. Boundary data, never a constructor name.
pub fn to_string(interval: Interval) -> String {
  case interval {
    IntervalOneMinute -> "1m"
    IntervalThreeMinute -> "3m"
    IntervalFifteenMinute -> "15m"
    IntervalThirtyMinute -> "30m"
    IntervalOneHour -> "1h"
    IntervalFourHour -> "4h"
    IntervalOneDay -> "1d"
    IntervalOneWeek -> "1wk"
    IntervalOneMonth -> "1mo"
  }
}

/// Read a wire spelling. Failure has nothing to say, so the error is `Nil`
/// (core §6); this is a codec, not a validation layer.
pub fn from_string(name: String) -> Result(Interval, Nil) {
  case name {
    "1m" -> Ok(IntervalOneMinute)
    "3m" -> Ok(IntervalThreeMinute)
    "15m" -> Ok(IntervalFifteenMinute)
    "30m" -> Ok(IntervalThirtyMinute)
    "1h" -> Ok(IntervalOneHour)
    "4h" -> Ok(IntervalFourHour)
    "1d" -> Ok(IntervalOneDay)
    "1wk" -> Ok(IntervalOneWeek)
    "1mo" -> Ok(IntervalOneMonth)
    _ -> Error(Nil)
  }
}

/// <**human: bar_close or bar_closes or bar_closed might be a better choice, but still need to check gleam official docs on naming convetions https://gleam.run/documentation/conventions-patterns-and-anti-patterns/**>
/// READS: the `Interval` key of `Instrument.timeframes` and one absolute
/// `Timestamp`. WRITES: one `Bool` — whether a `SourceBar` of that
/// interval has closed at that `Timestamp` on the UTC unix-second grid
/// (R27 / R29).
///
/// The readers are `ib/sourcebar.five_second_to_one_minute` and its eight
/// siblings: each takes ONE arriving five-second bar and uses this grid to
/// know whether a whole `SourceBar` of the target grade has closed.
/// `instrument.compose_ib_realtime_bar` dispatches them by the key held
/// here, which is why the boundary is a PERIOD and not a count of bars.
///
/// `sourcebar` names the one Type in this question and `closed` is the
/// verb IN the name. A candle's `open` means open and its `close` means
/// close; there is no other word for either. This is NOT
/// `timeframe.working_databar_archived`: that bar was already closed
/// before it entered the system, and `archived` names the end of the work
/// THIS system assigned to it (R39). No calendar, no offset, no system
/// clock.
pub fn sourcebar_closed(interval: Interval, timestamp: Timestamp) -> Bool {
  let #(seconds, _nanoseconds) =
    timestamp.to_unix_seconds_and_nanoseconds(timestamp)
  case interval {
    // A one-minute bar's every arrival closes it at the source; the finer
    // sub-daily grids are the unix-second modulo R27 names. Daily, weekly and
    // monthly keep their historical `True` — the UTC/market-calendar grid for
    // them is explicit deferred debt (R29 / plan 04-02), not invented here.
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
