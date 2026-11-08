import gleam/float
import gleam/list
import gleam/option.{None, Some}
import gleam/time/timestamp
import gleeunit
import glibe/api/asset
import glibe/api/interval
import glibe/api/rules
import glibe/api/sourcebar.{SourceBar}
import glibe/api/symbol
import glibe/config
import glibe/databar
import glibe/desk
import glibe/engine
import glibe/indicator
import glibe/indicator_settings
import glibe/kdj
import glibe/sma
import glibe/timeframe
import glibe/trading/signal.{Buy, NoSignal, Sell}
import glibe/trading/strategy

/// A test clock: parse a wire label through the same boundary conversion the
/// adapters use, so no test builds a Time by hand.
fn at(raw: String) -> timestamp.Timestamp {
  let assert Ok(instant) = sourcebar.unix_timestamp(raw)
    as "test clock label parses"
  instant
}

pub fn main() {
  gleeunit.main()
}

// Assertion style (Gleam Language Tour, Advanced features): bool `assert` is
// designed for test conditions, `let assert` for partial patterns that must
// match, and `panic` is "should almost never be used" — it is not a test
// assertion. `todo` emits a compile warning, so it never appears in this tree
// (the build requires 0 warnings). Both assertion forms carry `as "message"`.

// ============================================================================
// Test helpers
// ============================================================================

/// Build a DataBar with all indicator fields at zero/defaults.
/// Used as a seed for indicator tests.
fn bar(close: Float) -> databar.DataBar {
  databar.DataBar(
    idx: 0,
    timestamp: at("2024-01-01 00:00:00"),
    open: close,
    high: close,
    low: close,
    close: close,
    volume: 0,
    sma_tiny: 0.0,
    sma_small: 0.0,
    sma_medium: 0.0,
    sma_large: 0.0,
    sma_huge: 0.0,
    bb_m: 0.0,
    bb_u3: 0.0,
    bb_l3: 0.0,
    bb_u2: 0.0,
    bb_u1: 0.0,
    bb_l1: 0.0,
    bb_l2: 0.0,
    sigma_n: 0,
    sigma_mean: 0.0,
    sigma_m2: 0.0,
    k: 50.0,
    d: 50.0,
    j: 50.0,
    m: 50.0,
    kdj_h: close,
    kdj_h_idx: 0,
    kdj_l: close,
    kdj_l_idx: 0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
    signal: NoSignal,
  )
}

/// Build a DataBar with explicit low/high for KDJ tests.
fn bar_ohlc(
  open: Float,
  high: Float,
  low: Float,
  close: Float,
) -> databar.DataBar {
  databar.DataBar(..bar(close), open: open, high: high, low: low)
}

/// Standard settings used across indicator tests.
/// sma_tiny=7, sma_small=14, sma_medium=30, sma_large=60
/// kdj window=7, k_period=3, d_period=3
/// Bollinger centred on sma_small, multiplier=2.0
fn settings() -> indicator_settings.TimeframeSettings {
  indicator_settings.TimeframeSettings(
    sma_tiny_window_size: 7,
    sma_small_window_size: 14,
    sma_medium_window_size: 30,
    sma_large_window_size: 60,
    sma_huge_window_size: 504,
    kdj_window_size: 7,
    kdj_k_period: 3,
    kdj_m_period: 10,
    bb_multiplier: 2.0,
    sma_for_bbm: indicator_settings.SmaForBbmSmall,
    branch_exit_leaf_size: 40,
  )
}

/// Float near-equality: |a - b| < 0.0001
fn approx(a: Float, b: Float) -> Bool {
  float.absolute_value(a -. b) <. 0.0001
}

pub fn asset_class_from_string_crypto_test() {
  let result = asset.asset_class_from_string("Crypto")
  let assert asset.Crypto = result as "Expected Crypto"
}

pub fn asset_class_from_string_equity_test() {
  let result = asset.asset_class_from_string("Equity")
  let assert asset.Equity = result as "Expected Equity"
}

