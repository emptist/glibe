//// Binance kline (candlestick) decoding — array-format REST response.
//// Format: [[openTime, open, high, low, close, volume, ...], ...]
////
//// Plans: `.planning/phases/04-domain-cleanup/04-02-PLAN.md`,
//// `.planning/phases/04-domain-cleanup/04-06-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R21 (full constructor names), R27 (standard bar
//// time is unix time), R28 (native provider bars stay native).
////
//// **This module holds Binance's own shape.** A REST kline has twelve fields;
//// `closeTime`, `quoteAssetVolume`, `numberOfTrades`, the two taker-buy
//// volumes and `ignore` are things IB does not send. They are kept here, in a
//// native `Kline`, not discarded on the way in and not pushed into the common
//// `SourceBar`. `to_sourcebar` is this provider's own standardisation step:
//// it converts `openTime` (unix milliseconds) into the unix time the standard
//// bar carries and picks the OHLCV the engine consumes. IB will have a
//// different native type and a different converter.
////
//// This adapter also holds the Binance spelling of each `Interval`; the
//// canonical spelling lives in `api/interval.gleam`. Adding a constructor to
//// that closed set makes this `case` non-exhaustive until it is answered here —
//// the compiler is the checklist, not a grep guard.

import gleam/dynamic
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import glibe/api/interval.{
  type Interval, IntervalFifteenMinute, IntervalFourHour, IntervalOneDay,
  IntervalOneHour, IntervalOneMinute, IntervalOneMonth, IntervalOneWeek,
  IntervalThirtyMinute, IntervalThreeMinute,
}
import glibe/api/sourcebar.{type SourceBar, type SourceBarTimeError, SourceBar}

/// **Binance's native kline: all twelve REST array fields, none dropped.**
/// `open_time` / `close_time` are unix milliseconds, exactly as the wire spells
/// them. They are converted once, in `to_sourcebar`, and nowhere else.
pub type Kline {
  Kline(
    open_time: Int,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Int,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
}

/// Convert a canonical `Interval` to the Binance REST spelling.
pub fn interval_to_binance_string(i: Interval) -> String {
  case i {
    IntervalOneDay -> "1d"
    IntervalOneHour -> "1h"
    IntervalOneWeek -> "1w"
    IntervalOneMonth -> "1M"
    IntervalOneMinute -> "1m"
    IntervalThreeMinute -> "3m"
    IntervalFifteenMinute -> "15m"
    IntervalThirtyMinute -> "30m"
    IntervalFourHour -> "4h"
  }
}

/// Decode the REST array into **native** Binance klines. An array that does not
/// carry all twelve fields is skipped, not padded with invented values.
pub fn decode_klines(raw: String) -> Result(List(Kline), String) {
  let parsed =
    json.parse(raw, using: decode.list(of: decode.list(of: decode.dynamic)))
  result.map(parsed, fn(arrays) { list.filter_map(arrays, to_kline) })
  |> result.map_error(fn(_) { "JSON parse error" })
}

/// **This provider's standardisation step (R28).** The only place a Binance
/// time becomes the standard bar's unix time (R27). All the provider-specific
/// fields stay on the `Kline`; `SourceBar` receives only what the engine uses.
pub fn to_sourcebar(kline: Kline) -> Result(SourceBar, SourceBarTimeError) {
  use instant <- result.try(
    sourcebar.unix_timestamp(int.to_string(kline.open_time)),
  )
  Ok(SourceBar(
    timestamp: instant,
    open: kline.open,
    high: kline.high,
    low: kline.low,
    close: kline.close,
    volume: float.truncate(kline.volume),
  ))
}

/// Read one native kline from one REST array. Every field is kept.
fn to_kline(arr: List(dynamic.Dynamic)) -> Result(Kline, Nil) {
  use open_time <- result.try(get_int(arr, 0))
  use open <- result.try(get_float(arr, 1))
  use high <- result.try(get_float(arr, 2))
  use low <- result.try(get_float(arr, 3))
  use close <- result.try(get_float(arr, 4))
  use volume <- result.try(get_float(arr, 5))
  use close_time <- result.try(get_int(arr, 6))
  use quote_asset_volume <- result.try(get_float(arr, 7))
  use number_of_trades <- result.try(get_int(arr, 8))
  use taker_buy_base <- result.try(get_float(arr, 9))
  use taker_buy_quote <- result.try(get_float(arr, 10))
  use ignore <- result.try(get_string(arr, 11))
  Ok(Kline(
    open_time:,
    open:,
    high:,
    low:,
    close:,
    volume:,
    close_time:,
    quote_asset_volume:,
    number_of_trades:,
    taker_buy_base_asset_volume: taker_buy_base,
    taker_buy_quote_asset_volume: taker_buy_quote,
    ignore:,
  ))
}

/// A provider number may be a JSON number, a decimal string, or an integer
/// string. `float.parse` rejects `"100"` because it has no decimal point, so
/// an integer spelling is read as an `Int` and widened here — one conversion,
/// at the wire edge, instead of a default zero.
fn parse_number(text: String) -> Result(Float, Nil) {
  case float.parse(text) {
    Ok(value) -> Ok(value)
    Error(_) ->
      case int.parse(text) {
        Ok(value) -> Ok(int.to_float(value))
        Error(_) -> Error(Nil)
      }
  }
}

fn get_element(
  arr: List(dynamic.Dynamic),
  idx: Int,
) -> Result(dynamic.Dynamic, Nil) {
  list.drop(arr, idx)
  |> list.first
  |> result.map_error(fn(_) { Nil })
}

fn get_string(arr: List(dynamic.Dynamic), idx: Int) -> Result(String, Nil) {
  case get_element(arr, idx) {
    Ok(d) ->
      case decode.run(d, decode.string) {
        Ok(s) -> Ok(s)
        Error(_) ->
          case decode.run(d, decode.int) {
            Ok(i) -> Ok(int.to_string(i))
            Error(_) -> Error(Nil)
          }
      }
    Error(_) -> Error(Nil)
  }
}

fn get_float(arr: List(dynamic.Dynamic), idx: Int) -> Result(Float, Nil) {
  case get_element(arr, idx) {
    Ok(d) ->
      case decode.run(d, decode.float) {
        Ok(f) -> Ok(f)
        Error(_) ->
          case decode.run(d, decode.string) {
            Ok(s) ->
              case parse_number(s) {
                Ok(f) -> Ok(f)
                Error(_) -> Error(Nil)
              }
            Error(_) -> Error(Nil)
          }
      }
    Error(_) -> Error(Nil)
  }
}

fn get_int(arr: List(dynamic.Dynamic), idx: Int) -> Result(Int, Nil) {
  case get_element(arr, idx) {
    Ok(d) ->
      case decode.run(d, decode.int) {
        Ok(i) -> Ok(i)
        Error(_) ->
          case decode.run(d, decode.float) {
            Ok(f) -> Ok(float.truncate(f))
            Error(_) ->
              case decode.run(d, decode.string) {
                Ok(s) ->
                  case parse_number(s) {
                    Ok(f) -> Ok(float.truncate(f))
                    Error(_) -> Error(Nil)
                  }
                Error(_) -> Error(Nil)
              }
          }
      }
    Error(_) -> Error(Nil)
  }
}
