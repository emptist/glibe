# 02-01 — Fill the `timeframe` indicator step + carried state (SUMMARY)

Date: 2026-11-23. Executed per plan `02-01-PLAN.md`, tasks 1–2 fully, task 3
partially (see "Open points"). All O(1) bodies ported from the frozen glib
source; no new type, field (beyond the plan's prerequisite carried fields),
dependency or identity argument was introduced.

**Correction this session.** An earlier pass of this SUMMARY recorded a
*partial* indicator set and a "band centre = sma_medium, awaiting owner
confirmation" implementation decision. That was wrong: owner 2026-11-23 ruled
*"所有技术指标，glib有的，你不能残缺不全"*, and "chart 不消费 / 字段不存在 /
待确认" are not reasons to omit a measurement. The partial body was reverted to
`todo`, RED tests were written for the complete set, and the body was refilled.
The old "待确认" section is withdrawn below.

## What landed

- **Task 67 (prerequisite) — the field set of frozen glib `databar.gleam:40-77`**:
  every computed field glib's `DataBar` carries is now on glibe's `DataBar` —
  five SMA (`tiny/small/medium/large/huge`), seven Bollinger lines
  (`bb_m/u3/u2/u1/l1/l2/l3`), four KDJ (`k/d/j/m`), Welford σ state
  (`sigma_n/mean/m2`), the cached RSV extremes (`kdj_h/h_idx/l/l_idx`) and the
  YinLeaf / YangLeaf CMAs. All seeded neutral at `sourcebar.to_databar` birth.
  The chart still reads only `bb_u3/bb_l3/sma_medium/k/d/j` + the two CMAs; a
  field the chart does not consume is still a measurement the model owns.
- **Task 68 — `IntervalSettings` as an R40-A pipe argument**: `indicator(tf,
  settings)` and `branches(tf, settings)`; `databar_processing(tf, settings)`
  threads it. Shape tests updated (`pipeline_steps_shape_test`,
  `databar_processing_shape_test`), RED→GREEN on arity.
- **Task 69 — `indicator` body, the COMPLETE glib set** in the order of glib
  `indicator.gleam:35-54`:
  1. all five SMA series via `sma_series_stream` — O(1) add-arriving /
     subtract-leaving (glib `sma.gleam:60-108`);
  2. `bb_m = sma_of(working, settings.sma_for_bbm)` — the SELECTED centre, never
     hard-coded (glib `indicator.gleam:45`); week/month select small/tiny, now
     possible because the bar carries all five series;
  3. Welford σ over that centre's OWN window (`size_of(settings,
     settings.sma_for_bbm)`, glib `bollinger.gleam:165`), carried via
     `sigma_stream` + `sigma_add/remove`;
  4. all seven Bollinger lines via `band` + `write_band`; the lower edge is
     floored BEFORE the 0.618/0.382 interpolation (glib
     `bollinger.gleam:199-246`), then `single_bar_test` enforces the strict
     `l3 ≤ l2 ≤ l1 ≤ m ≤ u1 ≤ u2 ≤ u3` order at runtime;
  5. KDJ K/D/J + M via `kdj_stream`: cached-extreme RSV with the rare-path
     `rescan_window`, one alpha for K/D, `j = 3k − 2d`, and M the O(1) rolling
     mean of K (glib `kdj.gleam:15-72`).
  No `Σx²−(Σx)²/n`, no per-bar full-window fold. `rescan_window` is the
  amortised rare path, not the ban. `test/timeframe_steps_test.gleam` now has
  12 assertions: the 6 earlier cases plus five-SMA-complete, selected-centre,
  seven-lines, KDJ-M and lower-band-floor, plus the band-order test.
- **Task 70 — `leaf_cma` body** (plan 02-02 helper, filled here because its
  twin-mean fields now exist): polarity-picked `yin_leaf_cma`/`yang_leaf_cma`
  reader over `sma_tiny` raw, via `cma_recurrence` (glib `leaf.gleam:147-159`).
  1 RED→GREEN case added (`leaf_cma_reads_twin_and_selected_ma_test`).

## RED / GREEN counts

| Step | RED | GREEN | Total test count after |
|---|---|---|---|
| carried fields (67) | compile RED on constructor sites | GREEN | 64 |
| settings pipe (68) | 2 shape arity errors | GREEN | 64 |
| indicator, initial partial (69) | 5 `todo` crashes | GREEN (partial) | 70 |
| leaf_cma (70) | 1 `todo` crash | GREEN | 70 |
| indicator, FULL set (correction) | 10 `todo` crashes (66 passed / 10 failed) | GREEN | 76 |

The 10 RED failures on the correction were: the 4 prior indicator cases plus
the 6 newly added or re-touched (five-SMA, selected-centre, seven-lines,
KDJ-M, lower-floor, and the re-run first-bar/sigma case); every one pointed at
the `indicator` `todo` line, then all turned green on the single body fill.

## Config values consumed by indicator

All read from the `IntervalSettings` pipe argument (never a `Timeframe` field):
`sma_tiny/small/medium/large/huge_window_size` (five SMA),
`sma_for_bbm` (selected centre), `kdj_window_size`, `kdj_k_period`,
`kdj_m_period` (KDJ + M), `bb_multiplier` (band width).
Not consumed here: `kdj_d_period` (glib derives D from the same K alpha),
`branch_exit_leaf_size` (belongs to the `branches` step, still todo).

## WITHDRAWN — "band centre = sma_medium" (was my inference, now void)

The earlier claim that the centre must be hard-coded `sma_medium` because
"glibe carries only tiny/medium" is **withdrawn**. Once the complete field set
was added (Task 67), `sma_for_bbm` can select any of the five series exactly as
in glib, including `SmaSmall` for week and `SmaTiny` for month. KDJ's `m` is now
written too. Nothing in this step is a pending owner decision — the owner
ruled the full set is mandatory.

## Open points (R.5 — do NOT invent; left at declared shape)

The three remaining `timeframe` steps and their helpers still `todo`, because
their rules are registered open points, not missing code:

- `timeframe.leaves` → `leaf.next_yin_leaf` / `next_yang_leaf`: need the
  leaf-death/turn criterion (R.5, "not specified by this skeleton's `///`").
- `timeframe.branches` → `branch` step helpers: need the growing-branch
  signature / Option shape (R.5).
- `timeframe.strategy`: needs the decision rule (R.5).
- `sourcebar_gate` still does not read `sourcebar.interval(of:)` to select
  `config.for_interval_default` — no in-scope caller needs the settings yet;
  inserting it now would create a WAE unused value (plan LANDING POINT note).

None of these were fabricated to turn a test green. They are work items in
`docs/PENDING_DECISIONS.md` R.5, not decisions awaiting the owner (queue = 0).

## Verification (real exit codes, 2026-11-23)

- `gleam format --check` → 0 (after `gleam format`)
- `gleam check` → 0
- `gleam test` → 0, **76 passed, no failures** (was 64)
- `gleam docs build` → 0
- `gleam export package-interface` → 0
- `gleam build --warnings-as-errors` → 1, 53 warnings (17 Todo + 36 unused arg):
  remaining are the untouched R.5 steps + skeleton unused args. No new warning
  category; no `indicator` warning remains.
- No `Σx²`, no whole-window `list.fold` in the indicator body (only the
  rare-path `rescan_window`, which is the documented amortised KDJ path).
