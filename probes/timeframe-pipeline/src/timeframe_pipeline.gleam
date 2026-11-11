//// `databar_processing` as a plain Gleam pipeline, measured on the REAL
//// `glibe/timeframe.Timeframe`.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-12-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R39 (one straight line, everything happens in
//// `working_databar`), R40 (the pipeline is the body), R33 (pure value
//// recompute), R35 (simple is the verification code), R19 (docs → skeleton →
//// tests → bodies).
////
//// The shape the owner named on 2026-11-12:
////
////   timeframe |> function1 |> function2 |> function3 ... |> functionN
////
//// **Owner's clarification, same day (verbatim)**: *"我在举例时候方便起见，
//// 没有写 function(...),所以你如果以为这是限定，那么就很难做，因为只有单参数fn
//// 才能像上面那样写，实际上你可有有无数参数，只要第一个是所谓 subject即可，
//// 具体的看 官方文件，搜索其中的标题包含 piplines 这部分"*.
////
//// Official source, `https://tour.gleam.run/everything/#functions-pipelines`,
//// section **"Pipelines"**, verbatim:
////
////   "If the right-hand expression is a function call then then the left-hand
////    value will be used as the first argument to the call. For example,
////    `rocket |> launch(1, 2)` would become `launch(rocket, 1, 2)`."
////
////   "If the right-hand expression is not a function call then then it will
////    become one, and the left-hand value will be the sole argument to the
////    call. For example, `rocket |> launch` would become `launch(rocket)`."
////
////   "Gleam code is typically written with the "subject" of the function as
////    the first argument, to make it easier to pipe. If you wish to pipe to a
////    different position then a function capture can be used to insert the
////    argument to the desired position."
////
//// So each step is `fn(Timeframe, ...extra) -> Timeframe`: the FIRST
//// argument is the subject and the result is the subject. `function1` with
//// no call is only the shorthand for a one-argument step, NOT a restriction.
//// All other parameters are supplied at the pipe site — positional, labelled,
//// or a whole configuration type — and none of them is a bar.
//// `working_databar` is a FIELD of `Timeframe`, so every step reads the bar
//// out of the record and puts the result back with a record update.
////
//// This file measures, on the compiler:
////
////   1. the pipe chain runs, in order, and every step sees the previous
////      step's write to `working_databar`;
////   2. one more `|> step` changes no earlier step — extensibility, including
////      a `List(fn(Timeframe) -> Timeframe)` folded over N steps;
////   3. labelled arguments and a fallible (`Result`) step, in the forms
////      Gleam actually allows inside a pipe;
////   4. a fact one step hands to the next belongs in a FIELD, not a tuple —
////      the tuple shape is the one thing that breaks the pipe;
////   5. the last step archives the working bar and needs no bar of its own;
////   6. steps with two extra positional args, three labelled args in any
////      order, a whole settings type, and a function capture into a LATER
////      argument, all stay pipeable — including a mixed-arity straight line.
////
//// `working_databar` is `Option(DataBar)`, so `option.map` keeps every step
//// total: no `let assert`, no `panic`, no catch-all `case` over a custom type.
////
//// **Measured 2026-11-12**: round one `gleam test` = 6 passed; the
//// multi-argument clarification went RED (6 passed / 5 failures) and then
//// GREEN = **11 passed, no failures**, with `gleam build --warnings-as-errors`
//// = 0, `gleam format --check` = 0, `gleam docs build` = 0. On the REAL
//// `Timeframe`, all of these compile and run inside one pipe:
////
////   tf |> add_weighted(2.0, 1.0)
////   tf |> with_labels(cap: 10.0, plus: 1.0, by: 2.0)
////   tf |> bounded(_, StepSettings(..))
////   tf |> subject_second(2.0, _)
////
//// `mixed_line` puts a bare name, a positional call, a labelled call and a
//// capture in ONE straight line ending in `working_databar_archived`. So the
//// answer to "can Gleam write it this way" is YES, and a bare `function1`
//// is only the one-argument shorthand, never a restriction.
////
//// The shape Gleam refuses is a step returning something BESIDE the record.
//// Negative fixture `/tmp/gleam_pipe_negative`, same real `Timeframe`:
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

/// The parameters a step may need BESIDE the subject. A type, not a bag of
/// loose scalars: when a type is called for in nature, define the type.
pub type StepSettings {
  StepSettings(factor: Float, bias: Float, ceiling: Float)
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

/// A step with TWO extra positional arguments. The pipe fills only the
/// first argument; the remaining arguments are written at the call site.
pub fn add_weighted(
  timeframe: Timeframe,
  weight: Float,
  bias: Float,
) -> Timeframe {
  on_working(timeframe, fn(bar) {
    DataBar(..bar, close: bar.close *. weight +. bias)
  })
}

/// A step with THREE labelled arguments. Labels are order-free at the pipe
/// site, so the caller can name them in any order.
pub fn with_labels(
  timeframe: Timeframe,
  by factor: Float,
  plus bias: Float,
  cap ceiling: Float,
) -> Timeframe {
  on_working(timeframe, fn(bar) {
    let computed = bar.close *. factor +. bias
    let close = case computed >. ceiling {
      True -> ceiling
      False -> computed
    }
    DataBar(..bar, close:)
  })
}

/// A step whose subject is NOT the first argument. The tour's function
/// capture (`string.append("3", _)`) puts the piped value at the `_`.
/// Measured for completeness; R40 keeps the subject first.
pub fn subject_second(offset: Float, timeframe: Timeframe) -> Timeframe {
  on_working(timeframe, fn(bar) { DataBar(..bar, close: bar.close +. offset) })
}

/// A step carrying a whole settings type beside the subject. Capturing its
/// other argument turns it into a `fn(Timeframe) -> Timeframe` value, so a
/// multi-argument step also folds over N steps.
pub fn bounded(timeframe: Timeframe, settings: StepSettings) -> Timeframe {
  on_working(timeframe, fn(bar) {
    let computed = bar.close *. settings.factor +. settings.bias
    let close = case computed >. settings.ceiling {
      True -> settings.ceiling
      False -> computed
    }
    DataBar(..bar, close:)
  })
}

/// The body of `databar_processing`: one straight line, no side doors.
/// Here every name happens to be `fn(Timeframe) -> Timeframe`; that is a
/// choice of these three steps, NOT a requirement of `|>` (see `mixed_line`).
/// Adding `|> step_n` changes nothing else in the file.
pub fn straight_line(timeframe: Timeframe) -> Timeframe {
  timeframe
  |> step_one
  |> step_two
  |> step_three
  |> working_databar_archived
}

/// One straight line with MIXED arities: a bare name, two positional
/// arguments, three labelled arguments out of order, and a capture into a
/// later argument. Extra parameters never break the subject-first pipe.
pub fn mixed_line(timeframe: Timeframe) -> Timeframe {
  timeframe
  |> step_one
  |> add_weighted(2.0, 1.0)
  |> with_labels(cap: 100.0, plus: 0.5, by: 1.0)
  |> subject_second(0.5, _)
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
