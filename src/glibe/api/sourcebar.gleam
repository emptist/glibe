// The source bar — what an exchange hands us, before anything has been decided
// about it.
//
// **This module is the boundary.** Everything downstream of it may assume the
// bar is well-formed and that `date` is a timestamp a human can read. Both of
// those are produced here, and nowhere else:
//
// | what | who |
// |---|---|
// | `validate` | rejects a bar that cannot be right — **rejects, never repairs** |
// | `normalize_date` | turns the provider's epoch-milliseconds into ISO-8601 |
//
// The second one is the whole of a bug that lived here for three review rounds:
// Binance sends `openTime` as epoch-milliseconds, it reached the bucket test as
// `"1735704000000"`, no minute field matched, and an hourly timeframe therefore
// never closed a bar — every source bar was folded into one growing bar
// forever. Converting at the boundary is the fix; converting inside the bucket
// test would have been the same bug twice.

import gleam/dynamic/decode
import gleam/int

/// Raw API bar data from an exchange (Binance, IB).
pub type SourceBar {
  SourceBar(
    date: String,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
}

/// Decode SourceBar from JSON
pub fn decode_bar() -> decode.Decoder(SourceBar) {
  use date <- decode.field("date", decode.string)
  use open <- decode.field("open", decode.float)
  use high <- decode.field("high", decode.float)
  use low <- decode.field("low", decode.float)
  use close <- decode.field("close", decode.float)
  use volume <- decode.field("volume", decode.int)
  decode.success(SourceBar(date:, open:, high:, low:, close:, volume:))
}

/// Decode list of SourceBar from JSON
pub fn decode_bars() -> decode.Decoder(List(SourceBar)) {
  decode.list(of: decode_bar())
}

// ============================================================================
// The boundary
// ============================================================================

/// **The bar, or the reason it is not one.**
///
/// A bar whose own numbers disagree is not repaired into a bar that agrees — a
/// repair puts a number in the engine that no exchange ever sent, and every
/// indicator downstream is then measured on it. The checks are the four that
/// are true of an OHLC bar by definition: the high is the highest of the four,
/// the low is the lowest, neither is negative, and a volume is not negative.
pub fn validate(bar: SourceBar) -> Result(SourceBar, String) {
  case
    bar.open <. 0.0 || bar.high <. 0.0 || bar.low <. 0.0 || bar.close <. 0.0
  {
    True -> Error("a price is negative")
    False ->
      case bar.high <. bar.low {
        True -> Error("high is below low")
        False ->
          case bar.high <. bar.open || bar.high <. bar.close {
            True -> Error("high is not the highest")
            False ->
              case bar.low >. bar.open || bar.low >. bar.close {
                True -> Error("low is not the lowest")
                False ->
                  case bar.volume < 0 {
                    True -> Error("volume is negative")
                    False -> Ok(bar)
                  }
              }
          }
      }
  }
}

/// **The bar with its date in the one shape the engine reads.**
///
/// A provider that counts milliseconds since the epoch is translated here, so
/// that `interval.bucket_ends` — and every CSV, chart and log downstream — see
/// `"2024-01-15 09:00:00"` and not `"1705299600000"`.
pub fn normalize_date(bar: SourceBar) -> SourceBar {
  SourceBar(..bar, date: date_to_iso(bar.date))
}

/// Epoch-milliseconds in, ISO-8601 out; anything that already reads as a date
/// passes through untouched. The test for "is this a count of milliseconds" is
/// that it parses as an integer large enough to be one — a date with a dash or
/// a colon in it does not.
pub fn date_to_iso(date: String) -> String {
  case int.parse(date) {
    Ok(ms) ->
      case ms > 1_000_000_000_000 {
        True -> epoch_ms_to_iso(ms)
        False -> date
      }
    Error(_) -> date
  }
}

// ============================================================================
// Epoch milliseconds → civil date
// ============================================================================

/// Howard Hinnant's `civil_from_days`, in Gleam, because the tree has no date
/// library and does not need one for this: the algorithm is three divisions and
/// two corrections, and it is exact for every date the epoch can name.
///
/// Written for counts at or after the epoch, which is every bar any exchange
/// will ever send; an earlier count is returned unchanged rather than silently
/// shifted.
pub fn epoch_ms_to_iso(ms: Int) -> String {
  case ms < 0 {
    True -> int.to_string(ms)
    False -> {
      let seconds = ms / 1000
      let days = seconds / 86_400
      let in_day = seconds % 86_400
      let hour = in_day / 3600
      let minute = { in_day % 3600 } / 60
      let second = in_day % 60
      let #(year, month, day) = civil_from_days(days)
      int.to_string(year)
      <> "-"
      <> pad(month)
      <> "-"
      <> pad(day)
      <> " "
      <> pad(hour)
      <> ":"
      <> pad(minute)
      <> ":"
      <> pad(second)
    }
  }
}

fn civil_from_days(days: Int) -> #(Int, Int, Int) {
  let z = days + 719_468
  let era = z / 146_097
  let doe = z - era * 146_097
  let yoe = { doe - doe / 1460 + doe / 36_524 - doe / 146_096 } / 365
  let y = yoe + era * 400
  let doy = doe - { 365 * yoe + yoe / 4 - yoe / 100 }
  let mp = { 5 * doy + 2 } / 153
  let d = doy - { 153 * mp + 2 } / 5 + 1
  let m = case mp < 10 {
    True -> mp + 3
    False -> mp - 9
  }
  let y = case m <= 2 {
    True -> y + 1
    False -> y
  }
  #(y, m, d)
}

fn pad(n: Int) -> String {
  case n < 10 {
    True -> "0" <> int.to_string(n)
    False -> int.to_string(n)
  }
}
