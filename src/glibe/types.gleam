import gleam/dynamic/decode
import gleam/json.{type Json}

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

pub type Interval {
  D1
  H1
  W1
  MO1  // 1 month
  MIN1   // 1 minute
  MIN15  // 15 minutes
  MIN30  // 30 minutes
}

pub type MarketType {
  Stock   // Traditional markets (IB): ~20 trading days/month, RTH/ETH
  Crypto  // Binance: 30 days/month, 24/7 trading
}

pub type BollingerBands {
  BollingerBands(
    bb_m: Float,
    bb_u3: Float,
    bb_l3: Float,
    bb_u2: Float,
    bb_u1: Float,
    bb_l1: Float,
    bb_l2: Float,
  )
}

pub type KDJ {
  KDJ(k: Float, d: Float, j: Float, m: Float)
}

pub type MarketSession {
  RTH
  ETH
  OTH
  CLOSED
}

pub type NextSession {
  NextSession(session: String, time: String)
}

pub type MarketTime {
  MarketTime(
    is_rth: Bool,
    is_eth: Bool,
    is_oth: Bool,
    session: MarketSession,
    et_time: String,
    next_session: NextSession,
  )
}

pub type RiskCheck {
  RiskCheck(check: String, ok: Bool, message: String)
}

pub type RiskResult {
  RiskResult(ok: Bool, results: List(RiskCheck))
}

pub type RiskSettings {
  RiskSettings(
    min_net_liquidation: Float,
    min_day_trades_remaining: Int,
    max_position_percent: Float,
    max_total_exposure: Float,
    max_daily_loss: Float,
    order_interval_seconds: Int,
    pdt_protect_fund_level: Float,
  )
}

pub type IndicatorConfig {
  IndicatorConfig(
    sma_period: Int,
    bb_window: Int,
    bb_multiplier: Float,
    bb_std_fallback: Float,
    kdj_period: Int,
    kdj_k_period: Int,
    kdj_d_period: Int,
    kdj_m_period: Int,
  )
}

pub fn default_indicator_config() -> IndicatorConfig {
  IndicatorConfig(
    sma_period: 7,
    bb_window: 140,
    bb_multiplier: 1.99,
    bb_std_fallback: 0.1,
    kdj_period: 14,
    kdj_k_period: 3,
    kdj_d_period: 2,
    kdj_m_period: 10,
  )
}

pub type RiskStatus {
  RiskStatus(
    net_liquidation: Float,
    day_trades_remaining: Int,
    gross_position_value: Float,
    daily_pnl: Float,
    trades_today: Int,
  )
}

pub type OrderType {
  Market
  Limit
  Stop
  StopLimit
  TrailingStop
}

pub type OrderAction {
  Buy
  Sell
}

pub type OrderStatus {
  PendingSubmit
  PreSubmitted
  Submitted
  Filled
  PartiallyFilled
  Cancelled
  Rejected
  ApiPending
  ApiCancelled
  Inactive
}

pub type Order {
  Order(
    id: Int,
    symbol: String,
    action: OrderAction,
    qty: Int,
    order_type: OrderType,
    price: Float,
    status: OrderStatus,
    filled_qty: Int,
    avg_fill_price: Float,
    timestamp: String,
  )
}

pub type Position {
  Position(
    symbol: String,
    sec_type: String,
    currency: String,
    exchange: String,
    qty: Int,
    avg_cost: Float,
    market_value: Float,
    pnl: Float,
    realized_pnl: Float,
    account: String,
  )
}

pub type AccountSummary {
  AccountSummary(
    net_liquidation: Float,
    available_funds: Float,
    day_trades_remaining: Int,
    gross_position_value: Float,
  )
}

/// The bar the system works with.
pub type DataBar {
  DataBar(
    date: String,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,
    sma_tiny: Float,
    prev_sma_tiny: Float,
    sma_small: Float,
    sma_medium: Float,
    sma_large: Float,
    bb_m: Float,
    prev_bb_m: Float,
    bb_u3: Float,
    bb_l3: Float,
    bb_u2: Float,
    bb_u1: Float,
    bb_l1: Float,
    bb_l2: Float,
    k: Float,
    d: Float,
    j: Float,
    m: Float,
    prev_k: Float,
    prev_j: Float,
    bias: Float,
    small_above_tiny: Bool,
    cmas_up: Bool,
    bars_k_on_d: Int,
    bars_d_on_k: Int,
    yin_leaf_cma: Float,
    yang_leaf_cma: Float,
    inner_yin_leaf_cma: Float,
    inner_yang_leaf_cma: Float,
    inner_inner_yin_leaf_cma: Float,
    inner_inner_yang_leaf_cma: Float,
    kdj_cross_up: Bool,
    kdj_bearish_left: Bool,
    price_at_lower_band: Bool,
    sma_tiny_rising: Bool,
    leaf_cmas_rising: Bool,
    leaf_cmas_falling: Bool,
    signal: String,
  )
}

pub type SignalDirection {
  Bullish
  Bearish
  Neutral
}

pub type SignalType {
  SignalBuy
  SignalSell
  SignalHold
  SignalCall
  SignalPut
  SignalWatch
}

pub type TradeSignal {
  TradeSignal(
    signal_type: SignalType,
    direction: SignalDirection,
    price: Float,
    bar: SourceBar,
    confidence: Float,
    reason: String,
  )
}

pub type StrategyMode {
  StrategyManual     // idib's strategy rules
  StrategyAI         // analogical reasoning
  StrategyHybrid     // AI confirms/rejects manual signals
}

pub type ConditionOperator {
  GreaterThan
  LessThan
  CrossAbove
  CrossBelow
}

pub type ConditionField {
  FieldPrice
  FieldSmaTiny
  FieldSmaSmall
  FieldSmaLarge
  FieldBbL3
  FieldBbM
  FieldBbU3
  FieldYinLeafCMA
  FieldYangLeafCMA
  FieldInnerYinLeafCMA
  FieldKdjK
  FieldKdjD
  FieldKdjJ
  FieldBBWidth
}

pub type ConditionalOrder {
  ConditionalOrder(
    id: String,
    symbol: String,
    action: String,
    field: ConditionField,
    operator: ConditionOperator,
    target_value: Float,
    active: Bool,
    triggered: Bool,
  )
}

pub type TradeRecord {
  TradeRecord(
    action: String,
    price: Float,
    time: String,
    reason: String,
    pnl: String,
  )
}

pub type TradingPosition {
  TradingPosition(
    position: Int,
    entry_price: Float,
    symbol: String,
  )
}

pub type DashboardEvent {
  DashboardEvent(event_type: String, data: Json)
}

pub fn decode_bar() -> decode.Decoder(SourceBar) {
  use date <- decode.field("date", decode.string)
  use open <- decode.field("open", decode.float)
  use high <- decode.field("high", decode.float)
  use low <- decode.field("low", decode.float)
  use close <- decode.field("close", decode.float)
  use volume <- decode.field("volume", decode.int)
  decode.success(SourceBar(date:, open:, high:, low:, close:, volume:))
}

pub fn decode_bars() -> decode.Decoder(List(SourceBar)) {
  decode.list(of: decode_bar())
}

