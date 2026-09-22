// KDJ oscillator — batch LLV/HHV over window, incremental SMA for K/D/M

import gleam/list
import gleam/float
import gleam/int
import glibe/types as types
import glibe/indicator_settings.{type TimeframeSettings}

/// KDJ — batch LLV/HHV over window, incremental SMA for K/D/M
pub fn kdj(databar: types.DataBar, databar_list: List(types.DataBar), settings: TimeframeSettings) -> types.DataBar {
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

  // K = SMA(RSV, k_period) - approximate incremental
  let k = incremental_sma(databar.k, rsv, settings.kdj_k_period)

  // D = SMA(K, d_period)
  let d = incremental_sma(databar.d, k, settings.kdj_d_period)

  // J = 3*K - 2*D
  let j = 3.0 *. k -. 2.0 *. d

  // M = SMA(K, 10) - fixed 10 period
  let m = incremental_sma(databar.m, k, 10)

  types.DataBar(
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