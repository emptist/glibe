// KDJ oscillator — batch LLV/HHV over window, incremental SMA for K/D/M

import gleam/list
import gleam/float
import gleam/int
import gleam/result
import glibe/databar as databar
import glibe/indicator_settings.{type TimeframeSettings}

/// KDJ — batch LLV/HHV over window, incremental SMA for K/D/M
pub fn kdj(databar: databar.DataBar, databar_list: List(databar.DataBar), settings: TimeframeSettings) -> databar.DataBar {
  // Window for LLV/HHV
  let window = list.take(databar_list, settings.window_kdj_size)

  // LLV/HHV by scanning window (O(9) = trivial)
  let #(llv, hhv) = list.fold(window, #(databar.low, databar.high), fn(acc, bar) {
    let #(l, h) = acc
    #(float.min(l, bar.low), float.max(h, bar.high))
  })

  // RSV
  let rsv = case hhv -. llv >. 0.0 {
    True -> { databar.close -. llv } /. { hhv -. llv } *. 100.0
    False -> 50.0
  }

  // Previous bar's K/D/M — read from settled list, not from working bar (which starts at 50)
  let prev_bar = list.first(databar_list)
  let prev_k = prev_bar |> result.map(fn(b) { b.k }) |> result.unwrap(50.0)
  let prev_d = prev_bar |> result.map(fn(b) { b.d }) |> result.unwrap(50.0)
  let prev_m = prev_bar |> result.map(fn(b) { b.m }) |> result.unwrap(50.0)

  // K = incremental SMA(RSV, k_period)
  let k = incremental_sma(prev_k, rsv, settings.kdj_k_period)

  // D = incremental SMA(K, d_period)
  let d = incremental_sma(prev_d, k, settings.kdj_d_period)

  // J = 3*K - 2*D
  let j = 3.0 *. k -. 2.0 *. d

  // M = streaming incremental mean of last kdj_m_period K values
  // Same three-case pattern as sma_tiny: empty / warm-up / full window
  let len = list.length(databar_list)
  let m = case len == 0 {
    True -> k
    False ->
      case len < settings.kdj_m_period {
        True ->
          { int.to_float(len) *. prev_m +. k } /. int.to_float(len + 1)
        False -> {
          let leaving_k =
            list.drop(databar_list, settings.kdj_m_period - 1)
            |> list.first()
            |> result.map(fn(b) { b.k })
            |> result.unwrap(k)
          { int.to_float(settings.kdj_m_period) *. prev_m +. k -. leaving_k }
            /. int.to_float(settings.kdj_m_period)
        }
      }
  }

  databar.DataBar(
    ..databar,
    k: k,
    d: d,
    j: j,
    m: m,
  )
}

/// Approximate incremental SMA: new = prev + (new - prev) / period
/// Full incremental needs leaving value; this is good enough for small periods
fn incremental_sma(prev: Float, new_val: Float, period: Int) -> Float {
  prev +. {new_val -. prev} /. int.to_float(period)
}