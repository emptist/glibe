// KDJ oscillator — amortised-constant LLV/HHV over window, incremental SMA for K/D/M
// (plan 31-04, UC-64). Each bar caches its window's extremes (highest/lowest + idx);
// the next bar only rescans when the leaving bar was the cached extreme.

import gleam/list
import gleam/float
import gleam/int
import gleam/result
import glibe/databar
import glibe/indicator_settings.{type TimeframeSettings}

/// KDJ — amortised-constant LLV/HHV over window, incremental SMA for K/D/M
pub fn kdj(
  databar: databar.DataBar,
  databar_list: List(databar.DataBar),
  settings: TimeframeSettings,
) -> databar.DataBar {
  // --- RSV: amortised-constant highest/lowest over the window ending at this
  // bar. The window is `kdj_window_size` bars INCLUDING the bar in hand, so it
  // holds `kdj_window_size - 1` settled bars plus `databar` (idib
  // `Incremental.idr:144-148`, plan 31-04 §2). Each settled bar carries the
  // extreme of its own window; the next bar compares the leaving-bar idx to the
  // cached idx and only rescans when the leaving bar was that extreme.
  let #(highest, h_idx, lowest, l_idx) =
    rsv_extrema(databar, databar_list, settings)
  let rsv =
    case highest -. lowest <=. 0.0001 {
      // A flat window is not an error — RSV is the conventional neutral 50, the
      // defined value of an undefined quotient (idib), not an invented default.
      True -> 50.0
      False -> { databar.close -. lowest } /. { highest -. lowest } *. 100.0
    }

  // --- K and D: one alpha, seeded at the neutral 50 (plan 31-04 §3). idib wins
  // over ibOptions: D is smoothed with the same alpha as K, not a separate 1/2.
  let alpha = 1.0 /. int.to_float(settings.kdj_k_period)
  let #(previous_k, previous_d) =
    case list.first(databar_list) {
      Ok(bar) -> #(bar.k, bar.d)
      Error(_) -> #(50.0, 50.0)
    }
  let k = { 1.0 -. alpha } *. previous_k +. alpha *. rsv
  let d = { 1.0 -. alpha } *. previous_d +. alpha *. k
  let j = 3.0 *. k -. 2.0 *. d

  // K, D and J are written onto the bar before M, because M reads this bar's
  // freshly computed `k` (plan 31-04 §4).
  let working =
    databar.DataBar(..databar, k:, d:, j:, highest:, h_idx:, lowest:, l_idx:)

  // --- M: the plain mean of the last `kdj_m_period` K values, carried as `m` by
  // the general `sma` recurrence over `k` — add the arriving `k`, subtract the
  // one that left. No `mean_of` of an array (UC-64). The previous bar's `m` is
  // the carried mean; the window is the bar in hand plus the `kdj_m_period - 1`
  // before it, exactly as the sma ladder.
  let working =
    sma.sma(
      working,
      databar_list,
      settings.kdj_m_period,
      fn(b) { b.k },
      fn(b) { b.m },
      fn(b, v) { databar.DataBar(..b, m: v) },
    )

  databar.DataBar(
    ..working,
    highest: highest,
    h_idx: h_idx,
    lowest: lowest,
    l_idx: l_idx,
  )
}

/// The cached highest/lowest of the window ending at `working`, and the idx of
/// the bar carrying each. Amortised-constant: if the bar leaving the window
/// (`working.idx - kdj_window_size`) was not the cached extreme, the cached
/// extreme is still in the window and only the new bar is folded in; if it was,
/// the window is rescanned once (UC-64, plan 31-04 §2).
fn rsv_extrema(
  working: databar.DataBar,
  databar_list: List(databar.DataBar),
  settings: TimeframeSettings,
) -> #(Float, Int, Float, Int) {
  let w = settings.window_kdj_size
  let #(prev_h, prev_h_idx, prev_l, prev_l_idx) =
    case list.first(databar_list) {
      Ok(b) -> #(b.kdj_h, b.kdj_h_idx, b.kdj_l, b.kdj_l_idx)
      Error(_) -> #(working.high, working.idx, working.low, working.idx)
    }
  let leaving_idx = working.idx - w
  case leaving_idx == prev_h_idx || leaving_idx == prev_l_idx {
    // The leaving bar was an extreme — rescan the window once (this bar plus the
    // `w - 1` settled bars that belong to it).
    True -> batch_window(working, databar_list, w)
    // The cached extreme is still in the window: fold in only the new bar.
    False -> {
      let h_idx =
        case working.high >. prev_h {
          True -> working.idx
          False -> prev_h_idx
        }
      let l_idx =
        case working.low <. prev_l {
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

/// Rescan the window (the bar in hand plus the `w - 1` settled bars before it)
/// for its highest high and lowest low, recording the idx of each. Called only
/// when the leaving bar was the cached extreme, so it is the rare path (UC-64).
fn batch_window(
  working: databar.DataBar,
  databar_list: List(databar.DataBar),
  w: Int,
) -> #(Float, Int, Float, Int) {
  // Note: this folds `w-1` settled bars (the working bar's extreme is initialized)
  list.take(databar_list, w - 1)
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
      #(
        float.max(acc.0, b.high),
        h_idx,
        float.min(acc.2, b.low),
        l_idx,
      )
    },
  )
}