//// The branches — `YinBranch` / `YangBranch` and every function that builds
//// or reads one. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
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
//// The four bar names and the function names are the ones in
//// `glib/src/glib/branch.gleam`, taken only after comparing that
//// implementation with the rulings above (R38 / R42). Each
//// `todo as "..."` says what its body has to write (R19);
//// `gleam build --warnings-as-errors` reports each one until it is written.
//// R6 (owner, verbatim): *"closing is a length test, never a price test"* —
//// `branch_size` and `leaf.leaf_size` are counts of bars, never prices.
//// R5 / R6 name the closing count `branch_exit_leaf_size`; it is the
//// parameter `next_yang_branch` / `next_yin_branch` compare the riding
//// leaf's length against. `timeframe.branches` is the caller that passes
//// it to either function (R40-A lets a pipeline step carry extra
//// arguments, given at the pipe call site).

import gleam/option.{type Option}
import glibe/databar.{type DataBar}
import glibe/leaf.{type DataLeaf}

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
  todo as "05-01: read branch.start_bar"
}

/// The bar the branch was recognised on. `timeframe.branches` writes it
/// from `working_databar`; R11 makes it the manual enter point, so
/// `timeframe.strategy` reads it to put the decision on that bar.
pub fn enter_bar(branch: DataBranch) -> DataBar {
  todo as "05-01: read branch.enter_bar"
}

/// The bar the move actually ended on, or `None` while it grows (R1 / R5).
/// A death, not a discovery: `timeframe.branches` fills it from the
/// riding leaf's `start_bar`.
pub fn end_bar(branch: DataBranch) -> Option(DataBar) {
  todo as "05-01: read branch.end_bar"
}

/// The bar the branch was recognised as dead on, `branch_exit_leaf_size`
/// bars after the death — never the death bar itself (R5).
/// `timeframe.strategy` reads it as the manual exit point (R11); `None`
/// until that bar arrives.
pub fn exit_bar(branch: DataBranch) -> Option(DataBar) {
  todo as "05-01: read branch.exit_bar"
}

/// How many bars the branch spans, `start_bar` to `exit_bar`, both ends
/// inclusive (R6). A growing branch has no `exit_bar` and no size.
pub fn branch_size(branch: DataBranch) -> Int {
  todo as "05-01: count from start_bar.idx to exit_bar.idx, both ends included"
}

/// The polarity name a view projection reads to label a `YinBranch` or a
/// `YangBranch` (R20 / R30). It is projected from the constructor, so the
/// spelling cannot contradict the value it names (R2).
pub fn lower_case_type_name(the_branch: DataBranch) -> String {
  todo as "05-01: project yin or yang from the constructor"
}

/// The move between ANY two bars — the one measurement every profit and
/// loss reads. `branch_stat` calls it with `start_bar` / `end_bar`,
/// `recognised_move` with `enter_bar` / `exit_bar` (R11); it reads `idx`
/// and the measurement series off the two bars (R6).
pub fn move_between(
  from_bar: DataBar,
  to_bar: DataBar,
) -> #(Float, Float, Float) {
  todo as "05-01: share of the move, its length in bars, and the move per bar"
}

/// Three measurements of an ENDED branch: `branch_stat` reads `start_bar`
/// and `end_bar` and hands them to `move_between`. A view projection reads
/// the result off `yin_branch_list` / `yang_branch_list` (R20 / R30); a
/// growing branch has no `end_bar` to measure (R1).
pub fn branch_stat(branch: DataBranch) -> #(Float, Float, Float) {
  todo as "05-01: move_between(start_bar, end_bar) for an ended branch"
}

/// The actionable window of a branch, `enter_bar` to `exit_bar` (R11).
/// A view projection reads it from the ended branch (R20 / R30); `None`
/// while no `exit_bar` exists, because one end of a move is not a move
/// (R1 / R5). It calls `move_between`.
pub fn recognised_move(branch: DataBranch) -> Option(#(Float, Float, Float)) {
  todo as "05-01: move_between(enter_bar, exit_bar), None while exit_bar is None"
}

/// R4's one-line recognition question: was this branch recognised on this
/// bar? `timeframe.strategy` passes `working_databar.idx` and reads the
/// answer on the same bar it reads `enter_bar` (R11). `None` names a
/// branch not in hand.
pub fn recognised_this_bar(branch: Option(DataBranch), idx: Int) -> Bool {
  todo as "05-01: compare enter_bar.idx with idx; None is False"
}

/// `start_bar.idx` of a branch that was recognised, and `None` otherwise.
/// `timeframe.strategy` reads it only on the bar a branch was recognised
/// (R4 / R11); `recognised` is that step's answer from
/// `recognised_this_bar`, so no branch is looked up a second time.
pub fn recognised_start_idx(
  branch: Option(DataBranch),
  recognised: Bool,
) -> Option(Int) {
  todo as "05-01: read start_bar.idx only when recognised is True and a branch is in hand"
}

/// The branch the list ends on this bar, and nothing else (R5).
/// `timeframe.strategy` reads `Timeframe.yin_branch_list` /
/// `yang_branch_list`; the head is the newest ended branch, and `None`
/// on every other bar keeps one exit from being marked twice.
pub fn exited_branch(
  branches: List(DataBranch),
  idx: Int,
) -> Option(DataBranch) {
  todo as "05-01: read the first branch whose exit_bar.idx is idx, otherwise None"
}

/// One bar of a `YangBranch`'s life (rides yin leaves, R2).
/// `timeframe.branches` returns `#(exited, growing)`: the first goes into
/// `yang_branch_list`, the second back into `growing_yang_branch`.
/// `previous` is the leaf that settled this bar, read only to take the new
/// branch's `start_bar` from its `corner_bar` (R4 / R5); `riding` is the
/// leaf whose length closes the branch (R6); `branch_exit_leaf_size` is
/// that count of bars, named by R5 / R6 and supplied by the caller at the
/// pipe call site (R40-A).
pub fn next_yang_branch(
  growing: Option(DataBranch),
  databar: DataBar,
  previous: Option(DataLeaf),
  riding: DataLeaf,
  recognised: Bool,
  branch_exit_leaf_size: Int,
) -> #(Option(DataBranch), Option(DataBranch)) {
  todo as "05-01: birth on recognition, close when leaf_size >= branch_exit_leaf_size, carry a growing branch unchanged"
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
  todo as "05-01: birth on recognition, close when leaf_size >= branch_exit_leaf_size, carry a growing branch unchanged"
}
