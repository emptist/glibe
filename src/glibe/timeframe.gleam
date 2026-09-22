// Timeframe — one (symbol, interval), holds everything.
// Phase 1: sourcebar_gate, databar_processing, SMA series, Bollinger, KDJ.

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/int
import gleam/float
import glibe/types as types
import glibe/indicator_settings.{type TimeframeSettings}
import glibe/indicator

pub type Timeframe {
  Timeframe(
    symbol: String,
    interval: types.Interval,
    market_type: types.MarketType,

    // working_databar is Option — after a close, None until next source bar
    working_databar: Option(types.DataBar),
    databar_list: List(types.DataBar), // newest-first
  )
}

/// Born with NO bar. First bar comes through sourcebar_gate.
pub fn new(symbol: String, interval: types.Interval, market_type: types.MarketType) -> Timeframe {
  Timeframe(
    symbol: symbol,
    interval: interval,
    market_type: market_type,
    working_databar: None,
    databar_list: [],
  )
}

/// The ONLY function that touches SourceBar.
/// Returns #(closed_databar_if_any, new_timeframe)
pub fn sourcebar_gate(timeframe: Timeframe, sourcebar: types.SourceBar) -> #(Option(types.DataBar), Timeframe) {
  let in_hand = case timeframe.working_databar {
    None -> first_databar(sourcebar)
    Some(bar) -> fold_databar(bar, sourcebar)
  }

  case bucket_ends(sourcebar, timeframe.interval) {
    True -> #(
      Some(in_hand),
      Timeframe(..timeframe, working_databar: None),
    )
    False -> #(
      None,
      Timeframe(..timeframe, working_databar: Some(in_hand)),
    )
  }
}

/// Does this source bar end its bucket? Decision from timestamp + interval only.
fn bucket_ends(_sourcebar: types.SourceBar, interval: types.Interval) -> Bool {
  case interval {
    types.D1 -> True
    types.H1 -> True
    _ -> True
  }
}

/// First source bar of a bucket becomes a new DataBar (OHLCV = that bar's values)
fn first_databar(sourcebar: types.SourceBar) -> types.DataBar {
  types.DataBar(
    date: sourcebar.date,
    open: sourcebar.open,
    high: sourcebar.high,
    low: sourcebar.low,
    close: sourcebar.close,
    volume: sourcebar.volume,
    sma_tiny: 0.0,
    prev_sma_tiny: 0.0,
    sma_small: 0.0,
    sma_medium: 0.0,
    sma_large: 0.0,
    bb_m: 0.0,
    prev_bb_m: 0.0,
    bb_u3: 0.0,
    bb_l3: 0.0,
    bb_u2: 0.0,
    bb_u1: 0.0,
    bb_l1: 0.0,
    bb_l2: 0.0,
    k: 50.0,
    d: 50.0,
    j: 50.0,
    m: 50.0,
    prev_k: 50.0,
    prev_j: 50.0,
    bias: 0.0,
    small_above_tiny: False,
    cmas_up: False,
    bars_k_on_d: 0,
    bars_d_on_k: 0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
    inner_yin_leaf_cma: 0.0,
    inner_yang_leaf_cma: 0.0,
    inner_inner_yin_leaf_cma: 0.0,
    inner_inner_yang_leaf_cma: 0.0,
    kdj_cross_up: False,
    kdj_bearish_left: False,
    price_at_lower_band: False,
    sma_tiny_rising: False,
    leaf_cmas_rising: False,
    leaf_cmas_falling: False,
    signal: "",
  )
}

/// Fold source bar into working DataBar (update high/low/close/volume)
fn fold_databar(databar: types.DataBar, sourcebar: types.SourceBar) -> types.DataBar {
  types.DataBar(
    ..databar,
    high: float.max(databar.high, sourcebar.high),
    low: float.min(databar.low, sourcebar.low),
    close: sourcebar.close,
    volume: databar.volume + sourcebar.volume,
  )
}

/// The super function — lives in Timeframe module, holds no arithmetic of its own
pub fn databar_processing(timeframe: Timeframe, databar: types.DataBar, settings: TimeframeSettings) -> Timeframe {
  let databar = indicator.run(databar, timeframe.databar_list, settings)
  // TODO: leaves, branches, strategy, runtime_test
  accept(timeframe, databar)
}

/// The finished bar goes into databar_list (newest-first)
fn accept(timeframe: Timeframe, databar: types.DataBar) -> Timeframe {
  Timeframe(
    ..timeframe,
    databar_list: list.prepend(timeframe.databar_list, databar),
  )
}