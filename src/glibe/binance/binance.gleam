//// Binance REST client — the provider's boundary with our standard model.
////
//// Plans: `.planning/phases/04-domain-cleanup/04-06-PLAN.md`,
//// `.planning/phases/04-domain-cleanup/04-08-PLAN.md` (the requested symbol is
//// a `Symbol`, not a universal `String`).
//// Rulings: `docs/RULINGS.md` R27 (standard bar time is unix time),
//// R28 (native provider bars stay native, each provider standardises itself),
//// R22 (a name is a `Symbol`, not the instrument).
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
import glibe/api/symbol.{type Symbol}
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

/// Fetch ONE interval's kline stream and hand the engine standard `SourceBar`
/// values only. The requested name is a `Symbol` (R22); it becomes a `String`
/// only here, in the HTTP query. The identity of the request is NOT returned
/// inside each bar — `monitor.IncomingBar` pairs it at the ingest boundary
/// (plan 04-08), and the broker half of the address is a subscription fact,
/// not a provider↔broker relation invented here (R26).
pub fn fetch_klines(
  name: Symbol,
  interval: Interval,
  limit: Int,
) -> Result(List(SourceBar), BinanceError) {
  let interval_str = interval_to_binance_string(interval)
  get("/api/v3/klines", [
    #("symbol", symbol.to_string(name)),
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
