# 02-02 — Fill the leaf / branch helpers (SUMMARY)

Date: 2026-11-23. Executed per plan `02-02-PLAN.md`. Owner's rule: fill helpers
whose rule exists in the frozen glib source; where it does not, keep a typed
`todo` and register the specific gap in `docs/PENDING_DECISIONS.md` R.5 — never
invent a rule. All eight helpers were audited against glib; **four were filled
RED→GREEN, three remain registered open points, one was filled earlier**.

## Eight-helper status table

| Helper | Status | Source / reason |
|---|---|---|
| `leaf.leaf_cma` | filled (earlier, 02-01) | glib `leaf.gleam:147-159`; twin CMA reader over `sma_tiny` |
| `leaf.next_yin_leaf` | **filled** | glib `leaf.gleam:207-223` — dies on new HIGH `sma_tiny`, corners on new LOW; threshold = own start |
| `leaf.next_yang_leaf` | **filled** | glib `leaf.gleam:231-247` — polarity mirror |
| `branch.next_yang_branch` | **filled** | glib `branch.gleam:346-384` — birth on recognition, close on `leaf_size >= exit_size`, carry unchanged |
| `branch.next_yin_branch` | **filled** | glib `branch.gleam:388-424` — polarity mirror |
| `branch.branch_size` | registered (todo) | signature returns bare `Int` but a growing branch has no `exit_bar`; correct fix touches `DataBranch` type — architectural, no real caller yet |
| `branch.branch_stat` | registered (todo) | same `Option` problem via `end_bar`; glib's `let assert` is banned by core §7 |
| `branch_exit_leaf_size()` | registered (todo) | no-arg signature cannot express the per-interval count (40/8/2 already in `config.gleam`); shape waits for `timeframe.branches` |

The three registered gaps are work items in `docs/PENDING_DECISIONS.md` R.5,
not decisions awaiting the owner (queue stays 0). None was fabricated to turn a
test green.

## RED / GREEN

- `test/leaf_test.gleam` (new): 5 tests — yin dies-on-new-high (settle/rebirth),
  yin moves-corner-on-new-low, yin holds-when-no-extreme, yang dies-on-new-low,
  yang moves-corner-on-new-high.
- `test/branch_test.gleam` (new): 5 tests — yang born-on-recognition, no-birth-
  without-recognition, closes-on-leaf-size, carried-while-growing, yin born-and-
  closes.
- RED: `gleam test` → 66+10 = **76 passed / 10 `todo` crashes**, each naming the
  exact helper line (`leaf.gleam:206/217`, `branch.gleam:251/267`).
- GREEN after filling the four bodies: **86 passed, no failures**.

## Rules sourced (never invented)

- Leaf death/turn: threshold is the leaf's own `start_bar.sma_tiny` (leaf law 3,
  seib `anotherFish`, DESIGN §5); the killing bar belongs to the newborn, so a
  settled leaf ends at the named `last_bar` — no `idx - 1`, no list walk.
- Branch close: a length test `leaf.leaf_size(riding, databar) >=
  branch_exit_leaf_size` (R6, "closing is a length test, never a price test");
  `end_bar` = where the leaf died (riding leaf's start), `exit_bar` = the bar it
  was found dead on (R5); both late bars filled here and nowhere else; a growing
  branch is carried unchanged.
- Every rule line in the bodies cites its frozen glib source in the `///`/`//`
  comment immediately above it.

## Verification (real exit codes, 2026-11-23)

- `gleam format --check` → 0 (after `gleam format`)
- `gleam check` → 0
- `gleam test` → 0, **86 passed, no failures**
- `gleam docs build` → 0; `gleam export package-interface` → 0
- `gleam build --warnings-as-errors` → 1: 13 `Todo found` + 18 unused arg.
  Domain-layer R.5 todos remaining = branch 3 (`branch_size`/`branch_stat`/
  `branch_exit_leaf_size`) + timeframe 3 (`leaves`/`branches`/`strategy`);
  the rest are app-layer (`runtime.update`) and other skeleton todos. No new
  warning category; none of the four filled helpers appears in WAE.
- No O(n²) / no full-window fold in any new body (all four are O(1) field reads
  and idx comparisons).

## Continuation 2026-11-23 — final 3 branch todos resolved (Task 3)

- `branch.branch_size`: signature `Int → Option(Int)`; `None` while growing,
  `Some(exit.idx - start.idx + 1)` when ended (R1/R6, glib `branch.gleam:96-98`).
- `branch.branch_stat`: signature `#(Float,Float,Float) → Option(...)`; `None`
  while growing, `Some(move_between(start, end))` when ended (glib `:201-204`).
  Both had zero existing callers, so the signature fix needed no call-site edits.
- `branch.branch_exit_leaf_size()` (no-arg): DELETED, not filled. Zero callers,
  and the per-interval count already lives in `config`'s `branch_exit_leaf_size`
  table → `config.for_interval` → `IntervalSettings.branch_exit_leaf_size` →
  `timeframe.branches` → `next_yang/yin_branch`. A no-arg function could not
  express which interval it meant (R49 / core §5 / one-owner R50).

RED→GREEN (`test/domain_steps_test.gleam`): branch_size + branch_stat each had
a test asserting both the ended value and the growing `None`; both were RED on
the todo, GREEN after the body. The no-arg function had no test because it was
removed as dead code, with the reason recorded in the module `////` and in
`02-01-SUMMARY.md`.

Result: **branch.gleam has zero `todo`**; domain layer fully green. WAE Todo
count is now entirely app-layer (see 02-01 SUMMARY continuation).

## Continuation 2026-11-23 — module split (R53) and the RED proof that was missing (R56)

**The split.** `timeframe.gleam` carried 19 functions belonging to glib's four
indicator modules; they now live in `sma.gleam` / `bollinger.gleam` /
`kdj.gleam` / `indicator.gleam` (owner: *"他的补充完全是敷衍，所以全部塞进不应该
塞进去的模块，而不去新建应该用的模块"*). `timeframe.gleam` 838 → 440 lines.

**`sma_of` / `size_of` are now `pub`** — they are the only places a `SmaSeries`
name becomes a field, and while they were private inside `timeframe.gleam` no
other module could read `sma_small` / `sma_large` / `sma_huge` at all. That lock
was the structural mechanism behind "只有 sma_tiny".

**GDLTDD slip, and how it was repaired (R56).** `test/sma_test.gleam` was written
AFTER the three accessor bodies were filled, and its RED was never observed —
a violation of the discipline owner reaffirmed the same day. Repaired by
**mutation testing**: four deliberate defects injected one at a time, each caught
(5 / 5 / 3 / 5 failures), with the unmutated baseline at 102 passed / 1 failure.
The fourth mutation — `sma_of` degraded to "always reads `sma_tiny`" — is the
exact shape of the defect the split removed, so the guard is aimed at the right
thing.

**One operational error, recorded because it nearly hid a real defect**: after
restoring a mutated source file, the incremental build served a stale binary and
the "restored" run still showed the mutation's failures. Every mutation run now
clears `build/dev` first. Full detail: `docs/RULINGS.md` R56.

**`indicator` keeps the pipeline shape** `fn(Timeframe, IntervalSettings) ->
Timeframe` (R40/R40-A/R41, owner 逐字 2026-11-12) while its arithmetic lives in
`indicator.gleam` as a pure `bar → bar` function that never names the record —
the same split glib has (`glib/indicator.gleam:9-13`, `glib/timeframe.gleam:369-379`).