pub fn trading_hours_twenty_four_seven_test() {
  let result = rules.trading_hours_from_string("TwentyFourSeven")
  let assert rules.TwentyFourSeven = result as "Expected TwentyFourSeven"
}

pub fn trading_hours_twenty_four_five_test() {
  let result = rules.trading_hours_from_string("TwentyFourFive")
  let assert rules.TwentyFourFive = result as "Expected TwentyFourFive"
}

pub fn trading_hours_rth_test() {
  let result =
    rules.trading_hours_from_string("RTH;09:30;16:00;America/New_York")
  let assert rules.RTH(
    open: "09:30",
    close: "16:00",
    timezone: "America/New_York",
  ) = result
    as "Expected RTH"
}

pub fn trading_hours_custom_test() {
  let result =
    rules.trading_hours_from_string(
      "Custom;09:30,12:00,Asia/Hong_Kong|13:00,16:00,Asia/Hong_Kong",
    )
  let assert rules.Custom(sessions) = result as "Expected Custom"
  assert list.length(sessions) == 2 as "Expected 2 sessions"
}

pub fn settlement_type_instant_test() {
  let result = rules.settlement_type_from_string("Instant")
  let assert rules.Instant = result as "Expected Instant"
}

pub fn settlement_type_tplus2_test() {
  let result = rules.settlement_type_from_string("TPlus2")
  let assert rules.TPlus2 = result as "Expected TPlus2"
}

pub fn auction_type_both_test() {
  let result = rules.auction_type_from_string("Both")
  let assert rules.Both = result as "Expected Both"
}

pub fn circuit_breaker_test() {
  let result = rules.circuit_breaker_from_string("CircuitBreaker;0.07;300;15")
  let assert rules.CircuitBreaker(
    threshold_pct: 0.07,
    window_seconds: 300,
    halt_minutes: 15,
  ) = result
    as "Expected CircuitBreaker"
}

pub fn asset_class_all_values_test() {
  let classes = [
    "Crypto",
    "Equity",
    "ETF",
    "BStock",
    "Future",
    "Option",
    "Currency",
  ]
  list.each(classes, fn(c) {
    let _ = asset.asset_class_from_string(c)
    Nil
  })
  Nil
}

pub fn trading_hours_all_formats_test() {
  let _ = rules.trading_hours_from_string("TwentyFourSeven")
  let _ = rules.trading_hours_from_string("TwentyFourFive")
  let _ = rules.trading_hours_from_string("RTH;09:30;16:00;America/New_York")
  let _ =
    rules.trading_hours_from_string(
      "Custom;09:30,12:00,Asia/Hong_Kong|13:00,16:00,Asia/Hong_Kong",
    )
  Nil
}

// ============================================================================
// Config
// ============================================================================

/// Verifies default_config() does not panic.
/// Regression test for the circuit-breaker delimiter bug (colon vs semicolon).
pub fn default_config_does_not_panic_test() {
  let cfg = config.default_config()
  assert cfg.version == 1 as "Expected version 1"
}

/// R23: configuration expresses ownership with typed values. There is no
/// `"BTCUSDT_H1"` composite string, no `config_get_tfs`, and no second
/// settings dictionary — the numbers live on the `Timeframe` we reach through
/// Desk -> Broker -> Instrument -> Interval.
pub fn default_config_builds_a_typed_desk_test() {
  let cfg = config.default_config()
  let assert Ok(broker) = desk.get_broker(cfg.desk, desk.broker_id("binance"))
    as "binance is a broker on the configured desk"
  let assert Ok(instrument) =
    desk.get_instrument(broker, symbol.from_string("BTCUSDT"))
    as "BTCUSDT names an instrument under that broker"
  let assert Ok(tf) = desk.get_timeframe(instrument, interval.IntervalOneHour)
    as "the hourly timeframe is in the instrument's one dictionary"
  assert tf.settings.sma_tiny_window_size == 7
    as "the engine carries its own parameter block"
  assert tf.databar_list == [] as "a configured timeframe starts with no bars"
}

