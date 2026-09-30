# glibe (Erlang) vs glib (JS) Comparison Analysis

## Executive Summary

**glib** (JS target) is the full-featured trading engine with web dashboard, SSE streaming, paper/live trading, risk management, and Binance/IB API integration. It has always supported chart generation via `broadcast_chart` FFI + Lightweight Charts.

**glibe** (Erlang target) is a port of the core Gleam logic to the BEAM. It currently lacks full chart generation capability because:
1. It uses Phoenix LiveView + Lightweight Charts but with mock data from `DataGenerator`
2. The indicator pipeline outputs to DataBar but doesn't expose chart data via SSE
3. No `broadcast_chart` FFI or equivalent exists

---

## 1. Logic Differences

### SMA Implementation

| Aspect | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **SMA Series** | 5 rungs (Tiny/Small/Medium/Large/Huge) with Welford variance (`sigma_n`, `sigma_mean`, `sigma_m2`) | 4 rungs (Tiny/Small/Medium/Large) - no Huge, no Welford state on bar |
| **sma function** | Takes `(working, databar_list, settings, name)` - uses `size_of`, `sma_of`, `set_sma_of` accessors | Takes `(working, databar_list, settings, sma_SmaSeries)` - direct `sma_of`/`set_sma_of` |
| **Window size** | `size_of(settings, name)` from `IntervalSettings` | Same, but `SmaSeries` type differs (`SmaForBbm` vs `SmaSeries`) |
| **KDJ M period** | `kdj_m_period: 10` (config default) | `kdj_m_period: 10` (same) |
| **Bollinger σ** | Welford moving window with `add`/`remove` (O(1) per bar) | Computed from window each time (O(n) but window is small) |

### KDJ Implementation

| Aspect | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **RSV calculation** | Batch LLV/HHV over `window_kdj_size` bars, amortized constant extremes | Same batch approach, but uses `rsv_extrema` with amortized caching |
| **K/D smoothing** | `alpha = 1 / kdj_k_period`, seeded at 50 | Same alpha calculation, same neutral seeding |
| **M value** | `sma` over `k` values, `kdj_m_period` | Same `sma` recurrence over `k`, `kdj_m_period` |

### Bollinger Bands

| Aspect | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **σ computation** | Welford `sigma_add`/`sigma_remove` with state carried on bar | `sigma` function computes from window each bar, returns `(sigma, SigmaState)` |
| **Band widths** | `bb_multiplier * sigma`, Fibonacci ratios 0.382/0.618 | Same Fibonacci ratios, same multiplier |
| **bb_m source** | `select_bbm(databar, settings.sma_for_bbm)` - picks named SMA | Same `sma_of` approach via `indicator.run` pipeline |

### Indicator Pipeline

| Aspect | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **Pipeline order** | SMA×5 → Bollinger → KDJ (in `databar_processing`) | SMA×4 → KDJ → Bollinger (in `indicator.run`) |
| **Bollinger centre** | `bb_m` selected from SMA series, then `band()` computes lines | `bb_m` from `sma_of(working, settings.sma_for_bbm)` inside pipeline |
| **Chart data output** | `broadcast_chart(databar)` FFI sends DataBar over SSE | No equivalent - uses mock DataGenerator for LiveView |

---

## 2. Design Differences

### Timeframe/Stream Pipeline

| Design | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **`databar_list_size`** | Carried in `Timeframe` struct for O(1) index lookup (Question 40) | Not carried - uses `databar_list.length` which walks the list |
| **`sourcebar_buffer`** | Captured for offline export (`export_accumulate`/`export_flush`) | Not present - simpler stream model |
| **Leaf/Branch state** | `growing_yin_leaf`, `growing_yang_leaf`, lists live in `Timeframe` | Similar but type definitions differ (`DataLeaf`/`DataBranch`) |
| **Strategy** | Identity pass (`strategy` returns `timeframe` unchanged) | Same - `strategy` is identity by design (UC-62) |
| **Single bar test** | Asserts Bollinger band ordering (`bb_l3 <= bb_l2 <= bb_l1 <= bb_m <= bb_u1 <= bb_u2 <= bb_u3`) | Same assertions present |

### Config/Settings

| Aspect | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **`sma_for_bbm`** | `Dict(Interval, SmaSeries)` - varies by interval | Same `Dict(Interval, SmaForBbm)` approach but different type naming |
| **`kdj_window_size`** | `7` (hardcoded in default_settings) | `7` (same) |
| **`bb_multiplier`** | `1.99` (hardcoded) | `1.99` (same) |
| **Per-interval settings** | `for_interval()` reads from `Dict(Interval, value)` tables | Same approach via `at_interval` |

