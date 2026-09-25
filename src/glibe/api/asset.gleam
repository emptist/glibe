/// Asset types - legally standardized tradable things

/// Asset = legally standardized tradable thing
pub type Asset {
  Asset(
    id: String,          // "BTC", "AAPL", "TSLA", "USD", "CNY", "HKD"
    name: String,        // "Bitcoin", "Apple Inc.", "Tesla Inc."
    class: AssetClass    // Crypto, Equity, ETF, BStock, Future, Option, Currency
  )
}

/// Asset reference (for base/quote in Symbol)
pub type AssetRef {
  AssetRef(
    id: String,
    name: String,
    class: AssetClass
  )
}

/// Asset classification (legal standardization)
pub type AssetClass {
  Crypto      // Native crypto (BTC, ETH)
  Equity      // Stocks (AAPL, TSLA)
  ETF         // ETFs (SPY, QQQ)
  BStock      // Binance tokenized stocks (TSLAB, NVDAB)
  Future      // Futures contracts
  Option      // Options contracts
  Currency    // Forex pairs (USD, CNY, HKD)
}

/// Parse AssetClass from string (for config)
pub fn asset_class_from_string(s: String) -> AssetClass {
  case s {
    "Crypto" -> Crypto
    "Equity" -> Equity
    "ETF" -> ETF
    "BStock" -> BStock
    "Future" -> Future
    "Option" -> Option
    "Currency" -> Currency
    _ -> panic as "Unknown AssetClass"
  }
}