//// The `Timeframe` — one interval of one instrument, **its type and every fn
//// that moves it**. One module holds the record and its transitions; there is
//// no second "engine" module.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-13-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R19 (docs-first / TDD), R23 (settings live here),
//// R27/R29 (standard bar time is unix time), R33 (a pure value recomputed as
//// data moves), R37 (identity is the holder's key), R38 (no replay, no second
//// implementation), R39 (the whole system is one straight line), R40/R40-A
//// (the pipeline), R41 (a pipeline is a shape constraint).
////
//// **Owner 2026-11-12**: *"glibe本来就是抄作业，抄glib的，仅仅要求将JS target
//// 改编成erlang target"*; *"timeframe.gleam 定义 Timeframe type以及相关的fn"*.
//// The module shape is copied from `glib/src/glib/timeframe.gleam:32-35`:
//// *"What stays is what names the record: `new`, `sourcebar_gate`,
//// `databar_processing`, the two steps that write leaf and branch fields
//// (`leaves`, `branches`), the strategy step"*. `engine.gleam` and the grep
//// guard that enforced its split are removed; they were the AI's mechanism,
//// not this design.
////
//// **The straight line (R39), four steps, no side doors**:
//// ```
//// ① one SourceBar arrives
//// ② a qualified SourceBar becomes `working_databar`, born whole (sourcebar_gate)
//// ③ ALL calculations / processing / decisions happen in that working databar
////    (the databar_processing pipeline)
//// ④ working_databar_archived -> databar_list, working_databar back to None
//// ```
//// `working_databar` has exactly three states: `None` (nothing in flight) →
//// `Some(bar)` (the bar being dealt with) → `None` (archived). It is NOT a
//// bucket accumulating several source bars.
////
//// **Upstream contracts, found by writing this doc and walking the imports
//// backwards (04-13 plan §5/§6)**. Each name below is a module the pipeline
//// reads; a missing or wrongly-owned one is a design gap, not a body to fill:
//// - `api/sourcebar`: `SourceBar`, `SourceBarRejection`, `validate`,
////   **`to_databar`** — a raw bar becoming a `DataBar` is the SOURCE's law
////   (`glib/src/glib/timeframe.gleam:25`, owner 2026-10-12), not the bar's.
//// - `api/interval`: `Interval`, `bucket_ends` — the UTC unix-second grid,
////   given by the holder (R23 / R37 / R29).
//// - `databar`: `DataBar` — the working bar's shape.
//// - `indicator_settings`: `TimeframeSettings` — one value per Timeframe (R23).
//// - `indicator`: `run` — the five SMAs, KDJ and Bollinger, bar → bar.
//// - `leaf`: `DataLeaf`, growth and cma — the two twins (「叶子」).
//// - `branch`: `DataBranch`, growth, recognition — the branches off leaves.
//// - `trading/strategy`: `manual_signal`; `trading/signal`: `Signal` — the one
////   verdict, written on the bar.
////
//// **The pipeline (R40 / R41)**. `databar_processing` is
//// `timeframe |> indicator |> leaves |> branches |> strategy |>
//// working_databar_archived`. Every step is `fn(Timeframe) -> Timeframe`:
//// the first argument and the return value are the subject, and **no step
//// takes a bar as an argument** — the bar lives in `working_databar`. Adding a
//// step is adding one `|>`; no earlier step changes. Settings, history and the
//// bar are all fields of the subject, so no step needs extra parameters
//// (R40-A permits them; this design does not need them).
////
//// **R37**: this record stores NO `symbol`, NO `interval` and NO market tag.
//// `Interval` is the key in `Instrument.timeframes`; `Symbol` is the key in
//// `Broker.instruments`. Identity belongs to the holder's Dict key —
//// *"你的左手不知道他是左还是右"*.
////
//// **Backwards from this module to the top (owner 2026-11-12 07:25)**:
//// `Timeframe ← Instrument ← Broker ← Desk`. Writing this skeleton showed
//// that one arriving bar needs the WHOLE chain, not just this record,
//// because `Desk` is the ONE top-level Value (R33); data moves and every
//// holder recomputes. The services each level must provide:
//// - `desk.gleam`: `get_broker` / `put_broker`, `timeframe_under` (read down
////   the three keys), and **`put_timeframe_under`** — write the recomputed
////   `Timeframe` back and return a NEW `Desk`. The write half was missing;
////   04-13 adds it as a documented skeleton alongside this one.
//// - `Broker`: `get_instrument` / `put_instrument`.
//// - `Instrument`: `get_timeframe` / `put_timeframe`.
//// - `Timeframe`: `sourcebar_gate` / `databar_processing` (this file).
//// No `feed` wrapper, no addressed message and no scheduler (R38 / R33):
//// an arriving bar uses these existing services in order.
////
//// **R19 status**: module doc → types → documented signatures with `todo`
//// bodies → unit tests in `test/timeframe_pipeline_test.gleam` (RED:
//// 64 passed / 19 failures) → bodies filled one at a time to GREEN. The
//// document, the skeleton, the tests and the bodies land in the SAME change,
//// so the doc never describes code that is not here.

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import glibe/api/interval
import glibe/api/sourcebar
import glibe/branch
import glibe/databar.{type DataBar}
import glibe/indicator as indicators
import glibe/indicator_settings.{type TimeframeSettings}
import glibe/leaf
import glibe/trading/strategy.{manual_signal}

