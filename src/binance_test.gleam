import glibe/binance/binance
import glibe/binance/types as types
import gleam/io
import gleam/result
import gleam/int
import gleam/float

pub fn main() {
  io.println("Fetching BTCUSDT 1h klines...")
  case binance.fetch_klines("BTCUSDT", types.H1, 5) {
    Ok(bars) ->
      io.println("Got bars: " <> bars_to_string(bars))
    Error(e) -> io.println("Error: " <> debug(e))
  }
}

fn bars_to_string(bars) {
  case bars {
    [] -> "0 bars"
    [first, ..rest] ->
      format_first_bar(first)
  }
}

fn format_first_bar(bar: types.SourceBar) {
  let date = bar.date
  let open = bar.open
  let high = bar.high
  let low = bar.low
  let close = bar.close
  let volume = bar.volume
  "First: " <> date <> " O:" <> float.to_string(open) <> " H:" <> float.to_string(high) <> " L:" <> float.to_string(low) <> " C:" <> float.to_string(close) <> " V:" <> int.to_string(volume)
}

fn debug(e) {
  case e {
    binance.HttpError(code, msg) -> "HttpError(" <> int.to_string(code) <> "): " <> msg
    binance.JsonError -> "JsonError"
  }
}