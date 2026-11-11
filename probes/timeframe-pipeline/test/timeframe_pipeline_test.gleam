//// Design goals for the `databar_processing` pipeline (R19: written BEFORE
//// the bodies). Every assertion here is a claim about the SHAPE the owner
//// named on 2026-11-12, not about a number the implementation happens to
//// return.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-12-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R39 (one straight line, no step takes the bar
//// as an argument), R40 (the pipeline is the body), R33 (pure value
//// recompute), R35 (simple is the check).
////
//// Owner 2026-11-12 clarification: `function1` was shorthand, NOT a
//// one-argument restriction; a step may have any number of parameters as
//// long as the FIRST one is the subject `Timeframe`. Official tour section
//// "Pipelines": `rocket |> launch(1, 2)` becomes `launch(rocket, 1, 2)`.
////
//// The subject of every pipe is a REAL `glibe.timeframe.Timeframe`, whose
//// `working_databar` field is where all of the work happens.

import gleam/list
import gleam/option.{None, Some}
import gleeunit
import glibe/timeframe
import timeframe_pipeline.{Frame, NoWorkingDatabar}

/// gleeunit's entrypoint; every `pub fn *_test()` is discovered.
pub fn main() -> Nil {
  gleeunit.main()
}

/// One `Timeframe` with one whole bar in hand: the state the gate hands to
/// `databar_processing`, before any step has run.
fn seeded() -> timeframe.Timeframe {
  timeframe.new(timeframe_pipeline.settings())
  |> timeframe_pipeline.in_hand(timeframe_pipeline.born_bar())
}

/// The whole point: `timeframe |> f1 |> f2 |> f3` compiles, runs in order,
/// and each step reads the working databar the previous step wrote.
pub fn pipe_chain_runs_in_order_test() {
  let tf =
    seeded()
    |> timeframe_pipeline.step_one
    |> timeframe_pipeline.step_two
    |> timeframe_pipeline.step_three
  let assert Some(bar) = tf.working_databar
  assert bar.close == 12.0 as "(1.5 * 2 + 1) * 3 — the order is visible"
  assert bar.idx == 0 as "the bar's identity survives every step"
  assert tf.databar_list == [] as "no step archives before the last one"
}

/// Adding one more `|> step` changes no earlier step and no earlier value:
/// that is what "infinitely extensible" means for a pure value.
pub fn one_more_step_changes_no_earlier_value_test() {
  let three =
    seeded()
    |> timeframe_pipeline.step_one
    |> timeframe_pipeline.step_two
    |> timeframe_pipeline.step_three
  let four = three |> timeframe_pipeline.scale(by: 2.0)
  let assert Some(before) = three.working_databar
  let assert Some(after) = four.working_databar
  assert before.close == 12.0 as "the old value is untouched"
  assert after.close == 24.0 as "the new step sees the previous write"
}

/// N steps, held as values, folded over the record: the pipe is not limited
/// to the number of lines a human wrote in the source file.
pub fn n_steps_test() {
  let steps = list.repeat(timeframe_pipeline.step_two, 1000)
  let tf = timeframe_pipeline.run_steps(seeded(), steps)
  let assert Some(bar) = tf.working_databar
  assert bar.close == 1001.5 as "all 1000 steps read the previous step's bar"
}

/// A fallible step cannot sit in a plain `|>`; Gleam's allowed form is
/// `Ok(tf) |> result.try(step) |> result.try(step)`.
pub fn fallible_pipe_test() {
  let assert Ok(tf) = timeframe_pipeline.checked(seeded())
  let assert Some(bar) = tf.working_databar
  assert bar.close == 3.5 as "both fallible steps ran"
  assert timeframe_pipeline.checked(
      timeframe.new(timeframe_pipeline.settings()),
    )
    == Error(NoWorkingDatabar)
    as "no bar in hand is a typed error"
}

