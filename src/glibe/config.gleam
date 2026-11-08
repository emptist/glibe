//// Configuration for the entire trading system. Gleam IS the config: no JSON,
//// no parser, no `panic` on an unknown spelling.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`.
//// Ruling: `docs/RULINGS.md` R22 (a name is not the thing), R23 (no composite
//// string keys, no stand-in tables), R13, R19, R20.
////
//// Ownership is a VALUE here, not a lookup: `AppConfig.desk` is a `Desk` built
//// from `Symbol` names, `Instrument` values and `Interval`-keyed `Timeframe`s.
//// The old `symbols` / `timeframe_settings` tables, their `"BTCUSDT_H1"`
//// composite keys and the `get_symbol` / `config_get_tfs` `list.find`
//// accessors are DELETED, not adapted (R23). The parameter block each engine
//// runs on is `Timeframe.settings`; there is no second dictionary.
////
//// Per-interval data limits are `Dict(Interval, Int)` here (R21 / 04-02).
//// The three catalog tables (`exchanges` / `assets` / `markets`) stay as they
//// are. They are NOT part of the `Desk` ownership chain and have no typed
//// relation to `Instrument`. R26: only `Broker ▸ Instrument` is settled from
//// the data-source argument; the other relations are deliberately left open,
//// and types are added one at a time when a consumer actually needs one.
//// See `docs/RULINGS.md` R26 and the 04-03 plan's out-of-scope section.

import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import glibe/api/interval

// ============================================================================
// Config Types (structure only, types imported from their modules)
// ============================================================================

