/// Configuration for the entire trading system
/// Single source of truth - no JSON needed, Gleam IS the config

import gleam/list
import gleam/option.{type Option, Some, None}

// ============================================================================
// Config Types (structure only, types imported from their modules)
// ============================================================================

pub type AppConfig {
  AppConfig(
    version: Int,
    exchanges: List(#(String, exchange.Exchange)),
    assets: List(#(String, asset.Asset)),
    markets: List(#(String, market.Market)),
    symbols: List(#(String, symbol.Symbol)),
    timeframe_settings: List(#(String, indicators.TimeframeSettings))
  )
}

import glibe/api/exchange
import glibe/api/asset.{asset_class_from_string}
import glibe/api/market
import glibe/api/symbol
import glibe/api/rules.{trading_hours_from_string, settlement_type_from_string, auction_type_from_string, circuit_breaker_from_string}
import glibe/indicators

// ============================================================================
// Default Configuration (Single Source of Truth)
// ============================================================================

pub fn default_config() -> AppConfig {
  AppConfig(
    version: 1,
    exchanges: [
      #(
        "binance",
        exchange.Exchange(
          id: "binance",
          name: "Binance",
          mic: "BINA",
          base_url: Some("https://testnet.binance.vision"),
          ws_url: Some("wss://stream.testnet.binance.vision"),
          gateway_host: None,
          gateway_port: None
        )
      ),
      #(
        "ib",
        exchange.Exchange(
          id: "ib",
          name: "Interactive Brokers",
          mic: "IBKR",
          base_url: None,
          ws_url: None,
          gateway_host: Some("127.0.0.1"),
          gateway_port: Some(5001)
        )
      ),
      #(
        "futu",
        exchange.Exchange(
          id: "futu",
          name: "Futu",
          mic: "FUTU",
          base_url: Some("https://openapi.futunn.com"),
          ws_url: None,
          gateway_host: Some("127.0.0.1"),
          gateway_port: Some(11111)
        )
      )
    ],
    assets: [
      #("BTC", asset.Asset(id: "BTC", name: "Bitcoin", class: asset_class_from_string("Crypto"))),
      #("ETH", asset.Asset(id: "ETH", name: "Ethereum", class: asset_class_from_string("Crypto"))),
      #("SPY", asset.Asset(id: "SPY", name: "SPDR S&P 500 ETF Trust", class: asset_class_from_string("ETF"))),
      #("AAPL", asset.Asset(id: "AAPL", name: "Apple Inc.", class: asset_class_from_string("Equity"))),
      #("TSLA", asset.Asset(id: "TSLA", name: "Tesla Inc.", class: asset_class_from_string("BStock"))),
      #("USD", asset.Asset(id: "USD", name: "US Dollar", class: asset_class_from_string("Currency"))),
      #("USDT", asset.Asset(id: "USDT", name: "Tether", class: asset_class_from_string("Crypto"))),
      #("CNY", asset.Asset(id: "CNY", name: "Chinese Yuan", class: asset_class_from_string("Currency"))),
      #("HKD", asset.Asset(id: "HKD", name: "Hong Kong Dollar", class: asset_class_from_string("Currency")))
    ],
    markets: [
      #(
        "binance_spot_crypto",
        market.Market(
          exchange: "binance",
          asset_class: asset_class_from_string("Crypto"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string("TwentyFourSeven"),
            fees: rules.FeeSchedule(
              maker_bps: 1,
              taker_bps: 1,
              min_commission_usd: 0.10,
              platform_fee_bps: 0
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: [#("D1", 1000), #("H1", 1000), #("H4", 500)],
              max_history_days: [#("D1", 3650), #("H1", 730), #("H4", 1825)],
              rate_limit_req_per_sec: 50,
              rate_limit_req_per_min: 1200,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True
            ),
            order_types: ["Market", "Limit", "StopLimit", "StopMarket"],
            leverage_limits: [#("spot", 1), #("margin", 10), #("futures", 125)],
            settlement: settlement_type_from_string("Instant"),
            min_order_size: 0.00001,
            price_precision: 8,
            lot_size: 0.00001,
            price_limits: None,
            short_selling_allowed: True,
            auction_mechanism: None,
            margin_model: [#("initial", 0.5), #("maintenance", 0.25)],
            circuit_breaker: None,
            corporate_actions: "standard",
            dividend_handling: "none",
            withholding_tax: None,
            convert_hours: None
          )
        )
      ),
      #(
        "binance_bstock",
        market.Market(
          exchange: "binance",
          asset_class: asset_class_from_string("BStock"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string("TwentyFourSeven"),
            fees: rules.FeeSchedule(
              maker_bps: 10,
              taker_bps: 10,
              min_commission_usd: 0.01,
              platform_fee_bps: 0
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: [#("D1", 1000), #("H1", 1000)],
              max_history_days: [#("D1", 3650), #("H1", 730)],
              rate_limit_req_per_sec: 50,
              rate_limit_req_per_min: 1200,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True
            ),
            order_types: ["Market", "Limit"],
            leverage_limits: [#("spot", 1)],
            settlement: settlement_type_from_string("Instant"),
            min_order_size: 0.01,
            price_precision: 2,
            lot_size: 0.01,
            price_limits: None,
            short_selling_allowed: True,
            auction_mechanism: None,
            margin_model: [#("initial", 1.0), #("maintenance", 1.0)],
            circuit_breaker: None,
            corporate_actions: "bstock",
            dividend_handling: "multiplier_rebase",
            withholding_tax: Some(0.30),
            convert_hours: Some("US_RTH")
          )
        )
      ),
      #(
        "ib_equity",
        market.Market(
          exchange: "ib",
          asset_class: asset_class_from_string("Equity"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string("RTH;09:30;16:00;America/New_York"),
            fees: rules.FeeSchedule(
              maker_bps: 0,
              taker_bps: 5,
              min_commission_usd: 1.00,
              platform_fee_bps: 0
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: [#("D1", 2520), #("H1", 5000)],
              max_history_days: [#("D1", 7560), #("H1", 730)],
              rate_limit_req_per_sec: 50,
              rate_limit_req_per_min: 3000,
              max_concurrent_requests: 5,
              requires_pagination: True,
              supports_streaming: False
            ),
            order_types: ["Market", "Limit", "Stop", "StopLimit", "TrailingStop"],
            leverage_limits: [#("cash", 1), #("margin", 4)],
            settlement: settlement_type_from_string("TPlus2"),
            min_order_size: 1.0,
            price_precision: 2,
            lot_size: 1.0,
            price_limits: None,
            short_selling_allowed: True,
            auction_mechanism: Some(auction_type_from_string("Both")),
            margin_model: [#("initial", 0.5), #("maintenance", 0.25)],
            circuit_breaker: Some(circuit_breaker_from_string("CircuitBreaker:0.07:300:15")),
            corporate_actions: "standard",
            dividend_handling: "cash",
            withholding_tax: Some(0.30),
            convert_hours: None
          )
        )
      ),
      #(
        "futu_hk_equity",
        market.Market(
          exchange: "futu",
          asset_class: asset_class_from_string("Equity"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string("Custom;09:30:12:00:Asia/Hong_Kong|13:00:16:00:Asia/Hong_Kong"),
            fees: rules.FeeSchedule(
              maker_bps: 0,
              taker_bps: 8,
              min_commission_usd: 2.00,
              platform_fee_bps: 3
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: [#("D1", 1260), #("H1", 2000)],
              max_history_days: [#("D1", 2520), #("H1", 365)],
              rate_limit_req_per_sec: 10,
              rate_limit_req_per_min: 100,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True
            ),
            order_types: ["Market", "Limit", "Stop", "StopLimit"],
            leverage_limits: [#("cash", 1), #("margin", 5)],
            settlement: settlement_type_from_string("TPlus2"),
            min_order_size: 1.0,
            price_precision: 3,
            lot_size: 100.0,
            price_limits: Some(rules.PriceLimits(max_up_pct: 0.10, max_down_pct: 0.10)),
            short_selling_allowed: False,
            auction_mechanism: Some(auction_type_from_string("Both")),
            margin_model: [#("initial", 0.5), #("maintenance", 0.3)],
            circuit_breaker: Some(circuit_breaker_from_string("CircuitBreaker:0.10:60:30")),
            corporate_actions: "standard",
            dividend_handling: "cash",
            withholding_tax: Some(0.00),
            convert_hours: None
          )
        )
      ),
      #(
        "futu_us_equity",
        market.Market(
          exchange: "futu",
          asset_class: asset_class_from_string("Equity"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string("RTH;09:30;16:00;America/New_York"),
            fees: rules.FeeSchedule(
              maker_bps: 0,
              taker_bps: 4,
              min_commission_usd: 0.99,
              platform_fee_bps: 3
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: [#("D1", 2000), #("H1", 5000)],
              max_history_days: [#("D1", 5040), #("H1", 730)],
              rate_limit_req_per_sec: 10,
              rate_limit_req_per_min: 100,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True
            ),
            order_types: ["Market", "Limit", "Stop", "StopLimit"],
            leverage_limits: [#("cash", 1), #("margin", 4)],
            settlement: settlement_type_from_string("TPlus2"),
            min_order_size: 1.0,
            price_precision: 2,
            lot_size: 1.0,
            price_limits: None,
            short_selling_allowed: True,
            auction_mechanism: Some(auction_type_from_string("Both")),
            margin_model: [#("initial", 0.5), #("maintenance", 0.25)],
            circuit_breaker: Some(circuit_breaker_from_string("CircuitBreaker:0.07:300:15")),
            corporate_actions: "standard",
            dividend_handling: "cash",
            withholding_tax: Some(0.30),
            convert_hours: None
          )
        )
      ),
      #(
        "futu_futures",
        market.Market(
          exchange: "futu",
          asset_class: asset_class_from_string("Future"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string("TwentyFourFive"),
            fees: rules.FeeSchedule(
              maker_bps: 2,
              taker_bps: 2,
              min_commission_usd: 2.00,
              platform_fee_bps: 0
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: [#("D1", 1000), #("H1", 5000)],
              max_history_days: [#("D1", 2520), #("H1", 730)],
              rate_limit_req_per_sec: 10,
              rate_limit_req_per_min: 100,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True
            ),
            order_types: ["Market", "Limit", "Stop", "StopLimit"],
            leverage_limits: [#("futures", 20)],
            settlement: settlement_type_from_string("TPlus1"),
            min_order_size: 1.0,
            price_precision: 2,
            lot_size: 1.0,
            price_limits: None,
            short_selling_allowed: True,
            auction_mechanism: None,
            margin_model: [#("initial", 0.1), #("maintenance", 0.05)],
            circuit_breaker: None,
            corporate_actions: "standard",
            dividend_handling: "none",
            withholding_tax: None,
            convert_hours: None
          )
        )
      ),
      #(
        "futu_forex",
        market.Market(
          exchange: "futu",
          asset_class: asset_class_from_string("Currency"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string("TwentyFourFive"),
            fees: rules.FeeSchedule(
              maker_bps: 1,
              taker_bps: 1,
              min_commission_usd: 0.00,
              platform_fee_bps: 0
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: [#("D1", 2000), #("H1", 5000)],
              max_history_days: [#("D1", 3650), #("H1", 730)],
              rate_limit_req_per_sec: 10,
              rate_limit_req_per_min: 100,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True
            ),
            order_types: ["Market", "Limit", "Stop", "StopLimit"],
            leverage_limits: [#("forex", 50)],
            settlement: settlement_type_from_string("TPlus2"),
            min_order_size: 1000.0,
            price_precision: 5,
            lot_size: 1000.0,
            price_limits: None,
            short_selling_allowed: True,
            auction_mechanism: None,
            margin_model: [#("initial", 0.02), #("maintenance", 0.01)],
            circuit_breaker: None,
            corporate_actions: "standard",
            dividend_handling: "none",
            withholding_tax: None,
            convert_hours: None
          )
        )
      )
    ],
    symbols: [
      #(
        "BTCUSDT",
        symbol.Symbol(
          market_id: "binance_spot_crypto",
          asset_id: "BTC",
          market_symbol: "BTCUSDT",
          base_asset: asset.AssetRef(id: "BTC", name: "Bitcoin", class: asset_class_from_string("Crypto")),
          quote_asset: asset.AssetRef(id: "USDT", name: "Tether", class: asset_class_from_string("Crypto")),
          available_brokers: ["binance"],
          available_data_providers: ["binance"],
          primary_execution_venue: "binance"
        )
      ),
      #(
        "SPY",
        symbol.Symbol(
          market_id: "ib_equity",
          asset_id: "SPY",
          market_symbol: "SPY",
          base_asset: asset.AssetRef(id: "SPY", name: "SPDR S&P 500 ETF Trust", class: asset_class_from_string("ETF")),
          quote_asset: asset.AssetRef(id: "USD", name: "US Dollar", class: asset_class_from_string("Currency")),
          available_brokers: ["ib", "futu"],
          available_data_providers: ["ib", "futu", "polygon"],
          primary_execution_venue: "ib"
        )
      ),
      #(
        "SPY_FUTU",
        symbol.Symbol(
          market_id: "futu_us_equity",
          asset_id: "SPY",
          market_symbol: "SPY",
          base_asset: asset.AssetRef(id: "SPY", name: "SPDR S&P 500 ETF Trust", class: asset_class_from_string("ETF")),
          quote_asset: asset.AssetRef(id: "USD", name: "US Dollar", class: asset_class_from_string("Currency")),
          available_brokers: ["futu"],
          available_data_providers: ["futu"],
          primary_execution_venue: "futu"
        )
      )
    ],
    timeframe_settings: [
      #(
        "BTCUSDT_H1",
        indicators.TimeframeSettings(
          sma_tiny_window_size: 7,
          sma_small_window_size: 70,
          sma_medium_window_size: 140,
          sma_large_window_size: 252,
          kdj_k_period: 3,
          kdj_d_period: 2,
          window_kdj_size: 9,
          bb_multiplier: 1.99,
          sma_for_bbm: indicators.SmaForBbmMedium,
          branch_exit_leaf_size: 40
        )
      ),
      #(
        "BTCUSDT_D1",
        indicators.TimeframeSettings(
          sma_tiny_window_size: 7,
          sma_small_window_size: 70,
          sma_medium_window_size: 140,
          sma_large_window_size: 252,
          kdj_k_period: 3,
          kdj_d_period: 2,
          window_kdj_size: 9,
          bb_multiplier: 1.99,
          sma_for_bbm: indicators.SmaForBbmMedium,
          branch_exit_leaf_size: 40
        )
      ),
      #(
        "SPY_H1",
        indicators.TimeframeSettings(
          sma_tiny_window_size: 7,
          sma_small_window_size: 70,
          sma_medium_window_size: 140,
          sma_large_window_size: 252,
          kdj_k_period: 3,
          kdj_d_period: 2,
          window_kdj_size: 9,
          bb_multiplier: 1.99,
          sma_for_bbm: indicators.SmaForBbmMedium,
          branch_exit_leaf_size: 40
        )
      ),
      #(
        "SPY_D1",
        indicators.TimeframeSettings(
          sma_tiny_window_size: 7,
          sma_small_window_size: 70,
          sma_medium_window_size: 140,
          sma_large_window_size: 252,
          kdj_k_period: 3,
          kdj_d_period: 2,
          window_kdj_size: 9,
          bb_multiplier: 1.99,
          sma_for_bbm: indicators.SmaForBbmMedium,
          branch_exit_leaf_size: 40
        )
      )
    ]
  )
}

// ============================================================================
// Accessor Functions
// ============================================================================

pub fn get_exchange(config: AppConfig, id: String) -> Option(exchange.Exchange) {
  case list.find(config.exchanges, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_asset(config: AppConfig, id: String) -> Option(asset.Asset) {
  case list.find(config.assets, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_market(config: AppConfig, id: String) -> Option(market.Market) {
  case list.find(config.markets, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_symbol(config: AppConfig, id: String) -> Option(symbol.Symbol) {
  case list.find(config.symbols, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn config_get_tfs(config: AppConfig, id: String) -> Option(indicators.TimeframeSettings) {
  case list.find(config.timeframe_settings, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_market_rules(config: AppConfig, market_id: String) -> Option(rules.MarketRules) {
  get_market(config, market_id) |> option.map(fn(m) { m.rules })
}

// ============================================================================
// Environment Override
// ============================================================================

pub fn with_env_overrides(config: AppConfig) -> AppConfig {
  config
}