// Branch detection module — YinBranch/YangBranch types and streaming detection
// Per DESIGN.md §6, NAMING.md §3, RULINGS.md §1.2
// databar_list is newest-first; indices are global (0=oldest)
//
// Index semantics:
// - start_idx / end_idx: trend FACTS (where trend actually started/ended)
// - exit_idx / enter_idx: trading SIGNALS (where we enter/exit, known only later)
//   exit_idx = discrimination bar where over-long leaf detected
//   enter_idx = exit_idx of previous branch = corner_idx of over-long leaf
//
// Law 6: Old branch end_idx = over-long leaf start_idx (trend fact)
// Law 7: New branch start_idx = over-long leaf corner_idx = last inner opposite leaf's start_idx
// Law 8: Computable from leaf alone
//
// Note: AI strategy (Phase 4) does NOT change branch definitions.
// Main target: POST-APPROVE both enter_idx AND exit_idx earlier than structural signals.
//   - enter_idx: structural = 100 bars after start_idx; AI post-approves at 80 bars
//   - exit_idx: end_idx marks highest SMA in yang_branch (we're in yin_leaf, opposite polarity).
//     Structural exit_idx comes late; AI post-approves earlier to capture more profit.
//   Prediction (guessing before confirmation) is riskier and less trustworthy.
//   Analogy: like a good doctor who DIAGNOSES issues earlier, not PREDICTS disease in healthy patients.
//   扁鹊也只是早起诊断，不是预测蔡桓公将要生病。

import gleam/option.{type Option, None, Some}
import gleam/list
import glibe/leaf

// ============================================================================
// Public Types
// ============================================================================

/// Fractal branch — indices only, no values.
/// Values read from databar_list at indices.
///
/// Index semantics (per DESIGN.md §6):
/// - start_idx: trend FACT start (where trend actually began)
/// - end_idx: trend FACT end (where trend actually ended)
/// - corner_idx: pivot point = last inner opposite leaf's start_idx
/// - exit_idx: trading SIGNAL exit (discrimination bar where over-long leaf detected)
///
/// enter_idx (for next branch) = exit_idx of this branch = corner_idx of over-long leaf
pub type DataBranch {
  YinBranch(start_idx: Int, end_idx: Int, corner_idx: Int, exit_idx: Int)
  YangBranch(start_idx: Int, end_idx: Int, corner_idx: Int, exit_idx: Int)
}

// ============================================================================
// Helper Functions (Public)
// ============================================================================

/// Size of branch = end_idx - start_idx + 1 (cardinality, not distance)
pub fn data_branch_size(branch: DataBranch) -> Int {
  let start = case branch {
    YinBranch(s, _, _, _) -> s
    YangBranch(s, _, _, _) -> s
  }
  let end = case branch {
    YinBranch(_, e, _, _) -> e
    YangBranch(_, e, _, _) -> e
  }
  end - start + 1
}

pub fn branch_start_idx(branch: DataBranch) -> Int {
  case branch {
    YinBranch(s, _, _, _) -> s
    YangBranch(s, _, _, _) -> s
  }
}

pub fn branch_end_idx(branch: DataBranch) -> Int {
  case branch {
    YinBranch(_, e, _, _) -> e
    YangBranch(_, e, _, _) -> e
  }
}

pub fn branch_corner_idx(branch: DataBranch) -> Int {
  case branch {
    YinBranch(_, _, c, _) -> c
    YangBranch(_, _, c, _) -> c
  }
}

pub fn branch_exit_idx(branch: DataBranch) -> Int {
  case branch {
    YinBranch(_, _, _, e) -> e
    YangBranch(_, _, _, e) -> e
  }
}

pub fn mk_yin_branch(start: Int, end: Int, corner: Int, exit: Int) -> DataBranch {
  YinBranch(start_idx: start, end_idx: end, corner_idx: corner, exit_idx: exit)
}

pub fn mk_yang_branch(start: Int, end: Int, corner: Int, exit: Int) -> DataBranch {
  YangBranch(start_idx: start, end_idx: end, corner_idx: corner, exit_idx: exit)
}

/// Initialize growing yin branch at bar idx (start=corner=end=exit=idx)
pub fn init_yin_branch(idx: Int) -> DataBranch {
  YinBranch(start_idx: idx, end_idx: idx, corner_idx: idx, exit_idx: idx)
}

/// Initialize growing yang branch at bar idx (start=corner=end=exit=idx)
pub fn init_yang_branch(idx: Int) -> DataBranch {
  YangBranch(start_idx: idx, end_idx: idx, corner_idx: idx, exit_idx: idx)
}

// ============================================================================
// Streaming Branch Detection (Simplified per user guidance)
// ============================================================================

/// Check if leaf is new (1-bar leaf just created)
fn is_new_leaf(leaf: leaf.DataLeaf, idx: Int) -> Bool {
  leaf.leaf_start_idx(leaf) == idx
}

