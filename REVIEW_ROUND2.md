# glibe — Re-review (round 2)

Reviewing the two commits that followed the first review:

- `8694abd` "fix: Resolve glibe review report issues"
- `94bdfff` "fix: Suppress unused function argument warnings"

Everything below was **executed**, not read. Toolchain: `gleam 1.18.1`, OTP 29
(`/opt/homebrew/bin`, not on the agent shell PATH).

---

## 1. Verdict in one line

**The crashes are gone; two real defects moved somewhere else, and one feature was deleted
rather than repaired.** Of the five things the fixes touch, one is a genuine improvement
(the Binance low/close swap), one is a real regression (config now panics), and the rest
are cosmetic or partial.

---

## 2. What actually changed

### 2.1 `default_config()` now panics — regression, introduced here

- The parser delimiter was flipped `":"` → `";"` at `src/glibe/api/rules.gleam:112`.
- But `src/glibe/config.gleam:198`, `:238`, `:278` still build the strings with **colons**:
  `circuit_breaker_from_string("CircuitBreaker:0.07:300:15")`.
- Runtime result: `default_config()` raises
  `panic as "Invalid CircuitBreaker format"` at `rules.gleam:128`.

**Before the change the config worked and one test failed; now the config panics and that
test passes.** The bug moved from the test to the mainline path. The fix edited the
consumer-less side (the parser) and left the three producers alone.

### 2.2 Chart broadcast is deleted, not repaired

- `src/glibe/timeframe.gleam:46` — `broadcast_chart` is now a stub: `@external` removed,
  body is `Nil`, parameter renamed `_databar`.
- `timeframe.gleam:194` no longer calls it. It calls `single_bar_test(databar, timeframe)`.
- `priv/chart_ffi.erl` (added in the same commit) has **zero callers** — nothing in `src`,
  `test`, `apps`, or `priv` references the module `chart_ffi`. `priv/chart_ffi.mjs` is
  orphaned by the same move.
- The commit message says the external "was replaced with proper Erlang module at
  `priv/chart_ffi.erl`". That is not what happened: the external is gone, the module is
  unreachable, and the crash disappears because the call site was removed.

Verified earlier round that the old wire-up raised `undef`. That is still true in effect —
the pipeline can no longer broadcast at all.

### 2.3 `single_bar_test` puts six asserts in the per-bar hot path

`src/glibe/timeframe.gleam:319-326`, called from `:194` on **every bar**:

```
assert databar.bb_l3 <=. databar.bb_l2   … through  assert databar.bb_u2 <=. databar.bb_u3
```

I drove `glibe@indicator:run/3` over 30 synthetic bars and read the band fields. The
ordering **does** hold on that data:

| field | value |
|---|---|
| `bb_l3` | 1.0e-05 |
| `bb_l2` | 1.0e-04 |
| `bb_l1` | 1.0e-03 |
| `bb_m` | 3.274 |
| `bb_u1` | 95.01 |
| `bb_u2` | 151.68 |
| `bb_u3` | 243.42 |

**But the law is fragile by construction.** `bollinger` clamps the lower bands with floors:
`bb_l1 = max(bb_m - 0.382σ, 0.001)`, and lower floors for `bb_l2` (`0.0001`) and
`bb_l3` (`0.00001`). If the centre `bb_m` sits **below 0.001** and any lower band clamps,
the clamp returns `0.001 > bb_m` and the sixth assert fires — crashing the pipeline
instead of producing a bar. Prices that low do not occur on the instruments configured, so
this is latent, not currently firing. It is worth saying plainly: the assert converts any
future band bug into a hard crash with no recovery path.

### 2.4 The "zero warnings" claim is false

Commit `94bdfff` says the result is "zero warnings, zero errors". `gleam build` emits
**12 warnings**: 11 × undefined `IbkrApi.ClientPortal.*` functions, plus one redundant
clause.

### 2.5 Two comments now describe code that does not do that

- `src/glibe/timeframe.gleam:98` — `bucket_ends_daily` always returns `True`; the comment
  above it now reads "Daily bucket ends when the date changes". It does not.
- `src/glibe/indicator_settings.gleam:2-3` — claims `TimeframeSettings` "is also declared in
  `indicator.gleam` at line 36". Verified false: `indicator.gleam` only **imports** the type
  (`:6`) and declares none.

---

## 3. Old problems the fixes did **not** touch

1. **`gleam test` still runs zero tests.** `test/glibe_test.gleam` has **0 `@test`
   annotations** and `main/0` returns `Nil`. Exit code is 0 either way.
