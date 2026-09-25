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
    exchanges: List(#(String, Exchange)),
    assets: List(#(String, Asset)),
    markets: List(#(String, Market)),
    symbols: List(#(String, Symbol)),
    timeframe_settings: List(#(String, TimeframeSettings))
  )
}

// Import types from their proper modules
import glibe/api/exchange.{type Exchange}
import glibe/api/asset.{type Asset, type AssetClass, type AssetRef}
import glibe/api/market.{type Market}
import glibe/api/symbol.{type Symbol}
import glibe/api/rules.{type MarketRules, type FeeSchedule, type DataRequestLimits, type TradingHours, type Session, type SettlementType, type PriceLimits, type AuctionType, type CircuitBreaker}
import glibe/api/sourcebar.{type SourceBar}
import glibe/indicators.{type TimeframeSettings}

// ============================================================================
// Default Configuration (Single Source of Truth)
// ============================================================================

pub fn default_config() -> AppConfig {
  AppConfig(
    version: 1,
    exchanges: [
      #(
        "binance",
        Exchange(
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
        Exchange(
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
        Exchange(
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
      #("BTC", Asset(id: "BTC", name: "Bitcoin", class: AssetClass.Crypto)),
      #("ETH", Asset(id: "ETH", name: "Ethereum", class: AssetClass.Crypto)),
      #("SPY", Asset(id: "SPY", name: "SPDR S&P 500 ETF Trust", class: AssetClass.ETF)),
      #("AAPL", Asset(id: "AAPL", name: "Apple Inc.", class: AssetClass.Equity)),
      #("TSLA", Asset(id: "TSLA", name: "Tesla Inc.", class: AssetClass.BStock)),
      #("USD", Asset(id: "USD", name: "US Dollar", class: AssetClass.Currency)),
      #("USDT", Asset(id: "USDT", name: "Tether", class: AssetClass.Crypto)),
      #("CNY", Asset(id: "CNY", name: "Chinese Yuan", class: AssetClass.Currency)),
      #("HKD", Asset(id: "HKD", name: "Hong Kong Dollar", class: AssetClass.Currency))
    ],
    markets: [
      #(
        "binance_spot_crypto",
        Market(
          exchange: "binance",
          asset_class: AssetClass.Crypto,
          rules: MarketRules(
            trading_hours: TradingHours.TwentyFourSeven,
            fees: FeeSchedule(
              maker_bps: 1,
              taker_bps: 1,
              min_commission_usd: 0.10,
              platform_fee_bps: 0
            ),
            data_limits: DataRequestLimits(
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
            settlement: SettlementType.Instant,
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
        Market(
          exchange: "binance",
          asset_class: AssetClass.BStock,
          rules: MarketRules(
            trading_hours: TradingHours.TwentyFourSeven,
            fees: FeeSchedule(
              maker_bps: 10,
              taker_bps: 10,
              min_commission_usd: 0.01,
              platform_fee_bps: 0
            ),
            data_limits: DataRequestLimits(
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
            settlement: SettlementType.Instant,
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
        Market(
          exchange: "ib",
          asset_class: AssetClass.Equity,
          rules: MarketRules(
            trading_hours: TradingHours.RTH(open: "09:30", close: "16:00", timezone: "America/New_York"),
            fees: FeeSchedule(
              maker_bps: 0,
              taker_bps: 5,
              min_commission_usd: 1.00,
              platform_fee_bps: 0
            ),
            data_limits: DataRequestLimits(
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
            settlement: SettlementType.TPlus2,
            min_order_size: 1.0,
            price_precision: 2,
            lot_size: 1.0,
            price_limits: None,
            short_selling_allowed: True,
            auction_mechanism: Some(AuctionType.Both),
            margin_model: [#("initial", 0.5), #("maintenance", 0.25)],
            circuit_breaker: Some(CircuitBreaker(threshold_pct: 0.07, window_seconds: 300, halt_minutes: 15)),
            corporate_actions: "standard",
            dividend_handling: "cash",
            withholding_tax: Some(0.30),
            convert_hours: None
          )
        )
      ),
      #(
        "futu_hk_equity",
        Market(
          exchange: "futu",
          asset_class: AssetClass.Equity,
          rules: MarketRules(
            trading_hours: TradingHours.Custom([
              Session(open: "09:30", close: "12:00", timezone: "Asia/Hong_Kong"),
              Session(open: "13:00", close: "16:00", timezone: "Asia/Hong_Kong")
            ]),
            fees: FeeSchedule(
              maker_bps: 0,
              taker_bps: 8,
              min_commission_usd: 2.00,
              platform_fee_bps: 3
            ),
            data_limits: DataRequestLimits(
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
            settlement: SettlementType.TPlus2,
            min_order_size: 1.0,
            price_precision: 3,
            lot_size: 100.0,
            price_limits: Some(PriceLimits(max_up_pct: 0.10, max_down_pct: 0.10)),
            short_selling_allowed: False,
            auction_mechanism: Some(AuctionType.Both),
            margin_model: [#("initial", 0.5), #("maintenance", 0.3)],
            circuit_breaker: Some(CircuitBreaker(threshold_pct: 0.10, window_seconds: 60, halt_minutes: 30)),
            corporate_actions: "standard",
            dividend_handling: "cash",
            withholding_tax: Some(0.00),
            convert_hours: None
          )
        )
      ),
      #(
        "futu_us_equity",
        Market(
          exchange: "futu",
          asset_class: AssetClass.Equity,
          rules: MarketRules(
            trading_hours: TradingHours.RTH(open: "09:30", close: "16:00", timezone: "America/New_York"),
            fees: FeeSchedule(
              maker_bps: 0,
              taker_bps: 4,
              min_commission_usd: 0.99,
              platform_fee_bps: 3
            ),
            data_limits: DataRequestLimits(
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
            settlement: SettlementType.TPlus2,
            min_order_size: 1.0,
            price_precision: 2,
            lot_size: 1.0,
            price_limits: None,
            short_selling_allowed: True,
            auction_mechanism: Some(AuctionType.Both),
            margin_model: [#("initial", 0.5), #("maintenance", 0.25)],
            circuit_breaker: Some(CircuitBreaker(threshold_pct: 0.07, window_seconds: 300, halt_minutes: 15)),
            corporate_actions: "standard",
            dividend_handling: "cash",
            withholding_tax: Some(0.30),
            convert_hours: None
          )
        )
      ),
      #(
        "futu_futures",
        Market(
          exchange: "futu",
          asset_class: AssetClass.Future,
          rules: MarketRules(
            trading_hours: TradingHours.TwentyFourFive,
            fees: FeeSchedule(
              maker_bps: 2,
              taker_bps: 2,
              min_commission_usd: 2.00,
              platform_fee_bps: 0
            ),
            data_limits: DataRequestLimits(
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
            settlement: SettlementType.TPlus1,
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
        Market(
          exchange: "futu",
          asset_class: AssetClass.Currency,
          rules: MarketRules(
            trading_hours: TradingHours.TwentyFourFive,
            fees: FeeSchedule(
              maker_bps: 1,
              taker_bps: 1,
              min_commission_usd: 0.00,
              platform_fee_bps: 0
            ),
            data_limits: DataRequestLimits(
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
            settlement: SettlementType.TPlus2,
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
        Symbol(
          market_id: "binance_spot_crypto",
          asset_id: "BTC",
          market_symbol: "BTCUSDT",
          base_asset: AssetRef(id: "BTC", name: "Bitcoin", class: AssetClass.Crypto),
          quote_asset: AssetRef(id: "USDT", name: "Tether", class: AssetClass.Crypto),
          available_brokers: ["binance"],
          available_data_providers: ["binance"],
          primary_execution_venue: "binance"
        )
      ),
      #(
        "SPY",
        Symbol(
          market_id: "ib_equity",
          asset_id: "SPY",
          market_symbol: "SPY",
          base_asset: AssetRef(id: "SPY", name: "SPDR S&P 500 ETF Trust", class: AssetClass.ETF),
          quote_asset: AssetRef(id: "USD", name: "US Dollar", class: AssetClass.Currency),
          available_brokers: ["ib", "futu"],
          available_data_providers: ["ib", "futu", "polygon"],
          primary_execution_venue: "ib"
        )
      ),
      #(
        "SPY_FUTU",
        Symbol(
          market_id: "futu_us_equity",
          asset_id: "SPY",
          market_symbol: "SPY",
          base_asset: AssetRef(id: "SPY", name: "SPDR S&P 500 ETF Trust", class: AssetClass.ETF),
          quote_asset: AssetRef(id: "USD", name: "US Dollar", class: AssetClass.Currency),
          available_brokers: ["futu"],
          available_data_providers: ["futu"],
          primary_execution_venue: "futu"
        )
      )
    ],
    timeframe_settings: [
      #(
        "BTCUSDT_H1",
        TimeframeSettings(
          sma_tiny: 7,
          sma_small: 70,
          sma_medium: 140,
          sma_large: 252,
          kdj_k_period: 3,
          kdj_d_period: 2,
          bb_multiplier: 1.99,
          sma_for_bbm: "sma_medium",
          branch_exit_leaf_size: 40
        )
      ),
      #(
        "BTCUSDT_D1",
        TimeframeSettings(
          sma_tiny: 7,
          sma_small: 70,
          sma_medium: 140,
          sma_large: 252,
          kdj_k_period: 3,
          kdj_d_period: 2,
          bb_multiplier: 1.99,
          sma_for_bbm: "sma_medium",
          branch_exit_leaf_size: 40
        )
      ),
      #(
        "SPY_H1",
        TimeframeSettings(
          sma_tiny: 7,
          sma_small: 70,
          sma_medium: 140,
          sma_large: 252,
          kdj_k_period: 3,
          kdj_d_period: 2,
          bb_multiplier: 1.99,
          sma_for_bbm: "sma_medium",
          branch_exit_leaf_size: 40
        )
      ),
      #(
        "SPY_D1",
        TimeframeSettings(
          sma_tiny: 7,
          sma_small: 70,
          sma_medium: 140,
          sma_large: 252,
          kdj_k_period: 3,
          kdj_d_period: 2,
          bb_multiplier: 1.99,
          sma_for_bbm: "sma_medium",
          branch_exit_leaf_size: 40
        )
      )
    ]
  )
}

// ============================================================================
// Accessor Functions
// ============================================================================

pub fn get_exchange(config: AppConfig, id: String) -> Option(Exchange) {
  case list.find(config.exchanges, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_asset(config: AppConfig, id: String) -> Option(Asset) {
  case list.find(config.assets, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_market(config: AppConfig, id: String) -> Option(Market) {
  case list.find(config.markets, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_symbol(config: AppConfig, id: String) -> Option(Symbol) {
  case list.find(config.symbols, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_timeframe_settings(config: AppConfig, id: String) -> Option(TimeframeSettings) {
  case list.find(config.timeframe_settings, fn(pair) {
    let #(k, _) = pair
    k == id
  }) {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_market_rules(config: AppConfig, market_id: String) -> Option(MarketRules) {
  get_market(config, market_id) |> option.map(fn(m) { m.rules })
}

// ============================================================================
// Environment Override
// ============================================================================

pub fn with_env_overrides(config: AppConfig) -> AppConfig {
  config
}