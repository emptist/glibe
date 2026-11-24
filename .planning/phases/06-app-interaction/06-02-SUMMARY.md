# Phase 06 Plan 02: Remove the synthetic feed — Summary

**No fake-bar generator remains in the codebase; the only data source is the real Binance REST live feed.**

## Accomplishments
- Deleted `src/glibe/demo_feed.gleam` (triangle-wave placeholder) and `test/demo_feed_test.gleam`. Confirmed beforehand `grep -rn demo_feed src/` returns nothing — `main` already drove the app solely from `live_feed.run` (real klines).
- Historical RULINGS/STATE mentions of demo_feed left intact (R38, no rewind).

## Files Modified
- deleted `src/glibe/demo_feed.gleam`, `test/demo_feed_test.gleam`.

## Decisions Made
- None.

## Issues Encountered
- None. Test count moved 152 → 149 (exactly the 3 demo_feed tests removed), confirming no other test depended on it.

## Gates (real exit)
format 0 · check 0 · test **149 passed, 0 failures** · docs 0 · export 0 · WAE 0.

## Next Step
06-03 (repeatable runtime-tree diag, remove the hand-made SVG, align ROADMAP). Commit: TBD.
