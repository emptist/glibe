/// SourceBar - Raw API bar data from exchange

import gleam/dynamic/decode
import gleam/json.{type Json}

/// Raw API bar data from exchange (Binance/IB)
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

/// Decode SourceBar from JSON
pub fn decode_bar() -> decode.Decoder(SourceBar) {
  use date <- decode.field("date", decode.string)
  use open <- decode.field("open", decode.float)
  use high <- decode.field("high", decode.float)
  use low <- decode.field("low", decode.float)
  use close <- decode.field("close", decode.float)
  use volume <- decode.field("volume", decode.int)
  decode.success(SourceBar(date:, open:, high:, low:, close:, volume:))
}

/// Decode list of SourceBar from JSON
pub fn decode_bars() -> decode.Decoder(List(SourceBar)) {
  decode.list(of: decode_bar())
}