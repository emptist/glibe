// The interval — one bar's width, and the only thing that knows when a bar's
// width has run out.
//
// **One class, one module.** `Interval` and everything that is a question about
// an interval live here: the codec the settings file is written in, and the
// bucket-end test that decides whether a source bar closes the bar in hand.
// The bucket test used to sit in `timeframe.gleam` next to the `Timeframe`
// record; it touches no field of that record, and its absence from there is
// what `scripts/no_timeframe_mixture.sh` enforces.
//
// **The settings spelling lives here, once** — `to_string` is the name
// `config.gleam` is written in. Binance spells the same interval differently,
// and that is the adapter's vocabulary, not the type's: it stays in
// `binance/`.

import gleam/int
import gleam/string

pub type Interval {
  /// 1 minute
  MIN1
  /// 15 minutes
  MIN15
  /// 30 minutes
  MIN30
  /// 1 hour
  H1
  /// 1 day
  D1
  /// 1 week
  W1
  /// 1 month
  MO1
}

/// **Every interval the system cares about.** Adding one is one constructor
/// here, one line in `to_string`, one in `from_string`, and one row in
/// `config.gleam`.
pub fn all() -> List(Interval) {
  [MIN1, MIN15, MIN30, H1, D1, W1, MO1]
}

/// The name as it is written in the settings file.
pub fn to_string(interval: Interval) -> String {
  case interval {
    MIN1 -> "1m"
    MIN15 -> "15m"
    MIN30 -> "30m"
    H1 -> "1h"
    D1 -> "1d"
    W1 -> "1w"
    MO1 -> "1M"
  }
}

/// The other direction — a settings file and a command line both need it.
pub fn from_string(name: String) -> Result(Interval, Nil) {
  case name {
    "1m" -> Ok(MIN1)
    "15m" -> Ok(MIN15)
    "30m" -> Ok(MIN30)
    "1h" -> Ok(H1)
    "1d" -> Ok(D1)
    "1w" -> Ok(W1)
    "1M" -> Ok(MO1)
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
/// bare date. The provider's epoch-milliseconds never reach this function:
/// converting them at the boundary is what made an hourly timeframe close at
/// all — before that, `"1735704000000"` matched no minute field and every
/// hourly bar was folded into one bar forever.
pub fn bucket_ends(interval: Interval, date: String) -> Bool {
  case interval {
    MIN1 -> True
    MIN15 -> bucket_ends_minutes(date, 15)
    MIN30 -> bucket_ends_minutes(date, 30)
    H1 -> bucket_ends_minutes(date, 60)
    D1 -> True
    W1 -> True
    MO1 -> True
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

/// The minute field of a timestamp, however the date and the time are
/// separated. Both `"2024-01-15 09:30:00"` and `"2024-01-15T09:30:00"` read
/// `30`; a bare `"2024-01-15"` reads no minute at all.
fn minute_of(date: String) -> Result(Int, Nil) {
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
    [_hour, minute, ..] -> int.parse(minute)
    _ -> Error(Nil)
  }
}
