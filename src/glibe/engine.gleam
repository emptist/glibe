//// The engine — every step that moves a `Timeframe`, in the order they run.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`.
//// Ruling: `docs/RULINGS.md` R23 (settings travel with the engine; the
//// interval is in the key, not in the value), R19.
////
//// `sourcebar_gate` is given the `Interval` by the caller that selected this
//// `Timeframe` from `Instrument.timeframes`. `databar_processing` reads
//// `timeframe.settings` instead of receiving a second argument. Neither
//// function needs the `Timeframe` to name its owner (R22 / R23).

//

// **This module is the pipeline; `timeframe.gleam` is the state.** Keeping them
// apart is what ends the argument glib is still having with itself about which
// functions belong in `timeframe.gleam`: `leaf.gleam` and `branch.gleam` never
// imported the record, only the record imported them, so the cycle was never
// the reason — the two things living in one file was.
//
// The order is fixed and it is not a matter of taste:
//
// ```
// sourcebar_gate  ->  databar_processing
//                       indicator   the five smas, the band, KDJ
//                       leaves      both twins grow; the bar gets its cmas
//                       branches    recognised off the leaf that just settled
//                       strategy    the manual signal, written on the bar
//                       accept      the bar joins the history
// ```
//
// Branches come after leaves because a branch is recognised off the leaf that
// settles — 辞旧迎新 — and strategy comes after branches because the branch's
// two bars *are* the manual enter and exit (UC-62).

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import glibe/api/interval
import glibe/api/sourcebar.{type SourceBar}
import glibe/branch
import glibe/databar.{type DataBar}
import glibe/indicator
import glibe/leaf
import glibe/timeframe.{type Timeframe, Timeframe}
import glibe/trading/strategy.{manual_signal}

// ============================================================================
// The gate — the only way a source bar enters
// ============================================================================

/// **One source bar arrives; a bucket may close.**
///
/// The bar is validated and its date normalised **before** anything else sees
/// it, because both are facts about the boundary and not about the engine: an
/// exchange that counts milliseconds since the epoch is translated here, so
/// every step downstream reads `"2024-01-15 09:00:00"` and not
/// `"1705299600000"`. Before the conversion lived here, an hourly timeframe
/// never closed a bar at all on Binance data — no minute field matched, and
/// every source bar was folded into one growing bar forever.
///
/// **A bar that cannot be right is rejected, with the reason, and nothing is
/// repaired**: a repair puts a number in the engine that no exchange sent, and
/// every indicator downstream is then measured on it.
pub fn sourcebar_gate(
  timeframe: Timeframe,
  interval: interval.Interval,
  sourcebar: SourceBar,
) -> Result(#(Option(DataBar), Timeframe), String) {
  use bar <- result.try(sourcebar.validate(sourcebar))
  let bar = sourcebar.normalize_date(bar)
  let idx = bars_accepted(timeframe.databar_list)
  let in_hand = case timeframe.working_databar {
    None -> databar.of_sourcebar(bar, idx)
    Some(working) -> databar.fold_sourcebar(working, bar)
  }
  case interval.bucket_ends(interval, bar.date) {
    True -> Ok(#(Some(in_hand), Timeframe(..timeframe, working_databar: None)))
    False -> Ok(#(None, Timeframe(..timeframe, working_databar: Some(in_hand))))
  }
}

// ============================================================================
// The run — one finished bar, start to finish
// ============================================================================

/// **One bar through the whole engine.** The bar handed in is the one the gate
/// closed; what comes out is a `Timeframe` one bar longer.
pub fn databar_processing(timeframe: Timeframe, databar: DataBar) -> Timeframe {
  let settings = timeframe.settings
  let databar = indicator.run(databar, timeframe.databar_list, settings)
  let #(databar, timeframe, yin_settled, yang_settled) =
    leaves(timeframe, databar)
  let timeframe =
    branches(
      timeframe,
      databar,
      yin_settled,
      yang_settled,
      settings.branch_exit_leaf_size,
    )
  let #(timeframe, databar) = strategy(timeframe, databar)
  accept(timeframe, databar)
}

/// **Grow both twins one bar**, and hand back the two that settled on it.
///
/// **Settling and being listed are two different facts.** The leaf that settled
/// is returned to the caller and handed straight to `branches` — it is never
/// looked up in a list, and no list of settled leaves is kept, because a branch
/// is recognised off *this* bar's leaf and nothing else.
///
/// It also writes the bar's two leaf cmas: every bar belongs to one leaf of
/// each polarity, so every bar carries the running mean of `sma_tiny` over the
/// leaf it sits in. That is why this step hands the bar back and not only the
/// `Timeframe`.
fn leaves(
  timeframe: Timeframe,
  databar: DataBar,
) -> #(DataBar, Timeframe, Option(leaf.DataLeaf), Option(leaf.DataLeaf)) {
  let #(yin_settled, yin_grow) = case timeframe.growing_yin_leaf {
    None -> #(None, leaf.init_yin_leaf(databar))
    Some(g) -> leaf.next_yin_leaf(databar, g, last_bar(timeframe))
  }
  let #(yang_settled, yang_grow) = case timeframe.growing_yang_leaf {
    None -> #(None, leaf.init_yang_leaf(databar))
    Some(g) -> leaf.next_yang_leaf(databar, g, last_bar(timeframe))
  }
  // The bar sits in the twin that is growing AFTER this bar's growth — on a
  // death bar that is the new twin born here, not the one that settled.
  let databar =
    databar.DataBar(
      ..databar,
      yin_leaf_cma: leaf.leaf_cma(databar, timeframe.databar_list, yin_grow),
      yang_leaf_cma: leaf.leaf_cma(databar, timeframe.databar_list, yang_grow),
    )
  #(
    databar,
    Timeframe(
      ..timeframe,
      growing_yin_leaf: Some(yin_grow),
      growing_yang_leaf: Some(yang_grow),
    ),
    yin_settled,
    yang_settled,
  )
}

