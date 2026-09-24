import gleam/httpc
import gleam/http/request
import gleam/result
import gleam/int
import glibe/binance/types.{type SourceBar, type Interval, decode_klines}

pub type BinanceError {
  HttpError(Int, String)
  JsonError
}

fn get(path: String, query: List(#(String, String))) -> Result(String, BinanceError) {
  let req = request.new()
  |> request.set_host("testnet.binance.vision")
  |> request.set_path(path)
  |> request.set_query(query)
  case httpc.send(req) {
    Ok(resp) ->
      case resp.status {
        200 -> Ok(resp.body)
        code -> Error(HttpError(code, resp.body))
      }
    Error(_e) -> Error(HttpError(0, "http error"))
  }
}

pub fn fetch_klines(symbol: String, interval: Interval, limit: Int) -> Result(List(SourceBar), BinanceError) {
  let interval_str = types.interval_to_binance_string(interval)
  get("/api/v3/klines", [
    #("symbol", symbol),
    #("interval", interval_str),
    #("limit", int.to_string(limit)),
  ])
  |> result.try(fn(raw) { decode_klines(raw) |> result.map_error(fn(_) { JsonError }) })
}

pub fn fetch_ticker(symbol: String) -> Result(String, BinanceError) {
  get("/api/v3/ticker/24hr", [#("symbol", symbol)])
}

pub fn fetch_exchange_info() -> Result(String, BinanceError) {
  get("/api/v3/exchangeInfo", [])
}