/// The whole live state of ONE interval of ONE instrument. Its owner and its
/// interval are the keys above it; neither is a field here.
pub type Timeframe {
  Timeframe(
    // The parameter block this pipeline runs on. One value per `Timeframe`;
    // no second dictionary and no config table (R23).
    settings: TimeframeSettings,
    // The bar BEING DEALT WITH. `None` before a bar arrives and after it is
    // archived; `Some(bar)` for the whole time it is being computed. Three
    // states, never a bucket (R39).
    working_databar: Option(DataBar),
    // The history, newest-first. `working_databar_archived` is its only
    // writer; the head bar's `idx` + 1 is how many bars have been listed.
    databar_list: List(DataBar),
    // The two twins every bar belongs to. `None` until the first bar: a leaf
    // is born on a bar, and a bar of zeros standing in for "nothing yet"
    // would be a number that lies.
    growing_yin_leaf: Option(leaf.DataLeaf),
    growing_yang_leaf: Option(leaf.DataLeaf),
    // The leaf that settled ON this bar. A fact about the present, not a
    // list to be searched: `leaves` writes the pair, `branches` reads it,
    // so `branches` needs no bar or leaf among its arguments (R40/R41).
    // Owner's requirement recorded in
    // `glib/docs/reference/timeframe-cleanup-audit-2026-10-28.md:665-671`;
    // glib's code never landed it.
    yin_leaf_settled: Option(leaf.DataLeaf),
    yang_leaf_settled: Option(leaf.DataLeaf),
    // A branch is optional; a leaf is not. No branch exists until a leaf
    // settles and its corner can name a start.
    growing_yin_branch: Option(branch.DataBranch),
    growing_yang_branch: Option(branch.DataBranch),
    yin_branch_list: List(branch.DataBranch),
    yang_branch_list: List(branch.DataBranch),
  )
}

/// **An empty `Timeframe`, born before any bar.** Nothing is seeded with a
/// value: there is no bar to seed it from, and a seed would be read as a fact.
/// `settings` is the one thing it carries, because a pipeline cannot run
/// without the numbers it runs on.
pub fn new(settings: TimeframeSettings) -> Timeframe {
  Timeframe(
    settings: settings,
    working_databar: None,
    databar_list: [],
    growing_yin_leaf: None,
    growing_yang_leaf: None,
    yin_leaf_settled: None,
    yang_leaf_settled: None,
    growing_yin_branch: None,
    growing_yang_branch: None,
    yin_branch_list: [],
    yang_branch_list: [],
  )
}

/// **Step ② of the straight line: one arriving source bar becomes the working
/// databar, or is refused.**
///
/// Three outcomes, all as values of this record (R13, R38):
/// - OHLC invalid → `Error(reason)`, the `Timeframe` unchanged; a bad bar
///   becomes no bar, no leaf and no chart point.
/// - period not over → `Ok(timeframe)`, ignored and kept nowhere; nothing is
///   held against a later arrival (no bucket, no `fold_sourcebar`).
/// - period over → `Ok` with `working_databar: Some(to_databar(...))`, the
///   bar born whole with its position `idx = bars_listed(databar_list)`.
///
/// `interval_key` comes from the HOLDER that selected this `Timeframe` from
/// `Instrument.timeframes` (R23/R37); `bucket_ends` answers on the UTC
/// unix-second grid (R27/R29). There is no third function between this one
/// and `databar_processing`: one arriving bar calls the pair in order (R38).
pub fn sourcebar_gate(
  timeframe: Timeframe,
  interval_key: interval.Interval,
  incoming: sourcebar.SourceBar,
) -> Result(Timeframe, sourcebar.SourceBarRejection) {
  use bar <- result.try(sourcebar.validate(incoming))
  case interval.bucket_ends(interval_key, bar.timestamp) {
    False -> Ok(timeframe)
    True ->
      Ok(
        Timeframe(
          ..timeframe,
          working_databar: Some(sourcebar.to_databar(
            bar,
            bars_listed(timeframe.databar_list),
          )),
        ),
      )
  }
}

/// **Step ③ + ④: everything that happens to the working databar, in order.**
///
/// The whole body is one pipeline whose subject is this `Timeframe`. Each
/// step reads `working_databar` from the record and writes its result back;
/// none of them receives a bar. The last step files the bar and returns the
/// record to `working_databar: None`.
pub fn databar_processing(timeframe: Timeframe) -> Timeframe {
  timeframe
  |> indicator
  |> leaves
  |> branches
  |> strategy
  |> working_databar_archived
}

/// **Pipeline step 1: the indicators, computed on the working bar.**
///
/// Reads `working_databar`, `databar_list` and `settings` from the record and
/// writes the computed bar back into `working_databar`. With no bar in hand
/// it is a no-op, not a crash and not a guessed bar.
pub fn indicator(timeframe: Timeframe) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(bar) ->
      Timeframe(
        ..timeframe,
        working_databar: Some(indicators.run(
          bar,
          timeframe.databar_list,
          timeframe.settings,
        )),
      )
  }
}

