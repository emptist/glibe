# Bollinger Bands: Port of Welford Streaming Algorithm from glib to glibe

## Summary

Ported the Welford online incremental variance algorithm (from Zhihu article p/408474710) from the **glib** project to the **glibe** project's Bollinger Bands implementation. This eliminates the batch standard deviation computation and uses an O(1) per-bar recurrence instead.

## Changes Made

### 1. `src/glibe/bollinger.gleam` — Core algorithm replacement

**Before:** Batch standard deviation computation over a full window of bars:
```gleam
let count = list.length(window)
let sum_sq_diff = list.fold(window, 0.0, fn(acc, bar) {
  let diff = bar.close -. bb_m
  acc +. diff *. diff
})
let sigma = float.power(sum_sq_diff /. int.to_float(count), 0.5)
```

**After:** Welford moving-window recurrence (proposal 2026-10-01, plan 31-02 §3):

- **`SigmaState`** type with `n`, `mean`, `m2` — carried on each bar bar-to-bar
- **`sigma_init()`** — returns initial state `SigmaState(0, 0.0, 0.0)`
- **`sigma_add(s, x)`** — online update: `mean_n = mean_{n-1} + (x - mean_{n-1}) / n`, `M2_n = M2_{n-1} + (x - mean_{n-1}) * (x - mean_n)`
- **`sigma_remove(s, x)`** — window sliding: removes the leaving close when the window is full
- **`sigma(working, databar_list, settings)`** — returns `(σ, state)` where `σ = sqrt(m2 / n)`. On the first bar (n=0), σ=0 and bands collapse to the centre bb_m. No windowed cache needed — the leaving close is read from `databar_list[size - 1]` (newest-first).
- **`bollinger()`** — now calls `sigma` instead of batch computation, and carries the `SigmaState` forward on the returned `DataBar`

**Key design goals achieved:**
- ✅ O(1) per bar — no need to keep a full window cache
- ✅ Avoids the `Σx² − (Σx)²/n` catastrophic cancellation that DESIGN.md §14.6 warns about
- ✅ First bar is honest: σ=0, bands collapse to bb_m (not a fabricated fallback)
- ✅ Mathematically equivalent to batch std dev (Welford's recurrence is equivalent to the population variance formula)

### 2. `src/glibe/databar.gleam` — Sigma state on the bar

- Added three new fields to `DataBar` type:
  - `sigma_n: Int` — number of closes in the Welford window
  - `sigma_mean: Float` — running mean from Welford recurrence
  - `sigma_m2: Float` — sum of squared deviations from Welford recurrence
- **`of_sourcebar()`** — initializes new fields to `sigma_n: 0`, `sigma_mean: 0.0`, `sigma_m2: 0.0`
- **`fold_sourcebar()`** — uses `..bar` spread, so sigma fields carry forward automatically

### 3. No changes needed to `indicator.gleam` pipeline

The pipeline at `src/glibe/indicator.gleam` continues to call `bollinger.bollinger(databar, databar_list, settings)` unchanged. The returned `DataBar` now includes the sigma state fields, which flow forward through the pipeline and are available for the next bar's Welford recurrence.

## Why This Matters

The glib project had already ported to this Welford approach (starting 2026-09-30 per REVIEW_REPORT.md), resolving the catastrophic-cancellation risk and the 16.3-unit error that idib had observed at ~44,000 bars. The glibe project was still on the old batch approach. This port brings glibe in line with the streaming paradigm that has been consistently advocated.

## Band Ordering Law

The `bollinger_band_ordering_law_test` in `test/glibe_test.gleam` verifies:
```
bb_l3 ≤ bb_l2 ≤ bb_l1 ≤ bb_m ≤ bb_u1 ≤ bb_u2 ≤ bb_u3
```

This law continues to hold because:
- On the first bar: σ=0, all bands = bb_m, law holds as equality
- On subsequent bars: Welford σ is mathematically equivalent to batch σ, bands are spaced at Fibonacci ratios (0.382, 0.618, 1.0) around bb_m