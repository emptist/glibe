//// The five simple moving averages, and the ONE place a series NAME becomes a
//// field. Implements `.planning/phases/02-domain-stream/02-02-PLAN.md` Task 3.
////
//// WHY THIS IS ITS OWN MODULE, AND WHY ITS ACCESSORS ARE `pub` (owner
//// 2026-11-23, and the glib design it copies):
////
//// Frozen glib `sma.gleam:6-7` says it outright: *"sma_of / set_sma_of / size_of
//// are the only three places a name becomes a field; each is one case over the
//// five windows."* — the translation from a `SmaSeries` name to the field it
//// names lives HERE and nowhere else, and the accessors are `pub` so that any
//// module can read a NAMED series.
////
//// This matters because a `SmaSeries` selection that only ONE module can see
//// is a selection that does not exist for the others. When the five series
//// were added (2026-11-23) the accessors lived inside `timeframe.gleam` as
//// PRIVATE functions, so no other module could read `sma_small` / `sma_large`
//// / `sma_huge` at all — the only series a view or a strategy module could
//// reach was `sma_tiny`, the one it could hard-code. That is exactly the
//// failure mode owner named: *"本来应该使用其他 sma 的地方，他可能全部是用
//// sma_tiny"*. The fix is not to guess which series each place should use
//// (that is a design question per consumer), but to make the NAME-to-field
//// translation OPEN so no consumer is forced onto `sma_tiny`.
////
//// R50 (one module, one ownership relation): this module reads the five SMA
//// fields of `DataBar` and the window sizes of `IntervalSettings`, and writes
//// the five SMA fields. It depends on `databar.gleam` and `config.gleam` only
//// — both of which import no engine module — so there is no cycle.
////
//// R19 status (2026-11-23): the three accessors are filled — `sma_of`
//// `set_sma_of` `size_of` — one case over the five windows each, ported from
//// frozen glib `sma.gleam:18-48`. `sma_stream` / `sma_series` came with the
//// module (the O(1) recurrence the five series and KDJ's M share).
////
//// THE TESTS ARE PROVEN TO BITE (owner 2026-11-23: *"GDLTDD 是非常有效的，
//// 能限制 AI 的缺陷"*). `test/sma_test.gleam` was written AFTER the bodies —
//// a GDLTDD slip — so it was proven by MUTATION instead: four deliberate
//// defects were injected one at a time and each was caught.
////   1. `sma_of` reading `SmaSmall` as `sma_medium`   → 5 failures
////   2. `set_sma_of` writing `SmaLarge` onto `sma_tiny` → 5 failures
////   3. `size_of` reading `SmaMedium`'s window as Small → 3 failures
////   4. `sma_of` degraded to "always reads sma_tiny"    → 5 failures
////      (the exact shape of the defect this module's split removed)
//// Baseline with no defect: 102 passed / 1 failure (the pre-existing Phase 03
//// `app_shape_test.from_event` todo). Every mutation run cleared `build/dev`
//// first — an incremental build served a stale binary once and nearly made a
//// mutation look like a false pass.

import gleam/int
import gleam/list
import glibe/config.{
  type IntervalSettings, type SmaSeries, SmaHuge, SmaLarge, SmaMedium, SmaSmall,
  SmaTiny,
}
import glibe/databar.{type DataBar, DataBar}

/// Read the named SMA series off a bar. The one place a `SmaSeries` name
/// becomes a field (glib `sma.sma_of:18-26`).
///
/// READER: anything that needs a NAMED series — `timeframe.indicator` (which
/// writes them and picks the Bollinger centre), and later a view that draws
/// the week line (`SmaSmall`) or a strategy module that takes `SmaLarge` /
/// `SmaHuge` as a feature. The accessors are `pub` so no consumer has to
/// re-implement the case, which would be a second answer to one question
/// (R47).
pub fn sma_of(bar: DataBar, name: SmaSeries) -> Float {
  // Frozen glib `sma.sma_of:18-26`: one case over the five windows, each
  // reading its OWN field. No fallback and no default arm — a third
  // constructor fails the compile rather than silently reading another series.
  case name {
    SmaTiny -> bar.sma_tiny
    SmaSmall -> bar.sma_small
    SmaMedium -> bar.sma_medium
    SmaLarge -> bar.sma_large
    SmaHuge -> bar.sma_huge
  }
}

