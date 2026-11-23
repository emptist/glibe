//// The branches — `YinBranch` / `YangBranch` and every function that builds
//// or reads one. Implements
//// `.planning/phases/02-domain-stream/02-02-PLAN.md`.
////
//// This module owns `DataBranch` and its measurements: a function here
//// constructs one, reads one of its four bars, or computes a measurement
//// that a view projection reads (R20 / R30). `timeframe.branches` reads the
//// `Timeframe.yin_leaf_settled` / `yang_leaf_settled` fields, calls these
//// functions, and writes `growing_yin_branch` / `growing_yang_branch` and
//// `yin_branch_list` / `yang_branch_list` back onto the record (R40 / R41).
//// `timeframe.strategy` reads `enter_bar` / `exit_bar` from the record to
//// put the decision on the working bar (R11). This module is upstream of
//// `glibe/timeframe` and never imports it (R50).
////
//// R2 (owner, verbatim): *"branches are conceptually a group of leaves"* —
//// a `YangBranch` rides yin leaves and a `YinBranch` rides yang leaves.
//// R4 (owner, verbatim): recognition is one line, `growing_yang_branch` is
//// `None` AND `working_databar.idx == growing_yin_leaf.start_bar.idx`.
//// R5 (owner, verbatim): *"since it has been dead for a while, it is not
//// the death bar"* — `end_bar` is where the branch died, `exit_bar` is
//// where it was found dead later. R1 (owner, verbatim) *"a structure
//// doesn't have an end_bar unless it is ended"* makes both `Option`.
//// R11: `enter_bar` / `exit_bar` ARE the manual enter and exit; there is
//// no second strategy and no provisional field for either (R38 / R39).
////
//// R6 (owner, verbatim): *"closing is a length test, never a price test"* —
//// `branch_size` and `leaf.leaf_size` are counts of bars, never prices.
//// R5 / R6 name the closing count `branch_exit_leaf_size`. That count is
//// THIS module's rule, so it lives here: `branch_exit_leaf_size()` is read
//// by `timeframe.branches` and handed to `next_yang_branch` /
//// `next_yin_branch`, which compare the riding leaf's length against it.
//// No step of the pipeline carries it as an extra argument, and no other
//// layer owns a branch's closing rule (R50). Each `todo as "..."` says
//// what its body has to write (R19); `gleam build --warnings-as-errors`
//// reports each one until it is written.
////
//// R19 status (2026-11-23): 13 bodies filled — four bar readers
//// (`start_bar` / `enter_bar` / `end_bar` / `exit_bar`), `lower_case_type_name`,
//// `recognised_this_bar`, `recognised_start_idx`, `exited_branch`,
//// `start_end_move` / `enter_exit_move` (both call `move.move_between`, whose
//// three numbers are named by the `Move` type), `next_yang/yin_branch` (closing
//// rules from frozen glib `branch.gleam:346-424`), and `branch_size`
//// (2026-11-23: signature corrected to `Option` — a growing branch has no
//// exit_bar/end_bar, so a bare value was a type that let a wrong question be
//// asked; R1 / core §2).
//// `move_between` itself MOVED to `move.gleam` on 2026-11-23 — it belongs with
//// the `Move` type it produces, not with the branch windows that call it.
//// No `todo` remains here. The old no-arg `branch_exit_leaf_size()` was DELETED:
//// the closing count is per-interval and already lives in `config`'s
//// `branch_exit_leaf_size` table, read by `config.for_interval` into
//// `IntervalSettings.branch_exit_leaf_size` and passed by `timeframe.branches`
//// to `next_yang/yin_branch`. A no-arg function had zero callers and could not
//// express the interval it needs (R49 / core §5); the settings parameter chain
//// IS its real consumer.
////
//// RENAMED 2026-11-23 (owner: *"branch_stat and recognised_move 存在命名不当的
//// 问题"*): `branch_stat` -> `start_end_move`, `recognised_move` ->
//// `enter_exit_move`. Both names now say WHICH PAIR of bars they measure, the
//// way glib's own page already spelled them: glib `web/branch_view.gleam:91`
//// has a private `fn start_end_move`, and its JSON keys are `start_end` /
//// `enter_exit` (`:123,126`; glib `DESIGN.md:2440` — *"start_end for what the
//// structure made, enter_exit for what a trader could have acted on"*). The old
//// `recognised_move` also STOLE a word: NAMING.md 1.23 pins `recognised` to
//// `enter_bar` ALONE (*"the bar it was identified, found, discovered"*), so
//// naming a whole WINDOW `recognised_move` broke "one word, one moment" and
//// "one concept, one name". The old `branch_stat` was also vague (statistics?
//// status?) and asymmetric with its sibling — both return the same triple.
//// `move_between` keeps its name: it is the general two-bar measurement and
//// knows whose bars it measures not at all.
////
//// MOVED 2026-11-23 (owner: *"注意 move 这个function，从move这个名字完全看不出
//// 他 return的东西……但是这正好说明，命名太差了"* + *"当这 move 和 move_between
//// 同时存在于一个 module 的时候，move 这个名字误导就更强烈"*): the measurement
//// itself now lives in ITS OWN module, `glibe/move.gleam`, as a named type
//// `Move(magnitude, duration, per_bar)`. Two defects closed:
////   1. the return value had NO NAME — it was a bare `#(Float, Float, Float)`,
////      so three positions with no labels; now the value says what it is;
////   2. `move` meant BOTH the concept (a span between two bars) AND the
////      first returned number (a share) — one word, two things, in one
////      module. Now this module holds only the two branch-shaped WINDOWS that
////      produce a measurement, and `move.gleam` holds the measurement.
//// `move_between` moved with the type; the two functions below call
//// `move.move_between`. See `docs/RULINGS.md` R52.

