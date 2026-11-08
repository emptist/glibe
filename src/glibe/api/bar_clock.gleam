//// The bar clock — the provider's wall-clock reading, parsed once at the
//// ingest boundary.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-06-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R13 (closed sets and errors are types),
//// R19 (docs-first / TDD), R22 (a name is not the thing named),
//// R23 (one fact in one place), R26 (types appear when a consumer needs one).
////
//// **What this is, and is not.** Binance sends `openTime` as milliseconds since
//// the UTC epoch; a JSON bar or a replay file sends `"2024-01-15 09:30:00"`.
//// Both are *time labels*, and every consumer downstream wants the same thing:
//// the hour and minute of that label, to decide whether a bucket ends. A
//// `String` standing in for that reading forced `interval.bucket_ends` to split
//// it with `string.split`, then silently answer `False` when the split failed —
//// the same fallback that let epoch-milliseconds flow through forever in the
//// historical bug. Here the label becomes a type once, at the boundary, and a
//// failure becomes a **rejection**, not a default.
////
//// **Why not `Timestamp` directly.** `gleam_time.Timestamp` is an absolute
//// instant: reading a wall clock from one requires an offset. Which offset a
//// provider's label uses belongs to exchange/market rules, which have no type
//// and no consumer yet (R26). Naming the *wall-clock reading* is the honest
//// boundary; `to_timestamp` takes the offset explicitly so that when a market
//// rule needs an instant, that consumer supplies it instead of a utility
//// function quietly assuming UTC for every market. Epoch milliseconds are the
//// one exception: they already are an absolute UTC instant, so their reading
//// is taken at `calendar.utc_offset`.
////
//// **Where strings live.** Wire decoders and the CSV/HTML output may spell a
//// clock as a `String`. Nothing in the domain splits one; `parse` and `to_iso`
//// are the two edges of this module.

import gleam/dynamic/decode
import gleam/int
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp

/// **A provider's parsed wall-clock reading.** The parts are `gleam_time`'s own
/// calendar types, not hand-rolled integers: a month is `calendar.Month`, not
/// `Int`. A `BarClock` is deliberately *not* an absolute instant.
pub type BarClock {
  BarClock(date: calendar.Date, time: calendar.TimeOfDay)
}

/// **The three ways a provider time label can fail to be a bar clock.**
/// An error is a value, never a `String` to be parsed again.
pub type BarClockError {
  /// Not epoch milliseconds and not a timestamp with a time of day.
  UnreadableTimestamp(raw: String)
  /// A bare `"2024-01-15"`: an OHLC bar has a time of day.
  TimestampHasNoTimeOfDay(raw: String)
  /// Parsed, but a field is outside its calendar range.
  TimestampFieldOutOfRange(raw: String)
}

/// **Parse a provider time label once, at the ingest boundary.**
///
/// Accepts epoch milliseconds (`"1705309200000"`), a space-separated ISO
/// timestamp (`"2024-01-15 09:00:00"`) and a `T`-separated one
/// (`"2024-01-15T09:00:00"`). Anything else is `Error(BarClockError)` and the
/// bar must be rejected: there is no safe default clock to fold a bar into.
pub fn parse(raw: String) -> Result(BarClock, BarClockError) {
  case int.parse(raw) {
    Ok(ms) ->
      case ms > 1_000_000_000_000 {
        True -> Ok(from_epoch_ms(ms))
        False -> parse_iso(raw)
      }
    Error(_) -> parse_iso(raw)
  }
}

/// **The output spelling of a clock** — the one CSV rows and HTML views use.
/// Formatting happens at the output edge, never inside a domain function. Bars
/// are second-precision, so nanoseconds are not written.
pub fn to_iso(clock: BarClock) -> String {
  let date = clock.date
  let time = clock.time
  int.to_string(date.year)
  <> "-"
  <> pad(month_number(date.month))
  <> "-"
  <> pad(date.day)
  <> " "
  <> pad(time.hours)
  <> ":"
  <> pad(time.minutes)
  <> ":"
  <> pad(time.seconds)
}

/// **An absolute instant, once a caller can say which offset applies.**
/// The offset is a parameter because the exchange calendar owns it (R26), not
/// this module. `calendar.utc_offset` is the value for an instant that is
/// already UTC.
pub fn to_timestamp(
  clock: BarClock,
  offset: duration.Duration,
) -> timestamp.Timestamp {
  timestamp.from_calendar(date: clock.date, time: clock.time, offset:)
}

/// The diagnostic spelling of a parse error, used by decoders and logs.
pub fn error_to_string(error: BarClockError) -> String {
  case error {
    UnreadableTimestamp(raw) -> "unreadable bar timestamp: " <> raw
    TimestampHasNoTimeOfDay(raw) -> "bar timestamp has no time of day: " <> raw
    TimestampFieldOutOfRange(raw) -> "bar timestamp field out of range: " <> raw
  }
}

/// **A decoder for a `date` field**, so JSON bars are parsed at the wire edge.
/// An unreadable label is a decode error, not a bar carrying a placeholder.
pub fn decoder() -> decode.Decoder(BarClock) {
  use raw <- decode.then(decode.string)
  case parse(raw) {
    Ok(clock) -> decode.success(clock)
    Error(error) -> decode.failure(placeholder_clock(), error_to_string(error))
  }
}

/// The value `decode.failure` needs to satisfy the type checker. A failing
/// decoder always carries an error, so this value is never returned to a caller.
fn placeholder_clock() -> BarClock {
  BarClock(
    date: calendar.Date(year: 1970, month: calendar.January, day: 1),
    time: calendar.TimeOfDay(hours: 0, minutes: 0, seconds: 0, nanoseconds: 0),
  )
}

