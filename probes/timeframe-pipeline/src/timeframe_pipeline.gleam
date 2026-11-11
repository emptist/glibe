//// `databar_processing` as a plain Gleam pipeline, measured on the REAL
//// `glibe/timeframe.Timeframe`.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-12-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R39 (one straight line, everything happens in
//// `working_databar`), R33 (pure value recompute), R35 (simple is the
//// verification code), R19 (docs → skeleton → tests → bodies).
////
//// The shape the owner named on 2026-11-12:
////
////   timeframe |> function1 |> function2 |> function3 ... |> functionN
////
//// Every step is `fn(Timeframe) -> Timeframe`. `working_databar` is a FIELD
//// of `Timeframe`, so no step ever takes a bar as an argument: it reads the
//// bar out of the record and puts the result back with a record update.
//// This file measures, on the compiler:
////
////   1. the pipe chain runs, in order, and every step sees the previous
////      step's write to `working_databar`;
////   2. one more `|> step` changes no earlier step — extensibility, including
////      a `List(fn(Timeframe) -> Timeframe)` folded over N steps;
////   3. a labelled-argument step and a fallible (`Result`) step, in the forms
////      Gleam actually allows inside a pipe;
////   4. a fact one step hands to the next belongs in a FIELD, not a tuple —
////      the tuple shape is the one thing that breaks the pipe;
////   5. the last step archives the working bar and needs no bar of its own.
////
//// `working_databar` is `Option(DataBar)`, so `option.map` keeps every step
//// total: no `let assert`, no `panic`, no catch-all `case` over a custom type.
////
//// **Measured 2026-11-12**: `gleam build --warnings-as-errors` = 0,
//// `gleam test` = 6 passed. The answer to "can Gleam write it this way" is
//// YES. The shape Gleam refuses is a step returning something BESIDE the
//// record. Negative fixture `/tmp/gleam_pipe_negative`, same real `Timeframe`:
////
////   tf |> tuple_step |> next_step
////   error: Type mismatch — "This function does not accept the piped type"
////   The argument is #(Timeframe, Int), but function expects Timeframe.
////
//// That shape's allowed form is `let #(tf, fact) = tuple_step(tf)` followed
//// by a pipe from `tf` — it compiles (measured, exit 0), but the straight
//// line is broken. Put the fact in a FIELD and the line stays a pipe, which
//// is what `settle_leaf |> read_settled_leaf` below measures.
////
//// **If `Timeframe` were `opaque`** (measured in the same fixture): a
//// cross-module `Timeframe(..tf, …)` fails with "Use of private value", but
//// `tf |> owner.step |> owner.step` still compiles. An opaque state type
//// keeps its steps in the module that owns it; glibe's `Timeframe` is
//// `pub type`, which is why a separate `engine.gleam` can pipe it.

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/time/timestamp
import glibe/api/sourcebar
import glibe/databar.{type DataBar, DataBar}
import glibe/indicator_settings
import glibe/leaf.{type DataLeaf, YinLeaf}
import glibe/timeframe.{type Timeframe, Timeframe}

/// The one failure a fallible step can have: there is no bar in hand.
/// An error is a closed set, never a `String` (R13).
pub type ProcessingError {
  NoWorkingDatabar
}

/// A miniature of `Timeframe` for ONE measurement: a fact produced by one
/// step and read by the next without a tuple. The two field names are the
/// ones the domain already uses; only the record is local to this probe.
pub type Frame {
  Frame(working_databar: Option(DataBar), yin_leaf_settled: Option(DataLeaf))
}

/// The parameter block one `Timeframe` runs on (R23): one value, not an
/// entity, and no second dictionary anywhere.
pub fn settings() -> indicator_settings.TimeframeSettings {
  indicator_settings.TimeframeSettings(
    sma_tiny_window_size: 7,
    sma_small_window_size: 70,
    sma_medium_window_size: 350,
    sma_large_window_size: 1750,
    sma_huge_window_size: 8750,
    kdj_window_size: 9,
    kdj_k_period: 3,
    kdj_m_period: 3,
    bb_multiplier: 2.0,
    sma_for_bbm: indicator_settings.SmaForBbmTiny,
    branch_exit_leaf_size: 5,
  )
}

/// One qualified `SourceBar` born whole as one `DataBar` (R39). Neither a
/// bucket nor a fold: one bar is the whole of the working databar.
pub fn born_bar() -> DataBar {
  databar.of_sourcebar(
    sourcebar.SourceBar(
      timestamp: timestamp.from_unix_seconds(0),
      open: 1.0,
      high: 2.0,
      low: 0.5,
      close: 1.5,
      volume: 100,
    ),
    0,
  )
}

