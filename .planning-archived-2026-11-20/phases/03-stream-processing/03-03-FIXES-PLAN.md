# Phase 3, Plan 3: Fix Critical Bugs

## Objective
Fix three critical bugs identified in code review:
1. `rules.gleam` - String parsing uses `:` delimiter which breaks RTH/Custom formats
2. `timeframe.gleam` - `bucket_ends` always returns `True`
3. `data_generator.ex` - Leaf/branch detection regenerates full lists every tick

## Tasks

### Task 1: Fix rules.gleam TradingHours parsing
**Files:** `src/glibe/api/rules.gleam`, `src/glibe/config.gleam`
**Action:** Change delimiter from `:` to `;` for RTH and Custom formats
**Verify:** `gleam build` succeeds, config parses correctly

### Task 2: Fix timeframe.gleam bucket_ends
**Files:** `src/glibe/timeframe.gleam`
**Action:** Implement actual time bucket logic using sourcebar timestamp and interval
**Verify:** Source bars accumulate into proper time buckets (H1, D1)

### Task 3: Fix data_generator.ex leaf/branch detection
**Files:** `apps/glibe_web/lib/glibe_web/data_generator.ex`
**Action:** Change to incremental detection - only check new bar for leaf/branch completion
**Verify:** New leaves/branches detected correctly without full list regeneration

### Task 4: Add Gleam tests
**Files:** `test/glebe_stream_test.gleam`, `test/glebe_indicators_test.gleam`, `test/glebe_leaf_branch_test.gleam`
**Action:** Unit tests for SMA, KDJ, Bollinger, leaf/branch invariants
**Verify:** `gleam test` passes

## Checkpoint
- [ ] All 3 bugs fixed
- [ ] `gleam build` succeeds with zero warnings
- [ ] `gleam test` passes (once tests added)
- [ ] Phoenix app compiles with zero warnings