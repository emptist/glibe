// The CSV export — one row per accepted bar, oldest first, for checking the
// engine against something that is not the engine (TradingView, a spreadsheet,
// another implementation).
//
// **Every column is a field something computed.** The header used to promise
// six leaf indices — start, end and corner for each polarity — and every row
// wrote `0` in all six, with a comment in the code admitting the values were
// not tracked. An export that prints a number nobody computed is worse than an
// export with six fewer columns, because the reader cannot tell the difference
// between "zero" and "never measured". The six columns are gone; when a bar can
// name the leaf it sits in, they come back as values.

import gleam/float
import gleam/int
import gleam/list
import gleam/string
import glibe/databar.{type DataBar}
import glibe/timeframe.{type Timeframe}
import glibe/trading/signal

/// Header and rows, in the order the columns are written.
pub fn to_csv(timeframe: Timeframe) -> String {
  let bars = list.reverse(timeframe.databar_list)
  list.append([header()], list.map(bars, row)) |> string.join("\n")
}

pub fn header() -> String {
  string.join(
    [
      "time",
      "open",
      "high",
      "low",
      "close",
      "volume",
      "sma_tiny",
      "sma_small",
      "sma_medium",
      "sma_large",
      "sma_huge",
      "bb_m",
      "bb_u3",
      "bb_l3",
      "bb_u2",
      "bb_u1",
      "bb_l1",
      "bb_l2",
      "k",
      "d",
      "j",
      "m",
      "yin_leaf_cma",
      "yang_leaf_cma",
      "signal",
    ],
    ",",
  )
}

fn row(bar: DataBar) -> String {
  string.join(
    [
      bar.date,
      f(bar.open),
      f(bar.high),
      f(bar.low),
      f(bar.close),
      int.to_string(bar.volume),
      f(bar.sma_tiny),
      f(bar.sma_small),
      f(bar.sma_medium),
      f(bar.sma_large),
      f(bar.sma_huge),
      f(bar.bb_m),
      f(bar.bb_u3),
      f(bar.bb_l3),
      f(bar.bb_u2),
      f(bar.bb_u1),
      f(bar.bb_l1),
      f(bar.bb_l2),
      f(bar.k),
      f(bar.d),
      f(bar.j),
      f(bar.m),
      f(bar.yin_leaf_cma),
      f(bar.yang_leaf_cma),
      signal.to_string(bar.signal),
    ],
    ",",
  )
}

fn f(value: Float) -> String {
  float.to_string(value)
}