/// A fact one step produces and the next step needs belongs in a FIELD.
/// Handing it beside the record (`#(Timeframe, a)`) is what breaks a pipe.
pub fn fact_in_a_field_stays_pipeable_test() {
  let frame =
    Frame(
      working_databar: Some(timeframe_pipeline.born_bar()),
      yin_leaf_settled: None,
    )
  let done =
    frame
    |> timeframe_pipeline.settle_leaf
    |> timeframe_pipeline.read_settled_leaf
  let assert Some(_) = done.yin_leaf_settled
  let assert Some(bar) = done.working_databar
  assert bar.close == 99.0 as "step B read the fact step A wrote into a field"
}

/// The last step takes no bar: what it files IS `working_databar`, and the
/// `Some -> None` transition is the boundary between present and history.
pub fn straight_line_archives_the_working_bar_test() {
  let tf = timeframe_pipeline.straight_line(seeded())
  assert tf.working_databar == None as "after archive nothing is in flight"
  let assert [bar, ..] = tf.databar_list
  assert bar.close == 12.0 as "the archived bar is the one every step worked on"
  assert timeframe_pipeline.working_databar_archived(
      timeframe.new(timeframe_pipeline.settings()),
    ).databar_list
    == []
    as "no bar in hand archives nothing"
}

/// Official "Pipelines": a call on the right of `|>` receives the left side
/// as its FIRST argument; all remaining arguments are written at the call
/// site. Two extra positional arguments are not a restriction.
pub fn many_positional_arguments_stay_pipeable_test() {
  let tf = seeded() |> timeframe_pipeline.add_weighted(2.0, 1.0)
  let assert Some(bar) = tf.working_databar
  assert bar.close == 4.0 as "1.5 * 2 + 1; Timeframe is still the only subject"
  assert bar.idx == 0 as "extra arguments never carried another bar"
}

/// Labelled arguments are order-free, so three of them can be named in any
/// order at the pipe site — and each one really reaches the step's body.
pub fn labelled_arguments_in_any_order_test() {
  let tf =
    seeded()
    |> timeframe_pipeline.with_labels(cap: 10.0, plus: 1.0, by: 2.0)
  let assert Some(bar) = tf.working_databar
  assert bar.close == 4.0 as "labels were filled by name, not by position"
  let capped =
    seeded()
    |> timeframe_pipeline.with_labels(by: 2.0, cap: 3.0, plus: 1.0)
  let assert Some(cap_bar) = capped.working_databar
  assert cap_bar.close == 3.0 as "the ceiling label reached the body"
}

/// The tour's function capture moves the piped value to a later argument.
/// The language allows it; R40 still keeps the subject first by convention.
pub fn capture_to_a_later_argument_test() {
  let tf = seeded() |> timeframe_pipeline.subject_second(2.0, _)
  let assert Some(bar) = tf.working_databar
  assert bar.close == 3.5 as "the piped Timeframe landed at the `_`"
}

/// A step that takes a whole settings type beside the subject can be
/// captured into a plain `fn(Timeframe) -> Timeframe` and folded 1000 times.
pub fn multi_argument_step_folded_n_times_test() {
  let step = timeframe_pipeline.bounded(
    _,
    timeframe_pipeline.StepSettings(factor: 1.0, bias: 1.0, ceiling: 2000.0),
  )
  let tf = timeframe_pipeline.run_steps(seeded(), list.repeat(step, 1000))
  let assert Some(bar) = tf.working_databar
  assert bar.close == 1001.5 as "the captured step is still an ordinary value"
}

/// Bare name, positional call, labelled call, capture — all in ONE straight
/// line, still ending in `working_databar_archived`. "Infinitely extensible"
/// does not mean "all steps have the same arity".
pub fn mixed_arity_line_archives_the_working_bar_test() {
  let tf = timeframe_pipeline.mixed_line(seeded())
  assert tf.working_databar == None as "archive is still the last step"
  let assert [bar, ..] = tf.databar_list
  assert bar.close == 8.0 as "((1.5*2)*2+1)*1+0.5+0.5, all in one pipe"
  assert bar.idx == 0 as "no step handed a bar to another step"
}