/// Epoch milliseconds are an absolute UTC instant; read its UTC wall clock.
/// `gleam_time` does the civil-date arithmetic, replacing the handwritten
/// `civil_from_days` that used to live in `api/sourcebar.gleam`.
fn from_epoch_ms(ms: Int) -> BarClock {
  let seconds = ms / 1000
  let nanoseconds = { ms % 1000 } * 1_000_000
  let instant =
    timestamp.from_unix_seconds_and_nanoseconds(seconds, nanoseconds)
  let #(date, time) = timestamp.to_calendar(instant, calendar.utc_offset)
  BarClock(date:, time:)
}

/// Split the one wire spelling into a date part and a time part. A label with
/// no time part is classified as a bare date when its date part is readable,
/// and as unreadable otherwise — the two rejections are different facts.
fn split_date_time(raw: String) -> Result(#(String, String), BarClockError) {
  case string.split(raw, " ") {
    [date_part, time_part, ..] -> Ok(#(date_part, time_part))
    [one] ->
      case string.split(one, "T") {
        [date_part, time_part, ..] -> Ok(#(date_part, time_part))
        _ -> classify_missing_time(raw, one)
      }
    _ -> Error(UnreadableTimestamp(raw))
  }
}

/// A bare `"2024-01-15"` is a readable date with no clock; `"not-a-date"` is
/// neither. Both are rejected, with different reasons.
fn classify_missing_time(
  raw: String,
  one: String,
) -> Result(#(String, String), BarClockError) {
  case string.split(one, "-") {
    [year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(_), Ok(_), Ok(_) -> Error(TimestampHasNoTimeOfDay(raw))
        _, _, _ -> Error(UnreadableTimestamp(raw))
      }
    _ -> Error(UnreadableTimestamp(raw))
  }
}

/// Read `YYYY-MM-DD` and reject fields outside their calendar ranges.
fn parse_date(
  part: String,
  raw: String,
) -> Result(calendar.Date, BarClockError) {
  case string.split(part, "-") {
    [year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(y), Ok(m), Ok(d) ->
          case y > 0 && in_range(m, 1, 12) && in_range(d, 1, 31) {
            True ->
              case month_from_number(m) {
                Ok(month_value) ->
                  Ok(calendar.Date(year: y, month: month_value, day: d))
                Error(_) -> Error(TimestampFieldOutOfRange(raw))
              }
            False -> Error(TimestampFieldOutOfRange(raw))
          }
        _, _, _ -> Error(UnreadableTimestamp(raw))
      }
    _ -> Error(UnreadableTimestamp(raw))
  }
}

/// Read `HH:MM:SS`; a field outside its range is not a wall clock.
fn parse_time(
  part: String,
  raw: String,
) -> Result(calendar.TimeOfDay, BarClockError) {
  case string.split(part, ":") {
    [hour, minute, second, ..] ->
      case int.parse(hour), int.parse(minute), int.parse(second) {
        Ok(h), Ok(m), Ok(s) ->
          case in_range(h, 0, 23) && in_range(m, 0, 59) && in_range(s, 0, 60) {
            True ->
              Ok(calendar.TimeOfDay(
                hours: h,
                minutes: m,
                seconds: s,
                nanoseconds: 0,
              ))
            False -> Error(TimestampFieldOutOfRange(raw))
          }
        _, _, _ -> Error(UnreadableTimestamp(raw))
      }
    _ -> Error(UnreadableTimestamp(raw))
  }
}

/// Assemble the clock from its two parts; a failure anywhere is a rejection.
fn parse_iso(raw: String) -> Result(BarClock, BarClockError) {
  use #(date_part, time_part) <- result.try(split_date_time(raw))
  use date <- result.try(parse_date(date_part, raw))
  use time <- result.try(parse_time(time_part, raw))
  Ok(BarClock(date:, time:))
}

/// The `Month` closed set, in wire order. Exhaustiveness checking names this
/// place whenever `gleam_time` adds a month — which it cannot, but that is the
/// point: the mapping is total, not a lookup that can fail silently.
fn month_from_number(number: Int) -> Result(calendar.Month, Nil) {
  case number {
    1 -> Ok(calendar.January)
    2 -> Ok(calendar.February)
    3 -> Ok(calendar.March)
    4 -> Ok(calendar.April)
    5 -> Ok(calendar.May)
    6 -> Ok(calendar.June)
    7 -> Ok(calendar.July)
    8 -> Ok(calendar.August)
    9 -> Ok(calendar.September)
    10 -> Ok(calendar.October)
    11 -> Ok(calendar.November)
    12 -> Ok(calendar.December)
    _ -> Error(Nil)
  }
}

/// The numeric month of a `calendar.Month`, for the ISO output spelling.
fn month_number(month: calendar.Month) -> Int {
  case month {
    calendar.January -> 1
    calendar.February -> 2
    calendar.March -> 3
    calendar.April -> 4
    calendar.May -> 5
    calendar.June -> 6
    calendar.July -> 7
    calendar.August -> 8
    calendar.September -> 9
    calendar.October -> 10
    calendar.November -> 11
    calendar.December -> 12
  }
}

/// Inclusive range check shared by date and time fields.
fn in_range(value: Int, low: Int, high: Int) -> Bool {
  value >= low && value <= high
}

/// Two-digit zero padding for the output spelling only.
fn pad(number: Int) -> String {
  case number < 10 {
    True -> "0" <> int.to_string(number)
    False -> int.to_string(number)
  }
}