import gleam/option.{type Option, None, Some}
import glibe/databar.{type DataBar, DataBar}
import glibe/leaf.{type DataLeaf}
import glibe/move.{type Move, move_between}

/// The four bars a branch is: where the move opened, where it was
/// recognised, where it actually died, and where it was found dead (R5).
/// `end_bar` / `exit_bar` are `None` while the branch grows (R1).
/// `timeframe.branches` writes all four; `timeframe.strategy` reads
/// `enter_bar` / `exit_bar` (R11).
pub type DataBranch {
  /// Rides yang leaves (R2). `timeframe.branches` holds it in
  /// `growing_yin_branch` and archives it into `yin_branch_list`.
  YinBranch(
    start_bar: DataBar,
    enter_bar: DataBar,
    end_bar: Option(DataBar),
    exit_bar: Option(DataBar),
  )
  /// Rides yin leaves (R2). `timeframe.branches` holds it in
  /// `growing_yang_branch` and archives it into `yang_branch_list`.
  YangBranch(
    start_bar: DataBar,
    enter_bar: DataBar,
    end_bar: Option(DataBar),
    exit_bar: Option(DataBar),
  )
}

/// The bar the move opened on — the dead leaf's `corner_bar` (R4 / R5).
/// `timeframe.strategy` reads it on the bar a branch is recognised (R11).
pub fn start_bar(branch: DataBranch) -> DataBar {
  case branch {
    YinBranch(start_bar:, ..) -> start_bar
    YangBranch(start_bar:, ..) -> start_bar
  }
}

/// The bar the branch was recognised on. `timeframe.branches` writes it
/// from `working_databar`; R11 makes it the manual enter point, so
/// `timeframe.strategy` reads it to put the decision on that bar.
pub fn enter_bar(branch: DataBranch) -> DataBar {
  case branch {
    YinBranch(enter_bar:, ..) -> enter_bar
    YangBranch(enter_bar:, ..) -> enter_bar
  }
}

/// The bar the move actually ended on, or `None` while it grows (R1 / R5).
/// A death, not a discovery: `timeframe.branches` fills it from the
/// riding leaf's `start_bar`.
pub fn end_bar(branch: DataBranch) -> Option(DataBar) {
  case branch {
    YinBranch(end_bar:, ..) -> end_bar
    YangBranch(end_bar:, ..) -> end_bar
  }
}

/// The bar the branch was recognised as dead on, `branch_exit_leaf_size`
/// bars after the death — never the death bar itself (R5).
/// `timeframe.strategy` reads it as the manual exit point (R11); `None`
/// until that bar arrives.
pub fn exit_bar(branch: DataBranch) -> Option(DataBar) {
  case branch {
    YinBranch(exit_bar:, ..) -> exit_bar
    YangBranch(exit_bar:, ..) -> exit_bar
  }
}

/// How many bars the branch spans, `start_bar` to `exit_bar`, both ends
/// inclusive (R6). A growing branch has no `exit_bar` and therefore NO size —
/// `None`, never a bare `Int` (R1: a wrong-but-well-formed value must be
/// unrepresentable; core §2). `exit_bar.idx - start_bar.idx + 1`, no list walk.
pub fn branch_size(branch: DataBranch) -> Option(Int) {
  case exit_bar(branch) {
    None -> None
    Some(exit) -> {
      let DataBar(idx: exit_idx, ..) = exit
      let DataBar(idx: start_idx, ..) = start_bar(branch)
      Some(exit_idx - start_idx + 1)
    }
  }
}

