//// The Bollinger band — the centre, the σ over it, and the seven lines.
//// Implements `.planning/phases/02-domain-stream/02-02-PLAN.md` Task 3.
////
//// WHY THIS IS ITS OWN MODULE (owner 2026-11-23: *"他的补充完全是敷衍，所以
//// 全部塞进不应该塞进去的模块，而不去新建应该用的模块"*): frozen glib has
//// `bollinger.gleam` as a separate file (250 lines) and this content was
//// sitting inside `timeframe.gleam`. NAMING.md 1.19 / 1.20 (one class, one
//// module) and R50 (one module, one ownership relation) put the band with the
//// lines it writes and the σ state it carries.
////
//// It reads `DataBar`'s seven band fields plus the σ state, and writes them
//// back; it depends on `databar.gleam` and `sma.gleam` only — neither of
//// which imports an engine module — so there is no cycle.
////
//// The centre line is NOT computed here: it is the SELECTED SMA series, read
//// by the caller through `sma.sma_of` (glib `indicator.gleam:45`). This module
//// takes the centre as an argument, which is what lets the week and the month
//// use their own centre (small / tiny) without a second answer.
////
//// R19 status: bodies moved verbatim from `timeframe.gleam` (2026-11-23) —
//// the arithmetic is unchanged, only the module changed.

import gleam/float
import gleam/int
import gleam/list
import gleam/result
import glibe/databar.{type DataBar, DataBar}

/// Welford moving-window σ over the closes. Returns σ and the carried state
/// #(n, mean, m2) to store on the bar for the next one (glib
/// `bollinger.gleam:160-186`). `sigma_add` then the inverse `sigma_remove`
/// keeps the window sliding in O(1) without materialising it (UC-63).
pub fn sigma_stream(
  working: DataBar,
  settled: List(DataBar),
  size: Int,
) -> #(Float, #(Int, Float, Float)) {
  let #(n, mean, m2) = case list.first(settled) {
    Ok(b) -> #(b.sigma_n, b.sigma_mean, b.sigma_m2)
    Error(_) -> #(0, 0.0, 0.0)
  }
  let #(an, amean, am2) = sigma_add(n, mean, m2, working.close)
  let state = case n >= size {
    True -> {
      let leaving = case list.drop(settled, size - 1) |> list.first {
        Ok(b) -> b.close
        Error(_) -> working.close
      }
      sigma_remove(an, amean, am2, leaving)
    }
    False -> #(an, amean, am2)
  }
  let sigma = case state.0 {
    0 -> 0.0
    _ ->
      result.unwrap(
        float.square_root(float.max(0.0, state.2 /. int.to_float(state.0))),
        0.0,
      )
  }
  #(sigma, state)
}

/// The one artificial floor on the lower edge, as a FRACTION of the centre —
/// glib `bollinger.gleam:121`. A fraction (not a fixed constant) cannot invert
/// the band order at any price: bb_l3 becomes `1e-6·bb_m`, below bb_m whatever
/// bb_m is, and the inner lines are convex blends of that edge and the basis.
pub const band_floor_ratio: Float = 0.000001

/// The seven Bollinger lines from the centre and σ (glib
/// `bollinger.gleam:199-225`). The lower edge is floored BEFORE interpolation,
/// so one floor suffices and `l3 ≤ l2 ≤ l1 ≤ m ≤ u1 ≤ u2 ≤ u3` holds by
/// construction. The inner lines blend edge and basis at 0.382 / 0.618.
pub fn band(
  bb_m: Float,
  sigma: Float,
  width: Float,
) -> #(Float, Float, Float, Float, Float, Float, Float) {
  let bb_u3 = bb_m +. width *. sigma
  let raw_l3 = bb_m -. width *. sigma
  // The floor is ordinary traffic, not a guard: the raw edge is at or below
  // zero on ~3% of glib's own bars (bollinger.gleam:205-206).
  let bb_l3 = case raw_l3 <=. 0.0 {
    True -> bb_m *. band_floor_ratio
    False -> raw_l3
  }
  #(
    bb_m,
    bb_u3,
    bb_l3,
    0.618 *. bb_u3 +. 0.382 *. bb_m,
    // bb_u2
    0.382 *. bb_u3 +. 0.618 *. bb_m,
    // bb_u1
    0.382 *. bb_l3 +. 0.618 *. bb_m,
    // bb_l1
    0.618 *. bb_l3 +. 0.382 *. bb_m,
    // bb_l2
  )
}

/// Write all seven lines plus the σ state onto the working bar (glib
/// `bollinger.set_bband:232-246`).
pub fn write_band(
  bar: DataBar,
  lines: #(Float, Float, Float, Float, Float, Float, Float),
  state: #(Int, Float, Float),
) -> DataBar {
  DataBar(
    ..bar,
    bb_m: lines.0,
    bb_u3: lines.1,
    bb_l3: lines.2,
    bb_u2: lines.3,
    bb_u1: lines.4,
    bb_l1: lines.5,
    bb_l2: lines.6,
    sigma_n: state.0,
    sigma_mean: state.1,
    sigma_m2: state.2,
  )
}

/// Welford's one step: add one observation (glib `bollinger.sigma_add:123-130`).
pub fn sigma_add(
  n: Int,
  mean: Float,
  m2: Float,
  x: Float,
) -> #(Int, Float, Float) {
  let next = n + 1
  let delta = x -. mean
  let next_mean = mean +. delta /. int.to_float(next)
  let delta2 = x -. next_mean
  #(next, next_mean, m2 +. delta *. delta2)
}

/// The exact inverse of `sigma_add`: remove the observation that left the
/// window (glib `bollinger.sigma_remove:132-139`).
pub fn sigma_remove(
  n: Int,
  mean: Float,
  m2: Float,
  x: Float,
) -> #(Int, Float, Float) {
  let next = n - 1
  let delta = x -. mean
  let next_mean = mean -. delta /. int.to_float(next)
  let delta2 = x -. next_mean
  #(next, next_mean, m2 -. delta *. delta2)
}
