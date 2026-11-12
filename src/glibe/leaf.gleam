//// The leaves. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: nothing.
//// WRITES: `YinLeaf` / `YangLeaf`, the only things called "leaves" here.
////
//// R33 (owner, verbatim): *"也不是'每一个叶子活起来'，叶子在这个系统中是
//// 特指 YinLeaf, YangLeaf 不要乱用。"* The word "leaf" does NOT mean a
//// Timeframe, a structural end, or a unit of concurrency. It means these two
//// constructors.
////
//// R39: leaf recognition happens IN the working databar as one step of
//// `databar_processing`; the settled leaf is a field of `Timeframe` so the
//// next step can take only `Timeframe` (R40 / R41). This module is an
//// UPSTREAM of `glibe/timeframe` and never imports it, so there is no cycle.
////
//// The enclosing type is named after this module, with the same noun shape
//// as `DataBar` / `DataBranch`: the owner named the two constructors (R33),
//// not their container. R21 forbids wire-code abbreviations, not full words
//// he used himself, so `YinLeaf` / `YangLeaf` stay as he said them.
////
//// The leaf's own fields are not listed: per R32 they are added when the
//// leaf step has a real consumer. `timeframe.leaves` writes these two
//// constructors into `Timeframe.growing_yin_leaf`, `growing_yang_leaf`,
//// `yin_leaf_settled` and `yang_leaf_settled`; `timeframe.branches`
//// reads the settled fields off the record.
////
//// R19 status: skeleton. No function here yet.

/// A leaf of a bar. Two constructors, both named by the owner.
pub type DataLeaf {
  /// A yin leaf.
  YinLeaf
  /// A yang leaf.
  YangLeaf
}
