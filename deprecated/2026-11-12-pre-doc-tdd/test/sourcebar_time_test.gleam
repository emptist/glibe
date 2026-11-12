//// Tests for R27: the standard `SourceBar` holds an absolute unix time, and
//// provider adapters are the only place a wire label is converted.
//// Plan: `.planning/phases/04-domain-cleanup/04-06-PLAN.md`.
//// Written before the migration of the consumers (R19).

import gleam/json
import gleam/time/timestamp
import glibe/api/interval
import glibe/api/sourcebar
import glibe/binance/kline

/// A complete JSON bar with one variable `date` field.
fn bar_json(date: String) -> String {
  "{\"date\":\""
  <> date
  <> "\",\"open\":100.0,\"high\":101.0,\"low\":99.0,"
  <> "\"close\":100.5,\"volume\":10}"
}

/// The unix seconds of a Timestamp — the only reading the domain needs.
fn seconds(instant: timestamp.Timestamp) -> Int {
  let #(whole_seconds, _nanoseconds) =
    timestamp.to_unix_seconds_and_nanoseconds(instant)
  whole_seconds
}

/// Binance's epoch milliseconds become exactly that instant, not a string.
pub fn json_epoch_ms_becomes_unix_time_test() {
  let assert Ok(bar) =
    json.parse(from: bar_json("1705309200000"), using: sourcebar.decode_bar())
    as "an epoch-ms date field decodes into a standard SourceBar"
  assert seconds(bar.timestamp) == 1_705_309_200
    as "2024-01-15 09:00:00 UTC is unix second 1705309200"
}

/// An unlabelled ISO label is converted at the JSON adapter, under its stated
/// UTC rule, to the same instant.
pub fn json_iso_label_becomes_unix_time_test() {
  let assert Ok(bar) =
    json.parse(
      from: bar_json("2024-01-15 09:00:00"),
      using: sourcebar.decode_bar(),
    )
    as "an ISO date field decodes"
  assert seconds(bar.timestamp) == 1_705_309_200
    as "the ISO label and epoch milliseconds are one instant"
}

/// A bare date is not a bar time: the adapter rejects instead of defaulting.
pub fn bare_date_is_rejected_test() {
  let assert Error(_) =
    json.parse(from: bar_json("2024-01-15"), using: sourcebar.decode_bar())
    as "an OHLC bar without a time of day is not a bar"
}

/// Garbage is rejected, never folded into an open bucket with a default clock.
pub fn unreadable_label_is_rejected_test() {
  let assert Error(_) =
    json.parse(from: bar_json("not-a-date"), using: sourcebar.decode_bar())
    as "an unreadable label is a decode error"
}

/// The bucket grid is arithmetic on unix seconds — no calendar, no offset, no
/// string splitting. These are the same boundaries the old string parser used.
pub fn bucket_grid_is_unix_seconds_test() {
  let at_0900 = timestamp.from_unix_seconds(1_705_309_200)
  let at_0930 = timestamp.from_unix_seconds(1_705_311_000)
  let at_0800 = timestamp.from_unix_seconds(1_705_305_600)
  let at_0903 = timestamp.from_unix_seconds(1_705_309_380)
  let at_0904 = timestamp.from_unix_seconds(1_705_309_440)

  assert interval.bucket_ends(interval.IntervalOneHour, at_0900)
    as "09:00 closes an hourly bucket"
  assert interval.bucket_ends(interval.IntervalOneHour, at_0930) == False
    as "09:30 does not close an hourly bucket"
  assert interval.bucket_ends(interval.IntervalFourHour, at_0800)
    as "08:00 closes a four-hour bucket"
  assert interval.bucket_ends(interval.IntervalFourHour, at_0900) == False
    as "09:00 is not a four-hour boundary"
  assert interval.bucket_ends(interval.IntervalThreeMinute, at_0903)
    as "09:03 closes a three-minute bucket"
  assert interval.bucket_ends(interval.IntervalThreeMinute, at_0904) == False
    as "09:04 does not close a three-minute bucket"
}

/// The Binance adapter has a `to_sourcebar` conversion: epoch milliseconds in
/// the kline array become the same standard instant.
pub fn binance_to_sourcebar_converts_epoch_ms_test() {
  let raw =
    "[[1705309200000,\"100\",\"101\",\"99\",\"100.5\",\"10\","
    <> "1705312800000,\"1000\",\"12\",\"5\",\"500\",\"0\"]]"
  let assert Ok([native]) = kline.decode_klines(raw)
    as "one kline decodes into one native Binance Kline"
  assert native.number_of_trades == 12
    as "provider-only fields survive decoding (R28)"
  assert native.close_time == 1_705_312_800_000
    as "closeTime is kept, not discarded"
  let assert Ok(bar) = kline.to_sourcebar(native)
    as "this provider standardises itself"
  assert seconds(bar.timestamp) == 1_705_309_200
    as "the provider spelling is gone at the boundary"
}
