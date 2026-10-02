// Leaf detection module — YinLeaf/YangLeaf types and streaming detection
// bar.idx is the bar's global position (0 = oldest settled bar)
//
// Leaves store DataBar references, not integer indices.  Values are read
// directly from the stored bar (O(1)) rather than traversing databar_list (O(n)).

import gleam/int
import gleam/option.{type Option, None, Some}
import glibe/databar.{type DataBar}

// ============================================================================
// Public Types
// ============================================================================

/// Fractal leaf — bar references, no separate index fields.
/// bar.idx gives the global position; sma_tiny and other values read directly.
pub type DataLeaf {
  YinLeaf(start_bar: DataBar, end_bar: DataBar, corner_bar: DataBar)
  YangLeaf(start_bar: DataBar, end_bar: DataBar, corner_bar: DataBar)
}

// ============================================================================
// Accessors
// ============================================================================

pub fn leaf_start_bar(leaf: DataLeaf) -> DataBar {
  case leaf {
    YinLeaf(s, _, _) -> s
    YangLeaf(s, _, _) -> s
  }
}

pub fn leaf_end_bar(leaf: DataLeaf) -> DataBar {
  case leaf {
    YinLeaf(_, e, _) -> e
    YangLeaf(_, e, _) -> e
  }
}

pub fn leaf_corner_bar(leaf: DataLeaf) -> DataBar {
  case leaf {
    YinLeaf(_, _, c) -> c
    YangLeaf(_, _, c) -> c
  }
}

/// Size of leaf = end_bar.idx - start_bar.idx + 1
pub fn data_leaf_size(leaf: DataLeaf) -> Int {
  leaf_end_bar(leaf).idx - leaf_start_bar(leaf).idx + 1
}

pub fn mk_yin_leaf(start: DataBar, end: DataBar, corner: DataBar) -> DataLeaf {
  YinLeaf(start_bar: start, end_bar: end, corner_bar: corner)
}

pub fn mk_yang_leaf(start: DataBar, end: DataBar, corner: DataBar) -> DataLeaf {
  YangLeaf(start_bar: start, end_bar: end, corner_bar: corner)
}

/// Initialize growing yin leaf — all three positions at the given bar.
pub fn init_yin_leaf(b: DataBar) -> DataLeaf {
  YinLeaf(start_bar: b, end_bar: b, corner_bar: b)
}

/// Initialize growing yang leaf — all three positions at the given bar.
pub fn init_yang_leaf(b: DataBar) -> DataLeaf {
  YangLeaf(start_bar: b, end_bar: b, corner_bar: b)
}

// ============================================================================
// CMA helper
// ============================================================================

fn compute_cma(prev_cma: Float, sma_tiny: Float, count: Int) -> Float {
  { prev_cma *. int.to_float(count) +. sma_tiny } /. int.to_float(count + 1)
}

// ============================================================================
// Streaming Leaf Detection
// ============================================================================

/// Update growing yin leaf with the current (post-indicator) bar.
/// Returns #(Option(completed_leaf), updated_growing_leaf, cma_for_this_bar).
///
/// Yin leaf threshold: sma_tiny rises above the leaf's start_bar.sma_tiny.
pub fn update_yin_leaf(
  growing: DataLeaf,
  current_bar: DataBar,
) -> #(Option(DataLeaf), DataLeaf, Float) {
  let is_new_leaf = leaf_start_bar(growing).idx == current_bar.idx

  case is_new_leaf {
    True -> {
      // First bar of this leaf — complete the previous leaf (end = idx - 1 is
      // already set on the old growing leaf) and open a new one.
      let completed =
        YinLeaf(
          start_bar: leaf_start_bar(growing),
          end_bar: leaf_end_bar(growing),
          corner_bar: leaf_corner_bar(growing),
        )
      #(Some(completed), init_yin_leaf(current_bar), current_bar.sma_tiny)
    }
    False -> {
      let start_sma = leaf_start_bar(growing).sma_tiny
      let threshold_crossed = current_bar.sma_tiny >. start_sma

      case threshold_crossed {
        True -> {
          // New yin leaf born — current bar is the killing bar
          let completed =
            YinLeaf(
              start_bar: leaf_start_bar(growing),
              end_bar: leaf_end_bar(growing),
              corner_bar: leaf_corner_bar(growing),
            )
          #(Some(completed), init_yin_leaf(current_bar), current_bar.sma_tiny)
        }
        False -> {
          // Leaf continues
          let bars_in_leaf =
            current_bar.idx - leaf_start_bar(growing).idx
          let prev_cma = case list_first_cma_yin(growing) {
            Some(c) -> c
            None -> current_bar.sma_tiny
          }
          let cma = compute_cma(prev_cma, current_bar.sma_tiny, bars_in_leaf)
          let corner_sma = leaf_corner_bar(growing).sma_tiny
          case current_bar.sma_tiny <. corner_sma {
            True ->
              #(
                None,
                YinLeaf(
                  start_bar: leaf_start_bar(growing),
                  end_bar: current_bar,
                  corner_bar: current_bar,
                ),
                cma,
              )
            False ->
              #(
                None,
                YinLeaf(
                  start_bar: leaf_start_bar(growing),
                  end_bar: current_bar,
                  corner_bar: leaf_corner_bar(growing),
                ),
                cma,
              )
          }
        }
      }
    }
  }
}

/// Update growing yang leaf with the current (post-indicator) bar.
/// Returns #(Option(completed_leaf), updated_growing_leaf, cma_for_this_bar).
///
/// Yang leaf threshold: sma_tiny falls below the leaf's start_bar.sma_tiny.
pub fn update_yang_leaf(
  growing: DataLeaf,
  current_bar: DataBar,
) -> #(Option(DataLeaf), DataLeaf, Float) {
  let start_sma = leaf_start_bar(growing).sma_tiny
  let is_new_leaf = current_bar.sma_tiny <. start_sma

  case is_new_leaf {
    True -> {
      let completed =
        YangLeaf(
          start_bar: leaf_start_bar(growing),
          end_bar: leaf_end_bar(growing),
          corner_bar: leaf_corner_bar(growing),
        )
      #(Some(completed), init_yang_leaf(current_bar), current_bar.sma_tiny)
    }
    False -> {
      let bars_in_leaf = current_bar.idx - leaf_start_bar(growing).idx
      let prev_cma = case list_first_cma_yang(growing) {
        Some(c) -> c
        None -> current_bar.sma_tiny
      }
      let cma = compute_cma(prev_cma, current_bar.sma_tiny, bars_in_leaf)
      let corner_sma = leaf_corner_bar(growing).sma_tiny
      case current_bar.sma_tiny >. corner_sma {
        True ->
          #(
            None,
            YangLeaf(
              start_bar: leaf_start_bar(growing),
              end_bar: current_bar,
              corner_bar: current_bar,
            ),
            cma,
          )
        False ->
          #(
            None,
            YangLeaf(
              start_bar: leaf_start_bar(growing),
              end_bar: current_bar,
              corner_bar: leaf_corner_bar(growing),
            ),
            cma,
          )
      }
    }
  }
}

// ============================================================================
// CMA helpers — read the previous bar's CMA from the growing leaf's end_bar
// ============================================================================

/// Previous yin_leaf_cma is stored on the previous end_bar.
fn list_first_cma_yin(growing: DataLeaf) -> Option(Float) {
  Some(leaf_end_bar(growing).yin_leaf_cma)
}

/// Previous yang_leaf_cma is stored on the previous end_bar.
fn list_first_cma_yang(growing: DataLeaf) -> Option(Float) {
  Some(leaf_end_bar(growing).yang_leaf_cma)
}
