//// The standard source bar — an absolute instant, plus the OHLCV a provider
//// sent. This is the one shape every downstream module works with.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-06-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R27 (standard bar time is unix time), R13
//// (errors are types), R19 (docs-first), R22 (a name is not the thing named),
//// R23 (one fact lives in one place).
////
//// **Why a standard bar exists.** A bar happens at an absolute instant.
//// Binance spells it as unix milliseconds; another provider spells a local
//// wall-clock label that only becomes an instant after its calendar rule is
//// applied. If the standard type held a provider's spelling instead, there
//// would be no reason to define a standard at all — and no reason for a
//// provider module to have a `to_sourcebar` converter. So the field is
//// `gleam_time.Timestamp`, whose representation *is* unix seconds plus
//// nanoseconds. The name changed from `date` for the same reason (R22): an
//// absolute instant is not a date.
////
//// **The boundary.** `unix_timestamp` is the wire-to-standard conversion,
//// called by `decode_bar` for JSON bars and by `binance/kline.gleam`'s
//// `to_sourcebar` for REST klines. It accepts unix milliseconds, an RFC3339
//// label that carries its own offset, and an unlabelled ISO label (read as UTC
//// *by this adapter*, a conversion rule at the edge, not a domain assumption).
//// Anything else is a typed rejection: a bar with an unknown time is not
//// repaired into a bar with a guessed one.
////
//// **Provider shapes stay native (R28).** `decode_bar` here serves one
//// concrete `date`-field JSON line format; it is not a universal provider
//// shape. `binance/kline.gleam` keeps its own twelve-field `Kline` and its own
//// `to_sourcebar`; IB keeps a different native type. The standard bar is the
//// single common target, never the union of provider fields.
////
//// **The historical bug this closes.** Binance's `openTime` used to reach the
//// bucket test as `"1735704000000"`; no minute field matched, so an hourly
//// timeframe folded every bar into one growing bar forever. Converting at the
//// boundary is the fix. Converting inside the bucket test would have been the
//// same bug twice, and `interval.bucket_ends` now receives only a `Timestamp`.

import gleam/dynamic/decode
import gleam/int
import gleam/result
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp.{type Timestamp}

/// **The standard bar.** `timestamp` is an absolute unix time; none of the
/// other fields say anything about when or where the bar came from.
pub type SourceBar {
  SourceBar(
    timestamp: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
  )
}

/// **The three ways a wire label can fail to name an instant.** An error is a
/// value of a closed set, never a `String` to be parsed again.
pub type SourceBarTimeError {
  /// Not unix milliseconds, not RFC3339 and not an ISO label with a clock.
  UnreadableBarTime(raw: String)
  /// A bare `"2024-01-15"`: an OHLC bar has a time of day.
  BarTimeHasNoTimeOfDay(raw: String)
  /// Parsed, but a field is outside its calendar range.
  BarTimeFieldOutOfRange(raw: String)
}

/// Decode one standard bar from JSON. The `date` field is converted at this
/// wire edge; a bad label is a decode error, not a bar with a default clock.
pub fn decode_bar() -> decode.Decoder(SourceBar) {
  use instant <- decode.field("date", timestamp_decoder())
  use open <- decode.field("open", decode.float)
  use high <- decode.field("high", decode.float)
  use low <- decode.field("low", decode.float)
  use close <- decode.field("close", decode.float)
  use volume <- decode.field("volume", decode.int)
  decode.success(SourceBar(
    timestamp: instant,
    open:,
    high:,
    low:,
    close:,
    volume:,
  ))
}

/// Decode a list of standard bars from JSON.
pub fn decode_bars() -> decode.Decoder(List(SourceBar)) {
  decode.list(of: decode_bar())
}

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

/// **Convert a provider wire label into a unix time.** This is the conversion
/// every `to_sourcebar` implementation calls; it is not domain logic and no
/// `String` survives it. An RFC3339 label carries its own offset; an
/// unlabelled ISO label is read as UTC by this adapter.
pub fn unix_timestamp(raw: String) -> Result(Timestamp, SourceBarTimeError) {
  case epoch_ms(raw) {
    Ok(instant) -> Ok(instant)
    Error(_) ->
      case timestamp.parse_rfc3339(raw) {
        Ok(instant) -> Ok(instant)
        Error(_) -> parse_unlabelled(raw)
      }
  }
}

