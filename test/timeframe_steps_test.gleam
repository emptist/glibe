//// Concrete assertions for the filled `timeframe` steps. Implements
//// `.planning/phases/02-domain-stream/02-01-PLAN.md` (Task 1 RED tests).
////
//// These pin the OBSERVABLE promises of `indicator`'s COMPLETE O(1) indicator
//// set before the body is filled (R19), sourced to frozen glib
//// `indicator.gleam:35-54`: all five SMA series, the SELECTED `sma_for_bbm`
//// centre, all seven Bollinger lines, KDJ with M, the cached-extreme recurrences,
//// and the runtime band-order test. Owner 2026-11-23: *"所有技术指标，glib有的，
//// 你不能残缺不全"* — nothing glib computes may be omitted. Also pinned: the pipe
//// contract (identity and `databar_list` unchanged; only the working bar's own
//// fields move). Numbers are hand-computable with the small windows in `settings`.

import gleam/option
import gleam/time/timestamp
import gleeunit
import glibe/config
import glibe/databar.{type DataBar}
import glibe/leaf
import glibe/timeframe
import glibe/trading/signal

pub fn main() {
  gleeunit.main()
}

/// Small, hand-computable window settings. Only tiny/medium have a short
/// window; small/large/huge are large, so a single settled bar drives every
/// series through the warm-up branch. `sma_for_bbm` is parameterised so a test
/// can prove the SELECTED centre is used — never a hard-coded `sma_medium`.
fn settings() -> config.IntervalSettings {
  settings_for_bbm(config.SmaMedium)
}

fn settings_for_bbm(series: config.SmaSeries) -> config.IntervalSettings {
  config.IntervalSettings(
    sma_tiny_window_size: 2,
    sma_small_window_size: 70,
    sma_medium_window_size: 2,
    sma_large_window_size: 252,
    sma_huge_window_size: 504,
    kdj_window_size: 7,
    kdj_k_period: 3,
    kdj_d_period: 2,
    kdj_m_period: 10,
    bb_multiplier: 1.99,
    sma_for_bbm: series,
    branch_exit_leaf_size: 40,
  )
}

/// A bar with chosen idx / close / high / low and chosen carried SMA. Every
/// other field is neutral, so each test states only the values it relies on.
fn bar_at(
  idx: Int,
  close: Float,
  high: Float,
  low: Float,
  sma: Float,
) -> DataBar {
  databar.DataBar(
    idx: idx,
    timestamp: timestamp.from_unix_seconds(1_499_040_000 + idx),
    open: close,
    high: high,
    low: low,
    close: close,
    volume: 0,
    signal: signal.SignalNoSignal,
    sma_tiny: sma,
    sma_small: sma,
    sma_medium: sma,
    sma_large: sma,
    sma_huge: sma,
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
    k: 0.0,
    d: 0.0,
    j: 0.0,
    m: 0.0,
    kdj_h: 0.0,
    kdj_h_idx: 0,
    kdj_l: 0.0,
    kdj_l_idx: 0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
  )
}

fn with_working(
  working: DataBar,
  settled: List(DataBar),
) -> timeframe.Timeframe {
  timeframe.Timeframe(
    growing_target_sourcebar: option.None,
    working_databar: option.Some(working),
    databar_list: settled,
    growing_yin_leaf: option.None,
    growing_yang_leaf: option.None,
    growing_yin_branch: option.None,
    growing_yang_branch: option.None,
    yin_branch_list: [],
    yang_branch_list: [],
    yin_leaf_settled: option.None,
    yang_leaf_settled: option.None,
  )
}

fn computed(tf: timeframe.Timeframe) -> DataBar {
  computed_with(tf, settings())
}

fn computed_with(
  tf: timeframe.Timeframe,
  s: config.IntervalSettings,
) -> DataBar {
  let out = timeframe.indicator(tf, s)
  let assert option.Some(bar) = out.working_databar
  bar
}

/// Warm-up SMA (fewer settled bars than the window): mean of the held bars.
/// size=2, settled=[prev(sma=20)], working close=30 → (1·20 + 30)/2 = 25.
pub fn indicator_sma_warmup_test() {
  let prev = bar_at(1, 20.0, 21.0, 19.0, 20.0)
  let working = bar_at(2, 30.0, 35.0, 25.0, 0.0)
  let result = computed(with_working(working, [prev]))
  assert result.sma_medium == 25.0
  assert result.sma_tiny == 25.0
  Nil
}

