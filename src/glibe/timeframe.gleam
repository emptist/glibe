// Timeframe — one (symbol, interval), holds everything.
// Phase 1: sourcebar_gate, databar_processing, SMA series, Bollinger, KDJ, Leaf.

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/float
import gleam/string
import glibe/types as types
import glibe/indicator_settings.{type TimeframeSettings}
import glibe/indicator
import glibe/leaf
import glibe/branch

pub type Timeframe {
  Timeframe(
    symbol: String,
    interval: types.Interval,
    market_type: types.MarketType,

    // working_databar is Option — after a close, None until next source bar
    working_databar: Option(types.DataBar),
    databar_list: List(types.DataBar), // newest-first

    // Leaf fields (NOT Option - every bar is in both leaves per DESIGN.md §3.4)
    // Growing leaf IS the DataLeaf record (YinLeaf/YangLeaf variant)
    growing_yin_leaf: leaf.DataLeaf,
    growing_yang_leaf: leaf.DataLeaf,
    yin_leaf_list: List(leaf.DataLeaf),
    yang_leaf_list: List(leaf.DataLeaf),

    // Branch fields (NOT Option - per DESIGN.md §6)
    // Growing branch IS the DataBranch record (YinBranch/YangBranch variant)
    growing_yin_branch: branch.DataBranch,
    growing_yang_branch: branch.DataBranch,
    yin_branch_list: List(branch.DataBranch),
    yang_branch_list: List(branch.DataBranch),
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
    growing_yin_leaf: leaf.init_yin_leaf(0),
    growing_yang_leaf: leaf.init_yang_leaf(0),
    yin_leaf_list: [],
    yang_leaf_list: [],
    growing_yin_branch: branch.init_yin_branch(0),
    growing_yang_branch: branch.init_yang_branch(0),
    yin_branch_list: [],
    yang_branch_list: [],
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
  let #(databar, timeframe) = leaves(databar, timeframe, settings)
  let #(databar, timeframe) = branches(databar, timeframe, settings)
  accept(timeframe, databar)
}

/// Leaf detection — after KDJ, before Bollinger per DESIGN.md §15.3
/// Updates growing leaves, moves completed leaves to lists, writes CMA to databar
fn leaves(databar: types.DataBar, timeframe: Timeframe, _settings: TimeframeSettings) -> #(types.DataBar, Timeframe) {
  let idx = list.length(timeframe.databar_list)
  let sma_tiny = databar.sma_tiny

  // Update growing yin leaf
  let #(closed_yin, new_yin, yin_cma) = leaf.update_yin_leaf(timeframe.growing_yin_leaf, idx, timeframe.databar_list, sma_tiny)
  // Update growing yang leaf
  let #(closed_yang, new_yang, yang_cma) = leaf.update_yang_leaf(timeframe.growing_yang_leaf, idx, timeframe.databar_list, sma_tiny)

  // Write CMA to databar
  let databar = types.DataBar(..databar, yin_leaf_cma: yin_cma, yang_leaf_cma: yang_cma)

  let timeframe = Timeframe(..timeframe,
    growing_yin_leaf: new_yin,
    growing_yang_leaf: new_yang,
    yin_leaf_list: case closed_yin {
      Some(l) -> list.prepend(timeframe.yin_leaf_list, l)
      None -> timeframe.yin_leaf_list
    },
    yang_leaf_list: case closed_yang {
      Some(l) -> list.prepend(timeframe.yang_leaf_list, l)
      None -> timeframe.yang_leaf_list
    },
  )

  #(databar, timeframe)
}

/// Branch detection — after Leaf per DESIGN.md §15.3
/// Updates growing branches, moves completed branches to lists
fn branches(databar: types.DataBar, timeframe: Timeframe, settings: TimeframeSettings) -> #(types.DataBar, Timeframe) {
  let idx = list.length(timeframe.databar_list)
  let exit_leaf_size = settings.branch_exit_leaf_size

  // Update growing yin branch (tracks growing yang leaf)
  let #(closed_yin_branch, new_yin_branch) =
    branch.update_yin_branch(
      timeframe.growing_yin_branch,
      idx,
      timeframe.growing_yang_leaf,
      timeframe.yin_leaf_list,
      exit_leaf_size,
    )

  // Update growing yang branch (tracks growing yin leaf)
  let #(closed_yang_branch, new_yang_branch) =
    branch.update_yang_branch(
      timeframe.growing_yang_branch,
      idx,
      timeframe.yang_leaf_list,
      timeframe.growing_yin_leaf,
      exit_leaf_size,
    )

  let timeframe = Timeframe(..timeframe,
    growing_yin_branch: new_yin_branch,
    growing_yang_branch: new_yang_branch,
    yin_branch_list: case closed_yin_branch {
      Some(b) -> list.prepend(timeframe.yin_branch_list, b)
      None -> timeframe.yin_branch_list
    },
    yang_branch_list: case closed_yang_branch {
      Some(b) -> list.prepend(timeframe.yang_branch_list, b)
      None -> timeframe.yang_branch_list
    },
  )

  #(databar, timeframe)
}

/// The finished bar goes into databar_list (newest-first)
fn accept(timeframe: Timeframe, databar: types.DataBar) -> Timeframe {
  Timeframe(
    ..timeframe,
    databar_list: list.prepend(timeframe.databar_list, databar),
  )
}

/// Export databar_list as CSV (oldest-first) for TradingView Pine Script verification.
/// Columns: time,open,high,low,close,volume,sma_tiny,sma_small,sma_medium,sma_large,
/// bb_m,bb_u3,bb_l3,bb_u2,bb_u1,bb_l1,bb_l2,k,d,j,m,
/// yin_leaf_cma,yang_leaf_cma,yin_leaf_start,yin_leaf_end,yin_leaf_corner,
/// yang_leaf_start,yang_leaf_end,yang_leaf_corner
pub fn to_csv(timeframe: Timeframe) -> String {
  let bars = list.reverse(timeframe.databar_list) // oldest-first
  let header = "time,open,high,low,close,volume,sma_tiny,sma_small,sma_medium,sma_large,bb_m,bb_u3,bb_l3,bb_u2,bb_u1,bb_l1,bb_l2,k,d,j,m,yin_leaf_cma,yang_leaf_cma,yin_leaf_start,yin_leaf_end,yin_leaf_corner,yang_leaf_start,yang_leaf_end,yang_leaf_corner"
  
  let rows = list.map(bars, fn(bar) {
    // Simplified: just export bar data, leaf/branch indices need separate tracking
    "#{bar.date},#{bar.open},#{bar.high},#{bar.low},#{bar.close},#{bar.volume},#{bar.sma_tiny},#{bar.sma_small},#{bar.sma_medium},#{bar.sma_large},#{bar.bb_m},#{bar.bb_u3},#{bar.bb_l3},#{bar.bb_u2},#{bar.bb_u1},#{bar.bb_l1},#{bar.bb_l2},#{bar.k},#{bar.d},#{bar.j},#{bar.m},#{bar.yin_leaf_cma},#{bar.yang_leaf_cma},0,0,0,0,0,0"
  })
  
  list.append([header], rows) |> string.join("\n")
}