// ============================================================================
// SMA — three cases (plan 31-01)
// ============================================================================

/// Case 1: no settled bars — SMA equals the bar's close.
pub fn sma_bar_zero_equals_close_test() {
  let working = bar(100.0)
  let result = sma.sma(working, [], settings(), sma.SmaSeriesTiny)
  assert approx(result.sma_tiny, 100.0)
    as "sma_tiny on bar 0 should equal close"
}

/// Case 2: warm-up — 1 settled bar, window size 7.
/// mean = (held * prev_sma + close) / (held + 1)
///      = (1 * 100 + 110) / 2 = 105.0
pub fn sma_warmup_true_mean_test() {
  let prev = databar.DataBar(..bar(100.0), sma_tiny: 100.0)
  let working = bar(110.0)
  let result = sma.sma(working, [prev], settings(), sma.SmaSeriesTiny)
  assert approx(result.sma_tiny, 105.0)
    as "sma_tiny during warm-up should be true mean"
}

/// Case 3: full window — 7 settled bars, new close shifts the window.
/// All settled bars have close=100, sma_tiny=100.  New close=107.
/// mean = (7 * 100 + 107 - 100) / 7 = 707 / 7 = 101.0
pub fn sma_full_window_incremental_test() {
  let settled = list.repeat(databar.DataBar(..bar(100.0), sma_tiny: 100.0), 7)
  let working = bar(107.0)
  let result = sma.sma(working, settled, settings(), sma.SmaSeriesTiny)
  assert approx(result.sma_tiny, 101.0)
    as "sma_tiny with full window should use incremental formula"
}

// ============================================================================
// KDJ
// ============================================================================

/// Flat market: all bars same price → RSV = 50 → K/D/J/M all stay at 50.
pub fn kdj_flat_market_stays_at_fifty_test() {
  let flat = list.repeat(bar(100.0), 7)
  let working = bar(100.0)
  let result = kdj.kdj(working, flat, settings())
  let flat =
    approx(result.k, 50.0)
    && approx(result.d, 50.0)
    && approx(result.j, 50.0)
    && approx(result.m, 50.0)
  assert flat as "KDJ should stay at 50 in a flat market"
}

/// Rising market: 7 settled bars climbing from 90→96, new bar at 100.
/// llv ≈ 89, hhv ≈ 101 → RSV ≈ 91.7 → K rises above 50.
pub fn kdj_rising_market_k_above_fifty_test() {
  // Settled bars newest-first: closes 96, 95, 94, 93, 92, 91, 90
  // Each has low = close - 1, high = close + 1
  let settled =
    list.map([96.0, 95.0, 94.0, 93.0, 92.0, 91.0, 90.0], fn(c) {
      bar_ohlc(c, c +. 1.0, c -. 1.0, c)
    })
  // Current bar: close=100, low=99, high=101
  let working = bar_ohlc(100.0, 101.0, 99.0, 100.0)
  let result = kdj.kdj(working, settled, settings())
  assert result.k >. 50.0 as "K should be above 50 in a rising market"
}

// ============================================================================
// Bollinger band ordering law
// ============================================================================

