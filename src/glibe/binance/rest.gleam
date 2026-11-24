//// The Binance LIVE REST data source. Implements Task 1–2 of
//// `.planning/phases/05-live-feed/05-01-PLAN.md`.
////
//// WHAT ARRIVES, AND WHY THIS IS NOT `binance/kline.gleam`: the public
//// endpoint `GET /api/v3/klines` returns an ARRAY OF ARRAYS — Binance's own
//// wire shape for this endpoint — not the twelve-named-field record that
//// `binance/kline.BinanceKline` models (that record is Binance's other,
//// websocket-facing shape). R28: each provider keeps its native shape and
//// standardises it in its OWN module. So this module decodes the REST wire
//// here and writes the ONE internal standard `SourceBar`; it never pretends
//// the wire is `BinanceKline` and never folds the two shapes together.
////
//// WHY THE DECODE IS PURE AND SEPARATE: `decode_klines` takes a payload
//// STRING, so a test pins it with a REAL captured response from
//// `data-api.binance.vision` — no network in the test gate. `fetch_klines`
//// is the only impure function: it builds the GET, calls `httpc.send`,
//// checks the status, then hands the body to `decode_klines`. This is the
//// sans-IO split (core §11): a request builder + a response parser, with
//// the boundary kept to one function.
////
//// THE WIRE'S FIELDS (owner's provider docs, Binance `/api/v3/klines`):
//// index 0 = Open time (epoch ms), 1 = Open, 2 = High, 3 = Low, 4 = Close,
//// 5 = Volume, 6 = Close time, 7 = Quote asset volume, 8 = Number of trades,
//// 9 = Taker buy base, 10 = Taker buy quote, 11 = Ignore. On the Erlang
//// target `decode.field` indexes only the first EIGHT list elements, so
//// this module reads 0–7 — exactly the six a standard bar needs (0 + 1..5)
//// plus close_time. Fields 8–11 are not needed to birth a `SourceBar` and
//// are deliberately NOT invented: they belong to the WS record in
//// `binance/kline.gleam` when a consumer needs them (R26).
////
//// R27: the wire's epoch milliseconds become ONE absolute `Timestamp` HERE,
//// at the boundary, and nowhere else. R23/R37: the interval is the caller's
//// key and names the standard variant; it is not a field smuggled onto a bar.
//// R33: history and live are ONE stream — `fetch_klines` feeds the same
//// `feed_sourcebar` entry the archive once used. No second path, no fallback
//// to synthetic data: a fetch failure is reported, never papered over.
////
//// R19 status (2026-11-25): skeleton — `////` → types → `///` + signature →
//// `todo` → RED test → one body at a time to GREEN.

import gleam/dynamic/decode
import gleam/float
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import gleam/time/timestamp.{type Timestamp}
import glibe/api/interval.{type Interval}
import glibe/api/sourcebar.{
  type SourceBar, SourceBarFifteenMinute, SourceBarFourHour, SourceBarOneDay,
  SourceBarOneHour, SourceBarOneMinute, SourceBarOneMonth, SourceBarOneWeek,
  SourceBarThirtyMinute, SourceBarThreeMinute,
}

/// The public, official market-data host. `api.binance.com` and
/// `api-gcp.binance.com` time out from this host (measured 2026-11-25);
/// `data-api.binance.vision` returns HTTP 200 with live klines. This is the
/// provider's own host spelling, held here as the provider's boundary fact.
const host = "https://data-api.binance.vision/api/v3/klines"

/// A real failure of a REST fetch, one constructor per failure that has a
/// caller. Errors carry the context needed to diagnose them (core §6), never
/// a bare `String`.
pub type RestError {
  /// The URL could not be built.
  FetchBadUrl
  /// The HTTP request failed at the transport / TLS layer.
  FetchHttpFailed
  /// The exchange answered, but not with 200. Carries the real status code.
  FetchBadStatus(status: Int)
  /// The body was not the kline wire shape.
  FetchDecodeFailed
  /// A numeric wire field (price, volume, epoch) failed to parse. Carries
  /// the field's wire index so the caller can locate it.
  FetchBadNumber(field_index: Int)
}

/// One kline's six usable wire fields, decoded from the array. Held only
/// inside this module: it is the REST wire's own shape, not an internal bar.
type KlineWire {
  KlineWire(
    open_time_ms: Int,
    open: String,
    high: String,
    low: String,
    close: String,
    volume: String,
  )
}

/// Binance's own spelling of the interval for `GET /api/v3/klines`
/// (`1m`/`3m`/`15m`/`30m`/`1h`/`4h`/`1d`/`1w`/`1M`) — the exchange's wire
/// code, never a type constructor (R21). Mirrors frozen glib
/// `binance.gleam:218-236`. Names every `Interval` variant, so adding a
/// tenth period is an `Inexhaustive patterns` error here (R13).
pub fn interval_to_binance_string(interval: Interval) -> String {
  case interval {
    interval.IntervalOneMinute -> "1m"
    interval.IntervalThreeMinute -> "3m"
    interval.IntervalFifteenMinute -> "15m"
    interval.IntervalThirtyMinute -> "30m"
    interval.IntervalOneHour -> "1h"
    interval.IntervalFourHour -> "4h"
    interval.IntervalOneDay -> "1d"
    interval.IntervalOneWeek -> "1w"
    // Capital M is Binance's month; the settings file spells it 1mo.
    interval.IntervalOneMonth -> "1M"
  }
}

