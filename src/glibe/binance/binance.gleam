//// Binance REST client — the provider's boundary with our standard model.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-06-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R27 (standard bar time is unix time),
//// R28 (native provider bars stay native, each provider standardises itself).
////
//// `kline.decode_klines` returns **native** twelve-field `Kline` values. This
//// module is where they cross into the standard model: each one goes through
//// `kline.to_sourcebar`, which converts `openTime` to unix time. Nothing
//// downstream ever sees a Binance-specific field or a provider time spelling.

import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/list
import gleam/result
import glibe/api/interval.{type Interval}
import glibe/api/sourcebar.{type SourceBar, type SourceBarTimeError}
import glibe/binance/kline.{
  decode_klines, interval_to_binance_string, to_sourcebar,
}

pub type BinanceError {
  HttpError(Int, String)
  JsonError
  /// A native kline's `openTime` could not be converted to unix time (R27).
  BarTimeError(SourceBarTimeError)
}

fn get(
  path: String,
  query: List(#(String, String)),
) -> Result(String, BinanceError) {
  let req =
    request.new()
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

/// Fetch klines and hand the engine standard `SourceBar` values only.
pub fn fetch_klines(
  symbol: String,
  interval: Interval,
  limit: Int,
) -> Result(List(SourceBar), BinanceError) {
  let interval_str = interval_to_binance_string(interval)
  get("/api/v3/klines", [
    #("symbol", symbol),
    #("interval", interval_str),
    #("limit", int.to_string(limit)),
  ])
  |> result.try(fn(raw) {
    use natives <- result.try(
      decode_klines(raw) |> result.map_error(fn(_) { JsonError }),
    )
    natives
    |> list.map(to_sourcebar)
    |> result.all
    |> result.map_error(fn(error) { BarTimeError(error) })
  })
}

pub fn fetch_ticker(symbol: String) -> Result(String, BinanceError) {
  get("/api/v3/ticker/24hr", [#("symbol", symbol)])
}

pub fn fetch_exchange_info() -> Result(String, BinanceError) {
  get("/api/v3/exchangeInfo", [])
}
