//// The branches — the move recognised late and ending late, grown off the
//// leaf chain of the opposite polarity (`YinBranch` rides yang leaves).
////
//// Plan: `.planning/phases/04-domain-cleanup/04-13-PLAN.md` §5 (upstream
//// contracts). This module is an UPSTREAM of `glibe/timeframe`: the
//// pipeline's `branches` step calls `next_yang_branch` / `next_yin_branch`
//// using the settled pair the `leaves` step left IN THE RECORD, and
//// `strategy` asks `recognised_this_bar` / `exited_branch` of the lists.
//// Three questions about a branch's four bars live beside the definition,
//// with no access to the record — so this module never imports `timeframe`.
////
//// The `////` above is a retrofit of the missing module doc (R19); the
//// definitions below are the existing, tested ones.

// The branches — the move recognised late and ending late. A branch rides the
// leaf chain of the opposite polarity: a `YinBranch` rides yang leaves, a
// `YangBranch` rides yin leaves.
//
// **A branch is a group of leaves, not a move drawn separately from them**
// [user 2026-10-03]: *"branches are conceptually a group of leaves, a
// yang_branch is a group of small yin_leaves that turn out to be rising in
// effect. That is the interesting part. And when the growing_yin_leaf grows too
// long, the yang_branch is recognized to be dead. Since it stops rising for too
// long a time. It must have changed in trend."*
//
// **Four bars, four words** (NAMING):
//
// | bar | word | when |
// |---|---|---|
// | `start_bar` | **born** | the corner of the leaf it was recognised off — backtracked |
// | `enter_bar` | **recognised** | the bar it was identified on; the manual enter |
// | `end_bar` | **ended** | the start of the leaf it was riding when it died — a death, backtracked |
// | `exit_bar` | **recognised as dead** | `branch_exit_leaf_size` bars later; the manual exit |
//
// A word never names two of them. `exit_bar` is never the death bar — *"since
// it has been dead for a while, it is not the death bar. Just like people who
// are found dead after a long time."*
//
// **A structure that has not ended has no `end_bar` and no `exit_bar`** — both
// are `Option`. The old shape carried four plain bars seeded with a sentinel,
// and the sentinel's `idx` was 0, which is also the first real bar's `idx`, so
// "is there a growing branch?" was answered wrong on the first bar of a run.
//
// **Closing is a length test and never a price test:** the leaf being ridden
// has lived `branch_exit_leaf_size` bars → end it now.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import glibe/databar.{type DataBar}
import glibe/leaf.{type DataLeaf}

// ============================================================================
// Public Types
// ============================================================================

pub type DataBranch {
  YinBranch(
    start_bar: DataBar,
    enter_bar: DataBar,
    end_bar: Option(DataBar),
    exit_bar: Option(DataBar),
  )
  YangBranch(
    start_bar: DataBar,
    enter_bar: DataBar,
    end_bar: Option(DataBar),
    exit_bar: Option(DataBar),
  )
}

// ============================================================================
// Accessors
// ============================================================================

pub fn branch_start_bar(branch: DataBranch) -> DataBar {
  case branch {
    YinBranch(start_bar:, ..) -> start_bar
    YangBranch(start_bar:, ..) -> start_bar
  }
}

/// **The manual enter point** — the bar the branch was recognised on. A branch
/// in hand always has one: it is the working bar of the day it was recognised.
pub fn branch_enter_bar(branch: DataBranch) -> DataBar {
  case branch {
    YinBranch(enter_bar:, ..) -> enter_bar
    YangBranch(enter_bar:, ..) -> enter_bar
  }
}

/// **Where the branch died** — the start of the leaf it was riding. `None`
/// while it grows.
pub fn branch_end_bar(branch: DataBranch) -> Option(DataBar) {
  case branch {
    YinBranch(end_bar:, ..) -> end_bar
    YangBranch(end_bar:, ..) -> end_bar
  }
}

/// **The manual exit point** — the bar the branch was recognised as dead on.
/// `None` while it grows.
pub fn branch_exit_bar(branch: DataBranch) -> Option(DataBar) {
  case branch {
    YinBranch(exit_bar:, ..) -> exit_bar
    YangBranch(exit_bar:, ..) -> exit_bar
  }
}

/// **How many bars the branch spans** — `start_bar` to `exit_bar`, both ends
/// inclusive, so it is a cardinality and never a field.
///
/// **A branch that has not ended has no size.** The question is only ever asked
/// of an ended branch, and `let assert` states that rather than answering with
/// a number nobody means.
pub fn data_branch_size(branch: DataBranch) -> Int {
  let assert Some(exit_bar) = branch_exit_bar(branch)
  exit_bar.idx - branch_start_bar(branch).idx + 1
}

