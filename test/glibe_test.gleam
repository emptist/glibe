import gleam/float
import gleam/list
import gleeunit
import glibe/api/asset
import glibe/api/interval
import glibe/api/rules
import glibe/api/sourcebar.{SourceBar}
import glibe/config
import glibe/databar
import glibe/indicator
import glibe/indicator_settings
import glibe/kdj
import glibe/sma

pub fn main() {
  gleeunit.main()
}

// ============================================================================
// Test helpers
// ============================================================================

/// Build a DataBar with all indicator fields at zero/defaults.
/// Used as a seed for indicator tests.
fn bar(close: Float) -> databar.DataBar {
  databar.DataBar(
    idx: 0,
    date: "2024-01-01",
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
    signal: "",
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
    window_kdj_size: 7,
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
  case result {
    asset.Crypto -> Nil
    _ -> panic as "Expected Crypto"
  }
}

pub fn asset_class_from_string_equity_test() {
  let result = asset.asset_class_from_string("Equity")
  case result {
    asset.Equity -> Nil
    _ -> panic as "Expected Equity"
  }
}

pub fn trading_hours_twenty_four_seven_test() {
  let result = rules.trading_hours_from_string("TwentyFourSeven")
  case result {
    rules.TwentyFourSeven -> Nil
    _ -> panic as "Expected TwentyFourSeven"
  }
}

pub fn trading_hours_twenty_four_five_test() {
  let result = rules.trading_hours_from_string("TwentyFourFive")
  case result {
    rules.TwentyFourFive -> Nil
    _ -> panic as "Expected TwentyFourFive"
  }
}

pub fn trading_hours_rth_test() {
  let result =
    rules.trading_hours_from_string("RTH;09:30;16:00;America/New_York")
  case result {
    rules.RTH(open: "09:30", close: "16:00", timezone: "America/New_York") ->
      Nil
    _ -> panic as "Expected RTH"
  }
}

pub fn trading_hours_custom_test() {
  let result =
    rules.trading_hours_from_string(
      "Custom;09:30,12:00,Asia/Hong_Kong|13:00,16:00,Asia/Hong_Kong",
    )
  case result {
    rules.Custom(sessions) -> {
      case list.length(sessions) == 2 {
        True -> Nil
        False -> panic as "Expected 2 sessions"
      }
    }
    _ -> panic as "Expected Custom"
  }
}

pub fn settlement_type_instant_test() {
  let result = rules.settlement_type_from_string("Instant")
  case result {
    rules.Instant -> Nil
    _ -> panic as "Expected Instant"
  }
}

pub fn settlement_type_tplus2_test() {
  let result = rules.settlement_type_from_string("TPlus2")
  case result {
    rules.TPlus2 -> Nil
    _ -> panic as "Expected TPlus2"
  }
}

pub fn auction_type_both_test() {
  let result = rules.auction_type_from_string("Both")
  case result {
    rules.Both -> Nil
    _ -> panic as "Expected Both"
  }
}

pub fn circuit_breaker_test() {
  let result = rules.circuit_breaker_from_string("CircuitBreaker;0.07;300;15")
  case result {
    rules.CircuitBreaker(
      threshold_pct: 0.07,
      window_seconds: 300,
      halt_minutes: 15,
    ) -> Nil
    _ -> panic as "Expected CircuitBreaker"
  }
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
  case cfg.version == 1 {
    True -> Nil
    False -> panic as "Expected version 1"
  }
}

// ============================================================================
// SMA — three cases (plan 31-01)
// ============================================================================

/// Case 1: no settled bars — SMA equals the bar's close.
pub fn sma_bar_zero_equals_close_test() {
  let working = bar(100.0)
  let result = sma.sma(working, [], settings(), sma.SmaSeriesTiny)
  case approx(result.sma_tiny, 100.0) {
    True -> Nil
    False -> panic as "sma_tiny on bar 0 should equal close"
  }
}

/// Case 2: warm-up — 1 settled bar, window size 7.
/// mean = (held * prev_sma + close) / (held + 1)
///      = (1 * 100 + 110) / 2 = 105.0
pub fn sma_warmup_true_mean_test() {
  let prev = databar.DataBar(..bar(100.0), sma_tiny: 100.0)
  let working = bar(110.0)
  let result = sma.sma(working, [prev], settings(), sma.SmaSeriesTiny)
  case approx(result.sma_tiny, 105.0) {
    True -> Nil
    False -> panic as "sma_tiny during warm-up should be true mean"
  }
}

/// Case 3: full window — 7 settled bars, new close shifts the window.
/// All settled bars have close=100, sma_tiny=100.  New close=107.
/// mean = (7 * 100 + 107 - 100) / 7 = 707 / 7 = 101.0
pub fn sma_full_window_incremental_test() {
  let settled = list.repeat(databar.DataBar(..bar(100.0), sma_tiny: 100.0), 7)
  let working = bar(107.0)
  let result = sma.sma(working, settled, settings(), sma.SmaSeriesTiny)
  case approx(result.sma_tiny, 101.0) {
    True -> Nil
    False -> panic as "sma_tiny with full window should use incremental formula"
  }
}

// ============================================================================
// KDJ
// ============================================================================

/// Flat market: all bars same price → RSV = 50 → K/D/J/M all stay at 50.
pub fn kdj_flat_market_stays_at_fifty_test() {
  let flat = list.repeat(bar(100.0), 7)
  let working = bar(100.0)
  let result = kdj.kdj(working, flat, settings())
  case
    approx(result.k, 50.0)
    && approx(result.d, 50.0)
    && approx(result.j, 50.0)
    && approx(result.m, 50.0)
  {
    True -> Nil
    False -> panic as "KDJ should stay at 50 in a flat market"
  }
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
  case result.k >. 50.0 {
    True -> Nil
    False -> panic as "K should be above 50 in a rising market"
  }
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
  case violations == 0 {
    True -> Nil
    False -> panic as "Bollinger band ordering violated on at least one bar"
  }
}

// ============================================================================
// Ingest boundary — the H1 bug and the reject-don't-repair rule
// ============================================================================

/// Binance sends `openTime` as epoch-milliseconds. Before the conversion lived
/// at the boundary, `"1735704000000"` reached `bucket_ends` and matched no
/// minute field, so an hourly timeframe never closed a bar. The boundary turns
/// it into a human-readable timestamp; this test pins that.
pub fn sourcebar_epoch_ms_normalizes_test() {
  let raw =
    SourceBar(
      date: "1705309200000",
      open: 100.0,
      high: 101.0,
      low: 99.0,
      close: 100.5,
      volume: 10,
    )
  let normalized = sourcebar.normalize_date(raw)
  case normalized.date == "2024-01-15 09:00:00" {
    True -> Nil
    False -> panic as "epoch-ms was not normalised to ISO-8601"
  }
}

/// A date that already reads as a date passes through untouched — the boundary
/// only translates, it never guesses.
pub fn sourcebar_iso_date_passes_through_test() {
  let raw =
    SourceBar(
      date: "2024-01-15 09:30:00",
      open: 100.0,
      high: 101.0,
      low: 99.0,
      close: 100.5,
      volume: 10,
    )
  let normalized = sourcebar.normalize_date(raw)
  case normalized.date == "2024-01-15 09:30:00" {
    True -> Nil
    False -> panic as "an already-ISO date was altered"
  }
}

/// The bucket test now closes an hourly bar on the minute the boundary hands
/// over: an hourly bar ends on minute `00`, so a source bar at `:00` closes the
/// bucket and one at `:30` does not. This is the bug, proved.
pub fn interval_h1_bucket_closes_on_hour_test() {
  case interval.bucket_ends(interval.H1, "2024-01-15 09:00:00") {
    True ->
      case interval.bucket_ends(interval.H1, "2024-01-15 09:30:00") {
        False -> Nil
        True -> panic as "an H1 bar should not close on minute 30"
      }
    False -> panic as "an H1 bar must close on minute 00"
  }
}

/// A bar whose own numbers disagree is rejected, with the reason, and nothing
/// is repaired. A high below the low is not a bar.
pub fn sourcebar_rejects_high_below_low_test() {
  let bad =
    sourcebar.validate(SourceBar(
      date: "2024-01-15 09:00:00",
      open: 100.0,
      high: 90.0,
      low: 99.0,
      close: 100.5,
      volume: 10,
    ))
  case bad {
    Error(_) -> Nil
    Ok(_) -> panic as "a high-below-low bar was accepted"
  }
}
