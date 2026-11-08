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
  todo as "04-06: parse epoch milliseconds or an ISO wall-clock label"
}

/// **The output spelling of a clock** — the one CSV rows and HTML views use.
/// Formatting happens at the output edge, never inside a domain function.
pub fn to_iso(clock: BarClock) -> String {
  todo as "04-06: format YYYY-MM-DD HH:MM:SS"
}

/// **An absolute instant, once a caller can say which offset applies.**
/// The offset is a parameter because the exchange calendar owns it (R26), not
/// this module. `calendar.utc_offset` is the value for an instant that is
/// already UTC.
pub fn to_timestamp(
  clock: BarClock,
  offset: duration.Duration,
) -> timestamp.Timestamp {
  todo as "04-06: build a Timestamp with the caller's offset"
}

/// The diagnostic spelling of a parse error, used by decoders and logs.
pub fn error_to_string(error: BarClockError) -> String {
  todo as "04-06: describe the rejection"
}

/// **A decoder for a `date` field**, so JSON bars are parsed at the wire edge.
/// An unreadable label is a decode error, not a bar carrying a placeholder.
pub fn decoder() -> decode.Decoder(BarClock) {
  todo as "04-06: decode a date field into a BarClock or fail"
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
fn from_epoch_ms(ms: Int) -> BarClock {
  todo as "04-06: read an epoch-millisecond instant at UTC"
}

/// The numeric month of a `calendar.Month`, for the ISO output spelling.
fn month_number(month: calendar.Month) -> Int {
  todo as "04-06: map the Month closed set to 1..12"
}