/// **The move itself, as three measurements** — how far it went, how long it
/// took, and the rate. All three ride `sma_tiny`, never price, so a 700-dollar
/// leg and a 60,000-dollar one are comparable.
///
/// The span is `start → end`, not `start → exit`: `exit_bar` is
/// `branch_exit_leaf_size` bars of recognition later, and a rate wants the
/// move's own length, not the discovery lag.
pub fn branch_stat(branch: DataBranch) -> #(Float, Float, Float) {
  let start = branch_start_bar(branch)
  let assert Some(end) = branch_end_bar(branch)
  let magnitude = { end.sma_tiny -. start.sma_tiny } /. start.sma_tiny
  let duration = case end.idx - start.idx + 1 {
    0 -> 1.0
    n -> int.to_float(n)
  }
  #(magnitude, duration, magnitude /. duration)
}

/// **Was this branch recognised on this bar?** Its `enter_bar` *is* the
/// recognition bar, so this is one index compare — and it answers `False` for
/// `None`, a branch that does not exist yet or is no longer in hand.
pub fn recognised_this_bar(branch: Option(DataBranch), idx: Int) -> Bool {
  case branch {
    Some(b) -> branch_enter_bar(b).idx == idx
    None -> False
  }
}

/// **The branch the list is ending on this bar, and nothing else.** The head of
/// the list is the newest branch that has ended, and a branch that has ended
/// always carries the bar it was recognised as dead on. `None` on every other
/// bar — that absence is what keeps a mark from naming the same branch twice.
pub fn exited_branch(
  branches: List(DataBranch),
  idx: Int,
) -> Option(DataBranch) {
  case list.first(branches) {
    Ok(b) ->
      case branch_exit_bar(b) {
        Some(exit) ->
          case exit.idx == idx {
            True -> Some(b)
            False -> None
          }
        None -> None
      }
    Error(_) -> None
  }
}

// ============================================================================
// Growth — one bar at a time
// ============================================================================

/// **A `YangBranch` rides yin leaves.** Returns `#(exited, growing)`:
/// `exited` is `Some` only on the bar the branch is recognised as dead,
/// `growing` is `None` once it has been.
///
/// **Recognition is one line and it names `enter_bar` only** — no growing
/// branch yet, and a yin leaf was born on this bar. `previous` is the leaf that
/// settled this bar, here to give `start_bar` the dead leaf's corner — a
/// backtracked fact. It gates nothing.
///
/// **A growing branch is carried, not rebuilt:** nothing about it changes until
/// the bar it is recognised as dead on.
pub fn next_yang_branch(
  growing: Option(DataBranch),
  databar: DataBar,
  previous: Option(DataLeaf),
  riding: DataLeaf,
  recognised: Bool,
  exit_size: Int,
) -> #(Option(DataBranch), Option(DataBranch)) {
  case growing {
    None ->
      case recognised, previous {
        True, Some(prev) -> #(
          None,
          Some(YangBranch(
            start_bar: leaf.leaf_corner_bar(prev),
            enter_bar: databar,
            end_bar: None,
            exit_bar: None,
          )),
        )
        _, _ -> #(None, None)
      }
    Some(b) ->
      case leaf.data_leaf_size(riding, databar) >= exit_size {
        True -> #(
          Some(YangBranch(
            start_bar: branch_start_bar(b),
            enter_bar: branch_enter_bar(b),
            end_bar: Some(leaf.leaf_start_bar(riding)),
            exit_bar: Some(databar),
          )),
          None,
        )
        False -> #(None, Some(b))
      }
  }
}

/// **A `YinBranch` rides yang leaves** — the mirror of `next_yang_branch`, and
/// every word of the rule there is the same with the polarities swapped.
pub fn next_yin_branch(
  growing: Option(DataBranch),
  databar: DataBar,
  previous: Option(DataLeaf),
  riding: DataLeaf,
  recognised: Bool,
  exit_size: Int,
) -> #(Option(DataBranch), Option(DataBranch)) {
  case growing {
    None ->
      case recognised, previous {
        True, Some(prev) -> #(
          None,
          Some(YinBranch(
            start_bar: leaf.leaf_corner_bar(prev),
            enter_bar: databar,
            end_bar: None,
            exit_bar: None,
          )),
        )
        _, _ -> #(None, None)
      }
    Some(b) ->
      case leaf.data_leaf_size(riding, databar) >= exit_size {
        True -> #(
          Some(YinBranch(
            start_bar: branch_start_bar(b),
            enter_bar: branch_enter_bar(b),
            end_bar: Some(leaf.leaf_start_bar(riding)),
            exit_bar: Some(databar),
          )),
          None,
        )
        False -> #(None, Some(b))
      }
  }
}