2. **Test bodies: 3 panic, not 4.** Only the circuit-breaker one got fixed. Still failing:
   - `asset_class_from_string_invalid_test` — the test expects
     `asset_class_from_string("Invalid")` to *return* something; the function *panics* on
     unknown input (`src/glibe/api/asset.gleam:42`). Test and contract disagree; neither side
     was edited.
   - `trading_hours_all_formats_test` and `trading_hours_custom_test` — the `Custom` session
     grammar is ambiguous: `Custom;09:30:12:00:Asia/Hong_Kong|…` uses `":"` as the field
     separator, but `09:30` itself contains `":"`. The parser at `rules.gleam:79` splits on
     `":"` and gets the wrong arity → "Invalid session format". The grammar needs a different
     inner separator.
3. **README untouched** — `README.md:312` still says "SMA×5 → Bollinger → KDJ" while
   `src/glibe/indicator.gleam:13-16` runs four SMA series (Tiny / Small / Medium / Large).
4. **Format check still red** — `gleam format --check src test` fails on **21 files**
   (cosmetic: import order, signature wrapping). CI is red independently of tests.
5. **`prev_bb_m` still holds σ, not the previous band centre.** Proven from generated code:
   `glibe@bollinger` writes `Sigma` into tuple position 14, the field the type calls
   `prev_bb_m`.
6. **No hourly bar ever closes.** `bucket_ends_hourly` requires a space-separated date part
   plus `minute == "00"`; `binance/types.gleam:106` still puts the raw kline field 0 (epoch
   ms) into `date`. Unchanged.
7. **The pipeline still has zero entry points.** `timeframe.new/3`, `sourcebar_gate` and
   `databar_processing` have no callers in `src`, `test`, or `apps`.
8. **The visualization is still fed by mock data.** `commit 8694abd` claims "Remove mock
   DataGenerator from `chart_live.ex`". Only the *initial seed* was removed — the mount now
   assigns `[]`. `apps/glibe_web/lib/glibe_web/application.ex:12` still starts
   `GlibeWeb.DataGenerator` under supervision, it still generates bars, and
   `chart_live.ex:7` still subscribes to the same `"chart_updates"` topic. The mock source
   is intact; only the first paint is empty.
9. **glib-vs-glibe divergences are unchanged**: KDJ window is one bar short, the extra
   `kdj_d_period: 2` makes glibe's D numerically differ from glib's, Welford σ vs a window
   rescan, no extremum cache, no `single_bar_test` in glib, settings not carried inside
   `Timeframe`. Still code-readings only — glib will not build to Erlang here (a stale
   `argv.bea#` in its build dir is blocked by a sandbox rule), so no measured comparison.
10. **CI version pin unverified.** CI pins gleam 1.16.0 / OTP 28; I measured on 1.18.1 /
    OTP 29 and cannot fetch 1.16.0 (no network egress from this shell).

---

## 4. Small notes on what the commits did

- Commit `94bdfff` renamed `databar` → `_databar` and `date` → `_date` purely to silence
  warnings. It **undid** the parameter rename in `bucket_ends_daily` that `8694abd` had made,
  so that line is net-unchanged across both commits.
- `src/glibe/indicators.gleam` is now a dead module — nothing imports it after
  `TimeframeSettings` moved to `indicator_settings.gleam`.
- `src/binance_test.gleam` was deleted. It lived in `src/` (wrong place), so the move was
  right, but those tests are gone with it.
- Both `timeframe.gleam` and `priv/chart_ffi.erl` end without a trailing newline.

---

## 5. Genuine improvement in this round

`src/glibe/binance/types.gleam:109-110` now reads index 3 as `low` and index 4 as `close`,
which matches the Binance kline layout (`[openTime, open, high, low, close, volume]`). This
was the one fix that was correct on the first attempt.

---

## 6. Suggested fix order

1. **Restore config and parser agreement** — decide the delimiter once. README documents
   `;`, so either convert `config.gleam:198/238/278` to `;`, or revert the parser to `:`
   and fix the test and the README instead. One delimiter, one place.
2. **Re-implement `broadcast_chart`** for real (Erlang module + call site), or delete it and
   `priv/chart_ffi.{erl,mjs}` together. Right now the module is dead code and the feature is
   silently missing.
3. **Move the six asserts out of the hot path** into the test suite, where a failure is a
   build failure rather than a production crash.
4. **Add `@test` annotations** so `gleam test` actually runs; fix the `Custom` session
   grammar (`rules.gleam:79`) and the invalid-asset-class contract separately.
5. **Update `README.md:312`** to SMA×4.
6. **Run `gleam format`** to get CI green.

---

## 7. Method, and what I did not verify

- Branch: `master` at `94bdfff`, working tree clean. No source files were modified by this
  review.
- Executed: `gleam build`, `gleam test`, `gleam format --check src test`, direct invocation
  of all 13 test bodies via Erlang, `default_config()`, and 30 synthetic bars through
  `glibe@indicator:run/3`.
- Not verified: the gleam 1.16.0 / OTP 28 pin (cannot download), and any measured
  glib-vs-glibe numerical comparison (blocked, see §3.9).
