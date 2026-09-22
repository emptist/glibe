import glibe/binance/binance
import glibe/binance/types as types
import gleam/io
import gleam/list
import gleam/int
import gleam/float

pub fn main() {
  io.println("Fetching BTCUSDT 1h klines...")
  case binance.fetch_klines("BTCUSDT", types.H1, 10) {
    Ok(bars) -> handle_bars(bars)
    Error(e) -> io.println("Error: " <> debug(e))
  }
}

fn handle_bars(bars: List(types.SourceBar)) {
  case list.first(bars) {
    Ok(first) -> {
      io.println("Got " <> int.to_string(list.length(bars)) <> " bars")
      io.println("First bar:")
      io.println("  date: " <> first.date)
      io.println("  open: " <> float.to_string(first.open))
      io.println("  high: " <> float.to_string(first.high))
      io.println("  low: " <> float.to_string(first.low))
      io.println("  close: " <> float.to_string(first.close))
      io.println("  volume: " <> int.to_string(first.volume))
      Nil
    }
    Error(_) -> io.println("No bars returned")
  }
}

fn debug(e) {
  case e {
    binance.HttpError(code, msg) -> "HttpError(" <> int.to_string(code) <> "): " <> msg
    binance.JsonError -> "JsonError"
  }
}