/// Full-window SMA: add the arriving close, subtract the one that left.
/// size=2, settled=[prev(sma=20), old(close=10)], working close=30 →
/// (2·20 + 30 − 10)/2 = 30. NO full-window fold.
pub fn indicator_sma_subtract_leaving_test() {
  let prev = bar_at(2, 20.0, 21.0, 19.0, 20.0)
  let old = bar_at(1, 10.0, 11.0, 9.0, 10.0)
  let working = bar_at(3, 30.0, 35.0, 25.0, 0.0)
  let result = computed(with_working(working, [prev, old]))
  assert result.sma_medium == 30.0
  Nil
}

/// First bar has no settled extremes: RSV = (close-low)/(high-low)·100 = 50,
/// K/D seed at 50, J = 3K − 2D = 50. The cached extremes are the bar's own.
pub fn indicator_kdj_neutral_first_bar_test() {
  let working = bar_at(0, 30.0, 35.0, 25.0, 30.0)
  let result = computed(with_working(working, []))
  assert result.k == 50.0
  assert result.d == 50.0
  assert result.j == 50.0
  assert result.kdj_h == 35.0
  assert result.kdj_h_idx == 0
  assert result.kdj_l == 25.0
  assert result.kdj_l_idx == 0
  Nil
}

/// Welford σ on the first bar: one sample → σ=0 → the two outer bands collapse
/// onto the centre (sma_medium). sigma_n seeds at 1. The band stays ordered.
pub fn indicator_sigma_and_band_first_bar_test() {
  let working = bar_at(0, 30.0, 35.0, 25.0, 0.0)
  let result = computed(with_working(working, []))
  assert result.sigma_n == 1
  assert result.sigma_mean == 30.0
  assert result.sigma_m2 == 0.0
  assert result.bb_u3 == result.sma_medium
  assert result.bb_l3 == result.sma_medium
  assert result.bb_l3 <=. result.bb_u3
  Nil
}

/// The step changes ONLY the working bar's computed fields: identity (idx,
/// timestamp, signal) and the archived `databar_list` are untouched.
pub fn indicator_preserves_identity_and_list_test() {
  let prev = bar_at(1, 20.0, 21.0, 19.0, 20.0)
  let working = bar_at(2, 30.0, 35.0, 25.0, 0.0)
  let tf = with_working(working, [prev])
  let out = timeframe.indicator(tf, settings())
  assert out.databar_list == [prev]
  let assert option.Some(result) = out.working_databar
  assert result.idx == working.idx
  assert result.timestamp == working.timestamp
  assert result.signal == working.signal
  assert result.close == working.close
  Nil
}

/// R3 (owner verbatim): the leaf's CMA is the mean of the SELECTED MA
/// (`sma_tiny`), not of price, and its carried mean is the twin of the SAME
/// polarity. A yin leaf reads `yin_leaf_cma` off the previous bar; a yang leaf
/// reads `yang_leaf_cma`. Born this bar (held=0) returns its own sma_tiny.
pub fn leaf_cma_reads_twin_and_selected_ma_test() {
  let start = bar_at(10, 100.0, 101.0, 99.0, 100.0)
  let yin = leaf.YinLeaf(start, option.None, start)
  let yang = leaf.YangLeaf(start, option.None, start)
  // born this bar: N=0 -> the bar's own sma_tiny
  assert leaf.leaf_cma(start, [], yin) == 100.0
  assert leaf.leaf_cma(start, [], yang) == 100.0
  // second bar: N=1, previous CMA 100, this bar's sma_tiny 80 -> 90
  let prev =
    databar.DataBar(
      ..bar_at(10, 100.0, 101.0, 99.0, 100.0),
      yin_leaf_cma: 100.0,
      yang_leaf_cma: 60.0,
    )
  let cur = bar_at(11, 80.0, 81.0, 79.0, 80.0)
  assert leaf.leaf_cma(cur, [prev], yin) == 90.0
  // yang uses ITS twin: previous yang_leaf_cma 60, raw 80 -> 70
  assert leaf.leaf_cma(cur, [prev], yang) == 70.0
  Nil
}

/// ALL FIVE SMA series are computed, not just tiny/medium. Each bar carries a
/// different previous mean, so the warm-up result (prev + close)/2 differs per
/// series: 10→20, 20→25, 30→30, 40→35, 50→40. A body that skips small/large/
/// huge leaves their seeded values and fails here.
pub fn indicator_computes_all_five_sma_test() {
  let prev =
    databar.DataBar(
      ..bar_at(1, 20.0, 21.0, 19.0, 0.0),
      sma_tiny: 10.0,
      sma_small: 20.0,
      sma_medium: 30.0,
      sma_large: 40.0,
      sma_huge: 50.0,
    )
  let working = bar_at(2, 30.0, 35.0, 25.0, 0.0)
  let result = computed(with_working(working, [prev]))
  assert result.sma_tiny == 20.0
  assert result.sma_small == 25.0
  assert result.sma_medium == 30.0
  assert result.sma_large == 35.0
  assert result.sma_huge == 40.0
  Nil
}

