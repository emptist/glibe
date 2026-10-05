// Bollinger Bands — uses selected SMA as centre, Fibonacci ratios 0.382 / 0.618
// σ computed via Welford online recurrence (plan 31-02, §3), proposal 2026-10-01.

import gleam/float
import gleam/int
import gleam/list
import gleam/result
import glibe/databar
import glibe/indicator_settings.{type SmaForBbm, type TimeframeSettings}

// ———— Welford recurrence types & state ———————————————————————————————

/// Running state for the Welford online variance recurrence.
/// Carried on each bar so the next bar extends σ in O(1) without a window cache.
pub type SigmaState {
  SigmaState(n: Int, mean: Float, m2: Float)
}

/// Initial state: n = 0, mean = 0, m2 = 0
pub fn sigma_init() -> SigmaState { SigmaState(0, 0.0, 0.0) }

/// Add a new close value to the Welford state.
fn sigma_add(s: SigmaState, x: Float) -> SigmaState {
  let n = s.n + 1
  let dn = int.to_float(n)
  let delta = x -. s.mean
  let mean = s.mean +. delta /. dn
  let delta2 = x -. mean
  SigmaState(n, mean, s.m2 +. delta *. delta2)
}

/// Remove a leaving close value from the Welford state (window sliding).
fn sigma_remove(s: SigmaState, x: Float) -> SigmaState {
  let n = s.n - 1
  let dn = int.to_float(n)
  let delta = x -. s.mean
  let mean = s.mean -. delta /. dn
  let delta2 = x -. mean
  SigmaState(n, mean, s.m2 -. delta *. delta2)
}

/// ———— σ: standard deviation over the selected SMA's window ———————————————

/// σ — the standard deviation of closes over **the very window `bb_m` is the
/// mean of**: the bar in hand plus the `size - 1` bars that came before it
/// (plan 31-02 §3). Uses the Welford moving-window recurrence so each bar
/// is O(1) and the subtraction `Σx² − (Σx)²/n` that DESIGN §14.6 forbids
/// never forms.
///
/// The bar in hand is in its own window, and that is what σ means. `bb_m` is
/// the mean of `size` closes *ending with this bar* (`sma.gleam`), so σ is
/// measured against that same sample — not one bar out of step.
///
/// One bar in the window (the very first bar of a run) has no spread: `m2` is
/// 0 and σ is 0, so the lines collapse onto the centre — the honest value, not
/// a fallback.
///
/// Returns `(σ, state)`; `state` is the next bar's carried recurrence. No
/// extra windowed cache — the leaving close is read from
/// `databar_list[size - 1]` (newest-first).
pub fn sigma(
  working: databar.DataBar,
  databar_list: List(databar.DataBar),
  settings: TimeframeSettings,
) -> #(Float, SigmaState) {
  let size = bb_window_size(settings)
  let prev =
    case list.first(databar_list) {
      Ok(b) -> SigmaState(b.sigma_n, b.sigma_mean, b.sigma_m2)
      Error(_) -> sigma_init()
    }
  let added = sigma_add(prev, working.close)
  let state =
    case prev.n >= size {
      True -> {
        let leaving =
          case list.drop(databar_list, size - 1) |> list.first {
            Ok(b) -> b.close
            Error(_) -> working.close
          }
        sigma_remove(added, leaving)
      }
      False -> added
    }
  let sigma =
    case state.n {
      0 -> 0.0
      _ -> float.power(state.m2 /. int.to_float(state.n), 0.5) |> result.unwrap(0.0)
    }
  #(sigma, state)
}

/// ———— Bollinger band construction ———————————————————————————————

/// Bollinger — uses selected SMA as centre, Fibonacci ratios 0.382 / 0.618
/// Returns updated databar; timeframe update handled by caller
pub fn bollinger(
  databar: databar.DataBar,
  databar_list: List(databar.DataBar),
  settings: TimeframeSettings,
) -> databar.DataBar {
  // Get the selected SMA as centre (bbm)
  let bb_m = select_bbm(databar, settings.sma_for_bbm)

  // σ via Welford online recurrence (no batch window needed)
  let #(sigma, state) = sigma(databar, databar_list, settings)

  // Build bands at Fibonacci ratios: 0.382, 0.618, 1.0
  let spread = settings.bb_multiplier *. sigma
  let bb_u3 = bb_m +. spread
  let bb_u2 = bb_m +. spread *. 0.618
  let bb_u1 = bb_m +. spread *. 0.382
  let bb_l1 = float.max(bb_m -. spread *. 0.382, 0.0)
  let bb_l2 = float.max(bb_m -. spread *. 0.618, 0.0)
  let bb_l3 = float.max(bb_m -. spread, 0.0)

  databar.DataBar(
    ..databar,
    bb_m: bb_m,
    bb_u3: bb_u3,
    bb_l3: bb_l3,
    bb_u2: bb_u2,
    bb_u1: bb_u1,
    bb_l1: bb_l1,
    bb_l2: bb_l2,
    sigma_n: state.n,
    sigma_mean: state.mean,
    sigma_m2: state.m2,
  )
}

/// Select which SMA is the Bollinger centre
pub fn select_bbm(databar: databar.DataBar, which: SmaForBbm) -> Float {
  case which {
    indicator_settings.SmaForBbmTiny -> databar.sma_tiny
    indicator_settings.SmaForBbmSmall -> databar.sma_small
    indicator_settings.SmaForBbmMedium -> databar.sma_medium
    indicator_settings.SmaForBbmLarge -> databar.sma_large
    indicator_settings.SmaForBbmHuge -> databar.sma_huge
  }
}

/// Window size for Bollinger = window size of the selected SMA
pub fn bb_window_size(settings: TimeframeSettings) -> Int {
  case settings.sma_for_bbm {
    indicator_settings.SmaForBbmTiny -> settings.sma_tiny_window_size
    indicator_settings.SmaForBbmSmall -> settings.sma_small_window_size
    indicator_settings.SmaForBbmMedium -> settings.sma_medium_window_size
    indicator_settings.SmaForBbmLarge -> settings.sma_large_window_size
    indicator_settings.SmaForBbmHuge -> settings.sma_huge_window_size
  }
}