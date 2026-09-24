import gleam/dynamic/decode

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

/// Timeframe intervals
pub type Interval {
  D1
  H1
  W1
  MO1  // 1 month
  MIN1   // 1 minute
  MIN15  // 15 minutes
  MIN30  // 30 minutes
}

/// Market type determines trading calendar
pub type MarketType {
  Stock   // Traditional markets (IB): ~20 trading days/month, RTH/ETH
  Crypto  // Binance: 30 days/month, 24/7 trading
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