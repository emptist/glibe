//// Market rules and trading parameters.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-02-PLAN.md`.
//// Ruling: `docs/RULINGS.md` R13 (closed sets are types), R19 (docs-first).
////
//// Per-interval data limits used to be `List(#(String, Int))`, and one of
//// those strings named a four-hour span the `Interval` type could not
//// represent. Both tables are now `Dict(Interval, Int)`: one interval, one
//// limit, and a typed key the compiler can check. The accessors return a
//// domain error carrying that key, never `Error(String)` and never an
//// `Option` that hides the reason.
//// Ruling `docs/RULINGS.md` R21 names every variant in full; wire spellings
//// such as `"1h"` live only in the codec, never in a type constructor.

import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/string
import glibe/api/interval.{type Interval}

/// Fee schedule per market
pub type FeeSchedule {
  FeeSchedule(
    maker_bps: Int,
    taker_bps: Int,
    min_commission_usd: Float,
    platform_fee_bps: Int,
  )
}

/// Data request limits per market. The two per-interval tables are keyed by
/// `Interval` values, not spellings, so an unrepresentable interval such as
/// the old four-hour string key cannot be written at all.
pub type DataRequestLimits {
  DataRequestLimits(
    /// Maximum bars one request may ask for, keyed by interval.
    max_bars_per_request: Dict(Interval, Int),
    /// Maximum days of history available, keyed by interval.
    max_history_days: Dict(Interval, Int),
    rate_limit_req_per_sec: Int,
    rate_limit_req_per_min: Int,
    max_concurrent_requests: Int,
    requires_pagination: Bool,
    supports_streaming: Bool,
  )
}

/// A per-interval limit was not configured. One variant per missing table,
/// each carrying the `Interval` that was asked for — never `Error(String)`.
pub type LimitError {
  NoBarLimit(Interval)
  NoHistoryLimit(Interval)
}

/// The maximum number of bars one request may ask for on `interval`.
/// A missing entry is `NoBarLimit(interval)`, not `None` and not a `panic`.
pub fn max_bars_per_request_for(
  limits: DataRequestLimits,
  interval: Interval,
) -> Result(Int, LimitError) {
  case dict.get(limits.max_bars_per_request, interval) {
    Ok(limit) -> Ok(limit)
    Error(Nil) -> Error(NoBarLimit(interval))
  }
}

/// The maximum number of days of history available on `interval`.
/// A missing entry is `NoHistoryLimit(interval)`.
pub fn max_history_days_for(
  limits: DataRequestLimits,
  interval: Interval,
) -> Result(Int, LimitError) {
  case dict.get(limits.max_history_days, interval) {
    Ok(limit) -> Ok(limit)
    Error(Nil) -> Error(NoHistoryLimit(interval))
  }
}

/// Trading hours specification
pub type TradingHours {
  TwentyFourSeven
  // Crypto, BStock
  TwentyFourFive
  // Forex 24/5
  RTH(open: String, close: String, timezone: String)
  // "09:30", "16:00", "America/New_York"
  Custom(List(Session))
  // China 2-session, HK 2-session
}

/// Session within a trading day
pub type Session {
  Session(open: String, close: String, timezone: String)
}

/// Settlement type
pub type SettlementType {
  Instant
  TPlus1
  TPlus2
  CryptoOnChain
}

/// Price limits (for China A-shares etc.)
pub type PriceLimits {
  PriceLimits(max_up_pct: Float, max_down_pct: Float)
}

/// Auction type
pub type AuctionType {
  Opening
  Closing
  Both
}

/// Circuit breaker
pub type CircuitBreaker {
  CircuitBreaker(threshold_pct: Float, window_seconds: Int, halt_minutes: Int)
}

/// Parse TradingHours from string (for config)
/// Formats: "TwentyFourSeven", "TwentyFourFive", "RTH;09:30;16:00;America/New_York",
///           "Custom;09:30,12:00,Asia/Hong_Kong|13:00,16:00,Asia/Hong_Kong"
/// Session fields use "," as separator (time values contain ":" so ":" cannot be used).
pub fn trading_hours_from_string(s: String) -> TradingHours {
  case string.split(s, ";") {
    ["TwentyFourSeven"] -> TwentyFourSeven
    ["TwentyFourFive"] -> TwentyFourFive
    ["RTH", open, close, timezone] ->
      RTH(open: open, close: close, timezone: timezone)
    ["Custom", sessions_str] ->
      Custom(
        list.map(string.split(sessions_str, "|"), fn(sess) {
          case string.split(sess, ",") {
            [open, close, timezone] ->
              Session(open: open, close: close, timezone: timezone)
            _ -> panic as "Invalid session format"
          }
        }),
      )
    _ -> panic as "Unknown TradingHours format"
  }
}

/// Parse SettlementType from string (for config)
pub fn settlement_type_from_string(s: String) -> SettlementType {
  case s {
    "Instant" -> Instant
    "TPlus1" -> TPlus1
    "TPlus2" -> TPlus2
    "CryptoOnChain" -> CryptoOnChain
    _ -> panic as "Unknown SettlementType"
  }
}

/// Parse AuctionType from string (for config)
pub fn auction_type_from_string(s: String) -> AuctionType {
  case s {
    "Opening" -> Opening
    "Closing" -> Closing
    "Both" -> Both
    _ -> panic as "Unknown AuctionType"
  }
}

/// Parse CircuitBreaker from string (for config)
/// Format: "CircuitBreaker;0.07;300;15"
pub fn circuit_breaker_from_string(s: String) -> CircuitBreaker {
  case string.split(s, ";") {
    ["CircuitBreaker", threshold_str, window_str, halt_str] -> {
      let threshold_pct = case float.parse(threshold_str) {
        Ok(v) -> v
        Error(_) -> panic as "Invalid threshold_pct"
      }
      let window_seconds = case int.parse(window_str) {
        Ok(v) -> v
        Error(_) -> panic as "Invalid window_seconds"
      }
      let halt_minutes = case int.parse(halt_str) {
        Ok(v) -> v
        Error(_) -> panic as "Invalid halt_minutes"
      }
      CircuitBreaker(
        threshold_pct: threshold_pct,
        window_seconds: window_seconds,
        halt_minutes: halt_minutes,
      )
    }
    _ -> panic as "Invalid CircuitBreaker format"
  }
}

/// Market-specific trading rules
pub type MarketRules {
  MarketRules(
    trading_hours: TradingHours,
    fees: FeeSchedule,
    data_limits: DataRequestLimits,
    order_types: List(String),
    leverage_limits: List(#(String, Int)),
    settlement: SettlementType,
    min_order_size: Float,
    price_precision: Int,
    lot_size: Float,
    price_limits: Option(PriceLimits),
    short_selling_allowed: Bool,
    auction_mechanism: Option(AuctionType),
    margin_model: List(#(String, Float)),
    circuit_breaker: Option(CircuitBreaker),
    corporate_actions: String,
    dividend_handling: String,
    // "cash", "multiplier_rebase", "none"
    withholding_tax: Option(Float),
    convert_hours: Option(String),
  )
}