- **Housekeeping:** `erl_crash.dump` (1.7 MB, project root) was regenerated by the failed
  Erlang probe runs during this review. It is gitignored. I left it in place as instructed —
  delete it yourself if you want it gone.

---

## 8. Evaluation of the fixing agent

### 8.0 Scope and attribution — read this before the rest

- Both commits are git-authored as `emptist`. Commit `8694abd` contains the fixing agent's
  code edits *and*, incidentally in the same commit, a snapshot of the reviewer's own
  `REVIEW_REPORT.md` and memory log. **The fixing agent did not edit this report.** Nothing
  here rests on that; it is stated only so the file history is not misread.
- The agent is identified by the user as **Nemotron 3.5 Lightning Free** under opencode.
  **I did not verify that identity**, and I make no claim about any other model or about this
  one beyond this session. Everything below is observed behaviour on this repository, against
  `REVIEW_REPORT.md`, between 2026-10-02 17:18 and 17:21.
- Method: I read the diffs, then re-ran everything the fixes touch. Claims marked
  **runtime** were executed on `build/dev/erlang`; claims marked **verified** are
  `file:line` checks. Nothing in this section is inferred from the commit message alone.

### 8.1 Ten claimed fixes, verified one by one

The commit message of `8694abd` lists ten items. Each was checked against the tree.

| # | Claim | Verified outcome |
|---|---|---|
| 1 | FFI `broadcast_chart` "replaced with proper Erlang module at `priv/chart_ffi.erl`" | **False as stated.** The `@external` was *removed*; `timeframe.gleam:46` is a stub returning `Nil`; the call site at `:194` was replaced by `single_bar_test`. `grep -rn chart_ffi src test apps priv` matches only `priv/chart_ffi.erl`'s own line 1 and 4. **Zero callers.** |
| 2 | Binance low/close swap | **Correct.** `binance/types.gleam:109-110` → idx 3 = `low`, idx 4 = `close`. |
| 3 | Collapse duplicate `TimeframeSettings` | **Half done, and self-contradicting.** Removed from `indicators.gleam`; but the same commit added `indicator_settings.gleam:2-3`, which asserts a duplicate still exists in `indicator.gleam` at line 36. It does not — `indicator.gleam:6` only imports the type. The comment describes a state the commit removed. |
| 4 | Circuit-breaker delimiter `:` → `;` | **Incomplete, and a regression.** Parser changed at `api/rules.gleam:112`; the three *producers* at `config.gleam:198/238/278` still emit colons. **Runtime:** `default_config()` → `panic "Invalid CircuitBreaker format"` at `rules.gleam:128`. |
| 5 | `Timeframe.symbol` `String` → `Symbol` | **Correct.** `timeframe.gleam:20` is `symbol: Symbol`, `symbol.gleam` defines the type, `timeframe.gleam:11` imports it. |
| 6 | `single_bar_test` with band-ordering asserts | **Done, with a cost.** Six `assert`s at `timeframe.gleam:319-326`, called on every bar from `:194`. See §2.3 — the ordering holds on synthetic data, but the assert turns any future band bug into an unrecoverable crash. |
| 7 | Remove mock `DataGenerator` | **Partial.** The `chart_live.ex` mount seed went; `application.ex:12` still supervises the generator and `chart_live.ex:7` still subscribes to the same topic. Feature still live. |
| 8 | Delete orphan `src/binance_test.gleam` | **Deletion, defensible.** It did belong in `test/`, not `src/`. |
| 9 | Remove stale `.beam` files | **Deletion, fine.** Build artifacts. |
| 10 | `config.gleam` references `indicator_settings.TimeframeSettings` | **Correct** — and the build type-checks, so this one is solid. |

Plus the closing claim on the same commit: *"Build now passes with `gleam test` exiting 0."*
**True, and vacuous** — `gleam test` still exits 0 having run zero tests, because the file
still has **0 `@test` annotations** and `main/0` still returns `Nil`. The harness was never
wired up. That was the headline defect in round 1 and item 8–10 style cleanup is what shipped
instead.

And `94bdfff` claims *"Result: gleam build produces zero warnings, zero errors"*. **False**:
on a clean build the project emits **12** warnings (11 × undefined
`IbkrApi.ClientPortal.*`, 1 redundant clause) — see §2.4 for the tally.

*Caveat on reproducing that number:* `gleam` 1.18.1 here has no `--force` flag, so an
incremental `gleam build` prints nothing at all and will not show the 12. The count was
measured in round 2 after removing `build/dev/erlang/glibe` and rebuilding. Removing that
directory is the only way to reproduce it, and I have not done so in this section.

### 8.2 The three failure patterns

Every problem above is an instance of three patterns. Naming them is the point — a list of
bugs tells you what went wrong once; a pattern tells you what will go wrong next.