/// The diagnostic spelling of a conversion error, for decoders and logs.
pub fn time_error_to_string(error: SourceBarTimeError) -> String {
  case error {
    UnreadableBarTime(raw) -> "unreadable bar time: " <> raw
    BarTimeHasNoTimeOfDay(raw) -> "bar time has no time of day: " <> raw
    BarTimeFieldOutOfRange(raw) -> "bar time field out of range: " <> raw
  }
}

/// A decoder for a wire `date` field. An unreadable label is a decode error.
fn timestamp_decoder() -> decode.Decoder(Timestamp) {
  use raw <- decode.then(decode.string)
  case unix_timestamp(raw) {
    Ok(instant) -> decode.success(instant)
    Error(error) ->
      decode.failure(
        timestamp.from_unix_seconds(0),
        time_error_to_string(error),
      )
  }
}

/// Unix milliseconds are already an absolute instant; only the unit changes.
fn epoch_ms(raw: String) -> Result(Timestamp, Nil) {
  case int.parse(raw) {
    Ok(ms) ->
      case ms > 1_000_000_000_000 {
        True ->
          Ok(timestamp.from_unix_seconds_and_nanoseconds(
            ms / 1000,
            { ms % 1000 } * 1_000_000,
          ))
        False -> Error(Nil)
      }
    Error(_) -> Error(Nil)
  }
}

/// Split an unlabelled ISO label into a date part and a time part.
fn split_date_time(
  raw: String,
) -> Result(#(String, String), SourceBarTimeError) {
  case string.split(raw, " ") {
    [date_part, time_part, ..] -> Ok(#(date_part, time_part))
    [one] ->
      case string.split(one, "T") {
        [date_part, time_part, ..] -> Ok(#(date_part, time_part))
        _ -> classify_missing_time(raw, one)
      }
    _ -> Error(UnreadableBarTime(raw))
  }
}

/// A bare `"2024-01-15"` is a readable date with no clock; `"not-a-date"` is
/// neither. Both are rejected, with different reasons.
fn classify_missing_time(
  raw: String,
  one: String,
) -> Result(#(String, String), SourceBarTimeError) {
  case string.split(one, "-") {
    [year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(_), Ok(_), Ok(_) -> Error(BarTimeHasNoTimeOfDay(raw))
        _, _, _ -> Error(UnreadableBarTime(raw))
      }
    _ -> Error(UnreadableBarTime(raw))
  }
}

/// Read `YYYY-MM-DD` and reject fields outside their calendar ranges.
fn parse_date(
  part: String,
  raw: String,
) -> Result(calendar.Date, SourceBarTimeError) {
  case string.split(part, "-") {
    [year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(y), Ok(m), Ok(d) ->
          case y > 0 && in_range(m, 1, 12) && in_range(d, 1, 31) {
            True ->
              case month_from_number(m) {
                Ok(month_value) ->
                  Ok(calendar.Date(year: y, month: month_value, day: d))
                Error(_) -> Error(BarTimeFieldOutOfRange(raw))
              }
            False -> Error(BarTimeFieldOutOfRange(raw))
          }
        _, _, _ -> Error(UnreadableBarTime(raw))
      }
    _ -> Error(UnreadableBarTime(raw))
  }
}

/// Read `HH:MM:SS`; a field outside its range is not a wall clock.
fn parse_time(
  part: String,
  raw: String,
) -> Result(calendar.TimeOfDay, SourceBarTimeError) {
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
            False -> Error(BarTimeFieldOutOfRange(raw))
          }
        _, _, _ -> Error(UnreadableBarTime(raw))
      }
    _ -> Error(UnreadableBarTime(raw))
  }
}

/// Convert an unlabelled ISO label to an instant using the adapter's UTC rule.
fn parse_unlabelled(raw: String) -> Result(Timestamp, SourceBarTimeError) {
  use #(date_part, time_part) <- result.try(split_date_time(raw))
  use date <- result.try(parse_date(date_part, raw))
  use time <- result.try(parse_time(time_part, raw))
  Ok(timestamp.from_calendar(date:, time:, offset: calendar.utc_offset))
}

/// The `Month` closed set, in wire order; the mapping is total.
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

/// Inclusive range check shared by date and time fields.
fn in_range(value: Int, low: Int, high: Int) -> Bool {
  value >= low && value <= high
}