/// Verifies bb_l3 ≤ bb_l2 ≤ bb_l1 ≤ bb_m ≤ bb_u1 ≤ bb_u2 ≤ bb_u3
/// on every bar produced by the full indicator pipeline over 30 synthetic bars.
/// This is the law that was previously asserted on every bar in the hot path.
pub fn bollinger_band_ordering_law_test() {
  let s = settings()
  // Run 30 bars with varying closes through the full pipeline
  let closes = [
    100.0, 102.0, 98.0, 105.0, 103.0, 97.0, 110.0, 108.0, 95.0, 112.0, 115.0,
    109.0, 104.0, 101.0, 99.0, 106.0, 114.0, 118.0, 107.0, 96.0, 103.0, 111.0,
    116.0, 100.0, 94.0, 120.0, 117.0, 108.0, 102.0, 105.0,
  ]
  // Accumulate bars through the pipeline; databar_list is newest-first
  let #(_, violations) =
    list.fold(closes, #([], 0), fn(acc, close) {
      let #(history, bad) = acc
      let working = bar(close)
      let result = indicator.run(working, history, s)
      let ordered =
        result.bb_l3 <=. result.bb_l2
        && result.bb_l2 <=. result.bb_l1
        && result.bb_l1 <=. result.bb_m
        && result.bb_m <=. result.bb_u1
        && result.bb_u1 <=. result.bb_u2
        && result.bb_u2 <=. result.bb_u3
      #(list.prepend(history, result), case ordered {
        True -> bad
        False -> bad + 1
      })
    })
  assert violations == 0
    as "Bollinger band ordering violated on at least one bar"
}

// ============================================================================
// Ingest boundary — the hourly-bar bug and the reject-don't-repair rule
// ============================================================================

