# Handoff — Phase 3 Stream Processing: DataLeaf Complete, Next: DataBranch

## What Was Done (This Session)

### DataLeaf Implementation Complete
Created `src/glibe/leaf.gleam` with:
- **DataLeaf type**: `YinLeaf(start_idx, end_idx, corner_idx)` / `YangLeaf(start_idx, end_idx, corner_idx)`
- **Streaming detection**: `update_yin_leaf/4`, `update_yang_leaf/4` returning `(Option(closed), updated, cma)`
- **CMA calculation**: Running mean of sma_tiny within leaf (incremental from previous bar's cma)
- **Index logic**: Global indices (0,1,2...), count-back for newest-first list access

### Timeframe Extended
Added 4 leaf fields to `Timeframe`:
```gleam
growing_yin_leaf: leaf.DataLeaf,
growing_yang_leaf: leaf.DataLeaf,
yin_leaf_list: List(leaf.DataLeaf),
yang_leaf_list: List(leaf.DataLeaf),
```

### Pipeline Integration
`leaves/3` in `timeframe.gleam` called after indicators, before Bollinger:
- Updates growing leaves
- Moves completed leaves to lists (newest-first via prepend)
- Writes CMA to `working_databar.yin_leaf_cma` / `yang_leaf_cma`

### Key Index Rules (in README.md)
1. **Working bar index = `databar_list.length`**
2. **New leaf: `start_idx = databar_list.length`**
3. **Closed leaf: `end_idx = databar_list.length - 1`**
4. **Count-back: `list_index = list.length - 1 - global_index`**

### Build Status
- `gleam build` passes cleanly (zero warnings from our code)
- IB dependency disabled (websockex incompatibility) — use Binance for testing

## What's Next: DataBranch Implementation

### Branch Rules (DESIGN.md §6)
- **Branch law 1**: May not exist; bar 0 cannot determine
- **Branch law 2**: New YinLeaf ⇒ YangBranch; new YangLeaf ⇒ YinBranch (opposite polarity)
- **Branch law 3**: Continuation = length test (not price test). `branch_exit_leaf_size` from settings
- **Branch law 4**: `exit_idx` = discrimination bar; `end_idx` = over-long leaf's `start_idx` (retrospective)
- **Branch law 5**: Recognized as already appeared (retrospective)
- **Branch law 6**: Old branch `end_idx` = over-long leaf `start_idx`; new branch `start_idx` = that leaf's `corner_idx`
- **Branch law 7**: `corner_idx` = that leaf's last inner opposite leaf's `start_idx`
- **Branch law 8**: Computable from leaf alone, no inner list needed
- **Branch law 9**: Working bar index = `databar_list.length`; backtracked start = `corner_idx` of last leaf in list

### Implementation Tasks
1. Create `src/glibe/branch.gleam` with `DataBranch` type (`YinBranch`/`YangBranch` with 4 indices)
2. Streaming detection: `update_yin_branch/4`, `update_yang_branch/4` taking leaf lists
3. Extend `Timeframe` with 4 branch fields (2 growing Option, 2 lists)
4. Add `branches/3` to pipeline in `timeframe.gleam` (after leaves)
5. Tests for branch detection

### Settings
- `branch_exit_leaf_size` already in `TimeframeSettings` (40/8/2 per interval)

## Files to Work With
- `src/glibe/leaf.gleam` — reference for patterns
- `src/glibe/timeframe.gleam` — pipeline integration point
- `src/glibe/types.gleam` — core types
- `src/glibe/indicator_settings.gleam` — settings

## Verification
- `gleam build` must pass
- Follow same index patterns as leaf (global indices, count-back access)