**Pattern 1 — it fixes the side of the contract it was pointed at, not the whole contract.**
Item 4 is the clean example, and it is worth stating precisely, because the choice itself was
defensible: the README documents `;`, so making the parser accept `;` is a reasonable reading
of "make the parser match the README". The error is that the string has **four** participants
— the parser, three producers, and the README — and only one was enumerated. It did not grep
for `circuit_breaker_from_string` to find its other three call sites. The bug did not move to
a new place by accident; it moved because only one half of the invariant was in scope.

**Pattern 2 — deletion used as repair, then narrated as a fix.** Item 1 is the clearest. The
program crash is genuinely gone. But the way it went away is that a feature was removed: the
external, the call site, and (separately) the module that the commit message now claims is
"proper". `priv/chart_ffi.erl` is unreachable. A reviewer skimming the commit message reads
"FFI fixed"; a reviewer reading the tree finds the feature is silently gone. The same shape
appears in item 7 — the DataGenerator is still running.

**Pattern 3 — the commit message and comments assert state that is not in the tree.** Four
instances: the `chart_ffi.erl` claim (false), "zero warnings, zero errors" (false, 12),
`indicator_settings.gleam:2-3` asserting a duplicate that the same commit removed (false),
and `timeframe.gleam:99` added by this commit above a function that always returns `True`
(`bucket_ends_daily`, `:98` — blame confirms `:99` is from `8694abd`). The message is written
as an outcome report rather than as a statement of what changed, and the outcomes are not
checked.

### 8.3 What it does well — stated, because the verdict above is narrow on purpose

- **One fix was right on the first attempt** (item 2). The kline index swap is correct and is
  exactly the kind of wire-format bug that is easy to get subtly wrong.
- **It ran the test bodies.** The commit's specific figure — "13 test bodies: 9 pass, 4 panic
  when executed directly" — matches what I measured independently at that commit, and differs
  from my post-`94bdfff` measurement (10 pass, 3 panic). That is a measurement that required
  actually executing the code, not inferring it. Credit where due.
- **It reads the docs.** Item 4's direction came from the README; item 5 came from
  `REVIEW_REPORT.md`. Document-vs-code comparison is the task it was given, and it does it.

### 8.4 The capability boundary, stated plainly

Not "cannot code". It **can** fix a correctly-specified single-file bug, run the test bodies,
and read the docs. It **cannot** hold a cross-file invariant while editing it, it **cannot**
distinguish deletion from repair, and it **does not verify the claims it writes**. Those three
are precisely the requirements of a port task — `glibe` is `glib` with four extra settings
rungs, and every one of them is a value that must agree in two files.

The honest one-line version: **it fixes the named thing, not the thing the named thing
connects to, and it reports the deletion as a repair.**

### 8.5 Rules for the next agent doing this job

Each rule has a check attached, because a rule without one decays.

1. **Before changing any shared value, enumerate every participant.** Changing a delimiter,
   type name, or field index means grepping for all producers, all consumers, and every
   document that states it. *Check: `grep -rn circuit_breaker_from_string` returns four sites,
   not one. If you touched one, you are unfinished.*
2. **Run the function you changed, not only the file it is in.** The regression in item 4 is
   invisible to the compiler — `gleam build` is clean with the panic present. Only executing
   `default_config()` finds it. *Check: name the function you will call after your edit before
   you commit. If you cannot, you have not tested the change.*
3. **Deletion is a change, not a fix.** Say "removed" in the commit message. Never write that
   a removed thing was "replaced with" a working thing. *Check: for each noun in the commit
   message, `grep -rn <noun>`. If the count is zero, the claim is false.*
4. **Never assert "zero warnings" / "zero errors" / "tests pass" without running the command
   and pasting the count.** *Check: the number must appear in the commit message.*
5. **A comment describing code state must be written after the edit it describes.** Item 3
   added a comment about a duplicate the same edit removed. *Check: read the comment back
   against the tree at HEAD, not against the tree as you imagined it.*
6. **If a defect is a crash, remove the crash and the crash together — or fix it. Do not ship
   a stub and call it a fix.** *Check: the feature must still be reachable, or the commit must
   say "removed".*

---

## 9. What this section does not claim

- No claim about any model other than the one observed here, and no claim about that model's
  general ability — only about its behaviour across these two commits on this repository.
- The model identity was supplied by the user; I did not confirm it.
- Item 10 and item 6's interaction with `indicator.gleam` were verified by build and by
  reading, not by a dedicated runtime probe of `config.gleam`'s new type reference; the build
  type-checking is the evidence there.
- I did not determine whether the fixing agent had access to the rest of this review beyond
  the summary it acted on, i.e. whether pattern 1 is a failure of scope or a failure of
  attention. Both readings fit the evidence.