/// **Grow both branches one bar.** A `YangBranch` rides yin leaves and a
/// `YinBranch` rides yang leaves.
///
/// **Recognition is one line and it names `enter_bar` only** — *"think of it
/// again, you seem to only need a line of code: `growing_yang_branch is None`
/// AND `working_databar.idx` is `growing_yin_leaf.start_bar.idx`"* [user
/// 2026-10-03]. `previous` — the leaf that settled this bar — is here only to
/// give `start_bar` the dead leaf's corner, a backtracked fact; it gates
/// nothing.
fn branches(
  timeframe: Timeframe,
  databar: DataBar,
  yin_settled: Option(leaf.DataLeaf),
  yang_settled: Option(leaf.DataLeaf),
  exit_size: Int,
) -> Timeframe {
  let assert Some(riding_yin) = timeframe.growing_yin_leaf
  let assert Some(riding_yang) = timeframe.growing_yang_leaf
  let yin_recognised = leaf.leaf_start_bar(riding_yin).idx == databar.idx
  let yang_recognised = leaf.leaf_start_bar(riding_yang).idx == databar.idx

  let #(yang_exited, yang_next) =
    branch.next_yang_branch(
      timeframe.growing_yang_branch,
      databar,
      yin_settled,
      riding_yin,
      yin_recognised,
      exit_size,
    )
  let #(yin_exited, yin_next) =
    branch.next_yin_branch(
      timeframe.growing_yin_branch,
      databar,
      yang_settled,
      riding_yang,
      yang_recognised,
      exit_size,
    )
  Timeframe(
    ..timeframe,
    growing_yang_branch: yang_next,
    yang_branch_list: case yang_exited {
      Some(b) -> [b, ..timeframe.yang_branch_list]
      None -> timeframe.yang_branch_list
    },
    growing_yin_branch: yin_next,
    yin_branch_list: case yin_exited {
      Some(b) -> [b, ..timeframe.yin_branch_list]
      None -> timeframe.yin_branch_list
    },
  )
}

/// **The strategy step: the manual signal, written onto the bar.**
///
/// It judges nothing of its own. A branch recognised this bar carries the
/// manual enter; a branch recognised as dead this bar carries the manual exit;
/// the word it writes is the `YangBranch`'s, and only its (UC-62).
///
/// **The signal is written on the bar, not on the `Timeframe`**: only a bar is
/// broadcast, drawn and accepted, so a signal left on the record is a signal
/// nothing can ever reach.
fn strategy(timeframe: Timeframe, databar: DataBar) -> #(Timeframe, DataBar) {
  let recognised_yang =
    branch.recognised_this_bar(timeframe.growing_yang_branch, databar.idx)
  let exited_yang =
    option.is_some(branch.exited_branch(timeframe.yang_branch_list, databar.idx))
  #(
    Timeframe(
      ..timeframe,
      manual_enter: case recognised_yang {
        True -> Some(databar)
        False -> timeframe.manual_enter
      },
      manual_exit: case exited_yang {
        True -> Some(databar)
        False -> timeframe.manual_exit
      },
    ),
    databar.DataBar(
      ..databar,
      signal: manual_signal(recognised_yang, exited_yang),
    ),
  )
}

/// **The only way a finished bar joins the history.** Prepend: the list is
/// newest-first, so the head bar's `idx` is the count and no counter is kept.
pub fn accept(timeframe: Timeframe, databar: DataBar) -> Timeframe {
  Timeframe(..timeframe, databar_list: [databar, ..timeframe.databar_list])
}

// ============================================================================
// Questions about the history
// ============================================================================

/// **How many bars have been accepted** — and it is no counter of its own: the
/// head bar's position *is* the count, because `idx` is a bar's position in the
/// stream and `accept` is the only way a bar joins the list. An empty list is
/// the first bar of a run, whose index is 0.
///
/// The parameter is the **list**, not the `Timeframe` that carries it: the
/// number asks one question, and the record would answer more than that.
pub fn bars_accepted(databar_list: List(DataBar)) -> Int {
  case list.first(databar_list) {
    Ok(bar) -> bar.idx + 1
    Error(_) -> 0
  }
}

/// **The bar before the working one.** `accept` ran on every bar before this
/// one and this bar is not in the list yet, so the head of the list is that
/// bar — and it exists whenever a leaf does, because a leaf is born on a bar.
///
/// The killing bar belongs to the newborn, so a leaf that settles here ends one
/// bar early, and this is the bar it ends on.
fn last_bar(timeframe: Timeframe) -> DataBar {
  let assert Ok(previous) = list.first(timeframe.databar_list)
  previous
}
