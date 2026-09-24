// Bollinger Bands — uses selected SMA as centre, Fibonacci ratios 0.382 / 0.618

import gleam/list
import gleam/result
import gleam/int
import gleam/float
import glibe/indicator_settings.{type TimeframeSettings, type SmaForBbm, SmaForBbmTiny, SmaForBbmSmall, SmaForBbmMedium, SmaForBbmLarge}
import glibe/databar as databar

/// Bollinger — uses selected SMA as centre, Fibonacci ratios 0.382 / 0.618
/// Returns updated databar; timeframe update handled by caller
pub fn bollinger(databar: databar.DataBar, databar_list: List(databar.DataBar), settings: TimeframeSettings) -> databar.DataBar {
  // Get the selected SMA as centre (bbm)
  let bb_m = select_bbm(databar, settings.sma_for_bbm)

  // Window = databar_list (newest-first)
  // Take `size` bars from the list for the window
  let size = bb_window_size(settings)
  let window = list.take(databar_list, size)

  // Compute std around bb_m using the window
  // divisor = count of bars in window (not window_size during warm-up)
  let count = list.length(window)
  let sum_sq_diff = list.fold(window, 0.0, fn(acc, bar) {
    let diff = bar.close -. bb_m
    acc +. diff *. diff
  })
  let variance = sum_sq_diff /. int.to_float(count)
  let sigma = float.power(variance, 0.5) |> result.unwrap(0.0)

  // Build bands at Fibonacci ratios: 0.382, 0.618, 1.0
  let spread = settings.bb_multiplier *. sigma
  let bb_u3 = bb_m +. spread
  let bb_u2 = bb_m +. spread *. 0.618
  let bb_u1 = bb_m +. spread *. 0.382
  let bb_l1 = max(bb_m -. spread *. 0.382, 0.001)
  let bb_l2 = max(bb_m -. spread *. 0.618, 0.0001)
  let bb_l3 = max(bb_m -. spread, 0.00001)

  // Set Bollinger values + sigma (deviation) on databar
  databar.DataBar(
    ..databar,
    bb_m: bb_m,
    bb_u3: bb_u3,
    bb_l3: bb_l3,
    bb_u2: bb_u2,
    bb_u1: bb_u1,
    bb_l1: bb_l1,
    bb_l2: bb_l2,
    // Store sigma as deviation on the bar
    prev_bb_m: sigma,
  )
}

/// Select which SMA is the Bollinger centre
pub fn select_bbm(databar: databar.DataBar, which: SmaForBbm) -> Float {
  case which {
    SmaForBbmTiny -> databar.sma_tiny
    SmaForBbmSmall -> databar.sma_small
    SmaForBbmMedium -> databar.sma_medium
    SmaForBbmLarge -> databar.sma_large
  }
}

/// Window size for Bollinger = window size of the selected SMA
pub fn bb_window_size(settings: TimeframeSettings) -> Int {
  case settings.sma_for_bbm {
    SmaForBbmTiny -> settings.sma_tiny_window_size
    SmaForBbmSmall -> settings.sma_small_window_size
    SmaForBbmMedium -> settings.sma_medium_window_size
    SmaForBbmLarge -> settings.sma_large_window_size
  }
}

fn max(a: Float, b: Float) -> Float {
  case a >. b {
    True -> a
    False -> b
  }
}