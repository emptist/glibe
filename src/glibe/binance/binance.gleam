import gleam/json
import gleam/result
import glibe/binance/types.{type SourceBar, type Interval, decode_klines}
import gleam/dynamic.{type Dynamic}

pub type BinanceError {
  HttpError(Int, String)
  JsonError
}

@external(erlang, "binance_ffi", "get_klines")
fn do_get_klines(symbol: String, interval: String, limit: Int) -> Result(String, String)

@external(erlang, "binance_ffi", "get_ticker")
fn do_get_ticker(symbol: String) -> Result(String, String)

@external(erlang, "binance_ffi", "get_exchange_info")
fn do_get_exchange_info() -> Result(String, String)

@external(erlang, "binance_ffi", "set_base_url")
fn do_set_base_url(url: String) -> Result(Nil, Dynamic)

pub fn fetch_klines(symbol: String, interval: Interval, limit: Int) -> Result(List(SourceBar), BinanceError) {
  let interval_str = types.interval_to_binance_string(interval)
  do_get_klines(symbol, interval_str, limit)
  |> result.map_error(fn(e) { HttpError(0, e) })
  |> result.try(fn(raw) { decode_klines(raw) |> result.map_error(fn(e) { JsonError }) })
  |> result.map_error(fn(e) {
    case e {
      HttpError(c, m) -> HttpError(c, m)
      _ -> e
    }
  })
}

pub fn fetch_ticker(symbol: String) -> Result(String, BinanceError) {
  do_get_ticker(symbol)
  |> result.map_error(fn(e) { HttpError(0, e) })
}

pub fn fetch_exchange_info() -> Result(String, BinanceError) {
  do_get_exchange_info()
  |> result.map_error(fn(e) { HttpError(0, e) })
}

pub fn set_base_url(url: String) -> Result(Nil, BinanceError) {
  do_set_base_url(url)
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
  |> result.map(fn(_) { Nil })
}