/// Write the named SMA series onto a bar, returning the copy (glib
/// `sma.set_sma_of:29-37`).
///
/// WRITER: `timeframe.indicator`, once per bar per series.
pub fn set_sma_of(bar: DataBar, name: SmaSeries, value: Float) -> DataBar {
  // Frozen glib `sma.set_sma_of:29-37`: one case over the five windows, each
  // writing its OWN field and copying the rest of the bar unchanged.
  case name {
    SmaTiny -> DataBar(..bar, sma_tiny: value)
    SmaSmall -> DataBar(..bar, sma_small: value)
    SmaMedium -> DataBar(..bar, sma_medium: value)
    SmaLarge -> DataBar(..bar, sma_large: value)
    SmaHuge -> DataBar(..bar, sma_huge: value)
  }
}

/// This series' window, in bars (glib `sma.size_of:40-48`).
///
/// READER: `timeframe.indicator` (the window each series streams over, and the
/// window the Bollinger σ spans — which is the SELECTED centre's own window,
/// glib `bollinger.gleam:165`).
pub fn size_of(settings: IntervalSettings, name: SmaSeries) -> Int {
  // Frozen glib `sma.size_of:40-48`: one case over the five windows, each
  // reading its OWN window size.
  case name {
    SmaTiny -> settings.sma_tiny_window_size
    SmaSmall -> settings.sma_small_window_size
    SmaMedium -> settings.sma_medium_window_size
    SmaLarge -> settings.sma_large_window_size
    SmaHuge -> settings.sma_huge_window_size
  }
}

/// The streaming mean over ANY raw field — the one recurrence that carries
/// every moving average in the engine (glib `sma.sma:60-89`).
///
/// `raw_of` reads the value to average off a bar, `read_mean` reads the carried
/// mean off a settled bar (the previous bar's own result), `write_mean` writes
/// the new mean onto `working`. The mean IS invertible: add the arriving
/// value, subtract the one that left — no `read_mean` of an array, no walk over
/// the window.
///
/// Used by the five SMA series (raw = close) and by KDJ's M (raw = k), so one
/// function does both. A bar carries the carried mean; the list is read only
/// for the single bar that leaves the span, by `list.split`.
///
/// `settled` is newest-first and does NOT include `working`; `size` includes
/// the bar in hand.
pub fn sma_stream(
  working: DataBar,
  settled: List(DataBar),
  size: Int,
  raw_of: fn(DataBar) -> Float,
  read_mean: fn(DataBar) -> Float,
  write_mean: fn(DataBar, Float) -> DataBar,
) -> DataBar {
  let arriving = raw_of(working)
  case list.split(settled, size - 1) {
    // Nothing settled (or a span of one): the mean is the bar's own value.
    #([], _) -> write_mean(working, arriving)
    // Fewer settled than the span: none has left; divide by bars held.
    #([previous, ..] as held, []) -> {
      let divisor = int.to_float(list.length(held))
      let mean =
        { divisor *. read_mean(previous) +. arriving } /. { divisor +. 1.0 }
      write_mean(working, mean)
    }
    // Full window: add the arriving value, subtract the one that left.
    #([previous, ..], [leaving, ..]) -> {
      let divisor = int.to_float(size)
      let mean =
        { divisor *. read_mean(previous) +. arriving -. raw_of(leaving) }
        /. divisor
      write_mean(working, mean)
    }
  }
}

/// The SMA series: a moving average of `close`, written to the named window.
/// A thin wrapper over `sma_stream` that binds the SMA series' accessors, so
/// the caller reads as before (glib `sma.sma_series:94-108`).
///
/// WRITER: `indicator.indicator` — once per bar, once per series (five calls).
pub fn sma_series(
  working: DataBar,
  settled: List(DataBar),
  settings: IntervalSettings,
  name: SmaSeries,
) -> DataBar {
  sma_stream(
    working,
    settled,
    size_of(settings, name),
    fn(b) { b.close },
    fn(b) { sma_of(b, name) },
    fn(b, v) { set_sma_of(b, name, v) },
  )
}
