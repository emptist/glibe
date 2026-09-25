/// Symbol = Instrument = Asset on specific Market (what you actually trade)

import glibe/api/asset.{type AssetRef}

/// Symbol = Instrument = Asset on specific Market (what you actually trade)
pub type Symbol {
  Symbol(
    market_id: String,                    // "binance_spot_crypto", "ib_equity", etc.
    asset_id: String,                     // "BTC", "AAPL", "TSLA"
    market_symbol: String,                // "BTCUSDT", "AAPL", "TSLAB/USDT", "00700.HK"
    base_asset: AssetRef,                 // Asset with class
    quote_asset: AssetRef,                // Asset with class (Currency for forex, USDT for crypto)
    available_brokers: List(String),      // broker_ids that can trade this
    available_data_providers: List(String), // data_provider_ids
    primary_execution_venue: String       // execution_venue_id
  )
}