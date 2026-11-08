//// Tests for the ingest boundary: a provider time label becomes a `BarClock`
//// once, or is rejected. Plan: `.planning/phases/04-domain-cleanup/04-06-PLAN.md`.
//// These tests are written before the bodies of `api/bar_clock.gleam` (R19).

import gleam/json
import gleam/time/calendar
import gleam/time/timestamp
import glibe/api/bar_clock

/// A space-separated ISO label parses into `gleam_time` calendar parts.
pub fn parses_space_separated_timestamp_test() {
  let assert Ok(clock) = bar_clock.parse("2024-01-15 09:30:00")
    as "a normal ISO bar timestamp parses"
  assert clock.date.year == 2024 as "year"
  assert clock.date.month == calendar.January as "month is a Month, not an Int"
  assert clock.date.day == 15 as "day"
  assert clock.time.hours == 9 as "hour"
  assert clock.time.minutes == 30 as "minute"
  assert clock.time.seconds == 0 as "second"
}

/// A `T`-separated label is the same clock, not a second format to maintain.
pub fn parses_t_separated_timestamp_test() {
  let assert Ok(clock) = bar_clock.parse("2024-01-15T00:00:00")
    as "an ISO T timestamp parses"
  assert clock.time.hours == 0 as "midnight"
  assert clock.time.minutes == 0 as "on the hour"
}

/// Epoch milliseconds are an absolute UTC instant: read its UTC wall clock.
pub fn parses_epoch_milliseconds_test() {
  let assert Ok(clock) = bar_clock.parse("1705309200000")
    as "Binance openTime parses"
  assert clock.date.year == 2024 as "2024"
  assert clock.date.month == calendar.January as "January"
  assert clock.date.day == 15 as "the 15th"
  assert clock.time.hours == 9 as "09 UTC"
  assert clock.time.minutes == 0 as "00 UTC"
}

/// A bare date is NOT a bar time: an OHLC bar has a time of day. This replaces
/// the old `bucket_ends(..., "2024-01-15") == False` fallback.
pub fn rejects_bare_date_test() {
  let assert Error(bar_clock.TimestampHasNoTimeOfDay(_)) =
    bar_clock.parse("2024-01-15")
    as "a bare date has no time of day"
}

/// Garbage is rejected, never folded into an open bucket with a default clock.
pub fn rejects_unreadable_label_test() {
  let assert Error(bar_clock.UnreadableTimestamp(_)) =
    bar_clock.parse("not-a-date")
    as "unreadable labels are errors"
}

/// Parsed but out-of-range fields are caught at the boundary.
pub fn rejects_out_of_range_field_test() {
  let assert Error(bar_clock.TimestampFieldOutOfRange(_)) =
    bar_clock.parse("2024-01-15 25:00:00")
    as "hour 25 is not a wall clock"
}

/// `to_iso` is the output edge and round-trips the parsed reading.
pub fn formats_iso_test() {
  let assert Ok(clock) = bar_clock.parse("2024-01-15 09:30:00") as "parse"
  assert bar_clock.to_iso(clock) == "2024-01-15 09:30:00"
    as "CSV and HTML see the human spelling"
}

/// An absolute instant is only built when a caller supplies the offset; the
/// UTC reading comes back unchanged.
pub fn to_timestamp_round_trip_test() {
  let assert Ok(clock) = bar_clock.parse("2024-01-15 09:30:00") as "parse"
  let instant = bar_clock.to_timestamp(clock, calendar.utc_offset)
  let #(date, time) = timestamp.to_calendar(instant, calendar.utc_offset)
  assert date.day == 15 as "same day"
  assert time.hours == 9 as "same hour"
  assert time.minutes == 30 as "same minute"
}

/// The wire decoder accepts a real label.
pub fn decoder_accepts_label_test() {
  let assert Ok(clock) =
    json.parse(from: "\"2024-01-15 09:30:00\"", using: bar_clock.decoder())
    as "a date field decodes into a BarClock"
  assert clock.time.minutes == 30 as "minute survived the wire"
}

/// The wire decoder rejects a bare date instead of constructing a fake clock.
pub fn decoder_rejects_bare_date_test() {
  let assert Error(_) =
    json.parse(from: "\"2024-01-15\"", using: bar_clock.decoder())
    as "a date field without a time of day is a decode error"
}

/// The error type has a diagnostic spelling for logs.
pub fn error_to_string_test() {
  let assert Error(error) = bar_clock.parse("2024-01-15") as "a bare date"
  assert bar_clock.error_to_string(error) != "" as "logs can name the rejection"
}