pub type AppConfig {
  AppConfig(
    version: Int,
    exchanges: List(#(String, exchange.Exchange)),
    assets: List(#(String, asset.Asset)),
    markets: List(#(String, market.Market)),
    desk: desk.Desk,
  )
}

import glibe/api/asset.{asset_class_from_string}
import glibe/api/exchange
import glibe/api/market
import glibe/api/rules.{
  auction_type_from_string, circuit_breaker_from_string,
  settlement_type_from_string, trading_hours_from_string,
}
import glibe/api/symbol
import glibe/desk
import glibe/indicator_settings
import glibe/timeframe

// ============================================================================
// Default Configuration (Single Source of Truth)
// ============================================================================

pub fn default_config() -> AppConfig {
  // R23: one parameter block, carried by each engine. No second dictionary,
  // no composite `"BTCUSDT_H1"` key, no `list.find` lookup.
  let settings =
    indicator_settings.TimeframeSettings(
      sma_tiny_window_size: 7,
      sma_small_window_size: 70,
      sma_medium_window_size: 140,
      sma_large_window_size: 252,
      sma_huge_window_size: 504,
      kdj_window_size: 7,
      kdj_k_period: 3,
      kdj_m_period: 10,
      bb_multiplier: 1.99,
      sma_for_bbm: indicator_settings.SmaForBbmMedium,
      branch_exit_leaf_size: 40,
    )
  let btc =
    desk.new_instrument()
    |> desk.put_timeframe(interval.IntervalOneHour, timeframe.new(settings))
    |> desk.put_timeframe(interval.IntervalOneDay, timeframe.new(settings))
  let spy =
    desk.new_instrument()
    |> desk.put_timeframe(interval.IntervalOneHour, timeframe.new(settings))
    |> desk.put_timeframe(interval.IntervalOneDay, timeframe.new(settings))
  let spy_futu =
    desk.new_instrument()
    |> desk.put_timeframe(interval.IntervalOneHour, timeframe.new(settings))
    |> desk.put_timeframe(interval.IntervalOneDay, timeframe.new(settings))
  let binance =
    desk.put_instrument(desk.new_broker(), symbol.from_string("BTCUSDT"), btc)
  let ib =
    desk.put_instrument(desk.new_broker(), symbol.from_string("SPY"), spy)
  let futu =
    desk.put_instrument(
      desk.new_broker(),
      symbol.from_string("SPY_FUTU"),
      spy_futu,
    )
  let configured_desk =
    desk.new()
    |> desk.put_broker(desk.broker_id("binance"), binance)
    |> desk.put_broker(desk.broker_id("ib"), ib)
    |> desk.put_broker(desk.broker_id("futu"), futu)
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
          gateway_port: None,
        ),
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
          gateway_port: Some(5001),
        ),
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
          gateway_port: Some(11_111),
        ),
      ),
    ],
    assets: [
      #(
        "BTC",
        asset.Asset(
          id: "BTC",
          name: "Bitcoin",
          class: asset_class_from_string("Crypto"),
        ),
      ),
      #(
        "ETH",
        asset.Asset(
          id: "ETH",
          name: "Ethereum",
          class: asset_class_from_string("Crypto"),
        ),
      ),
      #(
        "SPY",
        asset.Asset(
          id: "SPY",
          name: "SPDR S&P 500 ETF Trust",
          class: asset_class_from_string("ETF"),
        ),
      ),
      #(
        "AAPL",
        asset.Asset(
          id: "AAPL",
          name: "Apple Inc.",
          class: asset_class_from_string("Equity"),
        ),
      ),
      #(
        "TSLA",
        asset.Asset(
          id: "TSLA",
          name: "Tesla Inc.",
          class: asset_class_from_string("BStock"),
        ),
      ),
      #(
        "USD",
        asset.Asset(
          id: "USD",
          name: "US Dollar",
          class: asset_class_from_string("Currency"),
        ),
      ),
      #(
        "USDT",
        asset.Asset(
          id: "USDT",
          name: "Tether",
          class: asset_class_from_string("Crypto"),
        ),
      ),
      #(
        "CNY",
        asset.Asset(
          id: "CNY",
          name: "Chinese Yuan",
          class: asset_class_from_string("Currency"),
        ),
      ),
      #(
        "HKD",
        asset.Asset(
          id: "HKD",
          name: "Hong Kong Dollar",
          class: asset_class_from_string("Currency"),
        ),
      ),
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
              min_commission_usd: 0.1,
              platform_fee_bps: 0,
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: dict.from_list([
                #(interval.IntervalOneDay, 1000),
                #(interval.IntervalOneHour, 1000),
                #(interval.IntervalFourHour, 500),
              ]),
              max_history_days: dict.from_list([
                #(interval.IntervalOneDay, 3650),
                #(interval.IntervalOneHour, 730),
                #(interval.IntervalFourHour, 1825),
              ]),
              rate_limit_req_per_sec: 50,
              rate_limit_req_per_min: 1200,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True,
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
            convert_hours: None,
          ),
        ),
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
              platform_fee_bps: 0,
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: dict.from_list([
                #(interval.IntervalOneDay, 1000),
                #(interval.IntervalOneHour, 1000),
              ]),
              max_history_days: dict.from_list([
                #(interval.IntervalOneDay, 3650),
                #(interval.IntervalOneHour, 730),
              ]),
              rate_limit_req_per_sec: 50,
              rate_limit_req_per_min: 1200,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True,
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
            withholding_tax: Some(0.3),
            convert_hours: Some("US_RTH"),
          ),
        ),
      ),
      #(
        "ib_equity",
        market.Market(
          exchange: "ib",
          asset_class: asset_class_from_string("Equity"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string(
              "RTH;09:30;16:00;America/New_York",
            ),
            fees: rules.FeeSchedule(
              maker_bps: 0,
              taker_bps: 5,
              min_commission_usd: 1.0,
              platform_fee_bps: 0,
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: dict.from_list([
                #(interval.IntervalOneDay, 2520),
                #(interval.IntervalOneHour, 5000),
              ]),
              max_history_days: dict.from_list([
                #(interval.IntervalOneDay, 7560),
                #(interval.IntervalOneHour, 730),
              ]),
              rate_limit_req_per_sec: 50,
              rate_limit_req_per_min: 3000,
              max_concurrent_requests: 5,
              requires_pagination: True,
              supports_streaming: False,
            ),
            order_types: [
              "Market",
              "Limit",
              "Stop",
              "StopLimit",
              "TrailingStop",
            ],
            leverage_limits: [#("cash", 1), #("margin", 4)],
            settlement: settlement_type_from_string("TPlus2"),
            min_order_size: 1.0,
            price_precision: 2,
            lot_size: 1.0,
            price_limits: None,
            short_selling_allowed: True,
            auction_mechanism: Some(auction_type_from_string("Both")),
            margin_model: [#("initial", 0.5), #("maintenance", 0.25)],
            circuit_breaker: Some(circuit_breaker_from_string(
              "CircuitBreaker;0.07;300;15",
            )),
            corporate_actions: "standard",
            dividend_handling: "cash",
            withholding_tax: Some(0.3),
            convert_hours: None,
          ),
        ),
      ),
      #(
        "futu_hk_equity",
        market.Market(
          exchange: "futu",
          asset_class: asset_class_from_string("Equity"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string(
              "Custom;09:30,12:00,Asia/Hong_Kong|13:00,16:00,Asia/Hong_Kong",
            ),
            fees: rules.FeeSchedule(
              maker_bps: 0,
              taker_bps: 8,
              min_commission_usd: 2.0,
              platform_fee_bps: 3,
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: dict.from_list([
                #(interval.IntervalOneDay, 1260),
                #(interval.IntervalOneHour, 2000),
              ]),
              max_history_days: dict.from_list([
                #(interval.IntervalOneDay, 2520),
                #(interval.IntervalOneHour, 365),
              ]),
              rate_limit_req_per_sec: 10,
              rate_limit_req_per_min: 100,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True,
            ),
            order_types: ["Market", "Limit", "Stop", "StopLimit"],
            leverage_limits: [#("cash", 1), #("margin", 5)],
            settlement: settlement_type_from_string("TPlus2"),
            min_order_size: 1.0,
            price_precision: 3,
            lot_size: 100.0,
            price_limits: Some(rules.PriceLimits(
              max_up_pct: 0.1,
              max_down_pct: 0.1,
            )),
            short_selling_allowed: False,
            auction_mechanism: Some(auction_type_from_string("Both")),
            margin_model: [#("initial", 0.5), #("maintenance", 0.3)],
            circuit_breaker: Some(circuit_breaker_from_string(
              "CircuitBreaker;0.10;60;30",
            )),
            corporate_actions: "standard",
            dividend_handling: "cash",
            withholding_tax: Some(0.0),
            convert_hours: None,
          ),
        ),
      ),
      #(
        "futu_us_equity",
        market.Market(
          exchange: "futu",
          asset_class: asset_class_from_string("Equity"),
          rules: rules.MarketRules(
            trading_hours: trading_hours_from_string(
              "RTH;09:30;16:00;America/New_York",
            ),
            fees: rules.FeeSchedule(
              maker_bps: 0,
              taker_bps: 4,
              min_commission_usd: 0.99,
              platform_fee_bps: 3,
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: dict.from_list([
                #(interval.IntervalOneDay, 2000),
                #(interval.IntervalOneHour, 5000),
              ]),
              max_history_days: dict.from_list([
                #(interval.IntervalOneDay, 5040),
                #(interval.IntervalOneHour, 730),
              ]),
              rate_limit_req_per_sec: 10,
              rate_limit_req_per_min: 100,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True,
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
            circuit_breaker: Some(circuit_breaker_from_string(
              "CircuitBreaker;0.07;300;15",
            )),
            corporate_actions: "standard",
            dividend_handling: "cash",
            withholding_tax: Some(0.3),
            convert_hours: None,
          ),
        ),
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
              min_commission_usd: 2.0,
              platform_fee_bps: 0,
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: dict.from_list([
                #(interval.IntervalOneDay, 1000),
                #(interval.IntervalOneHour, 5000),
              ]),
              max_history_days: dict.from_list([
                #(interval.IntervalOneDay, 2520),
                #(interval.IntervalOneHour, 730),
              ]),
              rate_limit_req_per_sec: 10,
              rate_limit_req_per_min: 100,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True,
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
            convert_hours: None,
          ),
        ),
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
              min_commission_usd: 0.0,
              platform_fee_bps: 0,
            ),
            data_limits: rules.DataRequestLimits(
              max_bars_per_request: dict.from_list([
                #(interval.IntervalOneDay, 2000),
                #(interval.IntervalOneHour, 5000),
              ]),
              max_history_days: dict.from_list([
                #(interval.IntervalOneDay, 3650),
                #(interval.IntervalOneHour, 730),
              ]),
              rate_limit_req_per_sec: 10,
              rate_limit_req_per_min: 100,
              max_concurrent_requests: 5,
              requires_pagination: False,
              supports_streaming: True,
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
            convert_hours: None,
          ),
        ),
      ),
    ],
    desk: configured_desk,
  )
}

// ============================================================================
// Accessor Functions
// ============================================================================

pub fn get_exchange(
  config: AppConfig,
  id: String,
) -> Option(exchange.Exchange) {
  case
    list.find(config.exchanges, fn(pair) {
      let #(k, _) = pair
      k == id
    })
  {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_asset(config: AppConfig, id: String) -> Option(asset.Asset) {
  case
    list.find(config.assets, fn(pair) {
      let #(k, _) = pair
      k == id
    })
  {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_market(config: AppConfig, id: String) -> Option(market.Market) {
  case
    list.find(config.markets, fn(pair) {
      let #(k, _) = pair
      k == id
    })
  {
    Ok(pair) -> Some(pair.1)
    Error(_) -> None
  }
}

pub fn get_market_rules(
  config: AppConfig,
  market_id: String,
) -> Option(rules.MarketRules) {
  get_market(config, market_id) |> option.map(fn(m) { m.rules })
}

// ============================================================================
// Environment Override
// ============================================================================

pub fn with_env_overrides(config: AppConfig) -> AppConfig {
  config
}