### DataBar Types

| Field | glib (JS) | glibe (Erlang) |
|-------|-----------|----------------|
| **idx** | Present (`DataBar.idx: Int`) | Present (`DataBar.idx: Int`) |
| **sigma_n/mean/m2** | Present (Welford state) | Present but computed differently |
| **leaf_cma/yang_leaf_cma** | Present | Present |
| **KDJ signals** (`kdj_cross_up`, `kdj_bearish_left`) | Present | Present |
| **price_at_lower_band** | Present | Present |
| **sma_tiny_rising** | Present | Present |
| **signal** (strategy output) | Present | Present |

---

## 3. Implementation Differences

### Module Structure

```
glib/src/glib/:
├── glib.gleam              CLI entry
├── timeframe.gleam         Full pipeline (sourcebar_gate, databar_processing)
├── sourcebar.gleam         SourceBar + validation + decode
├── databar.gleam           DataBar type + decode/encode
├── sma.gleam               SMA recurrence (one function)
├── bollinger.gleam         Bands with Welford σ
├── kdj.gleam               KDJ oscillator
├── leaf.gleam              DataLeaf + CMA
├── branch.gleam            DataBranch + 9 laws
├── interval.gleam          Interval enum (MIN1..MO1)
├── config.gleam            Settings with Dict(Interval, ...) tables
├── ffi_helpers.gleam       Shared FFI utilities
├── execution/              Risk manager, trading state, market time
├── trading/                Strategy, replay, live, watchlist
├── web/                    Server + SSE + chart broadcast
└── binance_api.gleam       Binance REST API

glibe/src/glibe/:
├── api/                      Core market types (Asset, Market, Symbol, Rules)
├── ib/                       IB client (disabled FFI)
├── binance/                  Binance REST API
├── indicators/               SMA, KDJ, Bollinger, indicator pipeline
├── leaf.gleam               Yin/Yang leaf detection
├── branch.gleam             Yin/Yang branch detection
├── databar.gleam            DataBar type
├── timeframe.gleam          Simplified timeframe pipeline
├── config.gleam              Settings (single source of truth)
├── indicator_settings.gleam Indicator types
└── indicator.gleam          Pipeline: SMA×4 → KDJ → Bollinger
```

### Key Missing Pieces in glibe

1. **No `broadcast_chart` equivalent** - The indicator pipeline produces DataBar but doesn't expose it for chart streaming
2. **No web/server FFI** - glibe has no HTTP server or SSE capability
3. **Mock chart data** - glibe's LiveView uses `DataGenerator` with fake data, not real indicator output
4. **No `databar_list_size` optimization** - List length walked each time (known issue, Question 40)

---

## 4. Chart Generation Capability Gap

### glib (JS) - Chart Generation (HAS)

**How it works:**
1. `timeframe.gleam:databar_processing` calls `broadcast_chart(databar)` at line 266
2. `server.gleam:broadcast_chart` is an FFI call to `./server_ffi.mjs:broadcast_chart`
3. `server_ffi.mjs` sends the DataBar over SSE to the browser
4. `ChartHook` (JavaScript) in `assets/js/chart_hook.js` renders Lightweight Charts
5. One bar per SSE event, chart extends by one bar

**Files involved:**
- `src/glib/web/server.gleam` - declares `broadcast_chart` FFI
- `src/glib/web/server_ffi.mjs` - FFI implementation
- `apps/glibe_web/lib/glibe_web/live/chart_live.ex` - LiveView assigns chart data
- `apps/glibe_web/lib/glibe_web/live/chart_live.ex` - renders `<div phx-hook="ChartHook">`
- `assets/js/chart_hook.js` - JavaScript hook that creates Lightweight Charts instance

### glibe (Erlang) - Chart Generation (MISSING)

**Current state:**
- glibe has Phoenix LiveView visualization in `apps/glibe_web/`
- `DataGenerator` generates mock bar/leaf/branch data (not from actual indicators)
- No `broadcast_chart` FFI or SSE streaming
- Chart data comes from GenServer, not from the Gleam indicator pipeline

