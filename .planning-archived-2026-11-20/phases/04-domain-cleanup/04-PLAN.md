# Phase 04 — Domain Cleanup

Two independent structural improvements identified from comparing glibe against glib.
No logic changes in either task — both are pure renaming/restructuring.

---

## Task 04-01: Eliminate `binance/types.gleam`

### Why

`binance/types.gleam` commits two category errors:

1. **Duplicate types.** `SourceBar` is defined there AND in `api/sourcebar.gleam`.
   `Interval` is defined there AND in `api/interval.gleam`. Two canonical definitions
   of the same concept — one of them is wrong. The `api/` versions are canonical;
   the `binance/` copies must go.

2. **Wrong name.** A file called `types.gleam` in a Gleam project looks like a
   catch-all dump. In Gleam every type lives in its domain module; there is no
   `types.gleam`. The decode logic in the file belongs in a module named for what
   it decodes: Binance kline arrays → `binance/kline.gleam`.

### What `binance/types.gleam` contains today

| item | correct home | action |
|---|---|---|
| `pub type SourceBar` | `api/sourcebar.gleam` (already there) | delete duplicate |
| `pub type Interval` | `api/interval.gleam` (already there) | delete duplicate |
| `pub fn interval_to_binance_string` | `binance/kline.gleam` (Binance-specific serialisation) | move |
| `fn get_element / get_string / get_float / get_int` | `binance/kline.gleam` (private decode helpers) | move |
| `pub fn decode_bar` | `binance/kline.gleam` | move |
| `pub fn decode_klines` | `binance/kline.gleam` | move |

### Files changed

| file | change |
|---|---|
| `src/glibe/binance/kline.gleam` | **create** — imports `SourceBar` from `api/sourcebar`, `Interval` from `api/interval`; contains `interval_to_binance_string` + all decode functions |
| `src/glibe/binance/types.gleam` | **delete** |
| `src/glibe/binance/binance.gleam` | update import line 5: `glibe/binance/types.{…}` → `glibe/api/sourcebar.{type SourceBar}`, `glibe/api/interval.{type Interval}`, `glibe/binance/kline.{decode_klines, interval_to_binance_string}` |

### Verify

- `gleam build` passes with no new warnings
- `grep -rn "binance/types"` returns zero hits
- `grep -rn "type SourceBar"` returns exactly one definition (`api/sourcebar.gleam`)
- `grep -rn "pub type Interval"` returns exactly one definition (`api/interval.gleam`)

---

## Task 04-02: Replace `start_idx`/`end_idx` with `start_bar`/`end_bar` on leaf and branch

### Why

Every bar, the leaf detection code calls `get_sma_tiny_at(databar_list, start_idx)`:

```gleam
// leaf.gleam:145-148
let start_val = case get_sma_tiny_at(databar_list, leaf_start_idx(growing)) {
  None -> sma_tiny
  Some(v) -> v
}
```

`get_sma_tiny_at` calls `get_bar_at` which calls `list.drop(databar_list, len - 1 - idx)`
— an O(n) traversal **on every bar**. With a window of 504 bars (sma_huge), that is
504 list traversals per bar per leaf update, growing without bound.

Storing the DataBar directly on the leaf eliminates all list traversals:
`growing.start_bar.sma_tiny` is O(1).

It also removes two helper functions (`get_bar_at`, `get_sma_tiny_at`) that exist
solely to work around storing an index instead of a value.

### Required prerequisite: `idx: Int` on DataBar

To compute leaf/branch size and detect "new leaf" we still need to compare bar positions.
The solution is to make the bar self-describing: add `idx: Int` to `DataBar`.

`idx` is the bar's global position in `databar_list` (0 = oldest settled bar).
It is set once, in `sourcebar_gate`, when the working bar is first created:

```gleam
// first bar ever:        idx = 0  (databar_list is empty → length = 0)
// bar N:                 idx = list.length(timeframe.databar_list)
```

The value never changes after that bar is accepted.

### Type changes

**DataBar** (`databar.gleam`):
```
add: idx: Int   (position in databar_list; 0 = oldest)
```

**DataLeaf** (`leaf.gleam`):
```
before:  YinLeaf(start_idx: Int, end_idx: Int, corner_idx: Int)
after:   YinLeaf(start_bar: DataBar, end_bar: DataBar, corner_bar: DataBar)
```

**DataBranch** (`branch.gleam`):
```
before:  YinBranch(start_idx: Int, end_idx: Int, corner_idx: Int, exit_idx: Int)
after:   YinBranch(start_bar: DataBar, end_bar: DataBar, corner_bar: DataBar, exit_bar: DataBar)
```

### Derived simplifications

| was | becomes |
|---|---|
| `leaf_start_idx(l)` → `Int` | `l.start_bar.idx` |
| `leaf_end_idx(l)` → `Int` | `l.end_bar.idx` |
| `leaf_corner_idx(l)` → `Int` | `l.corner_bar.idx` |
| `data_leaf_size(l)` | `l.end_bar.idx - l.start_bar.idx + 1` |
| `get_sma_tiny_at(list, idx)` | `start_bar.sma_tiny` directly — **function deleted** |
| `get_bar_at(list, idx)` | not needed — **function deleted** |
| `leaf_start_idx(growing) == idx` | `growing.start_bar.idx == current_bar.idx` |
| `branch_start_idx / branch_end_idx / …` | `b.start_bar.idx / b.end_bar.idx / …` |

### Files changed

| file | change |
|---|---|
| `databar.gleam` | add `idx: Int` field (first field, before `date`) |
| `leaf.gleam` | DataLeaf type; accessor fns; init_yin_leaf/init_yang_leaf take `DataBar` not `Int`; delete `get_bar_at`, `get_sma_tiny_at`; rewrite `update_yin_leaf`, `update_yang_leaf` |
| `branch.gleam` | DataBranch type; accessor fns; init_yin_branch/init_yang_branch take `DataBar`; rewrite `update_yin_branch`, `update_yang_branch` |
| `timeframe.gleam` | `first_databar`: set `idx: list.length(timeframe.databar_list)` = 0; remove `let idx = list.length(…)` lines in `leaves`/`branches` — use `databar.idx` instead; `init_*_leaf(0)` → `init_*_leaf(first_databar)`; `init_*_branch(0)` → `init_*_branch(first_databar)` |
| `test/glibe_test.gleam` | `bar()` helper: add `idx: 0`; `bar_ohlc`: same |

### Order of changes within 04-02

1. `databar.gleam` — add `idx` (breaks all DataBar constructors)
2. `timeframe.gleam` — fix `first_databar` and `new()` constructors
3. `test/glibe_test.gleam` — fix `bar()` helper
4. `leaf.gleam` — new types and logic
5. `branch.gleam` — new types and logic
6. `timeframe.gleam` — update `leaves()` and `branches()` to use bar accessors

Build after each step to catch breakage early.

### Verify

- `gleam build` passes
- `grep -rn "start_idx\|end_idx\|corner_idx\|exit_idx" src/` returns zero hits
  (only allowed in comments)
- `grep -rn "get_bar_at\|get_sma_tiny_at" src/` returns zero hits
- `gleam test` passes (all 18 tests)

---

## Sequencing

04-01 is independent of 04-02 and smaller. Do 04-01 first, commit, then 04-02.

Neither task touches indicator math, config, or the Binance decode logic.
Both are pure structural moves with no semantic change.
