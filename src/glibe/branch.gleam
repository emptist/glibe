//// Branches. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: nothing yet.
//// WRITES: `DataBranch`, held in the branch fields of `Timeframe`.
////
//// R2 (owner, verbatim): *"branches are conceptually a group of leaves"* —
//// a `YangBranch` rides yin leaves and a `YinBranch` rides yang leaves.
//// The two constructor names are the owner's own words, not inventions.
//// R21 forbids wire-code abbreviations (`D1` / `H4`), not full words the
//// owner used himself, so `YinBranch` / `YangBranch` stay exactly as he
//// said them. The enclosing type is named after this module, with the same
//// noun shape as `DataBar` / `DataLeaf`: the owner named the constructors,
//// not their container.
////
//// R33: 「叶子」is reserved for `YinLeaf` / `YangLeaf`. A branch is not a
//// leaf, not a `Timeframe`, not a structural end and not a unit of
//// concurrency. R39: branch recognition is one step of
//// `databar_processing`, and its work is done IN the working databar.
//// This module is an UPSTREAM of `glibe/timeframe` and never imports it,
//// so there is no cycle.
////
//// The branch's own fields are NOT listed. R1 names `end_bar` / `exit_bar`
//// and R4 names `start_bar`; per R26 / R32 a field is added when its real
//// consumer exists, one at a time. `timeframe.branches` writes these two
//// constructors into `Timeframe.growing_yin_branch`,
//// `growing_yang_branch`, `yin_branch_list` and `yang_branch_list`.
////
//// R19 status: skeleton. No function here yet.

/// A branch: a group of leaves (R2). Only the two owner-named kinds are
/// fixed here; fields arrive one at a time with their consumer (R26 / R32).
pub type DataBranch {
  /// Rides yang leaves (R2).
  YinBranch
  /// Rides yin leaves (R2).
  YangBranch
}
