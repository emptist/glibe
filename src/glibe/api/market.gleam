/// Market types - Exchange + AssetClass + Rules

import gleam/option.{type Option, Some, None}
import glibe/api/asset.{type AssetClass, type AssetRef}
import glibe/api/rules.{type MarketRules}

/// Market = Exchange + AssetClass + Rules (trading rules live here)
pub type Market {
  Market(
    exchange: String,      // exchange_id from exchanges list
    asset_class: AssetClass, // Crypto, Equity, BStock, Future, Option, Currency
    rules: MarketRules     // All trading rules for this market
  )
}