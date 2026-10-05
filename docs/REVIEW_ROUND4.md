# Review Round 4 — glibe — 2026-10-05

## Headline
The tree had **not compiled** since the Welford-σ / KDJ port landed
(commit `530cb3f`). That port was authored by a lower-level model (glm) before
this session resumed, and it shipped compile errors that a stale `build/` cache
hid through every later review round. This pass makes the tree green
(`gleam build` exit 0, `gleam test` 23 passed, 0 failures) and removes ornament
that was never actually computed.

Root cause of the obstacle you flagged: broken code was committed unbuilt, and
because commits were not kept green, the breakage propagated through every
later layer instead of being caught at one commit.

## Blocking defects found and fixed (6 atomic commits)
1. `bollinger.gleam` used `SmaForBbm(..)` in an unqualified import list —
   rejected by Gleam 1.18.1 (syntax error that halted the whole build). Fixed:
   import the type qualified, reference constructors as
   `indicator_settings.SmaForBbmTiny` etc.
2. `databar.gleam` defined only the `DataBar` type — the `of_sourcebar` /
   `fold_sourcebar` functions `engine.gleam` calls existed nowhere. Added both.
3. `kdj.gleam` wrote `highest:` / `h_idx:` / `lowest:` / `l_idx:` onto the bar,
   but `DataBar` has no such fields (the real names are
   `kdj_h` / `kdj_h_idx` / `kdj_l` / `kdj_l_idx`). Fixed the field names.
4. `kdj.gleam` called `sma.sma` with 6 arguments — a generic mean over `k` that
   did not exist. Extracted `sma.incremental_mean(working, list, size, prev_of,
   value_of, set_of)` and called it; also refactored the five SMA ladders to use
   the same recurrence (windowing math now lives in one place).
5. `test/glibe_test.gleam` `bar()` omitted `kdj_h` / `kdj_h_idx` / `kdj_l` /
   `kdj_l_idx`, so the test module never compiled. Completed the literal.
6. Lower Bollinger bands were floored at magic numbers `0.001` / `0.0001` /
   `0.00001`; the only principled floor is `0.0` (price cannot be negative).
   Switched to `float.max(.., 0.0)` to match `kdj`.

## Dead code removed (ornament — the smell you named)
- **15 `DataBar` fields** nothing ever wrote or read: `bias`,
  `small_above_tiny`, `cmas_up`, `bars_k_on_d`, `bars_d_on_k`, the four
  `inner_*_leaf_cma`, `kdj_cross_up`, `kdj_bearish_left`,
  `price_at_lower_band`, `sma_tiny_rising`, `leaf_cmas_rising`,
  `leaf_cmas_falling`. An uncomputed number printed is a lie the reader cannot
  tell from a zero — they are gone.
- **`kdj_d_period` setting**: `kdj.gleam` uses `kdj_k_period` for both K and D
  alphas (single alpha by design — idib wins over ibOptions, not a separate
  1/2). The field was dead; removed from `TimeframeSettings` and the four config
  entries.

## Missed points from prior reviews, now closed
- The "review" was always of **unverified code** — nothing was ever built
  green, so type/field errors could not surface. Fixed by building before
  committing.
- The KDJ M computation was assumed to reuse the SMA recurrence; it did not —
  the helper it needed (`incremental_mean`) was never written. Now it exists and
  is shared.
- `bollinger`'s `σ` window and `bb_m` window are now provably the same size
  (both read `bb_window_size`), so `σ` is measured against the mean it brackets.

## Things NOT deep-reviewed this pass (flag, do not claim done)
- `api/*` (exchange, market, rules, symbol, asset, sourcebar, interval) and
  `binance/*` compile, so all references resolve, but their **semantics** (rule
  string parsing, circuit breaker, kline decode, epoch conversion edge cases)
  were not re-audited line by line.
- `strategy.gleam` emits buy/sell only off the `YangBranch` enter/exit;
  `YinBranch` shorting is explicitly ruled out. Confirm this matches intent.
- `branch` recognition and `kdj.rsv_extrema` both rely on **consecutive `idx`**.
  A non-trading gap would mis-detect the leaving extreme in the amortised LLV/
  HHV cache. Worth a guard or a note.
- The broken base `530cb3f` remains in history, now fixed by 6 commits on top.
  If you want a clean base, squash/amend it (local only, not yet pushed).

## Still deferred (from the earlier plan, unchanged)
- KDJ window `w+1 → w`; σ excludes bar-in-hand; `window_kdj_size` naming.
- BEAM concurrency (one `Timeframe` actor per instrument) / replay CLI /
  remove `DataGenerator`.
- AI-strategy port (left out by your instruction).