/// The wire body in, standard bars out — PURE, so a real captured payload can
/// pin it without a network. Decodes `decode_klines`'s array-of-arrays into
/// `KlineWire`, folds each epoch-ms to an absolute `Timestamp` (R27), and
/// births the standard `SourceBar` variant named by `interval` (R23/R37).
/// Names every variant, so a tenth is a compile error (R13). A malformed
/// numeric field becomes `FetchBadNumber` — refusal, never a panic.
pub fn decode_klines(
  payload: String,
  interval: Interval,
) -> Result(List(SourceBar), RestError) {
  case json.parse(payload, decode.list(of: kline_decoder())) {
    Error(_) -> Error(FetchDecodeFailed)
    Ok(wires) -> list.try_map(wires, fn(wire) { to_sourcebar(wire, interval) })
  }
}

/// The decoder for ONE kline array. Reads only fields 0–5 — the six a
/// standard bar needs — with the prices/volume arriving as numeric STRINGS
/// (Binance's own wire spelling) and the open time as epoch milliseconds.
/// The parse to Float/Int is deferred to `to_sourcebar` so a bad number becomes
/// a typed `FetchBadNumber` rather than a decoder failure with no field index.
fn kline_decoder() -> decode.Decoder(KlineWire) {
  use open_time_ms <- decode.field(0, decode.int)
  use open <- decode.field(1, decode.string)
  use high <- decode.field(2, decode.string)
  use low <- decode.field(3, decode.string)
  use close <- decode.field(4, decode.string)
  use volume <- decode.field(5, decode.string)
  decode.success(KlineWire(
    open_time_ms: open_time_ms,
    open: open,
    high: high,
    low: low,
    close: close,
    volume: volume,
  ))
}

/// Fold the wire's epoch milliseconds into one absolute `Timestamp` (R27),
/// the same truncation glib `sourcebar.gleam:298` proved exact for every bar
/// from 2020 on. The domain is positive epochs, so ms % 1000 is never negative.
fn epoch_ms_to_timestamp(ms: Int) -> Timestamp {
  timestamp.from_unix_seconds_and_nanoseconds(
    ms / 1000,
    int.absolute_value(ms % 1000) * 1_000_000,
  )
}

/// ONE wire kline becomes ONE standard bar of the caller's interval. Strings
/// are parsed here so a malformed field names its wire index (R13). Names
/// every interval variant, so a tenth period is a compile error (R13).
fn to_sourcebar(
  wire: KlineWire,
  interval: Interval,
) -> Result(SourceBar, RestError) {
  use open <- result.try(parse_number(wire.open, 1))
  use high <- result.try(parse_number(wire.high, 2))
  use low <- result.try(parse_number(wire.low, 3))
  use close <- result.try(parse_number(wire.close, 4))
  use volume_float <- result.try(parse_number(wire.volume, 5))
  let timestamp = epoch_ms_to_timestamp(wire.open_time_ms)
  let volume = float.truncate(volume_float)
  Ok(case interval {
    interval.IntervalOneMinute ->
      SourceBarOneMinute(timestamp:, open:, high:, low:, close:, volume:)
    interval.IntervalThreeMinute ->
      SourceBarThreeMinute(timestamp:, open:, high:, low:, close:, volume:)
    interval.IntervalFifteenMinute ->
      SourceBarFifteenMinute(timestamp:, open:, high:, low:, close:, volume:)
    interval.IntervalThirtyMinute ->
      SourceBarThirtyMinute(timestamp:, open:, high:, low:, close:, volume:)
    interval.IntervalOneHour ->
      SourceBarOneHour(timestamp:, open:, high:, low:, close:, volume:)
    interval.IntervalFourHour ->
      SourceBarFourHour(timestamp:, open:, high:, low:, close:, volume:)
    interval.IntervalOneDay ->
      SourceBarOneDay(timestamp:, open:, high:, low:, close:, volume:)
    interval.IntervalOneWeek ->
      SourceBarOneWeek(timestamp:, open:, high:, low:, close:, volume:)
    interval.IntervalOneMonth ->
      SourceBarOneMonth(timestamp:, open:, high:, low:, close:, volume:)
  })
}

/// A numeric wire field is a decimal string; parse it or name the field index
/// that failed (R13), never panic and never a fabricated zero.
fn parse_number(value: String, field_index: Int) -> Result(Float, RestError) {
  case float.parse(value) {
    Error(_) -> Error(FetchBadNumber(field_index))
    Ok(number) -> Ok(number)
  }
}

/// The impure boundary: build `GET /api/v3/klines?symbol=…&interval=…&limit=…`,
/// send it with `httpc`, require status 200, and hand the body to
/// `decode_klines`. Never falls back to synthetic bars: any failure is
/// returned so the caller can log and retry (R33, no fake data).
pub fn fetch_klines(
  symbol: String,
  interval: Interval,
  limit: Int,
) -> Result(List(SourceBar), RestError) {
  let url =
    host
    <> "?symbol="
    <> symbol
    <> "&interval="
    <> interval_to_binance_string(interval)
    <> "&limit="
    <> int.to_string(limit)
  use request <- result.try(
    request.to(url) |> result.map_error(fn(_) { FetchBadUrl }),
  )
  use response <- result.try(
    httpc.send(request) |> result.map_error(fn(_) { FetchHttpFailed }),
  )
  case response.status {
    200 -> decode_klines(response.body, interval)
    status -> Error(FetchBadStatus(status))
  }
}

/// A human-readable line for logging a failed fetch. Names every error
/// variant, so a new failure is a compile error here (R13).
pub fn describe_error(error: RestError) -> String {
  case error {
    FetchBadUrl -> "could not build the Binance kline URL"
    FetchHttpFailed -> "Binance kline HTTP request failed"
    FetchBadStatus(status) ->
      "Binance kline returned status " <> int.to_string(status)
    FetchDecodeFailed -> "Binance kline body was not decodable"
    FetchBadNumber(field_index) ->
      "Binance kline bad numeric field at index " <> int.to_string(field_index)
  }
}
