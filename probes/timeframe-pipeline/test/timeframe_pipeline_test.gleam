//// Design goals for the `databar_processing` pipeline (R19: written BEFORE
//// the bodies). Every assertion here is a claim about the SHAPE the owner
//// named on 2026-11-12, not about a number the implementation happens to
//// return.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-12-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R39 (one straight line, no step takes the bar
//// as an argument), R33 (pure value recompute), R35 (simple is the check).
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
