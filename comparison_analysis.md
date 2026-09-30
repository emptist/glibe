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