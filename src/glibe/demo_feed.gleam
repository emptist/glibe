//// A DEMONSTRATION bar source — NOT a real provider. Implements the demo
//// injection half of `.planning/phases/03-app-view/03-03-PLAN.md` (main +
//// feed helper). R26 leaves the real provider set OPEN: which broker,
//// which symbols, REST or WS is a real consumer's choice, never invented
//// here. This module exists ONLY so the App can be run and its chart seen
//// without a live account; it is plainly labelled DEMO and must never be
//// mistaken for data-source wiring.
////
//// WHAT THIS MODULE WRITES: a deterministic, pure list of standard
//// `SourceBarOneMinute` values — a gentle sine-wave OHLC walk with valid
//// high >= max(open, close) and low <= min(open, close) so `validate` and
//// `single_bar_test` accept every bar (a rejected bar would never archive,
//// R/UC-60). It writes NO Timeframe, NO DataBar and NO wire event; the
//// caller (`src/glibe.gleam` main) turns each bar into a `SourceBarArrived`
//// and dispatches it through `app/wire.gleam`.
////
//// R19 status: skeleton — `////` → type → `///` + signature → `todo` →
//// RED test → GREEN body, in that order.

import gleam/float
import gleam/int
import gleam/list
import gleam/time/timestamp.{from_unix_seconds}
import glibe/api/sourcebar.{type SourceBar, SourceBarOneMinute}

/// DEMO epoch start: a fixed absolute timestamp (R27), not a wall clock.
const demo_epoch_seconds: Int = 1_499_040_000

/// Seconds in one minute (the period this DEMO bar family carries).
const seconds_per_bar: Int = 60

/// DEMO base price and half-amplitude of the triangular walk.
const base_price: Float = 100.0

const amplitude: Float = 8.0

/// A deterministic float max/min — `gleam/float` has none (glib precedent).
fn fmax(a: Float, b: Float) -> Float {
  case a >=. b {
    True -> a
    False -> b
  }
}

fn fmin(a: Float, b: Float) -> Float {
  case a <=. b {
    True -> a
    False -> b
  }
}

/// DEMO close price for sample `index` (0-based): a triangular wave around
/// `base_price` with period 20, so the chart shows a recognisable shape.
/// Pure — no clock, no randomness, no float trigonometry.
fn demo_close(index: Int) -> Float {
  // phase in 0..19; triangle rises 0..10 then falls 10..19, scaled to -1..1
  let phase = index % 20
  let step = case phase <= 10 {
    True -> phase
    False -> 20 - phase
  }
  // 0..10
  // wave in -1..1: (step/10)*2 - 1
  let wave =
    float.subtract(float.multiply(int.to_float(step) /. 10.0, 2.0), 1.0)
  float.add(base_price, float.multiply(wave, amplitude))
}

/// A deterministic DEMO bar at `index` (0-based): OHLCV with a fixed epoch
/// start plus `index` minutes, valid high/low, and a constant volume. The
/// open is the previous sample's close, so consecutive bars join up. One
/// whole `SourceBarOneMinute`, no provider wire format (R28).
pub fn demo_bar(index: Int) -> SourceBar {
  let close = demo_close(index)
  let open = case index {
    0 -> base_price
    n -> demo_close(n - 1)
  }
  let wick = 0.5
  SourceBarOneMinute(
    timestamp: from_unix_seconds(demo_epoch_seconds + index * seconds_per_bar),
    open: open,
    high: fmax(open, close) +. wick,
    low: fmin(open, close) -. wick,
    close: close,
    volume: 1000 + index * 10,
  )
}

/// Build the DEMO bars for indices `from..to` inclusive, tail-recursive so a
/// long demo never grows the stack. Pure recursion — Gleam has no loop/range.
fn bars_from_to(from: Int, to: Int, acc: List(SourceBar)) -> List(SourceBar) {
  case from > to {
    True -> acc
    False -> bars_from_to(from + 1, to, [demo_bar(from), ..acc])
  }
}

/// The DEMO sequence of `count` bars starting at sample 0, oldest-first so
/// the feed can dispatch in time order; count <= 0 yields the empty list
/// (no guard, no panic). The accumulator is reversed once at the end.
pub fn demo_sourcebars(count: Int) -> List(SourceBar) {
  case count <= 0 {
    True -> []
    False -> bars_from_to(0, count - 1, []) |> list.reverse
  }
}
