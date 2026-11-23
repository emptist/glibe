//// The KDJ oscillator — K, D, J and M. Implements
//// `.planning/phases/02-domain-stream/02-02-PLAN.md` Task 3.
////
//// WHY THIS IS ITS OWN MODULE (owner 2026-11-23: *"他的补充完全是敷衍，所以
//// 全部塞进不应该塞进去的模块，而不去新建应该用的模块"*): frozen glib has
//// `kdj.gleam` as a separate file and this content was sitting inside
//// `timeframe.gleam`. NAMING.md 1.19 / 1.20 (one class, one module) and R50
//// (one module, one ownership relation) put the oscillator with the four
//// lines it writes and the cached extremes it carries.
////
//// It reads `DataBar`'s KDJ fields and writes them back; it depends on
//// `databar.gleam` and `sma.gleam` only — M is the same O(1) streaming mean
//// the SMA series use, so the recurrence is shared, not copied.
////
//// R19 status: bodies moved verbatim from `timeframe.gleam` (2026-11-23) —
//// the arithmetic is unchanged, only the module changed.

import gleam/float
import gleam/int
import gleam/list
import glibe/config.{type IntervalSettings}
import glibe/databar.{type DataBar, DataBar}
import glibe/sma

/// KDJ on the working bar, ported from glib `kdj.gleam:15-72`: RSV from
/// cached extremes (amortised O(1) rescan only when the leaving bar WAS an
/// extreme), then K/D/J rolling with one alpha seeded at 50, then M: the O(1)
/// rolling mean of this bar's freshly computed K over `kdj_m_period`.
pub fn kdj_stream(
  working: DataBar,
  settled: List(DataBar),
  settings: IntervalSettings,
) -> DataBar {
  let #(highest, h_idx, lowest, l_idx) =
    rsv_extrema(working, settled, settings.kdj_window_size)
  let rsv = case highest -. lowest <=. 0.0001 {
    True -> 50.0
    False -> { working.close -. lowest } /. { highest -. lowest } *. 100.0
  }
  let alpha = 1.0 /. int.to_float(settings.kdj_k_period)
  let #(prev_k, prev_d) = case list.first(settled) {
    Ok(b) -> #(b.k, b.d)
    Error(_) -> #(50.0, 50.0)
  }
  let k = { 1.0 -. alpha } *. prev_k +. alpha *. rsv
  let d = { 1.0 -. alpha } *. prev_d +. alpha *. k
  let j = 3.0 *. k -. 2.0 *. d
  // K/D/J are written BEFORE M, because M reads this bar's freshly computed K
  // (glib kdj.gleam:46-63). M is the rolling mean of K over kdj_m_period, the
  // same O(1) sma_stream recurrence — no array mean, no window walk.
  let bar =
    DataBar(..working, k: k, d: d, j: j)
    |> sma.sma_stream(
      settled,
      settings.kdj_m_period,
      fn(b) { b.k },
      fn(b) { b.m },
      fn(b, v) { DataBar(..b, m: v) },
    )
  DataBar(
    ..bar,
    kdj_h: highest,
    kdj_h_idx: h_idx,
    kdj_l: lowest,
    kdj_l_idx: l_idx,
  )
}

/// The cached highest-high / lowest-low of the window ending at `working` and
/// the idx of each (glib `kdj.gleam:79-114`). If the bar leaving the window is
/// not a cached extreme, only the new bar is folded in; otherwise one rescan.
fn rsv_extrema(
  working: DataBar,
  settled: List(DataBar),
  w: Int,
) -> #(Float, Int, Float, Int) {
  let #(prev_h, prev_h_idx, prev_l, prev_l_idx) = case list.first(settled) {
    Ok(b) -> #(b.kdj_h, b.kdj_h_idx, b.kdj_l, b.kdj_l_idx)
    Error(_) -> #(working.high, working.idx, working.low, working.idx)
  }
  let leaving_idx = working.idx - w
  case leaving_idx == prev_h_idx || leaving_idx == prev_l_idx {
    True -> rescan_window(working, settled, w)
    False -> {
      let h_idx = case working.high >. prev_h {
        True -> working.idx
        False -> prev_h_idx
      }
      let l_idx = case working.low <. prev_l {
        True -> working.idx
        False -> prev_l_idx
      }
      #(
        float.max(prev_h, working.high),
        h_idx,
        float.min(prev_l, working.low),
        l_idx,
      )
    }
  }
}

/// The rare path: rescan the bar in hand plus the `w - 1` settled bars before
/// it (glib `kdj.gleam:119-139`, `batch_window`). O(w) only when an extreme
/// left the window; this is the amortised-rescan path, NOT the banned per-bar
/// full-window recompute.
fn rescan_window(
  working: DataBar,
  settled: List(DataBar),
  w: Int,
) -> #(Float, Int, Float, Int) {
  list.take(settled, w - 1)
  |> list.fold(
    #(working.high, working.idx, working.low, working.idx),
    fn(acc, b) {
      let h_idx = case b.high >. acc.0 {
        True -> b.idx
        False -> acc.1
      }
      let l_idx = case b.low <. acc.2 {
        True -> b.idx
        False -> acc.3
      }
      #(float.max(acc.0, b.high), h_idx, float.min(acc.2, b.low), l_idx)
    },
  )
}
