import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import gleam/int
import gleam/float

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

pub type Interval {
  D1
  H1
  W1
  MO1
  MIN1
  MIN15
  MIN30
}

pub fn interval_to_binance_string(interval: Interval) -> String {
  case interval {
    D1 -> "1d"
    H1 -> "1h"
    W1 -> "1w"
    MO1 -> "1M"
    MIN1 -> "1m"
    MIN15 -> "15m"
    MIN30 -> "30m"
  }
}

fn get_element(arr: List(dynamic.Dynamic), idx: Int) -> Result(dynamic.Dynamic, Nil) {
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

pub fn decode_bar(arr: List(dynamic.Dynamic)) -> Result(SourceBar, Nil) {
  let date = case get_string(arr, 0) { Ok(s) -> s _ -> "" }
  let open = case get_float(arr, 1) { Ok(f) -> f _ -> 0.0 }
  let high = case get_float(arr, 2) { Ok(f) -> f _ -> 0.0 }
  let low = case get_float(arr, 4) { Ok(f) -> f _ -> 0.0 }
  let close = case get_float(arr, 3) { Ok(f) -> f _ -> 0.0 }
  let volume = case get_int(arr, 5) { Ok(i) -> i _ -> 0 }

  Ok(SourceBar(date:, open:, high:, low:, close:, volume:))
}

pub fn decode_klines(raw: String) -> Result(List(SourceBar), String) {
  let parsed = json.parse(raw, using: decode.list(of: decode.list(of: decode.dynamic)))
  result.try(parsed, fn(arrays) {
    let bars = arrays
      |> list.map(decode_bar)
      |> list.filter(fn(r) { case r { Ok(_) -> True _ -> False } })
      |> list.map(fn(r) { case r { Ok(b) -> b _ -> panic }})
    Ok(bars)
  })
  |> result.map_error(fn(e) { "JSON parse error" })
}