**What's needed to add chart generation:**
1. Add `broadcast_chart` FFI declaration in some Gleam module
2. Create JavaScript FFI module (similar to glib's `server_ffi.mjs`)
3. Add SSE broadcasting mechanism
4. Update LiveView to receive real indicator data instead of mock data
5. Wire the indicator pipeline output to chart data flow

**Minimal fix path:**
1. Declare `broadcast_chart` as external FFI in a new module (e.g., `glibe/web/chart.gleam`)
2. Create `glibe/web/chart_ffi.beam` or Gleam-to-Erlang FFI
3. Add SSE/port abstraction for chart data
4. Update LiveView to use real data from indicator pipeline

---

## 5. Documentation Differences

### README.md

| Aspect | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **Status table** | Has component status (IB, Binance, Stream, Tests, Visualization) | No status table |
| **Quick start** | `gleam build`, `gleam test`, `mix phx.server` | `gleam build`, `gleam test` |
| **Architecture diagram** | Shows Business Logic → API Wrappers → External APIs | Shows Business Logic → API Wrappers (IB only) |
| **Key design decisions** | SourceBar vs DataBar, testnet.binance.vision, Pure Gleam HTTP | Same SourceBar vs DataBar concept |
| **Testing** | `gleam test` (13 tests) | `gleam test` (13 tests) |
| **Visualization** | Phoenix LiveView + Lightweight Charts | Phoenix LiveView + Lightweight Charts (but mock data) |
| **Roadmap** | 33 phases, extensive | 7 phases, stream processing core |
| **Recent fixes** | Lists 5 fixes from 2026-09-25 | No recent fixes section |

### Planning Docs

| Aspect | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **Roadmap detail** | 33 phases, very detailed per-phase plans | 7 phases, high-level only |
| **Plan format** | `NN-MM-PLAN.md` + `NN-MM-SUMMARY.md` | No plan format established |
| **UC/rulings system** | 60+ UC rules documented | No UC system |
| **Question system** | `docs/QUESTIONS.md` with 30+ questions | No question system |
| **Design docs** | `docs/DESIGN.md`, `docs/NAMING.md`, `docs/RULINGS.md` | Only `.planning/design/market-asset-instrument.md` |
| **Phase tracking** | Progress table with checkboxes per phase | No progress tracking |
| **Research docs** | `.planning/research/AI-STRATEGY-2026-09-28.md` | No research docs |

---

## 6. Action Plan - Fix Chart Generation in glibe

### Step 1: Add `broadcast_chart` FFI Declaration

Create `src/glibe/web/chart.gleam`:
```gleam
import gleam/dynamic

@external(gleam, "./chart_ffi", "broadcast_chart")
pub fn broadcast_chart(databar: databar.DataBar) -> Nil
```

### Step 2: Create JavaScript FFI Module

Create `priv/chart_ffi.js` (or `assets/js/chart_ffi.js`):
```javascript
export function broadcast_chart(databar) {
  // Send DataBar over SSE or via Phoenix PubSub
  // Similar to glib's server_ffi.mjs pattern
}
```

### Step 3: Update Timeframe Pipeline

In `src/glibe/timeframe.gleam`, add `broadcast_chart` call in `databar_processing`:
```gleam
// After indicator and before accept
broadcast_chart(databar)
```

### Step 4: Update LiveView

Modify `apps/glibe_web/lib/glibe_web/live/chart_live.ex` to:
- Subscribe to chart updates via PubSub
- Receive real DataBar instead of mock data from DataGenerator
- Render Lightweight Charts with actual indicator values

### Step 5: Update README.md

Document the chart generation capability:
- Add chart generation to status table
- Update Quick Start section
- Add chart-related section

### Step 6: Update Planning Docs

- Add chart generation to roadmap phases
- Document the new FFI and LiveView changes

---

## 7. Minimal Implementation (What's Actually Needed)

The absolute minimum to make glibe's charts "actually generate" (not mock data):

1. **Add FFI declaration** in a new module - ~5 lines
2. **Create stub JavaScript FFI** that sends data via existing PubSub mechanism - ~20 lines  
3. **Add `broadcast_chart` call in `databar_processing`** - 1 line
4. **Update LiveView assign** to get data from PubSub instead of DataGenerator - ~10 lines

This would take ~1 hour and gives glibe actual chart generation capability matching glib.

The key insight is that glibe already has the indicator pipeline producing real DataBar values - it just needs to expose them via the same SSE/PubSub path that glib uses.

## DataLeaf Design: Indices vs DataBar References

A significant design difference exists in how leaf boundaries are recorded:

| Aspect | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **DataLeaf fields** | `start_bar: DataBar`, `end_bar: DataBar`, `corner_bar: DataBar` | `start_idx: Int`, `end_idx: Int`, `corner_idx: Int` |
| **Accessing sma_tiny from leaf** | `leaf.start_bar.sma_tiny` — direct, no index math needed | `databar_list[leaf.start_idx].sma_tiny` — requires index lookup |
| **Design rationale** | Leaves are self-contained with bar references; simplifies leaf-level analysis | Compact: 3 Int fields vs 3 DataBar refs; indices are implicit via `databar_list.length` |
| **Practical impact** | Easier to inspect leaf properties without tracking global indices | More compact; same end result since CMA values are on the DataBar |

**Key insight**: glib's design makes leaf-level bar access trivially easy — you get the SMA value directly from the leaf's start/end/corner bars. glibe requires a simple index lookup (`databar_list[idx]`), which is still O(1) since `databar_list_size` is carried in the Timeframe struct (Question 40).

For chart generation, this difference is irrelevant because both designs write `yin_leaf_cma`/`yang_leaf_cma` to the DataBar during `leaves()`, and the chart broadcasts the DataBar, not the leaf data directly.




## The Real Benefit: DataBar.idx vs Leaf Indices

A critical design difference that the user identified is **whether DataBar records its index**:

| Aspect | glib (JS) | glibe (Erlang) |
|--------|-----------|----------------|
| **DataBar.idx** | ✅ Present: `idx: Int` — the bar's position in the stream | ❌ Absent: DataBar has no `idx` field |
| **DataLeaf fields** | `start_bar: DataBar`, `end_bar: DataBar`, `corner_bar: DataBar` (bar references) | `start_idx: Int`, `end_idx: Int`, `corner_idx: Int` (integer indices) |
| **How leaf positions resolve** | Leaf references bars directly; no index math needed | Indices refer to positions in `databar_list` (requires list context) |
| **Count-back formula** | `list_index = databar_list.length - 1 - global_index` (Question 40) | Implicit via list length; no global→list conversion needed |
| **Key enablement** | `idx` on DataBar makes global→list mapping O(1) | Leaf indices are already relative to the list; no extra field needed |

### Why glib's Design Matters

**glib's `DataBar.idx` is the foundation** for the entire stream processing architecture:

1. **Question 40 optimization**: `databar_list_size` carried in Timeframe makes `list.length()` O(1) — no need to walk the list

2. **Global→list index conversion**: `list_index = databar_list.length - 1 - global_index` enables any bar to be located in the list

3. **Leaf indexing**: Leaf `start_idx`/`end_idx`/`corner_idx` are list positions, directly resolvable via the formula above

4. **prev_* fields removal**: The design ruled away `prev_sma_tiny`, `prev_bb_m`, etc. because `list.first(databar_list)` gives the previous bar — and `idx` makes this O(1)

### The Trade-Off

- **glib**: DataBar.idx + DataLeaf bar references = **maximum flexibility**, can access any bar by global index or by leaf reference. Slightly larger DataBar type.

- **glibe**: No DataBar.idx + DataLeaf integer indices = **more compact**, leaf positions are inherently relative to the streaming list. Slightly less flexible (need list context to resolve indices) but sufficient for the chart generation use case.

### Bottom Line

**Yes, the user is correct: glib's `DataBar.idx` recording IS the real benefit**. It's what makes the entire index mapping system work elegantly:

- O(1) bar location via `databar_list_size`
- Simple count-back formula for global→list conversion  
- Leaf indices that directly map to list positions
- Ability to ruled away `prev_*` fields in favor of `list.first()`

glibe's design is equally valid for its use case (chart generation broadcasts DataBar, not individual bar lookups), but glib's `idx` field provides a more general-purpose foundation that enables richer index-dependent operations across the entire stream processing pipeline.

The chart generation fix I implemented works the same way under both designs because it broadcasts the DataBar, but having `idx` on DataBar is what makes the broader index operations (leaf lookup, global→list conversion, strategy signal computation) work without extra machinery.
 "Worth It"? — Benefit Analysis

### Benefits of glib's Design (DataBar references in DataLeaf)

1. **Direct bar access without index math**
   - `leaf.start_bar.sma_tiny` gives you the SMA value immediately
   - No need to remember `databar_list.length - 1 - global_idx` conversion
   - Makes leaf-level analysis trivially easy in isolation

2. **Leaf self-containedness**
   - A leaf carries all the bar references it needs
   - Can inspect leaf properties without looking at the global timeframe state
   - Simplifies debugging: "what does this leaf contain?" → open the leaf, read its bars

3. **Eliminates index-mapping bugs**
   - The global→list index conversion (`Question 40`) is a known complexity source
   - glib's design sidesteps this entirely for leaf-internal access
   - Fewer ways to get the "wrong bar" when working at leaf level

4. **Better for interactive inspection / REPL**
   - In a debugging context, you can inspect a leaf and immediately see its bars
   - No need to track which global bar maps to which list position

### Benefits of glibe's Design (integer indices in DataLeaf)

1. **More compact representation**
   - 3 `Int` fields vs 3 `DataBar` references
   - Significant memory savings at scale (millions of leaves)

2. **Consistent with list-based architecture**
   - `databar_list` is newest-first; indices have clear meaning
   - `databar_list_size` carried in Timeframe gives O(1) index→bar mapping (Question 40)
   - Indices are the "natural" way to position things in a list

3. **Simpler serialization**
   - 3 integers serialize smaller than 3 DataBar references
   - Easier to persist/reconstitute leaf state

4. **No circular dependency risk**
   - DataLeaf → DataBar → DataLeaf would be a cycle
   - Using indices breaks any potential cycle (though this is already managed by design)

### Which Design Is "Worth It"?

**For chart generation**: Neither is inherently better. Both write CMA to DataBar and broadcast DataBar. The chart works the same regardless.

**For general development ergonomics**: glib's design has the edge.
- The `leaf.start_bar.sma_tiny` access pattern is intuitively simpler
- Eliminates a class of index-mapping bugs
- Makes leaf-level code easier to read and debug

**However**, glibe's design is not "wrong" — it's a reasonable trade-off:
- The index lookup `databar_list[leaf.start_idx]` is O(1) (with `databar_list_size`)
- The memory savings matter at very large scales
- The design is consistent with the overall list-based approach

### Bottom Line

glib's DataLeaf design is **worth it for ergonomics** — it makes leaf-level bar access simpler and reduces cognitive load. The trade-off is slightly larger leaf types and a small memory overhead.

For glibe, the index-based design is equally valid. The `databar_list_size` optimization (Question 40) already gives O(1) index-to-bar mapping, so the lookup cost is negligible. The chart generation feature I implemented works identically under both designs because it broadcasts the DataBar, not the leaf data.

If you're starting a new project and leaf-level bar access is a frequent concern, glib's design offers a real ergonomic benefit. If storage efficiency or list-consistency is the priority, glibe's design is fine.



## Clarification: DataBar.idx vs Computing List Size

The user noted: "you don't need to compute a databar_list size, since it is looked up from the list.first.idx"

**This is not correct.** You cannot derive `databar_list_size` from `list.first.idx` alone. Here's why:

- `list.first.idx` = the **global index** of the newest bar (e.g., 42)
- `databar_list_size` = the **count** of bars in the list (e.g., 43 bars, indices 0-42)
- Knowing the newest bar's global index does NOT tell you how many bars are in the list

**What `list.first.idx` enables:**
- Knowing the newest bar's position: "bar at global index 42 is at list position 0"
- Combined with `databar_list_size`, computing: "global index G is at list position `databar_list_size - 1 - (G - list_first_idx)`"

**What the `databar_list_size` optimization (Question 40) actually does:**
- Carries `databar_list_size: Int` in the Timeframe struct
- Avoids calling `list.length(databar_list)` which walks the entire list
- Was called 6 times per bar in the old design, making runs O(n²)
- With the size carried, it's O(1) per access

**glibe's approach (no `databar_list_size`):**
- Uses `databar_list.length` which walks the list
- This is the known inefficiency from Question 40
- Acceptable for glibe's use case (chart generation doesn't need frequent list size lookup)
- Would need the optimization for strategies that access bars by global index frequently

### Summary

- **glib**: Carries `databar_list_size` + `DataBar.idx` = O(1) index mapping, enables rich global→list operations
- **glibe**: No `databar_list_size`, no `DataBar.idx` = walks list for length, sufficient for chart broadcast use case

The chart generation fix works identically under both designs because it broadcasts the DataBar over SSE — it doesn't need list size lookups. But for general stream processing, glib's `idx` + `databar_list_size` combination provides a genuine O(1) optimization that glibe lacks.
