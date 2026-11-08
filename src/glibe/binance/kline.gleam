//// Binance kline (candlestick) decoding — array-format REST response.
//// Format: [[openTime, open, high, low, close, volume, ...], ...]
////
//// Plan: `.planning/phases/04-domain-cleanup/04-02-PLAN.md`.
//// This adapter holds the Binance spelling of each `Interval`; the canonical
//// spelling lives in `api/interval.gleam`. Adding a constructor to that closed
//// set makes this `case` non-exhaustive until it is answered here — the
//// compiler is the checklist, not a grep guard.

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
import glibe/api/sourcebar.{type SourceBar, SourceBar}

/// Convert canonical Interval to Binance REST string
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

pub fn decode_klines(raw: String) -> Result(List(SourceBar), String) {
  let parsed =
    json.parse(raw, using: decode.list(of: decode.list(of: decode.dynamic)))
  result.try(parsed, fn(arrays) {
    let bars =
      arrays
      |> list.map(decode_bar)
      |> list.filter(fn(r) {
        case r {
          Ok(_) -> True
          _ -> False
        }
      })
      |> list.map(fn(r) {
        case r {
          Ok(b) -> b
          _ -> panic
        }
      })
    Ok(bars)
  })
  |> result.map_error(fn(_) { "JSON parse error" })
}

fn decode_bar(arr: List(dynamic.Dynamic)) -> Result(SourceBar, Nil) {
  let date = case get_string(arr, 0) {
    Ok(s) -> s
    _ -> ""
  }
  let open = case get_float(arr, 1) {
    Ok(f) -> f
    _ -> 0.0
  }
  let high = case get_float(arr, 2) {
    Ok(f) -> f
    _ -> 0.0
  }
  let low = case get_float(arr, 3) {
    Ok(f) -> f
    _ -> 0.0
  }
  let close = case get_float(arr, 4) {
    Ok(f) -> f
    _ -> 0.0
  }
  let volume = case get_int(arr, 5) {
    Ok(i) -> i
    _ -> 0
  }
  Ok(SourceBar(date:, open:, high:, low:, close:, volume:))
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
              case float.parse(s) {
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
                  case float.parse(s) {
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