/// The entry point: put the bar in hand. No later step receives a bar.
pub fn in_hand(timeframe: Timeframe, bar: DataBar) -> Timeframe {
  Timeframe(..timeframe, working_databar: Some(bar))
}

/// Read the working bar out of the record and put the result back. Because
/// the field is an `Option`, `option.map` is total: no bar in hand means the
/// step is a no-op, not a crash and not a guessed bar.
fn on_working(
  timeframe: Timeframe,
  compute: fn(DataBar) -> DataBar,
) -> Timeframe {
  Timeframe(
    ..timeframe,
    working_databar: option.map(timeframe.working_databar, compute),
  )
}

/// Step 1: double the working bar's close. Reads and writes the record.
pub fn step_one(timeframe: Timeframe) -> Timeframe {
  on_working(timeframe, fn(bar) { DataBar(..bar, close: bar.close *. 2.0) })
}

/// Step 2: add one to the working bar's close.
pub fn step_two(timeframe: Timeframe) -> Timeframe {
  on_working(timeframe, fn(bar) { DataBar(..bar, close: bar.close +. 1.0) })
}

/// Step 3: triple the working bar's close, so order is observable.
pub fn step_three(timeframe: Timeframe) -> Timeframe {
  on_working(timeframe, fn(bar) { DataBar(..bar, close: bar.close *. 3.0) })
}

/// A step with configuration: a labelled argument is filled at the pipe
/// site, because `|>` inserts the left side as the FIRST argument.
pub fn scale(timeframe: Timeframe, by factor: Float) -> Timeframe {
  on_working(timeframe, fn(bar) { DataBar(..bar, close: bar.close *. factor) })
}

/// The body of `databar_processing`: one straight line, no side doors.
/// Every name in this chain has the same type, `fn(Timeframe) -> Timeframe`;
/// adding `|> step_n` changes nothing else in the file.
pub fn straight_line(timeframe: Timeframe) -> Timeframe {
  timeframe
  |> step_one
  |> step_two
  |> step_three
  |> working_databar_archived
}

/// N steps: the same shape, extended at runtime instead of at the pipe site.
/// The record is the accumulator; no state lives outside the value.
pub fn run_steps(
  timeframe: Timeframe,
  steps: List(fn(Timeframe) -> Timeframe),
) -> Timeframe {
  list.fold(steps, timeframe, fn(frame, step) { step(frame) })
}

/// A step that can fail. Its `Result` type is what makes the fallible pipe
/// possible without a `try`/`raise` that Gleam does not have.
pub fn checked_step(
  timeframe: Timeframe,
) -> Result(Timeframe, ProcessingError) {
  case timeframe.working_databar {
    None -> Error(NoWorkingDatabar)
    Some(_) -> Ok(step_two(timeframe))
  }
}

/// The fallible pipe: `Ok(tf) |> result.try(step) |> result.try(step)`.
/// When a step is fallible, `Result`, not the record, is what flows through
/// the pipe — this is the Gleam-allowed form, not a second mechanism.
pub fn checked(timeframe: Timeframe) -> Result(Timeframe, ProcessingError) {
  Ok(timeframe)
  |> result.try(checked_step)
  |> result.try(checked_step)
}

/// Step A of the miniature: write a settled leaf into a field.
pub fn settle_leaf(frame: Frame) -> Frame {
  Frame(
    ..frame,
    yin_leaf_settled: option.map(frame.working_databar, fn(bar) {
      YinLeaf(start_bar: bar, end_bar: None, corner_bar: bar)
    }),
  )
}

/// Step B of the miniature: read that field. Nothing is handed over beside
/// the record, so `frame |> settle_leaf |> read_settled_leaf` compiles.
pub fn read_settled_leaf(frame: Frame) -> Frame {
  let close = case frame.yin_leaf_settled {
    None -> 0.0
    Some(_) -> 99.0
  }
  Frame(
    ..frame,
    working_databar: option.map(frame.working_databar, fn(bar) {
      DataBar(..bar, close:)
    }),
  )
}

/// The last step: the bar it files IS `timeframe.working_databar`, so it
/// takes no bar of its own. `Some -> None` is the boundary of the present.
pub fn working_databar_archived(timeframe: Timeframe) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(bar) ->
      Timeframe(
        ..timeframe,
        databar_list: [bar, ..timeframe.databar_list],
        working_databar: None,
      )
  }
}