/// **Pipeline step 2: grow both twins one bar.**
///
/// Writes `growing_yin_leaf` / `growing_yang_leaf`, the two leaf cmas on the
/// working bar, and the pair that settled on this bar into
/// `yin_leaf_settled` / `yang_leaf_settled`. Settling and being listed are
/// two different facts: the settled leaf is a field of the present, never a
/// list to look up.
pub fn leaves(timeframe: Timeframe) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(bar) -> {
      // An empty history IS the first bar: both twins are born on it and
      // nothing has settled. Afterwards the head of the list is the bar a
      // dying leaf ends on (the killing bar belongs to the newborn).
      let #(yin_settled, yin_grow, yang_settled, yang_grow) = case
        list.first(timeframe.databar_list)
      {
        Error(_) -> #(
          None,
          leaf.init_yin_leaf(bar),
          None,
          leaf.init_yang_leaf(bar),
        )
        Ok(previous) -> {
          let #(ys, yg) = case timeframe.growing_yin_leaf {
            None -> #(None, leaf.init_yin_leaf(bar))
            Some(growing) -> leaf.next_yin_leaf(bar, growing, previous)
          }
          let #(xs, xg) = case timeframe.growing_yang_leaf {
            None -> #(None, leaf.init_yang_leaf(bar))
            Some(growing) -> leaf.next_yang_leaf(bar, growing, previous)
          }
          #(ys, yg, xs, xg)
        }
      }
      let yin_cma = leaf.leaf_cma(bar, timeframe.databar_list, yin_grow)
      let yang_cma = leaf.leaf_cma(bar, timeframe.databar_list, yang_grow)
      Timeframe(
        ..timeframe,
        working_databar: Some(
          databar.DataBar(..bar, yin_leaf_cma: yin_cma, yang_leaf_cma: yang_cma),
        ),
        growing_yin_leaf: Some(yin_grow),
        growing_yang_leaf: Some(yang_grow),
        yin_leaf_settled: yin_settled,
        yang_leaf_settled: yang_settled,
      )
    }
  }
}

/// **Pipeline step 3: grow both branches one bar.**
///
/// A `YangBranch` rides yin leaves and a `YinBranch` rides yang leaves.
/// It reads the settled pair written by `leaves` from the record — that is
/// why its only argument is the `Timeframe` (R40/R41).
pub fn branches(timeframe: Timeframe) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(bar) ->
      case timeframe.growing_yin_leaf, timeframe.growing_yang_leaf {
        Some(riding_yin), Some(riding_yang) -> {
          let yin_recognised = leaf.leaf_start_bar(riding_yin).idx == bar.idx
          let yang_recognised = leaf.leaf_start_bar(riding_yang).idx == bar.idx
          let exit_size = timeframe.settings.branch_exit_leaf_size
          let #(yang_exited, yang_next) =
            branch.next_yang_branch(
              timeframe.growing_yang_branch,
              bar,
              timeframe.yin_leaf_settled,
              riding_yin,
              yin_recognised,
              exit_size,
            )
          let #(yin_exited, yin_next) =
            branch.next_yin_branch(
              timeframe.growing_yin_branch,
              bar,
              timeframe.yang_leaf_settled,
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
        _, _ -> timeframe
      }
  }
}

/// **Pipeline step 4: the manual strategy's verdict, on the working bar.**
///
/// It judges nothing of its own: a branch recognised this bar carries the
/// manual enter, one recognised as dead carries the manual exit (UC-62).
/// The `Signal` is written on the bar — a bar is what is listed and drawn,
/// so a verdict left on the record is a verdict nothing can reach. The
/// provisional `manual_enter` / `manual_exit` fields were struck by the
/// owner on 2026-10-31 and are not here.
pub fn strategy(timeframe: Timeframe) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(bar) -> {
      let recognised_yang =
        branch.recognised_this_bar(timeframe.growing_yang_branch, bar.idx)
      let exited_yang =
        option.is_some(branch.exited_branch(timeframe.yang_branch_list, bar.idx))
      Timeframe(
        ..timeframe,
        working_databar: Some(
          databar.DataBar(
            ..bar,
            signal: manual_signal(recognised_yang, exited_yang),
          ),
        ),
      )
    }
  }
}

/// **Step ④ of the straight line: file the bar that is in hand.**
///
/// Takes NO bar: the bar it files IS `timeframe.working_databar`. This is the
/// only place `databar_list` grows, and the `Some -> None` transition that
/// ends the present. With nothing in hand it is a no-op.
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

/// **How many bars have been listed.** It is no counter of its own: the head
/// bar's `idx` + 1 is the count, because `idx` is a bar's position in the
/// stream and `working_databar_archived` is the only writer. An empty list
/// answers 0, the position of the first bar.
pub fn bars_listed(databar_list: List(DataBar)) -> Int {
  case list.first(databar_list) {
    Ok(bar) -> bar.idx + 1
    Error(_) -> 0
  }
}
