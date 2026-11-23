//// The bar's computed values, in one order. Implements
//// `.planning/phases/02-domain-stream/02-02-PLAN.md` Task 3.
////
//// WHY THIS IS ITS OWN MODULE (owner 2026-11-23: *"他的补充完全是敷衍，所以
//// 全部塞进不应该塞进去的模块，而不去新建应该用的模块"*): frozen glib has
//// `indicator.gleam` as a separate file (143 lines) and this content — the
//// indicator step, the runtime bar test and its error type — was sitting
//// inside `timeframe.gleam`. NAMING.md 1.19 / 1.20 (one class, one module)
//// and R50 (one module, one ownership relation) put the computation with the
//// values it writes.
////
//// **It computes bar → bar and never names the `Timeframe`.** Frozen glib
//// says why, and glibe adopts it: glib `indicator.gleam:9-13` — *"It takes the
//// settled bars and the settings, **not the `Timeframe`**. The whole point of
//// `indicator.gleam` is bar → bar, and importing `timeframe.gleam` just to
//// reach two fields it already owns would put the state record above the value
//// computed on it. It is also what makes the step movable: a function that
//// names the record cannot leave the record, and this one did (2026-10-03)."*
////
//// The pipeline shape is unchanged: `timeframe.databar_processing` keeps a
//// step of `fn(Timeframe, ...extra) -> Timeframe` (R40 / R40-A / R41, owner
//// 逐字 2026-11-12), and that step is the THIN ADAPTER here — it takes the
//// working bar and the settled list out of the record, calls
//// `indicator.compute_bar`, and writes the result back. glib does exactly
//// this (`glib/timeframe.gleam:369-379`).
////
//// R19 status: bodies moved verbatim from `timeframe.gleam` (2026-11-23) —
//// the arithmetic is unchanged, only the module and the shape changed.

import gleam/float
import gleam/int
import gleam/list
import glibe/bollinger
import glibe/config.{
  type IntervalSettings, SmaHuge, SmaLarge, SmaMedium, SmaSmall, SmaTiny,
}
import glibe/databar.{type DataBar}
import glibe/kdj
import glibe/sma

/// One call per indicator, in one order. `databar` is the bar just closed;
/// `databar_list` is the settled bars, which do **not** yet contain it — it is
/// computed against them, and the archive step joins it last.
///
/// The COMPLETE frozen-glib indicator set (owner 2026-11-23: *"所有技术指标，
/// glib有的，你不能残缺不全"*), in the exact order of glib
/// `indicator.gleam:35-54`:
///   1. all five SMA series (tiny/small/medium/large/huge);
///   2. `bb_m` = the SELECTED centre, never a hard-coded `sma_medium`
///      (glib `indicator.gleam:45`); the week and the month select small/tiny,
///      which is possible because the bar carries all five series;
///   3. Welford σ over that centre's OWN span — the selected centre's window
///      (glib `bollinger.gleam:165`);
///   4. all seven Bollinger lines — `band` + `write_band`; the lower edge is
///      floored BEFORE the 0.618/0.382 interpolation;
///   5. KDJ — cached-extreme RSV, K/D/J and M.
///
/// Every recurrence is O(1): add-arriving/subtract-leaving (SMA, M), a Welford
/// M2 state (σ), cached-extreme amortised rescan (KDJ). No `Σx²−(Σx)²/n`, no
/// per-bar window walk.
pub fn compute_bar(
  databar: DataBar,
  databar_list: List(DataBar),
  settings: IntervalSettings,
) -> DataBar {
  // 1. All five SMA series — each an O(1) add-arriving / subtract-leaving
  //    recurrence carried on its own field (glib indicator.gleam:40-44).
  let working = sma.sma_series(databar, databar_list, settings, SmaTiny)
  let working = sma.sma_series(working, databar_list, settings, SmaSmall)
  let working = sma.sma_series(working, databar_list, settings, SmaMedium)
  let working = sma.sma_series(working, databar_list, settings, SmaLarge)
  let working = sma.sma_series(working, databar_list, settings, SmaHuge)
  // 2. bb_m is the SELECTED centre, never recomputed (glib
  //    indicator.gleam:45). σ spans that centre's own window (glib
  //    bollinger.gleam:165): week/month select small/tiny, now possible
  //    because the bar carries all five series.
  let bb_m = sma.sma_of(working, settings.sma_for_bbm)
  let #(sigma, sigma_state) =
    bollinger.sigma_stream(
      working,
      databar_list,
      sma.size_of(settings, settings.sma_for_bbm),
    )
  // 3. All seven Bollinger lines, lower edge floored then interpolated.
  let lines = bollinger.band(bb_m, sigma, settings.bb_multiplier)
  let working = bollinger.write_band(working, lines, sigma_state)
  // 4. KDJ — cached-extreme RSV, K/D/J and the O(1) rolling mean M.
  kdj.kdj_stream(working, databar_list, settings)
}

/// Why `single_bar_test` refused a bar — glib `indicator.gleam:80-82`. Names
/// the two bands that broke the strict order and the bar they broke it on, so
/// a failure points at a bar to inspect.
pub type BarError {
  BandOutOfOrder(lower: Float, upper: Float, idx: Int)
}

/// The runtime check on the bar the indicator produced (glib
/// `indicator.gleam:84-103`, UC-60): the seven bands are strictly ordered
/// l3 ≤ l2 ≤ l1 ≤ m ≤ u1 ≤ u2 ≤ u3. A sign bug in σ or an interpolation error
/// breaks one of the six adjacent pairs; so does a NaN (every comparison
/// against NaN is false). Returns the first broken pair instead of crashing,
/// so one bad bar cannot abort a whole run.
pub fn single_bar_test(bar: DataBar) -> Result(Nil, BarError) {
  let pairs = [
    #(bar.bb_l3, bar.bb_l2),
    #(bar.bb_l2, bar.bb_l1),
    #(bar.bb_l1, bar.bb_m),
    #(bar.bb_m, bar.bb_u1),
    #(bar.bb_u1, bar.bb_u2),
    #(bar.bb_u2, bar.bb_u3),
  ]
  case list.find(pairs, fn(pair) { !ordered(pair.0, pair.1) }) {
    Ok(pair) -> Error(BandOutOfOrder(pair.0, pair.1, bar.idx))
    Error(_) -> Ok(Nil)
  }
}

/// The printed form of a refusal — glib `indicator.gleam:106-116`.
pub fn bar_error_text(error: BarError) -> String {
  case error {
    BandOutOfOrder(lower, upper, idx) ->
      "bands out of order on bar "
      <> int.to_string(idx)
      <> ": "
      <> float.to_string(lower)
      <> " should be at most "
      <> float.to_string(upper)
  }
}

/// Band ordering tolerant of float representation, not of a bug (glib
/// `indicator.gleam:132-135`). Bands mathematically equal can differ by one
/// unit in the last place and land on the wrong side of `<=.`; the slack is
/// one part in a billion of the band's own size, so a whole-sigma inversion
/// still fails.
fn ordered(lower: Float, upper: Float) -> Bool {
  let slack = float_max(float.absolute_value(upper) *. 1.0e-9, 1.0e-12)
  lower <=. upper +. slack
}

/// `gleam/float` has no `max` — glib `indicator.gleam:138-143`.
fn float_max(a: Float, b: Float) -> Float {
  case a >=. b {
    True -> a
    False -> b
  }
}
