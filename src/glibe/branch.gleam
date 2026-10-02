// Branch detection module — YinBranch/YangBranch types and streaming detection
// bar.idx is the bar's global position (0 = oldest settled bar)
//
// Branches store DataBar references, not integer indices.  Values are read
// directly from the stored bar (O(1)) rather than traversing databar_list (O(n)).
//
// Field semantics:
// - start_bar / end_bar: trend FACTS (where trend actually started/ended)
// - enter_bar: trading SIGNAL entry (recognition bar — when branch is first detected)
//   glib equivalent: enter_idx.  AI edge = entering BEFORE enter_bar.
//   start_bar < enter_bar.idx <= end_bar.idx < exit_bar.idx (UC-44, one <=)
// - exit_bar: trading SIGNAL exit (discrimination bar where over-long leaf detected)
//
// Law 6: Old branch end_bar = over-long leaf start_bar (trend fact)
// Law 7: New branch start_bar = over-long leaf corner_bar
// Law 8: Computable from leaf alone

import gleam/list
import gleam/option.{type Option, None, Some}
import glibe/databar.{type DataBar}
import glibe/leaf

// ============================================================================
// Public Types
// ============================================================================

pub type DataBranch {
  YinBranch(
    start_bar: DataBar,
    end_bar: DataBar,
    enter_bar: DataBar,
    exit_bar: DataBar,
  )
  YangBranch(
    start_bar: DataBar,
    end_bar: DataBar,
    enter_bar: DataBar,
    exit_bar: DataBar,
  )
}

// ============================================================================
// Accessors
// ============================================================================

pub fn branch_start_bar(branch: DataBranch) -> DataBar {
  case branch {
    YinBranch(s, _, _, _) -> s
    YangBranch(s, _, _, _) -> s
  }
}

pub fn branch_end_bar(branch: DataBranch) -> DataBar {
  case branch {
    YinBranch(_, e, _, _) -> e
    YangBranch(_, e, _, _) -> e
  }
}

pub fn branch_enter_bar(branch: DataBranch) -> DataBar {
  case branch {
    YinBranch(_, _, e, _) -> e
    YangBranch(_, _, e, _) -> e
  }
}

pub fn branch_exit_bar(branch: DataBranch) -> DataBar {
  case branch {
    YinBranch(_, _, _, e) -> e
    YangBranch(_, _, _, e) -> e
  }
}

/// Size of branch = end_bar.idx - start_bar.idx + 1
pub fn data_branch_size(branch: DataBranch) -> Int {
  branch_end_bar(branch).idx - branch_start_bar(branch).idx + 1
}

pub fn mk_yin_branch(
  start: DataBar,
  end: DataBar,
  enter: DataBar,
  exit: DataBar,
) -> DataBranch {
  YinBranch(start_bar: start, end_bar: end, enter_bar: enter, exit_bar: exit)
}

pub fn mk_yang_branch(
  start: DataBar,
  end: DataBar,
  enter: DataBar,
  exit: DataBar,
) -> DataBranch {
  YangBranch(
    start_bar: start,
    end_bar: end,
    enter_bar: enter,
    exit_bar: exit,
  )
}

/// Initialize growing yin branch — all four positions at the given bar.
pub fn init_yin_branch(b: DataBar) -> DataBranch {
  YinBranch(start_bar: b, end_bar: b, enter_bar: b, exit_bar: b)
}

/// Initialize growing yang branch — all four positions at the given bar.
pub fn init_yang_branch(b: DataBar) -> DataBranch {
  YangBranch(start_bar: b, end_bar: b, enter_bar: b, exit_bar: b)
}

// ============================================================================
// Streaming Branch Detection
// ============================================================================

