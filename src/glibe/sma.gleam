// SMA series — incremental means over databar_list (newest-first)
// Plan 31-01

import gleam/list
import gleam/result
import gleam/int
import glibe/databar as databar
import glibe/indicator_settings.{type TimeframeSettings}

pub type SmaSeries {
  SmaSeriesTiny
  SmaSeriesSmall
  SmaSeriesMedium
  SmaSeriesLarge
}

/// SMA — three cases by list length (plan 31-01)
pub fn sma(working: databar.DataBar, databar_list: List(databar.DataBar), settings: TimeframeSettings, name: SmaSeries) -> databar.DataBar {
  let size = size_of(settings, name)
  let len = list.length(databar_list)

  // Three cases by length:
  // 1. len == 0: no settled bars -> close
  // 2. len < size: fewer than span -> true mean of bars so far
  // 3. len >= size: window full -> incremental with leaving bar
  let mean = case len == 0 {
    True -> working.close
    False -> case len < size {
      True -> {
        // true mean: (held * previous_sma + close) / (held + 1)
        let previous = list.first(databar_list) |> result.unwrap(working)
        let held = int.to_float(len)
        { held *. sma_of(previous, name) +. working.close } /. { held +. 1.0 }
      }
      False -> {
        // window full: (size * previous_sma + close - leaving.close) / size
        // leaving bar is at index size - 1 (newest-first list)
        let previous = list.first(databar_list) |> result.unwrap(working)
        let leaving = list.drop(databar_list, size - 1) |> list.first |> result.unwrap(working)
        { int.to_float(size) *. sma_of(previous, name)
          +. working.close -. leaving.close } /. int.to_float(size)
      }
    }
  }

  // TODO: bias calculation for this SMA series (enable when needed)
  // bias = 100 * (close - sma) / sma
  // let bias = case mean >. 0.0 {
  //   True -> { working.close -. mean } /. mean *. 100.0
  //   False -> 0.0
  // }
  // set_bias_of(working, name, bias)

  set_sma_of(working, name, mean)
}

fn sma_of(databar: databar.DataBar, name: SmaSeries) -> Float {
  case name {
    SmaSeriesTiny -> databar.sma_tiny
    SmaSeriesSmall -> databar.sma_small
    SmaSeriesMedium -> databar.sma_medium
    SmaSeriesLarge -> databar.sma_large
  }
}

fn set_sma_of(databar: databar.DataBar, name: SmaSeries, value: Float) -> databar.DataBar {
  case name {
    SmaSeriesTiny -> databar.DataBar(..databar, sma_tiny: value)
    SmaSeriesSmall -> databar.DataBar(..databar, sma_small: value)
    SmaSeriesMedium -> databar.DataBar(..databar, sma_medium: value)
    SmaSeriesLarge -> databar.DataBar(..databar, sma_large: value)
  }
}

// Bias setter for future use (enable when needed)
// bias = 100 * (close - sma) / sma (can be positive or negative)
// fn set_bias_of(databar: databar.DataBar, name: SmaSeries, value: Float) -> databar.DataBar {
//   case name {
//     SmaSeriesTiny -> databar.DataBar(..databar, sma_tiny_bias: value)
//     SmaSeriesSmall -> databar.DataBar(..databar, sma_small_bias: value)
//     SmaSeriesMedium -> databar.DataBar(..databar, sma_medium_bias: value)
//     SmaSeriesLarge -> databar.DataBar(..databar, sma_large_bias: value)
//   }
// }

fn size_of(settings: TimeframeSettings, name: SmaSeries) -> Int {
  case name {
    SmaSeriesTiny -> settings.sma_tiny_window_size
    SmaSeriesSmall -> settings.sma_small_window_size
    SmaSeriesMedium -> settings.sma_medium_window_size
    SmaSeriesLarge -> settings.sma_large_window_size
  }
}