/// `bb_m` is the SELECTED `sma_for_bbm` series (glib `indicator.gleam:45`),
/// never a hard-coded `sma_medium`. With the five series seeded 10/20/30/40/50
/// and close 30, selecting small gives bb_m=25; selecting large gives bb_m=35.
pub fn indicator_bb_m_uses_selected_sma_series_test() {
  let prev =
    databar.DataBar(
      ..bar_at(1, 20.0, 21.0, 19.0, 0.0),
      sma_tiny: 10.0,
      sma_small: 20.0,
      sma_medium: 30.0,
      sma_large: 40.0,
      sma_huge: 50.0,
    )
  let working = bar_at(2, 30.0, 35.0, 25.0, 0.0)
  // First bar: settled has no σ state carried by `prev` (σ=0), so all seven
  // lines collapse onto bb_m — bb_m itself is the assertion.
  let small =
    computed_with(
      with_working(working, [prev]),
      settings_for_bbm(config.SmaSmall),
    )
  assert small.bb_m == 25.0
  let large =
    computed_with(
      with_working(working, [prev]),
      settings_for_bbm(config.SmaLarge),
    )
  assert large.bb_m == 35.0
  Nil
}

/// All SEVEN Bollinger lines are written. On the first bar σ=0, so every line
/// collapses onto bb_m; a body that writes only the two outer lines leaves
/// bb_m/u1/u2/l1/l2 at their seeded 0.0 and fails.
pub fn indicator_writes_all_seven_band_lines_test() {
  let working = bar_at(0, 30.0, 35.0, 25.0, 0.0)
  let result = computed(with_working(working, []))
  assert result.bb_m == result.sma_medium
  assert result.bb_u3 == result.bb_m
  assert result.bb_u2 == result.bb_m
  assert result.bb_u1 == result.bb_m
  assert result.bb_l1 == result.bb_m
  assert result.bb_l2 == result.bb_m
  assert result.bb_l3 == result.bb_m
  Nil
}

/// KDJ's fourth line M is computed (glib `kdj.gleam:50-63`): on the first bar
/// k=50, so the mean of K over the window is 50. A body that omits M leaves the
/// seeded 0.0 and fails.
pub fn indicator_computes_kdj_m_test() {
  let working = bar_at(0, 30.0, 35.0, 25.0, 30.0)
  let result = computed(with_working(working, []))
  assert result.k == 50.0
  assert result.m == 50.0
  Nil
}

/// The lower edge is floored before interpolation (glib `bollinger.gleam:207`):
/// with a carried σ≈70 and centre≈25, the raw lower edge is deeply negative and
/// must be lifted to a tiny positive fraction of bb_m. Without the floor it
/// stays negative and this fails.
pub fn indicator_floors_negative_lower_band_test() {
  let prev =
    databar.DataBar(
      ..bar_at(1, 100.0, 101.0, 99.0, 0.0),
      sma_medium: 50.0,
      sigma_n: 2,
      sigma_mean: 100.0,
      sigma_m2: 10_000.0,
    )
  let working = bar_at(2, 1.0, 2.0, 0.5, 0.0)
  let result = computed(with_working(working, [prev]))
  assert result.bb_l3 >. 0.0
  assert result.bb_l3 <=. result.bb_m
  Nil
}

/// The runtime band-order test (glib `indicator.gleam:84-103`): an ordered bar
/// passes; one with bb_m pushed above bb_u1 is refused, naming the bar.
pub fn single_bar_test_rejects_out_of_order_bands_test() {
  let ordered =
    databar.DataBar(
      ..bar_at(0, 30.0, 35.0, 25.0, 30.0),
      bb_l3: 1.0,
      bb_l2: 2.0,
      bb_l1: 3.0,
      bb_m: 4.0,
      bb_u1: 5.0,
      bb_u2: 6.0,
      bb_u3: 7.0,
    )
  assert timeframe.single_bar_test(ordered) == Ok(Nil)
  let broken = databar.DataBar(..ordered, bb_m: 9.0)
  assert timeframe.single_bar_test(broken) != Ok(Nil)
  Nil
}
