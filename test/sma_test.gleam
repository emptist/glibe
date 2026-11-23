//// RED tests for the `sma` accessors — the ONE place a series NAME becomes a
//// field. Implements `.planning/phases/02-domain-stream/02-02-PLAN.md` Task 3.
////
//// These pin the observable promises of the three accessors:
////   - `sma_of` reads the NAMED series off a bar — all five windows, each from
////     its own field, so a caller can ask for `SmaSmall` and get `sma_small`
////     (never a fallback to another series).
////   - `set_sma_of` writes the NAMED series onto a bar and returns the copy,
////     touching no other field.
////   - `size_of` reads the NAMED series' window in bars.
////
//// The rules are ported from frozen glib `sma.gleam:18-48`, whose module
//// header states the contract these three share: *"sma_of / set_sma_of /
//// size_of are the only three places a name becomes a field; each is one case
//// over the five windows."*
////
//// WHY THE ACCESSORS ARE `pub` (owner 2026-11-23): when they were private
//// inside `timeframe.gleam`, no other module could read `sma_small` /
//// `sma_large` / `sma_huge` — the only series a view or a strategy module could
//// reach was `sma_tiny`, the one it could hard-code. That is the failure mode
//// owner named: *"本来应该使用其他 sma 的地方，他可能全部是用 sma_tiny"*.

import gleam/time/timestamp
import glibe/config.{
  type IntervalSettings, type SmaSeries, IntervalSettings, SmaHuge, SmaLarge,
  SmaMedium, SmaSmall, SmaTiny,
}
import glibe/databar.{type DataBar, DataBar}
import glibe/sma
import glibe/trading/signal

/// A bar with distinct values in all five SMA fields, so an assertion can
/// tell WHICH series was read. Only the five SMA fields matter here.
fn bar_with_series(
  tiny: Float,
  small: Float,
  medium: Float,
  large: Float,
  huge: Float,
) -> DataBar {
  DataBar(
    idx: 0,
    timestamp: timestamp.from_unix_seconds(1_499_040_000),
    open: 0.0,
    high: 0.0,
    low: 0.0,
    close: 0.0,
    volume: 0,
    signal: signal.SignalNoSignal,
    sma_tiny: tiny,
    sma_small: small,
    sma_medium: medium,
    sma_large: large,
    sma_huge: huge,
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
    kdj_l: 0.0,
    kdj_h_idx: 0,
    kdj_l_idx: 0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
  )
}

/// `sma_of` reads the NAMED series — five distinct values, five distinct
/// answers. A series that fell back to another one could not pass this.
pub fn sma_of_reads_the_named_series_test() {
  let bar = bar_with_series(1.0, 2.0, 3.0, 4.0, 5.0)
  assert sma.sma_of(bar, SmaTiny) == 1.0
  assert sma.sma_of(bar, SmaSmall) == 2.0
  assert sma.sma_of(bar, SmaMedium) == 3.0
  assert sma.sma_of(bar, SmaLarge) == 4.0
  assert sma.sma_of(bar, SmaHuge) == 5.0
  Nil
}

/// `set_sma_of` writes the NAMED series and touches nothing else: the other
/// four series keep their values.
pub fn set_sma_of_writes_the_named_series_test() {
  let bar = bar_with_series(1.0, 2.0, 3.0, 4.0, 5.0)
  let written = sma.set_sma_of(bar, SmaLarge, 40.0)
  assert written.sma_large == 40.0
  assert written.sma_tiny == 1.0
  assert written.sma_small == 2.0
  assert written.sma_medium == 3.0
  assert written.sma_huge == 5.0
  Nil
}

/// `size_of` reads the NAMED window — five distinct sizes, five answers.
pub fn size_of_reads_the_named_window_test() {
  let settings = settings_with_windows(7, 70, 140, 252, 504)
  assert sma.size_of(settings, SmaTiny) == 7
  assert sma.size_of(settings, SmaSmall) == 70
  assert sma.size_of(settings, SmaMedium) == 140
  assert sma.size_of(settings, SmaLarge) == 252
  assert sma.size_of(settings, SmaHuge) == 504
  Nil
}

/// The write and the read are the same fact: what `set_sma_of` wrote is what
/// `sma_of` reads back, for EVERY series — so no writer and no reader can
/// disagree about which field a name means.
pub fn write_then_read_agrees_for_every_series_test() {
  let bar = bar_with_series(0.0, 0.0, 0.0, 0.0, 0.0)
  let names: List(SmaSeries) = [SmaTiny, SmaSmall, SmaMedium, SmaLarge, SmaHuge]
  let values = [10.0, 20.0, 30.0, 40.0, 50.0]
  let written = write_each(bar, names, values)
  assert sma.sma_of(written, SmaTiny) == 10.0
  assert sma.sma_of(written, SmaSmall) == 20.0
  assert sma.sma_of(written, SmaMedium) == 30.0
  assert sma.sma_of(written, SmaLarge) == 40.0
  assert sma.sma_of(written, SmaHuge) == 50.0
  Nil
}

/// Write each series in turn, pairing each name with its value.
fn write_each(
  bar: DataBar,
  names: List(SmaSeries),
  values: List(Float),
) -> DataBar {
  case names, values {
    [name, ..rest_names], [value, ..rest_values] ->
      write_each(sma.set_sma_of(bar, name, value), rest_names, rest_values)
    _, _ -> bar
  }
}

/// An `IntervalSettings` carrying five distinct window sizes, so `size_of` has
/// five distinct answers to give.
fn settings_with_windows(
  tiny: Int,
  small: Int,
  medium: Int,
  large: Int,
  huge: Int,
) -> IntervalSettings {
  IntervalSettings(
    sma_tiny_window_size: tiny,
    sma_small_window_size: small,
    sma_medium_window_size: medium,
    sma_large_window_size: large,
    sma_huge_window_size: huge,
    kdj_window_size: 7,
    kdj_k_period: 3,
    kdj_d_period: 2,
    kdj_m_period: 10,
    bb_multiplier: 1.99,
    sma_for_bbm: SmaMedium,
    branch_exit_leaf_size: 40,
  )
}
