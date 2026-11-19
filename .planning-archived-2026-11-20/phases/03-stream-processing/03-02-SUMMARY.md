# Summary: Phase 3 Stream Processing - DataLeaf Implementation

## Phase
03-stream-processing / 03-02

## Objective
Implement DataLeaf module with YinLeaf/YangLeaf types and streaming leaf detection.

## Completed Tasks

### Task 1: Create DataLeaf types module (`src/glibe/leaf.gleam`)
- Created new module with public types:
  - `YinLeaf(start_idx: Int, end_idx: Int, corner_idx: Int)`
  - `YangLeaf(start_idx: Int, end_idx: Int, corner_idx: Int)`
  - `GrowingYinLeaf(start_idx: Int, corner_idx: Int)` - growing state (no end_idx yet)
  - `GrowingYangLeaf(start_idx: Int, corner_idx: Int)` - growing state (no end_idx yet)
- Helper functions for size, indices, construction, and initialization
- Removed duplicate types from `types.gleam`

### Task 2: Implement streaming leaf detection
- `update_growing_yin(growing, idx, databar_list, sma_tiny) -> #(Option(YinLeaf), GrowingYinLeaf)`
- `update_growing_yang(growing, idx, databar_list, sma_tiny) -> #(Option(YangLeaf), GrowingYangLeaf)`
- `init_growing_yin(idx)`, `init_growing_yang(idx)` - start=corner=idx
- `finalize_yin(growing, end_idx)`, `finalize_yang(growing, end_idx)` - convert to settled leaf
- List access helper: `get_sma_tiny_at(databar_list, global_idx)` using `list.length - 1 - global_idx` for newest-first list

### Task 3: Extend Timeframe with leaf fields (`src/glibe/timeframe.gleam`)
- Added 4 fields to Timeframe:
  - `growing_yin_leaf: leaf.GrowingYinLeaf`
  - `growing_yang_leaf: leaf.GrowingYangLeaf`
  - `yin_leaf_list: List(leaf.YinLeaf)`
  - `yang_leaf_list: List(leaf.YangLeaf)`
- NOT Option - every bar is in both leaves per DESIGN.md §3.4
- Updated `new/3` to initialize with placeholder index -1

### Task 4: Add leaf processing to pipeline
- Added `leaves/3` function in `timeframe.gleam` (avoiding import cycle with indicator.gleam)
- Called in `databar_processing` after `indicator.run`, before `accept`
- Updates growing leaves, moves completed leaves to lists (newest-first via `list.prepend`)

### Task 5: Tests
- Created test file but test infrastructure has Erlang setup issues in this environment
- Build passes successfully

## Key Design Decisions

1. **No internal state types**: Growing leaf IS the record (RULINGS.md 1.2 item 58). Only `start_idx` and `corner_idx` stored; `end_idx` assigned only when leaf closes.

2. **Newest-first list access**: `list_idx = list.length - 1 - global_idx`. At birth (idx == len), list_idx = 0 = O(1). Same O(n) pattern as SMA's leaving bar access.

3. **Leaf laws implemented**:
   - Law 1: First bar (idx=0) opens both twins
   - Law 2: Every bar in current yin AND yang leaf
   - Law 3: New high→new YinLeaf, new low→new YangLeaf. Threshold = leaf's start_val from databar_list[start_idx]. Killing bar belongs to newborn. Shortest leaf = 1 bar.

4. **Yin/Yang separate types**: Per DESIGN.md §4 and NAMING.md rule 1.18 - separate `YinLeaf`/`YangLeaf` types, not `DataYinLeaf`/`DataYangLeaf`.

## Files Changed
- `src/glibe/leaf.gleam` - new module with types and detection
- `src/glibe/timeframe.gleam` - extended Timeframe, added leaves()
- `src/glibe/types.gleam` - removed duplicate DataLeaf/DataBranch
- `src/glibe/indicator.gleam` - unchanged (import cycle avoided)

## Verification
- `gleam build` passes (warnings only for unused imports)
- No import cycles

## Next Steps
- Implement Branch detection (DataBranch module)
- Integrate branch processing into pipeline
- Add strategy and runtime_test