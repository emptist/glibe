// SMA series — incremental means over databar_list (newest-first)
// Plan 31-01

import gleam/int
import gleam/list
import gleam/result
import glibe/databar
import glibe/indicator_settings.{type TimeframeSettings}

pub type SmaSeries {
  SmaSeriesTiny
  SmaSeriesSmall
  SmaSeriesMedium
  SmaSeriesLarge
  SmaSeriesHuge
}

/// SMA — three cases by list length (plan 31-01)
pub fn sma(
  working: databar.DataBar,
  databar_list: List(databar.DataBar),
  settings: TimeframeSettings,
  name: SmaSeries,
) -> databar.DataBar {
  let size = size_of(settings, name)
  incremental_mean(
    working,
    databar_list,
    size,
    fn(b) { sma_of(b, name) },
    fn(b) { b.close },
    fn(b, v) { set_sma_of(b, name, v) },
  )
}

/// Generic incremental windowed mean over `databar_list` (newest-first), the
/// bar in hand included. `size` bars end at `working` (working's value plus the
/// `size - 1` settled bars). `prev_of` reads the carried mean from the previous
/// bar, `value_of` reads the arriving value from any bar, `set_of` writes the
/// new mean back. The five SMA ladders and KDJ's M all use this one recurrence,
/// so the windowing math lives in exactly one place.
pub fn incremental_mean(
  working: databar.DataBar,
  databar_list: List(databar.DataBar),
  size: Int,
  prev_of: fn(databar.DataBar) -> Float,
  value_of: fn(databar.DataBar) -> Float,
  set_of: fn(databar.DataBar, Float) -> databar.DataBar,
) -> databar.DataBar {
  let len = list.length(databar_list)
  let mean = case len == 0 {
    True -> value_of(working)
    False ->
      case len < size {
        True -> {
          // warm-up: true mean of the bars seen so far
          let previous = list.first(databar_list) |> result.unwrap(working)
          let held = int.to_float(len)
          { held *. prev_of(previous) +. value_of(working) } /. { held +. 1.0 }
        }
        False -> {
          // window full: slide one bar out, one in
          let previous = list.first(databar_list) |> result.unwrap(working)
          let leaving =
            list.drop(databar_list, size - 1)
            |> list.first
            |> result.unwrap(working)
          {
            int.to_float(size)
            *. prev_of(previous)
            +. value_of(working)
            -. value_of(leaving)
          }
          /. int.to_float(size)
        }
      }
  }
  set_of(working, mean)
}

fn sma_of(databar: databar.DataBar, name: SmaSeries) -> Float {
  case name {
    SmaSeriesTiny -> databar.sma_tiny
    SmaSeriesSmall -> databar.sma_small
    SmaSeriesMedium -> databar.sma_medium
    SmaSeriesLarge -> databar.sma_large
    SmaSeriesHuge -> databar.sma_huge
  }
}

fn set_sma_of(
  databar: databar.DataBar,
  name: SmaSeries,
  value: Float,
) -> databar.DataBar {
  case name {
    SmaSeriesTiny -> databar.DataBar(..databar, sma_tiny: value)
    SmaSeriesSmall -> databar.DataBar(..databar, sma_small: value)
    SmaSeriesMedium -> databar.DataBar(..databar, sma_medium: value)
    SmaSeriesLarge -> databar.DataBar(..databar, sma_large: value)
    SmaSeriesHuge -> databar.DataBar(..databar, sma_huge: value)
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
    SmaSeriesHuge -> settings.sma_huge_window_size
  }
}
