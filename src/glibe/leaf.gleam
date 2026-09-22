// Leaf detection module — YinLeaf/YangLeaf types and streaming detection
// Per DESIGN.md §4-5, NAMING.md §3, RULINGS.md §1.2
// databar_list is newest-first; indices are global (0=oldest)
// Access: list.drop(list, list.length(list) - 1 - global_idx) |> list.first

import gleam/option.{type Option, None, Some}
import gleam/list
import glibe/types as types

// ============================================================================
// Public Types
// ============================================================================

/// Fractal leaf — indices only, no values.
/// Values read from databar_list at indices.
/// Per DESIGN.md §4: four records, four variants. Single type with two constructors.
pub type DataLeaf {
  YinLeaf(start_idx: Int, end_idx: Int, corner_idx: Int)
  YangLeaf(start_idx: Int, end_idx: Int, corner_idx: Int)
}

// ============================================================================
// Helper Functions (Public) - work on both YinLeaf and YangLeaf
// ============================================================================

/// Size of leaf = end_idx - start_idx + 1 (cardinality, not distance)
pub fn data_leaf_size(leaf: DataLeaf) -> Int {
  let start = case leaf {
    YinLeaf(s, _, _) -> s
    YangLeaf(s, _, _) -> s
  }
  let end = case leaf {
    YinLeaf(_, e, _) -> e
    YangLeaf(_, e, _) -> e
  }
  end - start + 1
}

pub fn leaf_start_idx(leaf: DataLeaf) -> Int {
  case leaf {
    YinLeaf(s, _, _) -> s
    YangLeaf(s, _, _) -> s
  }
}

pub fn leaf_end_idx(leaf: DataLeaf) -> Int {
  case leaf {
    YinLeaf(_, e, _) -> e
    YangLeaf(_, e, _) -> e
  }
}

pub fn leaf_corner_idx(leaf: DataLeaf) -> Int {
  case leaf {
    YinLeaf(_, _, c) -> c
    YangLeaf(_, _, c) -> c
  }
}

pub fn mk_yin_leaf(start: Int, end: Int, corner: Int) -> DataLeaf {
  YinLeaf(start_idx: start, end_idx: end, corner_idx: corner)
}

pub fn mk_yang_leaf(start: Int, end: Int, corner: Int) -> DataLeaf {
  YangLeaf(start_idx: start, end_idx: end, corner_idx: corner)
}

/// Initialize growing yin leaf at bar idx (start=corner=end=idx)
pub fn init_yin_leaf(idx: Int) -> DataLeaf {
  YinLeaf(start_idx: idx, end_idx: idx, corner_idx: idx)
}

/// Initialize growing yang leaf at bar idx (start=corner=end=idx)
pub fn init_yang_leaf(idx: Int) -> DataLeaf {
  YangLeaf(start_idx: idx, end_idx: idx, corner_idx: idx)
}

// ============================================================================
// List Access Helper (newest-first list, global indices)
// ============================================================================

/// Get DataBar at global index from newest-first list
fn get_bar_at(databar_list: List(types.DataBar), global_idx: Int) -> Option(types.DataBar) {
  let len = list.length(databar_list)
  let list_idx = len - 1 - global_idx
  case list_idx < 0 {
    True -> None
    False ->
      case list.drop(databar_list, list_idx) |> list.first {
        Ok(bar) -> Some(bar)
        Error(_) -> None
      }
  }
}

/// Get sma_tiny at global index
fn get_sma_tiny_at(databar_list: List(types.DataBar), global_idx: Int) -> Option(Float) {
  case get_bar_at(databar_list, global_idx) {
    None -> None
    Some(bar) -> Some(bar.sma_tiny)
  }
}

// ============================================================================
// Streaming Leaf Detection
// ============================================================================

/// Update growing yin leaf with new sma_tiny value.
/// Returns #(Option(completed_leaf), updated_growing_leaf).
/// Leaf laws (DESIGN.md §5):
/// - Law 1: First bar (idx=0) opens both twins
/// - Law 2: Every bar in current yin AND yang leaf
/// - Law 3: New high→new YinLeaf. Threshold = leaf's start_val (from databar_list[start_idx]).
///   Killing bar belongs to newborn. Shortest leaf = 1 bar (start=corner=end).
/// The growing leaf IS the DataLeaf record (YinLeaf variant); end_idx updates each bar.
/// When new leaf born, old leaf completed with end_idx = idx - 1.
pub fn update_yin_leaf(
  growing: DataLeaf,
  idx: Int,
  databar_list: List(types.DataBar),
  sma_tiny: Float,
) -> #(Option(DataLeaf), DataLeaf) {
  let start_val = case get_sma_tiny_at(databar_list, leaf_start_idx(growing)) {
    None -> sma_tiny
    Some(v) -> v
  }

  case sma_tiny >. start_val {
    True -> {
      // New yin leaf born at idx (killing bar belongs to newborn)
      let completed = YinLeaf(
        start_idx: leaf_start_idx(growing),
        end_idx: idx - 1,
        corner_idx: leaf_corner_idx(growing),
      )
      #(Some(completed), init_yin_leaf(idx))
    }
    False -> {
      let corner_val = case get_sma_tiny_at(databar_list, leaf_corner_idx(growing)) {
        None -> start_val
        Some(v) -> v
      }

      case sma_tiny <. corner_val {
        True ->
          // New low within leaf: update corner and end
          #(None, YinLeaf(start_idx: leaf_start_idx(growing), end_idx: idx, corner_idx: idx))
        False ->
          // Just extend end
          #(None, YinLeaf(start_idx: leaf_start_idx(growing), end_idx: idx, corner_idx: leaf_corner_idx(growing)))
      }
    }
  }
}

/// Update growing yang leaf with new sma_tiny value.
/// Returns #(Option(completed_leaf), updated_growing_leaf).
pub fn update_yang_leaf(
  growing: DataLeaf,
  idx: Int,
  databar_list: List(types.DataBar),
  sma_tiny: Float,
) -> #(Option(DataLeaf), DataLeaf) {
  let start_val = case get_sma_tiny_at(databar_list, leaf_start_idx(growing)) {
    None -> sma_tiny
    Some(v) -> v
  }

  case sma_tiny <. start_val {
    True -> {
      // New yang leaf born at idx
      let completed = YangLeaf(
        start_idx: leaf_start_idx(growing),
        end_idx: idx - 1,
        corner_idx: leaf_corner_idx(growing),
      )
      #(Some(completed), init_yang_leaf(idx))
    }
    False -> {
      let corner_val = case get_sma_tiny_at(databar_list, leaf_corner_idx(growing)) {
        None -> start_val
        Some(v) -> v
      }

      case sma_tiny >. corner_val {
        True ->
          #(None, YangLeaf(start_idx: leaf_start_idx(growing), end_idx: idx, corner_idx: idx))
        False ->
          #(None, YangLeaf(start_idx: leaf_start_idx(growing), end_idx: idx, corner_idx: leaf_corner_idx(growing)))
      }
    }
  }
}