/// The polarity name a view projection reads to label a `YinBranch` or a
/// `YangBranch` (R20 / R30). It is projected from the constructor, so the
/// spelling cannot contradict the value it names (R2).
pub fn lower_case_type_name(the_branch: DataBranch) -> String {
  case the_branch {
    YinBranch(..) -> "yin"
    YangBranch(..) -> "yang"
  }
}

/// Three measurements of an ENDED branch, taken over `start_bar` -> `end_bar`
/// — the move the STRUCTURE made, from its corner to where it actually died.
/// `start_end_move` reads `start_bar` and `end_bar` and hands them to
/// `move.move_between`. A view projection reads the result off
/// `yin_branch_list` / `yang_branch_list` (R20 / R30); a growing branch has no
/// `end_bar` to measure, so the result is `None` (R1 / core §2), never a bare
/// `Move`.
///
/// The name says the PAIR it measures, because the sibling `enter_exit_move`
/// measures a different pair and both return the same `Move` — the old names
/// (`branch_stat` / `recognised_move`) did not, and one of them took a word
/// NAMING.md 1.23 had already pinned to `enter_bar` alone. See the module
/// header for the rename record.
pub fn start_end_move(branch: DataBranch) -> Option(Move) {
  case end_bar(branch) {
    None -> None
    Some(end) -> Some(move_between(start_bar(branch), end))
  }
}

/// The actionable window of a branch, `enter_bar` to `exit_bar` (R11) — the
/// move anyone could have acted on, from the bar it was recognised to the bar
/// it was recognised as dead. A view projection reads it from the ended branch
/// (R20 / R30); `None` while no `exit_bar` exists, because one end of a move
/// is not a move (R1 / R5). It calls `move.move_between`.
///
/// `enter_exit_move` says the PAIR it measures. The old name `recognised_move`
/// said something else: NAMING.md 1.23 gives `recognised` to `enter_bar` alone
/// (*"the bar it was identified, found, discovered"*), so that name both stole
/// a word from one bar and hid the second end of the window it measured.
pub fn enter_exit_move(branch: DataBranch) -> Option(Move) {
  // R11/R1: one end of a move is not a move, so no exit_bar means no answer.
  // When it exists, the actionable window is enter -> exit; end_bar is a
  // different (magnitude) question that start_end_move asks.
  case exit_bar(branch) {
    None -> None
    Some(exit) -> Some(move_between(enter_bar(branch), exit))
  }
}

/// R4's one-line recognition question: was this branch recognised on this
/// bar? `timeframe.strategy` passes `working_databar.idx` and reads the
/// answer on the same bar it reads `enter_bar` (R11). `None` names a
/// branch not in hand.
pub fn recognised_this_bar(branch: Option(DataBranch), idx: Int) -> Bool {
  case branch {
    None -> False
    Some(b) -> {
      let DataBar(idx: enter_idx, ..) = enter_bar(b)
      enter_idx == idx
    }
  }
}

/// `start_bar.idx` of a branch that was recognised, and `None` otherwise.
/// `timeframe.strategy` reads it only on the bar a branch was recognised
/// (R4 / R11); `recognised` is that step's answer from
/// `recognised_this_bar`, so no branch is looked up a second time.
pub fn recognised_start_idx(
  branch: Option(DataBranch),
  recognised: Bool,
) -> Option(Int) {
  case branch, recognised {
    Some(b), True -> {
      let DataBar(idx: start_idx, ..) = start_bar(b)
      Some(start_idx)
    }
    _, _ -> None
  }
}

/// The branch the list ends on this bar, and nothing else (R5).
/// `timeframe.strategy` reads `Timeframe.yin_branch_list` /
/// `yang_branch_list`; the head is the newest ended branch, and `None`
/// on every other bar keeps one exit from being marked twice.
///
/// READS ONLY the head of `branches` — the newest ended branch, archived
/// first. WRITES `Some(branch)` when that head's `exit_bar.idx` is `idx`,
/// `None` otherwise. `list.find` is not called.
pub fn exited_branch(
  branches: List(DataBranch),
  idx: Int,
) -> Option(DataBranch) {
  // R5: only the head of the newest-first list (O(1), never list.find). Some
  // only when that head's exit_bar.idx is idx, so one exit is never marked
  // twice; a growing head (no exit_bar) or any other idx is None.
  case branches {
    [] -> None
    [newest, ..] ->
      case exit_bar(newest) {
        Some(exit) -> {
          let DataBar(idx: exit_idx, ..) = exit
          case exit_idx == idx {
            True -> Some(newest)
            False -> None
          }
        }
        None -> None
      }
  }
}