/// Update growing yin branch based on yang leaf.
/// YinBranch tracks YangLeaf (opposite polarity).
/// New YangLeaf ⇒ may start new YinBranch.
/// Old YangLeaf growing too large ⇒ closes current YinBranch.
pub fn update_yin_branch(
  growing: DataBranch,
  idx: Int,
  growing_yang_leaf: leaf.DataLeaf,
  yin_leaf_list: List(leaf.DataLeaf),
  exit_leaf_size: Int,
) -> #(Option(DataBranch), DataBranch) {
  let yang_leaf_is_new = is_new_leaf(growing_yang_leaf, idx)
  let yang_leaf_size = leaf.data_leaf_size(growing_yang_leaf)

  case yang_leaf_is_new {
    True -> {
      // New YangLeaf appeared (1-bar leaf)
      // Check if we have a growing YinBranch
      let has_growing_branch = branch_start_idx(growing) != idx
      
      case has_growing_branch {
        True -> {
          // Already have a growing branch, do nothing
          #(None, growing)
        }
        False -> {
          // Start new YinBranch
          // enter_idx (exit_idx) = current bar idx
          // start_idx = yang_leaf's corner_idx
          let new_branch = YinBranch(
            start_idx: leaf.leaf_corner_idx(growing_yang_leaf),
            end_idx: idx,
            corner_idx: idx,
            exit_idx: idx,
          )
          #(None, new_branch)
        }
      }
    }
    False -> {
      // Old YangLeaf - check if it's grown too large
      case yang_leaf_size > exit_leaf_size {
        True -> {
          // Close current YinBranch
          // exit_idx = current bar (discrimination bar)
          // end_idx = yang_leaf's start_idx
          let completed = YinBranch(
            start_idx: branch_start_idx(growing),
            end_idx: leaf.leaf_start_idx(growing_yang_leaf),
            corner_idx: branch_corner_idx(growing),
            exit_idx: idx,
          )
          // Start new YinBranch at FIRST yin_leaf_list's corner_idx (newest completed yin leaf)
          let new_start = case list.first(yin_leaf_list) {
            Ok(l) -> leaf.leaf_corner_idx(l)
            Error(_) -> leaf.leaf_corner_idx(growing_yang_leaf)
          }
          let new_branch = YinBranch(
            start_idx: new_start,
            end_idx: idx,
            corner_idx: idx,
            exit_idx: idx,
          )
          #(Some(completed), new_branch)
        }
        False -> {
          // Branch continues - just update end_idx
          #(None, YinBranch(
            start_idx: branch_start_idx(growing),
            end_idx: idx,
            corner_idx: branch_corner_idx(growing),
            exit_idx: branch_exit_idx(growing),
          ))
        }
      }
    }
  }
}

/// Update growing yang branch based on yin leaf.
/// YangBranch tracks YinLeaf (opposite polarity).
/// New YinLeaf ⇒ may start new YangBranch.
/// Old YinLeaf growing too large ⇒ closes current YangBranch.
pub fn update_yang_branch(
  growing: DataBranch,
  idx: Int,
  yang_leaf_list: List(leaf.DataLeaf),
  growing_yin_leaf: leaf.DataLeaf,
  exit_leaf_size: Int,
) -> #(Option(DataBranch), DataBranch) {
  let yin_leaf_is_new = is_new_leaf(growing_yin_leaf, idx)
  let yin_leaf_size = leaf.data_leaf_size(growing_yin_leaf)

  case yin_leaf_is_new {
    True -> {
      // New YinLeaf appeared (1-bar leaf)
      // Check if we have a growing YangBranch
      let has_growing_branch = branch_start_idx(growing) != idx
      
      case has_growing_branch {
        True -> {
          // Already have a growing branch, do nothing
          #(None, growing)
        }
        False -> {
          // Start new YangBranch
          // enter_idx (exit_idx) = current bar idx
          // start_idx = yin_leaf's corner_idx
          let new_branch = YangBranch(
            start_idx: leaf.leaf_corner_idx(growing_yin_leaf),
            end_idx: idx,
            corner_idx: idx,
            exit_idx: idx,
          )
          #(None, new_branch)
        }
      }
    }
    False -> {
      // Old YinLeaf - check if it's grown too large
      case yin_leaf_size > exit_leaf_size {
        True -> {
          // Close current YangBranch
          // exit_idx = current bar (discrimination bar)
          // end_idx = yin_leaf's start_idx
          let completed = YangBranch(
            start_idx: branch_start_idx(growing),
            end_idx: leaf.leaf_start_idx(growing_yin_leaf),
            corner_idx: branch_corner_idx(growing),
            exit_idx: idx,
          )
          // Start new YangBranch at FIRST yang_leaf_list's corner_idx (newest completed yang leaf)
          let new_start = case list.first(yang_leaf_list) {
            Ok(l) -> leaf.leaf_corner_idx(l)
            Error(_) -> leaf.leaf_corner_idx(growing_yin_leaf)
          }
          let new_branch = YangBranch(
            start_idx: new_start,
            end_idx: idx,
            corner_idx: idx,
            exit_idx: idx,
          )
          #(Some(completed), new_branch)
        }
        False -> {
          // Branch continues - just update end_idx
          #(None, YangBranch(
            start_idx: branch_start_idx(growing),
            end_idx: idx,
            corner_idx: branch_corner_idx(growing),
            exit_idx: branch_exit_idx(growing),
          ))
        }
      }
    }
  }
}