/// Exchange and venue types
/// Core types for exchange identity and connection details

import gleam/option.{type Option, Some, None}

/// Exchange = venue identity + connection details
pub type Exchange {
  Exchange(
    id: String,
    name: String,
    mic: String,                    // ISO 10383 MIC code
    base_url: Option(String),       // REST API base URL
    ws_url: Option(String),         // WebSocket URL
    gateway_host: Option(String),   // For IB gateway
    gateway_port: Option(Int)       // For IB gateway
  )
}

/// Market type determines trading calendar and rules for the venue
pub type MarketType {
  Stock   // Traditional markets (IB): ~20 trading days/month, RTH/ETH
  Crypto  // Native crypto (Binance): 30 days/month, 24/7 trading
  BStock  // Binance tokenized stocks (bStocks): 24/7, 1:1 backed US equities
}