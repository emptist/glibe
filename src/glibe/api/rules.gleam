/// Market rules and trading parameters

import gleam/option.{type Option, Some, None}

/// Fee schedule per market
pub type FeeSchedule {
  FeeSchedule(
    maker_bps: Int,
    taker_bps: Int,
    min_commission_usd: Float,
    platform_fee_bps: Int
  )
}

/// Data request limits per market
pub type DataRequestLimits {
  DataRequestLimits(
    max_bars_per_request: List(#(String, Int)),   // per interval
    max_history_days: List(#(String, Int)),       // per interval
    rate_limit_req_per_sec: Int,
    rate_limit_req_per_min: Int,
    max_concurrent_requests: Int,
    requires_pagination: Bool,
    supports_streaming: Bool
  )
}

/// Trading hours specification
pub type TradingHours {
  TwentyFourSeven          // Crypto, BStock
  TwentyFourFive           // Forex 24/5
  RTH(open: String, close: String, timezone: String)  // "09:30", "16:00", "America/New_York"
  Custom(List(Session))    // China 2-session, HK 2-session
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
    dividend_handling: String,        // "cash", "multiplier_rebase", "none"
    withholding_tax: Option(Float),
    convert_hours: Option(String)
  )
}