/// R23: `interval` lives ONLY in the key, so the caller that selected the
/// `Timeframe` hands it to the gate. One and the same `Timeframe` value closes
/// at 09:00 under `IntervalOneHour` and does not under `IntervalFourHour`
/// (09:00 is not on a four-hour boundary). Day/week/month buckets are
/// deliberately not used here — they still end on every bar, a separate debt
/// recorded in the 04-03 plan.
pub fn the_gate_is_given_the_interval_by_the_caller_test() {
  let raw =
    SourceBar(
      timestamp: at("2024-01-15 09:00:00"),
      open: 100.0,
      high: 101.0,
      low: 99.0,
      close: 100.5,
      volume: 10,
    )
  let tf = timeframe.new(settings())
  let assert Ok(#(Some(_), _)) =
    engine.sourcebar_gate(tf, interval.IntervalOneHour, raw)
    as "an hourly bucket ends on minute 00"
  let assert Ok(#(None, _)) =
    engine.sourcebar_gate(tf, interval.IntervalFourHour, raw)
    as "the same value under a four-hour key does not close at 09:00"
}

/// The bucket test now closes an hourly bar on the minute the boundary hands
/// over: an hourly bar ends on minute `00`, so a source bar at `:00` closes the
/// bucket and one at `:30` does not. This is the bug, proved.
pub fn interval_hourly_bucket_closes_on_hour_test() {
  assert interval.bucket_ends(
    interval.IntervalOneHour,
    at("2024-01-15 09:00:00"),
  )
    as "an hourly bar must close on minute 00"
  assert interval.bucket_ends(
      interval.IntervalOneHour,
      at("2024-01-15 09:30:00"),
    )
    == False
    as "an hourly bar should not close on minute 30"
}

/// A bar whose own numbers disagree is rejected, with the reason, and nothing
/// is repaired. A high below the low is not a bar.
pub fn sourcebar_rejects_high_below_low_test() {
  let bad =
    sourcebar.validate(SourceBar(
      timestamp: at("2024-01-15 09:00:00"),
      open: 100.0,
      high: 90.0,
      low: 99.0,
      close: 100.5,
      volume: 10,
    ))
  let assert Error(_) = bad as "a high-below-low bar was accepted"
}

// ============================================================================
// Round 5 — the owner's rulings adopted from glib, each with a mechanism
// ============================================================================

/// R12 — ONE tiny positive floor, on the lower edge, BEFORE interpolation.
/// Alternating 100 / 0.01 closes give a centre near 50 with σ near 50, so the
/// raw lower edge is negative. Three independent `max(..., 0.0)` clamps (the
/// old code) collapse the staff onto zero; the ruled construction keeps all
/// three lower lines positive, distinct, and ordered.
pub fn bollinger_one_tiny_positive_floor_before_interpolation_test() {
  let s = settings()
  let closes = [
    100.0, 0.01, 100.0, 0.01, 100.0, 0.01, 100.0, 0.01, 100.0, 0.01, 100.0, 0.01,
    100.0, 0.01, 100.0, 0.01, 100.0, 0.01, 100.0, 0.01,
  ]
  let #(_, final_bar) =
    list.fold(closes, #([], bar(100.0)), fn(acc, close) {
      let #(history, _) = acc
      let result = indicator.run(bar(close), history, s)
      #([result, ..history], result)
    })
  let ruled =
    final_bar.bb_l3 >. 0.0
    && approx(final_bar.bb_l3, final_bar.bb_m *. 0.000001)
    && final_bar.bb_l2 >. final_bar.bb_l3
    && final_bar.bb_l1 >. final_bar.bb_l2
    && final_bar.bb_l1 <=. final_bar.bb_m
  assert ruled
    as "the lower edge floor must be one tiny positive applied before interpolation"
}

/// R13 — the signal is a closed set, therefore a type, not a String.
/// Pattern matching is the proof: a fourth spelling cannot be constructed.
pub fn signal_is_a_closed_type_test() {
  let buy = strategy.manual_signal(True, False)
  let sell = strategy.manual_signal(False, True)
  let none = strategy.manual_signal(False, False)
  let assert #(Buy, Sell, NoSignal) = #(buy, sell, none)
    as "manual_signal returned a case outside the closed set"
  let wire =
    signal.to_string(buy) == "buy"
    && signal.to_string(sell) == "sell"
    && signal.to_string(none) == ""
  assert wire as "the wire spelling must be the only String in the system"
}

/// The KDJ cached extreme is retired by POSITION, not by `idx - w`. A gap in
/// the feed (a holiday, a dropped bar) makes indices non-consecutive; the old
/// arithmetic then names a bar that never existed and the stale extreme is
/// carried forever. Here the leaving bar has idx 10 while `working.idx - w`
/// is 101 — the two cannot be confused.
pub fn kdj_gapped_indices_retire_the_cached_extreme_test() {
  let s = settings()
  // Seven settled bars, newest-first. The oldest (idx 10) is the cached high
  // extreme and is the bar leaving the window on this step.
  let settled = [
    databar.DataBar(
      ..bar_ohlc(100.0, 100.0, 100.0, 100.0),
      idx: 107,
      kdj_h: 200.0,
      kdj_h_idx: 10,
      kdj_l: 100.0,
      kdj_l_idx: 107,
    ),
    databar.DataBar(
      ..bar(100.0),
      idx: 106,
      kdj_h: 200.0,
      kdj_h_idx: 10,
      kdj_l: 100.0,
      kdj_l_idx: 106,
    ),
    databar.DataBar(
      ..bar(100.0),
      idx: 105,
      kdj_h: 200.0,
      kdj_h_idx: 10,
      kdj_l: 100.0,
      kdj_l_idx: 105,
    ),
    databar.DataBar(
      ..bar(100.0),
      idx: 104,
      kdj_h: 200.0,
      kdj_h_idx: 10,
      kdj_l: 100.0,
      kdj_l_idx: 104,
    ),
    databar.DataBar(
      ..bar(100.0),
      idx: 103,
      kdj_h: 200.0,
      kdj_h_idx: 10,
      kdj_l: 100.0,
      kdj_l_idx: 103,
    ),
    databar.DataBar(
      ..bar(100.0),
      idx: 102,
      kdj_h: 200.0,
      kdj_h_idx: 10,
      kdj_l: 100.0,
      kdj_l_idx: 102,
    ),
    databar.DataBar(
      ..bar_ohlc(200.0, 200.0, 200.0, 200.0),
      idx: 10,
      kdj_h: 200.0,
      kdj_h_idx: 10,
      kdj_l: 200.0,
      kdj_l_idx: 10,
    ),
  ]
  let working =
    databar.DataBar(..bar_ohlc(100.0, 101.0, 100.0, 100.5), idx: 108)
  let result = kdj.kdj(working, settled, s)
  assert approx(result.kdj_h, 101.0)
    as "a gapped feed kept a cached extreme that left the window"
}