/// Update growing yin branch based on yang leaf.
/// YinBranch tracks YangLeaf (opposite polarity).
///
/// `yang_leaf_list` must be the YANG leaf list (same polarity as the riding leaf).
/// The just-died yang leaf is at the head; its corner_bar is the new branch's start.
pub fn update_yin_branch(
  growing: DataBranch,
  current_bar: DataBar,
  growing_yang_leaf: leaf.DataLeaf,
  yang_leaf_list: List(leaf.DataLeaf),
  exit_leaf_size: Int,
) -> #(Option(DataBranch), DataBranch) {
  let yang_leaf_is_new =
    leaf.leaf_start_bar(growing_yang_leaf).idx == current_bar.idx
  let yang_leaf_size = leaf.data_leaf_size(growing_yang_leaf)

  case yang_leaf_is_new {
    True -> {
      // A new yang leaf just born — the just-died yang leaf is at yang_leaf_list head.
      // Its corner_bar is where the new YinBranch starts (branch law 6/7).
      let has_growing_branch =
        branch_start_bar(growing).idx != current_bar.idx
      case has_growing_branch {
        True -> #(None, growing)
        False -> {
          let start_bar = case list.first(yang_leaf_list) {
            Ok(prev) -> leaf.leaf_corner_bar(prev)
            Error(_) -> current_bar
          }
          #(
            None,
            YinBranch(
              start_bar: start_bar,
              end_bar: current_bar,
              enter_bar: current_bar,
              exit_bar: current_bar,
            ),
          )
        }
      }
    }
    False -> {
      case yang_leaf_size > exit_leaf_size {
        True -> {
          // Over-long yang leaf — close this branch, start the next.
          // New start = corner of the over-long leaf (branch law 6/7).
          let completed =
            YinBranch(
              start_bar: branch_start_bar(growing),
              end_bar: leaf.leaf_start_bar(growing_yang_leaf),
              enter_bar: branch_enter_bar(growing),
              exit_bar: current_bar,
            )
          let new_branch =
            YinBranch(
              start_bar: leaf.leaf_corner_bar(growing_yang_leaf),
              end_bar: current_bar,
              enter_bar: current_bar,
              exit_bar: current_bar,
            )
          #(Some(completed), new_branch)
        }
        False ->
          #(
            None,
            YinBranch(
              start_bar: branch_start_bar(growing),
              end_bar: current_bar,
              enter_bar: branch_enter_bar(growing),
              exit_bar: branch_exit_bar(growing),
            ),
          )
      }
    }
  }
}

/// Update growing yang branch based on yin leaf.
/// YangBranch tracks YinLeaf (opposite polarity).
///
/// `yin_leaf_list` must be the YIN leaf list (same polarity as the riding leaf).
/// The just-died yin leaf is at the head; its corner_bar is the new branch's start.
pub fn update_yang_branch(
  growing: DataBranch,
  current_bar: DataBar,
  yin_leaf_list: List(leaf.DataLeaf),
  growing_yin_leaf: leaf.DataLeaf,
  exit_leaf_size: Int,
) -> #(Option(DataBranch), DataBranch) {
  let yin_leaf_is_new =
    leaf.leaf_start_bar(growing_yin_leaf).idx == current_bar.idx
  let yin_leaf_size = leaf.data_leaf_size(growing_yin_leaf)

  case yin_leaf_is_new {
    True -> {
      // A new yin leaf just born — the just-died yin leaf is at yin_leaf_list head.
      // Its corner_bar is where the new YangBranch starts (branch law 6/7).
      let has_growing_branch =
        branch_start_bar(growing).idx != current_bar.idx
      case has_growing_branch {
        True -> #(None, growing)
        False -> {
          let start_bar = case list.first(yin_leaf_list) {
            Ok(prev) -> leaf.leaf_corner_bar(prev)
            Error(_) -> current_bar
          }
          #(
            None,
            YangBranch(
              start_bar: start_bar,
              end_bar: current_bar,
              enter_bar: current_bar,
              exit_bar: current_bar,
            ),
          )
        }
      }
    }
    False -> {
      case yin_leaf_size > exit_leaf_size {
        True -> {
          // Over-long yin leaf — close this branch, start the next.
          // New start = corner of the over-long leaf (branch law 6/7).
          let completed =
            YangBranch(
              start_bar: branch_start_bar(growing),
              end_bar: leaf.leaf_start_bar(growing_yin_leaf),
              enter_bar: branch_enter_bar(growing),
              exit_bar: current_bar,
            )
          let new_branch =
            YangBranch(
              start_bar: leaf.leaf_corner_bar(growing_yin_leaf),
              end_bar: current_bar,
              enter_bar: current_bar,
              exit_bar: current_bar,
            )
          #(Some(completed), new_branch)
        }
        False ->
          #(
            None,
            YangBranch(
              start_bar: branch_start_bar(growing),
              end_bar: current_bar,
              enter_bar: branch_enter_bar(growing),
              exit_bar: branch_exit_bar(growing),
            ),
          )
      }
    }
  }
}