/// One bar of a `YangBranch`'s life (rides yin leaves, R2).
/// `timeframe.branches` returns `#(exited, growing)`: the first goes into
/// `yang_branch_list`, the second back into `growing_yang_branch`.
/// `previous` is the leaf that settled this bar, read only to take the new
/// branch's `start_bar` from its `corner_bar` (R4 / R5); `riding` is the
/// leaf whose length closes the branch (R6); `branch_exit_leaf_size` is
/// that count of bars, named by R5 / R6 and read by `timeframe.branches`
/// from `branch_exit_leaf_size()` in this module.
pub fn next_yang_branch(
  growing: Option(DataBranch),
  databar: DataBar,
  previous: Option(DataLeaf),
  riding: DataLeaf,
  recognised: Bool,
  branch_exit_leaf_size: Int,
) -> #(Option(DataBranch), Option(DataBranch)) {
  // Frozen glib `branch.gleam:354-383`. A yang branch rides yin leaves (R2).
  case growing {
    // Birth on recognition from the just-settled leaf's corner_bar (R4/R5);
    // databar is the manual enter point (R11); no late bars while growing (R1).
    None ->
      case recognised, previous {
        True, Some(prev) -> #(
          None,
          Some(YangBranch(
            start_bar: leaf.corner_bar(prev),
            enter_bar: databar,
            end_bar: None,
            exit_bar: None,
          )),
        )
        _, _ -> #(None, None)
      }
    // Closing is a LENGTH test, never a price test (R6): when the riding leaf
    // has lived branch_exit_leaf_size bars, end_bar = where it died (the leaf's
    // start), exit_bar = this bar (found dead). Both late bars filled here only.
    Some(b) ->
      case leaf.leaf_size(riding, databar) >= branch_exit_leaf_size {
        True -> #(
          Some(YangBranch(
            start_bar: b.start_bar,
            enter_bar: b.enter_bar,
            end_bar: Some(leaf.start_bar(riding)),
            exit_bar: Some(databar),
          )),
          None,
        )
        // Carried, not rebuilt: nothing about a growing branch changes until
        // the bar it is recognised as dead on.
        False -> #(None, Some(b))
      }
  }
}

/// The mirror of `next_yang_branch` — a `YinBranch` rides yang leaves
/// (R2). `timeframe.branches` writes the same two returned values into
/// `yin_branch_list` / `growing_yin_branch`; every rule above holds with
/// the polarities swapped (R4 / R5 / R6 / R40-A), including the comparison
/// against `branch_exit_leaf_size`.
pub fn next_yin_branch(
  growing: Option(DataBranch),
  databar: DataBar,
  previous: Option(DataLeaf),
  riding: DataLeaf,
  recognised: Bool,
  branch_exit_leaf_size: Int,
) -> #(Option(DataBranch), Option(DataBranch)) {
  // Frozen glib `branch.gleam:396-423` — the polarity mirror: a yin branch
  // rides yang leaves (R2); the rule is identical with polarities swapped.
  case growing {
    None ->
      case recognised, previous {
        True, Some(prev) -> #(
          None,
          Some(YinBranch(
            start_bar: leaf.corner_bar(prev),
            enter_bar: databar,
            end_bar: None,
            exit_bar: None,
          )),
        )
        _, _ -> #(None, None)
      }
    Some(b) ->
      case leaf.leaf_size(riding, databar) >= branch_exit_leaf_size {
        True -> #(
          Some(YinBranch(
            start_bar: b.start_bar,
            enter_bar: b.enter_bar,
            end_bar: Some(leaf.start_bar(riding)),
            exit_bar: Some(databar),
          )),
          None,
        )
        False -> #(None, Some(b))
      }
  }
}
/// (DELETED 2026-11-23) The old `branch_exit_leaf_size() -> Int` had zero
/// callers and no way to express the interval its per-interval value needs.
/// The closing count now lives ONLY in `config`'s `branch_exit_leaf_size`
/// table, selected by `config.for_interval` into
/// `IntervalSettings.branch_exit_leaf_size`, read by `timeframe.branches`
/// and handed to `next_yang_branch` / `next_yin_branch`. One owner (R50),
/// no dead mechanism (core §5). See module `////`.
