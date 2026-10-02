// KDJ oscillator — batch LLV/HHV over window, incremental SMA for K/D/M

import gleam/list
import gleam/float
import gleam/int
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

  // K = SMA(RSV, k_period) - approximate incremental
  let k = incremental_sma(databar.k, rsv, settings.kdj_k_period)

  // D = SMA(K, d_period)
  let d = incremental_sma(databar.d, k, settings.kdj_d_period)

  // J = 3*K - 2*D
  let j = 3.0 *. k -. 2.0 *. d

  // M = true arithmetic mean of last kdj_m_period K values (including current)
  let prev_ks = list.take(databar_list, settings.kdj_m_period - 1) |> list.map(fn(b) { b.k })
  let all_ks = list.prepend(prev_ks, k)
  let m_count = list.length(all_ks)
  let m_sum = list.fold(all_ks, 0.0, fn(acc, v) { acc +. v })
  let m = m_sum /. int.to_float(m_count)

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