# Review round 3 — glibe after the "round-2 fixes"

**Revision 2 — 2026-10-04.** The first publication of this review (2026-10-03) was
written against glib HEAD `915f5e0`. **glib has since moved and glibe has not.**
This revision re-measures every cross-project claim against glib as it stands
now. Three things changed materially:

1. glib deleted the six boolean verdict fields from `DataBar` — so the "both
   projects share this gap" note in §4.2 was **wrong** and is corrected.
2. glib made `end_bar` / `exit_bar` `Option` on **both** the leaf and the branch,
   on a recorded ruling — which sharpens I-6, I-7 and I-9 from "unjustified
   difference" into "contradicts a ruling".
3. glib's AI layer went from a placeholder to a measured bench. The distance
   between the two projects on that axis is now much larger than §7 said.

Nothing in either repository was modified for this review.

**Reviewed:** `/Users/jk/gits/hub/tools_ib/glibe` at HEAD `4c2e280` (branch
`fix-types`) — **unchanged since the first publication of this review.**
**Reference:** `/Users/jk/gits/hub/tools_ib/glib` at HEAD `5e471f8` (branch
`wip/streaming-kdj-2026-09-29`), **plus 19 modified/deleted files in the working
tree** — 21 commits (+3635/−1048 across 37 files) ahead of `915f5e0`, and
+2117/−908 uncommitted on top.

---

## 0. Method and environment

| item | value |
|---|---|
| local toolchain | `gleam 1.18.1`, Erlang/OTP 29 (needs `export PATH="/opt/homebrew/bin:$PATH"` — the same PATH gap noted in round 1) |
| CI pin | `.github/workflows/test.yml` pins gleam **1.16.0** / OTP 28. **Not verified** — 1.16.0 cannot be downloaded offline. All results below are 1.18.1; anything attributed to the pinned version is flagged. |
| probe procedure | copy tree → `grep -v "^@test$"` on the test file → `gleam build` / `gleam test` → drive modules directly from `erl` with all `-pa` paths |
| formatting | `gleam format --check` → **19 files** need formatting (was 21 in round 2) |

### 0.1 glib, measured at this revision

| check | result |
|---|---|
| `gleam build` | clean, no warnings |
| `gleam test` | **63 passed, no failures** (was 39 at `915f5e0`) |
| `GLEAM=/opt/homebrew/bin/gleam sh scripts/guards.sh --all` | **10 guards run, all green** |
| same without `GLEAM` set | `compiles.sh` FAILS — *"no gleam at gleam"*. The same PATH gap; it is not a defect in glib. |

---

## 0.5 What moved on the glib side (this is what this revision is about)

| change | where | kind |
|---|---|---|
| The six boolean verdicts leave `DataBar` and are **computed in the strategy** | `databar.gleam:216-222`, `trading/strategy.gleam:40-90` (`SignalBundle`, `evaluate_bar`) | deletion + move |
| `end_bar` / `exit_bar` become `Option(DataBar)` on the **branch** | `branch.gleam:34-41`, `:100-118` | ruling landed |
| `end_bar` becomes `Option(DataBar)` on the **leaf** too | `leaf.gleam:31-33`, `:42-49` | ruling landed |
| A growing branch is **carried unchanged**, not rebuilt | `branch.gleam:296-305` (`False -> #(None, Some(b))`) | semantics |
| The four-word vocabulary `born / recognised / ended / recognised-as-dead` | `NAMING.md` rule 1.23, `branch.gleam`, `timeframe.gleam` | naming |
| `Action { Buy Sell Watch Hold }` + `AiSignal` + `AiGuess` + `AiVerdict` | `databar.gleam:39-57`, `:114`, `:138` | new types |
| `ai_signals` / `ai_guesses` / `branch_yin` / `branch_yang` on the bar; `BranchMark` projection | `databar.gleam:271-…`, `:391-400` | new fields |
| The corner filter is struck (倒果为因) and `label.gleam` deleted | `ai_s1.gleam:41-56`, `src/glib/label.gleam` (D) | deletion |
| The AI bench: `learn.gleam` (945), `boost.gleam` (357), `knn.gleam` (110), `census --learn / --branches`, 114 generated features, multi-symbol pooling | `STATE.md §11.7-§11.9` | new capability |
| `guards.sh` gains compilation as a guard; `no_minute_trading.sh` added | `scripts/` | new guard |
| `databar_list_size` deleted (size is `list.first(databar_list).idx + 1`) | `STATE.md §11.4` | deletion |
| Docs: `DESIGN.md` 1758, `STATE.md` 1021, `NAMING.md` 312 (rules to 1.23), `QUESTIONS.md` 160, `RULINGS.md` 320, 36 archived rulings | `docs/` | documentation |

---

## 1. Verdict in one page

1. **The project does not compile at HEAD.** The new test file uses an attribute that the language does not have: `test/glibe_test.gleam:104` (and 18 more places) — `@test`. `gleam build` fails with *"This is a reserved word"*. This is a **new** break introduced by the round-2 fixes; the previous head built.
2. **Even after removing `@test`, `gleam test` runs zero tests.** `main/0` still returns `Nil` (`test/glibe_test.gleam:12-14`). The runner prints `Running glibe_test.main` and exits 0. The 19 test bodies are real and good — **all 19 pass when invoked directly** — but nothing invokes them. glib, on the same machine, runs **63**.
3. **Of the ten round-2 findings, six are fixed, two are partially fixed, two are untouched** — and the untouched ones include the one that stops the engine working at all on live data (§4.1).
4. **The numeric defaults now match glib exactly** (SMA ladder 7/70/140/252/504, KDJ 7/3/2/10, σ multiplier 1.99, exit leaf size 40, centre = medium). This is genuine progress: those numbers are now sourced, not invented.
5. **Six cross-project divergences now contradict a recorded ruling, not merely a preference** (I-4 the band floors, I-18 the `Option` end bars, I-17 verdicts on the bar, I-19 the rebuilt growing branch, I-2 the dead `kdj_d_period`, I-22 no guards). They are listed in §5 with both sides cited.
6. **The AI strategy is still zero, and the gap widened.** glib now has a working bench — three learners, walk-forward, 114 features, multi-symbol pooling, and a printed measurement of *why it has no edge yet*. glibe has `strategy_signal` returning the bar unchanged. See §7.
7. **The documentation port did not happen**, and the planning document that was supposed to drive it contains several claims about glib that are **false against glib HEAD** (§6.2) — false *before* glib's latest move, and now further behind.

---

## 2. New issue 1 — the tree does not build

```
$ gleam build
error: Syntax error
    ┌─ test/glibe_test.gleam:104:2
104 │ @test
    │ ^^^^ This is a reserved word
```

- 19 `@test` annotations were added (`test/glibe_test.gleam:104 …`).
- There is no `@test` attribute in Gleam. Round 2 reported that the test functions lacked "`@test` annotations"; that report was describing the missing **invocation**, and the name `@test` in it was the problem's label, not a suggested attribute. The fix implemented it literally.
- Corroboration: glib — a mature Gleam tree with ten test modules — contains **zero** `@test` occurrences; Gleam's own documentation shows the runner executing `main` of the test module (`Running glib_test.main`, 63 passed).
- After stripping the 19 lines in the probe copy, everything compiles.

**Severity: highest.** This blocks every other claim about the code being "fixed": nothing downstream can be validated by CI until it is removed.

---

## 3. New issue 2 — the test suite never runs

With `@test` stripped, in the probe copy:

```
$ gleam test
   Compiled in 0.45s
    Running glibe_test.main
```
`main/0` is `pub fn main() { Nil }` (`test/glibe_test.gleam:12-14`). Exit status 0. **Zero of the 19 tests execute.**

Driving each test function directly from `erl` (see §9.3) gives:

```
19 tests executed, 19 pass, 0 fail
```

so the bodies are correct — they are simply unreachable. This is the same failure shape as round 2, *not* a new occurrence, but it survived a round whose commit message says "add indicator test suite".

**Consequence of the two new issues together:** the state regressed. Before this round the tree compiled and `gleam test` silently ran nothing. Now the tree does not compile, and after repair `gleam test` still runs nothing.

**Third consequence — the production invariant is now checked nowhere.** Round 2's six Bollinger band-ordering asserts lived in `single_bar_test` inside the per-bar pipeline. This round moved them into `bollinger_band_ordering_law_test` (`test/glibe_test.gleam:331`) and left `single_bar_test` as `fn(databar, _timeframe) { databar }` (`timeframe.gleam:357-359`). Since no test runs, **the ordering law is asserted nowhere**, and the call itself now produces a warning (unused value, `timeframe.gleam:235`).

### Clean-build warnings: 17

| count | warning | source |
|---|---|---|
| 11 | `IbkrApi.ClientPortal.* is undefined` | from `src/glibe/ib/ibkr.ex`, compiled while its Gleam twin `ibkr.gleam.disabled` is disabled |
| 4 | Detached doc comment | dependency `gleam_erlang/process.gleam:366-369` (not glibe's) |
| 1 | redundant clause | `src/glibe/ib/ibkr.ex:83` |
| 1 | Unused value | `src/glibe/timeframe.gleam:235` — **new this round** (the gutted `single_bar_test` call) |

Round 2 counted 12. The increase to 17 is: +1 unused value, and 11+1 from the disabled IB module that are now always emitted on a clean build. glib's clean build emits **zero** warnings.

---

## 4. Status of the ten round-2 findings

| # | round-2 finding | status | evidence |
|---|---|---|---|
| 1 | `default_config` panics — delimiter flip in `rules.gleam` | **fixed** | three producers now `CircuitBreaker;0.07;300;15` (`config.gleam:198,238,278`); `default_config()` returns normally when called from `erl` |
| 2 | Custom session string unparseable (`"09:30"` split by `:`) | **fixed** | parser separator `,` (`rules.gleam:81`), producer `Custom;09:30,12:00,Asia/Hong_Kong\|…` (`config.gleam:212`), doc comment updated (`rules.gleam:71-73`) |
| 3 | `broadcast_chart` stub + orphan `priv/chart_ffi.{erl,mjs}` | **fixed** | no occurrence of `broadcast_chart`, `chart_ffi` or `@external` remains in `src/` or `priv/`; both FFI files deleted |
| 4 | duplicate `TimeframeSettings` type (`indicators.gleam` vs `indicator_settings.gleam`) | **partly fixed** | `indicators.gleam` deleted — but a **second duplicate lives on**: `indicator_settings.SmaSeries` (`indicator_settings.gleam:3-8`, **four** constructors) vs `sma.SmaSeries` (`sma.gleam:10-16`, **five**). The four-case copy has no users and contradicts `SmaForBbm` in the same file, which *does* have `Huge` (`indicator_settings.gleam:15`) |
| 5 | `single_bar_test` asserts in the hot path | **changed, net worse** | moved into the test suite, which does not run — see §3 |
| 6 | Bollinger σ = NaN on bar 0 (`0.0 /. 0.0`) | **fixed** | `count == 0` guard (`bollinger.gleam:29-34`) |
| 7 | README says SMA×5 | **fixed, then broken again** | README edited to `SMA×4` in `32d009f`; `4c2e280` then added the fifth rung. README now reads `SMA×4` / "Tiny/Small/Medium/Large" at lines **81, 144, 264, 267, 312** while the code has five series (`indicator.gleam:13-17`) |
| 8 | wrong pipeline order in docs | **fixed** | README now says `KDJ → Bollinger`; `indicator.run` is SMA → KDJ → Bollinger ✓ |
| 9 | Binance kline low/close swapped | **fixed (round 2)** and still correct | `kline.gleam:64-71` — idx 3 = low, idx 4 = close |
| 10 | 13 test bodies never run | **regression** | 19 bodies now, still never run, and the file no longer compiles |

### 4.1 Untouched — and now proven: an H1 timeframe never produces a bar

`kline.gleam:52-55` puts the Binance field `openTime` — an **epoch-milliseconds integer** — into `SourceBar.date` as a string. `bucket_ends_hourly` (`timeframe.gleam:148-170`) then splits that string on space/`:`/`T` looking for minute `00`; `"1735704000000"` matches nothing, so it returns `False` every time.

Measured by feeding `sourcebar_gate` three consecutive H1 source bars:

| `SourceBar.date` | result |
|---|---|
| `1735704000000` | `none` |
| `1735707600000` | `none` |
| `1735711200000` | `none` |
| `2024-01-15 09:00:00` | `{some, DataBar}` |

With Binance-shaped input the working bar **never closes**: every source bar is folded into one growing bar forever (`sourcebar_gate`, `timeframe.gleam:121-130`), so no indicator, leaf or branch is ever computed. The default configuration includes `BTCUSDT_H1` (`config.gleam:410`). This was reported in round 1 and again in round 2; it has never been touched.

### 4.2 Untouched — 14 `DataBar` fields have no writer

Fields declared on the record (`databar.gleam`), defaulted in two places (`timeframe.gleam:91-108`, `:192-213`), repeated in the test fixture — and assigned **nowhere** in any module:

`bias`, `small_above_tiny`, `cmas_up`, `bars_k_on_d`, `bars_d_on_k`, `inner_yin_leaf_cma`, `inner_yang_leaf_cma`, `inner_inner_yin_leaf_cma`, `inner_inner_yang_leaf_cma`, `kdj_cross_up`, `kdj_bearish_left`, `price_at_lower_band`, `sma_tiny_rising`, `leaf_cmas_rising`, `leaf_cmas_falling`.

**Correction to the first publication of this review.** It said glib "shares six of them" and treated that as a fairness note. **That is now false, and it was already half false.** At glib `915f5e0` the six booleans were fields of `DataBar` written by nobody. glib has since **deleted them from the bar** and moved them to the place that decides:

- `databar.gleam:216-222` — *"**No boolean verdicts live here.** The six the old bar carried … were never computed by this engine … so every reader of them got `False` … The bar carries **measurements**, and the verdicts are what a strategy derives from them — `trading/strategy.gleam` is the signal authority (UC-46/UC-47) and computes what it decides on."*
- `trading/strategy.gleam:40-90` — the six are now fields of `SignalBundle`, computed by `evaluate_bar`; two of them are idib's verbatim (`kdj_cross_up = k > d && prev_k <= prev_d`, `kdj_bearish_left = j < d && d < k && k > 65 && prev_k >= prev_d`), and the other four carry an honest note: *"**no definition on disk** … that derivation is the only one written anywhere, so it is not a fact about idib and may be wrong."*

So the gap is **glibe-only**, on both halves:

- the six booleans: glib computes them where the verdict belongs; glibe declares them on the bar and writes them nowhere.
- the four `inner_*_cma`: glib deleted them (Question 31, 2026-09-29) with the reason — *"a value the engine does not compute must not be drawn (DESIGN §13) or sent"*. glibe keeps four of them plus `bias`, `small_above_tiny`, `cmas_up`, `bars_k_on_d`, `bars_d_on_k`, which glib never had either.

### 4.3 Untouched — the web app still fabricates its own fractals

`apps/glibe_web/lib/glibe_web/application.ex:8-12` supervises `GlibeWeb.DataGenerator`, which builds its own synthetic bars, leaves and branches in Elixir (`data_generator.ex:18-30`). It is a second, independent implementation of the fractal structure, in another language, still running, still wired into the supervision tree — while glibe's actual engine has no caller anywhere.

glib's position on this is a guard (`no_obsolete_structures.sh`) and a stated invariant: *"The tree has one engine (UC-56) and no second implementation."*

---

## 5. Cross-project inconsistencies that have no stated reason

Each row: what glib does / what glibe does / why the difference is not currently justified. "No reason" means: no comment in glibe says why, no ruling in glib's docs allows it, and the two behaviours cannot both be the intended one.

### 5.1 Numeric / semantic (these change answers)

**I-1. The KDJ RSV window is one bar too wide (glibe).** *Still holds — glib unchanged here.*
glib takes the working bar plus `w-1` settled bars — the window *is* `kdj_window_size` wide (`glib/kdj.gleam:20-27, 127`); sourcing is `idib Incremental.idr:144-148`. glibe takes `window_kdj_size` settled bars **and** the working bar (`kdj.gleam:13, 16-19`) = `w+1` bars. Same configured value, different window.

**I-2. D is smoothed with a different alpha (glibe).** *Still holds, and glib re-states it this week.*
glib: one alpha for both K and D, `1/kdj_k_period` (`glib/kdj.gleam:47-53`), with the citation attached — *"idib wins over ibOptions: D is smoothed with the same alpha as K, not a separate 1/2"*. glib also records that `kdj_d_period` has **no consumer** after that decision. glibe revives the dead key: `kdj.gleam:37` smooths D with `kdj_d_period` = **2**, i.e. alpha ½ against glib's ⅓. D and J therefore differ on every bar, and nothing says why.

**I-3. Bollinger σ excludes the bar in hand (glibe).** *Still holds.*
glib measures σ over the window *ending with the bar being computed* (`glib/bollinger.gleam:56-100`), and says explicitly why: *"the bar in hand is in its own window, and that is what σ means … idib was wrong by up to 16.3 on ~44,000"*. glibe computes σ over `size` **settled** bars only (`bollinger.gleam:19-28`): the current bar is out, one extra old bar is in. This is the exact error glib documents having found and fixed.

**I-4. Lower bands are clamped to a floor (glibe) — against a user ruling.** *Still holds.*
`bollinger.gleam:41-43` clamps at `0.001 / 0.0001 / 0.00001`. glib states there is **no floor** and why, in the module header and again at the band function: *"A correctly-computed band is never negative or zero … a clamp would hide a bug upstream, not guard against one (user 2026-09-30)"* (`glib/bollinger.gleam:5-6, 108-112`). A recorded ruling, contradicted silently.

**I-5. The RSV flat-window guard uses a different threshold.** *Still holds.*
glib: `highest -. lowest <= 0.0001 → 50.0` (`glib/kdj.gleam:28-34`), with the rationale (neutral 50 is the defined value of an undefined quotient). glibe: `hhv -. llv >. 0.0` (`kdj.gleam:22-25`) — a window flat to 1e-9 produces an enormous RSV instead of 50.

**I-6. `branch_size` spans a different pair of bars.** *Still holds.*
glib: `exit_bar.idx - start_bar.idx + 1`, with `let assert Some(exit_bar) = branch.exit_bar` (`glib/branch.gleam:60-64`) — "start_bar to exit_bar, both ends inclusive", and **a branch that has not ended has no size**. glibe: `end_bar.idx - start_bar.idx + 1` (`branch.gleam:75-77`). One name, two spans. glib additionally notes the second span is a *different* quantity — `end − start + 1` is the move's own duration (`branch_stat`, `glib/branch.gleam:180-196`), which glibe does not have at all.

**I-7. A growing branch's `end_bar` tracks a different thing.** *Now sharper — see I-18.*
glib: a growing branch **carries two bars and is carried unchanged**; `end_bar` is filled only on the bar it is recognised as dead, and it is the **start of the leaf it was riding** (`glib/branch.gleam:284-296`) — a death, backtracked, never the current bar. glibe sets `end_bar` to the current bar every bar (`branch.gleam:182, 258`).

### 5.2 Structural

**I-8. Constructor field order differs.** *Still holds.*
glib `YinBranch(start_bar, enter_bar, end_bar, exit_bar)` (`glib/branch.gleam:34-41`) — the order of the invariant `start < enter ≤ end < exit`. glibe `YinBranch(start_bar, end_bar, enter_bar, exit_bar)` (`branch.gleam:27-40`). Both use positional patterns internally (`branch.gleam:46-72`), so any transcribed line breaks silently.

**I-9. Growing structures: `Option` vs sentinel bar.** *Still holds; glib strengthened its side.*
glib's branch functions take `Option(DataBranch)` and open a branch only when a leaf has just cornered (`glib/branch.gleam:264-296`). glibe keeps always-present records seeded with a sentinel bar (`timeframe.gleam:46-60`) and detects "not yet started" by `branch_start_bar(growing).idx != databar.idx` (`branch.gleam:136-137, 213-214`). **The sentinel's `idx` is 0 and the first real bar's `idx` is 0 too** (`sourcebar_gate` sets `idx = list.length(databar_list)`, `timeframe.gleam:115`), so on bar 0 the test answers "no growing branch" and a branch can open although no leaf has died. *Flagged as suspect, not proven* — there is no test that runs, and none that would show it.

**I-10. σ and the RSV extremes are recomputed every bar (glibe).** *Still holds.*
glib carries the Welford state (`sigma_n/mean/m2`, `glib/databar.gleam:190-192`) and the window's cached high/low with their owning idx (`kdj_h/kdj_h_idx/kdj_l/kdj_l_idx`, `glib/databar.gleam:206-212`, UC-64). glibe carries neither: σ is a full window fold per bar, RSV rescans per bar. Acceptable only if it is a deliberate "later" — nothing in the tree says so. (`kdj.gleam:15` still says "O(9)", stale since the window became 7.)

**I-11. The ingest boundary does not exist (glibe).** *Still holds.*
glib validates raw OHLC before admitting a bar (`glib/sourcebar.gleam:26-40`, corroborated against `seib/src/databar.coffee:18`, with the decision to reject rather than repair recorded). glibe's `sourcebar.gleam` has the type and two decoders and nothing else.

**I-12. Interval has no round trip (glibe).** *Still holds.*
glib has `to_string` / `from_string` and an `all()` completeness claim used by `config.gleam` at load (`glib/interval.gleam:33-60`). glibe's `api/interval.gleam` has seven constructors and **no** codec; the configuration therefore addresses timeframes by free-text keys `"BTCUSDT_H1"` … (`config.gleam:409+`) that no code parses.

### 5.3 Configuration shape

**I-13. The settings block is repeated four times, verbatim.** *Still holds.*
`config.gleam:409-475`: four `TimeframeSettings` blocks identical in all twelve fields, keyed by free-text strings. glib ruled this exact smell out (UC-49 / Question 24, `glib/docs/RULINGS.md:275`): *"a value that is identical in every block is not owned by that block"*, and its file is keyed by `Interval` with a load-time completeness check.

**I-14. One field is named differently for no reason.** *Still holds.*
glibe `window_kdj_size` vs glib `kdj_window_size` — glib prefixes every KDJ key with `kdj_` (`kdj_window_size`, `kdj_k_period`, `kdj_d_period`, `kdj_m_period`); glibe breaks the prefix on exactly one of them.

### 5.4 Output

**I-15. `to_csv` exports numbers that never existed.** *Still holds.*
`timeframe.gleam:322-332`: the header omits `sma_huge` (added by `4c2e280`), and every row appends six literal zeros where leaf start/end/corner were meant to go — with the code comment admitting *"leaf/branch indices need separate tracking"*. Exporting `0` for a value nobody computed is the thing glib's own tooling guards against. Note what glib built instead: a `BranchMark` projection (`start_idx, enter_idx, end_idx, exit_idx`, the late two `Option`) carried on the bar as `branch_yin` / `branch_yang` (`glib/databar.gleam:391-400`) so the page can draw the four bars — *"no size, no direction, no price"*.

**I-16. README documents a function that no longer exists.** *Still holds.*
`README.md:312`: `→ broadcast_chart → SSE → browser` — deleted this round. Combined with I-7's stale `SMA×4`, README and code disagree in both directions.

### 5.5 New at this revision — created by glib moving, not by glibe

**I-17. Verdicts live on the bar (glibe) instead of in the strategy (glib).**
glib removed the six booleans from `DataBar` on 2026-10-03 and computes them in `trading/strategy.gleam` (`SignalBundle`, `evaluate_bar`), on the stated principle UC-46/UC-47: *"a `DataBar` carries measurements, and a verdict belongs to whoever decides."* glibe still declares all six on `DataBar` (`databar.gleam:57-62`) and writes none. Same ten fields, opposite answer to "who owns a verdict".

**I-18. `end_bar` / `exit_bar` are not `Option` (glibe) — against a ruling.**
The ruling is explicit and dated: *"a structure doesn't have an `end_bar` unless it is ended"* [user 2026-10-03]. glib applied it to **both** structures: `YinLeaf(start_bar, end_bar: Option(DataBar), corner_bar)` (`glib/leaf.gleam:31-33`) and `YinBranch(start_bar, enter_bar, end_bar: Option(DataBar), exit_bar: Option(DataBar))` (`glib/branch.gleam:34-41`), with `let assert` at every reader and the reason spelled out in both files. glibe has `end_bar: DataBar` on the leaf (`leaf.gleam:18-19`) and four plain `DataBar`s on the branch (`branch.gleam:27-39`) — so a structure that has not ended must still name an end, which is what forces the sentinel in I-9 and the per-bar rewrite in I-7. **One ruling resolves three rows of this table; glibe has taken none of it.**

**I-19. A growing branch is rebuilt every bar (glibe) / carried unchanged (glib).**
glib: *"Carried, not rebuilt: nothing about a growing branch changes until the bar it is recognised as dead on"* (`glib/branch.gleam:300-305`) — `#(None, Some(b))`. glibe reassigns `end_bar` on every bar (`branch.gleam:182, 258`). This is the same fact as I-7 seen from the branch's side; it is listed separately because the fix is one line in one `case`.

**I-20. The four-word vocabulary does not exist in glibe.**
`born` / `recognised` / `ended` / `recognised-as-dead` are four bars and four words in glib (NAMING rule 1.23, landed in `branch.gleam`, `timeframe.gleam`, `census.gleam`, both test files). `grep -r "recognis\|recogniz" src` over glibe returns **zero hits**. Correspondingly, glibe's `signal` field is a `String` written only as `""` (`timeframe.gleam:108, 213`); glib writes it — `signal: manual_signal(recognised_yang, exited_yang)` (`glib/timeframe.gleam:582`) — because *"a signal left on the `Timeframe` is a signal no chart can ever draw"* (UC-57).

**I-21. There is no signal vocabulary type in glibe.**
glib: `pub type Action { Buy Sell Watch Hold }` and `pub type AiSignal { AiSignal(mark: String, action: Action) }` (`glib/databar.gleam:39-57`), plus `AiGuess` and `AiVerdict`; the bar carries `ai_signals: List(AiSignal)` and `ai_guesses`. The reason is recorded: *"a fifth word has no representation and `databar.action` answers `Error` for it"*, and `watch` / `hold` are **reserved** because only a fitted model may decide them. glibe: one `signal: String` and nothing else — no action set, no attempt marks, no room for a second strategy.

**I-22. glibe has no guards; glib has ten — including one that is a ruling.**
glib's `scripts/guards.sh` runs 10 checks (compiles, suite, banned names, obsolete structures, `types.gleam` bag, minute bars, config logic, doc scatter, plan format, hand-written JS) — and since 2026-10-03 compilation is one of them, because *"a check that cannot see the thing it guards is worse than no check, because it is reported."* `no_minute_trading.sh` exists because of *"never use 1 minute data to do trading, you should normally use daily data, at least hourly data bars"* [user 2026-10-03]. glibe has **no `scripts/` directory** and one CI workflow, pinned to a compiler version that cannot be fetched here.

**I-23. `api/rules.gleam` declares nine public types in one file.**
glib's UC-42/UC-43 and NAMING 1.19/1.20: one class per module, and a bag is wrong because it holds **many classes**. glib enforces the extreme case with `no_types_bag.sh`. glibe's `api/rules.gleam` alone declares nine; `api/asset.gleam` three, `api/exchange.gleam` two. Low severity — the file is coherent — but it is the direction glib explicitly moved away from.

---

## 6. Documentation

### 6.1 The port still has not happened — and the target moved again

| | glib | glibe |
|---|---|---|
| `docs/` | `DESIGN.md` 1758, `STATE.md` 1021, `RULINGS.md` 320, `NAMING.md` 312, `QUESTIONS.md` 160, **36 archived rulings** | **no `docs/` directory** |
| naming rules | 23 numbered rules, each with the user's own words and a date | — |
| open questions | 43, each dated and each either resolved or struck | — |
| measured state | "63 passing", "10/10 guards", with the day each number was taken | — |

glibe's markdown is: `README.md` (354), `comparison_analysis.md` (424), `.planning/{BRIEF,ROADMAP,DEEP-DIFF}` (806), six phase documents, and my three review reports. `.planning/DEEP-DIFF-2026-10-02.md §6` lists eleven glib rulings to port and says they *"should become comments or a `docs/RULINGS.md`"* — i.e. the work is specified and none of it landed.

**Since the first publication of this review, glib added ~1,900 lines of documentation**, most of it the user's own words recorded with dates: the four-bar vocabulary (NAMING 1.23), `manual_enter_bar` / `manual_exit_bar` accepted (1.21), the three parts every AI attempt must name (1.22), the corner struck as 倒果为因, the branch-as-a-group-of-leaves passage, and §11 of `STATE.md` — nine subsections of measured work. **None of it has a counterpart in glibe.** The distance on documentation is now larger than it was.

### 6.2 The deep-diff document misrepresents glib in three places

This matters because the document is written as the authority for future porting ("Authority is always the user's rulings in glib/docs/RULINGS.md").

| section | what it says about glib | what glib actually is | when glib changed |
|---|---|---|---|
| §1.1 | glib's leaf stores integers: `YinLeaf(start_idx: Int, …)` | `YinLeaf(start_bar: DataBar, end_bar: Option(DataBar), corner_bar: DataBar)` (`glib/leaf.gleam:31-33`) | `b2ca95d`, 2026-09-29 (+ `Option` 2026-10-03) |
| §1.2 | glib's branch uses `enter_idx` | `YangBranch(start_bar: DataBar, enter_bar: DataBar, end_bar: Option(DataBar), exit_bar: Option(DataBar))` (`glib/branch.gleam:34-41`) | same commit |
| §2.2 | glib computes M as an array mean (`mean_of`) | glib uses the general rolling recurrence with the comment *"No `mean_of` of an array (UC-64)"* (`glib/kdj.gleam:56-72`) | before 2026-10-02 |

All three were false **when the document was written** (2026-10-02 22:19). Its headline conclusion — that bar references are "glibe's biggest improvement over glib" — therefore rests on a glib that no longer exists; glib made the same move first. §1.6 (four vs five SMA rungs) is stale as of this round. The consequence: its "verdict: glibe's M is wrong" led to work that was unnecessary, and glibe's M now matches glib's *current* behaviour anyway (`kdj.gleam:42-61` vs `glib/kdj.gleam:56-72` — both are the same add/subtract recurrence).

**Do not port from `DEEP-DIFF` until those three are corrected.** Port from glib's source and `docs/`.

---

## 7. AI strategy — where each project actually stands

**glibe: nothing, unchanged.** `strategy_signal` (`timeframe.gleam:338-345`) and `runtime_test` (`:349-353`) both return the bar unchanged — re-read at this revision, still true. There is no features record, no corpus, no labels, no model type, no AI module, and no occurrence of `recognis`/`recogniz` anywhere in `src/`.

**glib, at this revision: a measured bench that prints why it has no edge yet.**

| piece | where | state |
|---|---|---|
| The attempt | `ai_s1.gleam` (214 lines) | `Unfitted` — one constructor, so "no fitted parameters" is a compile-time fact |
| The three parts of an attempt | `ai_s1.gleam:19-26` | *where to look* (nobody), *what to look at* (`learn.features`, generated), *whether to act* (fitted) |
| Features | `learn.gleam` (945 lines) | **114**, four groups: bar measurements all `sma_tiny`-anchored; every pairwise relative difference of 13 level series; the growing yin leaf's geometry; ended-branch statistics |
| Learners | `learn.gleam`, `boost.gleam`, `knn.gleam` | logistic regression, AdaBoost over stumps, k-NN (k=15) |
| Both ends | `census --learn` | enter **and** exit, because *"a strategy without an exit is not a strategy"* [user 2026-10-03] |
| Multi-symbol | `--learn SYM1 [SYM2 …]` | rows pooled for one fit, measured per symbol |
| Corpus / labels | `census.gleam` (1500 lines) | `--branches`, `--census`, replay through the public engine — one snapshot per accepted bar, nothing reconstructed |

Two things in there are worth copying as method, and both were found by measuring rather than reading:

- **A metric that was an identity.** `lead_bars mean=0.0 positive=0.0%` was printed as arithmetic, not measurement: it scored only the bars that *are* the enter bar, where `bar.idx` **is** `enter_idx`. Scoring the fired bars restored it — and immediately showed the model was early and wrong on price (`price_edge` median −9,672, positive 3.1%).
- **A gradient stepped the wrong way.** `w ← w + rate · ∇` maximises the loss; at `bias = 0` the fit climbed to `p ≈ 0.994` on every bar and reported `fired 163 of 166` on a 1.2% base rate. Stepped against the gradient: weights 0.02–0.23, threshold 0.1557, `fired 0 of 166`.

**And the honest ending, which is the part to imitate:** *"It is a fit now and it has no out-of-sample edge … nothing above is dressed up as an edge."* The binding constraint is printed — **`births 2, deaths 2`** in 499 daily bars — so the next step is data, not tuning.

For glibe the ordered list is unchanged in shape, but step 1 is now three items and all of them gate:

1. delete the 19 `@test` lines and make `main/0` call the tests, or adopt gleeunit (§2, §3);
2. fix the ingest boundary so an H1 bar closes at all (§4.1) and add a replay harness — without both there is no corpus, and without a corpus there is no AI;
3. take the ruling in I-18 first: `Option` end bars on both structures. It removes the sentinel, the per-bar rewrite and the false size in one move;
4. then the features — **from fields something actually writes** (§4.2), which today excludes 15 of them;
5. port the `Unfitted` trick last: a single-constructor model type, so "no fitted parameters" is a compile-time fact rather than a comment.

---

## 8. Recommended order

**P0 — makes every later claim verifiable**
1. Delete the 19 `@test` lines (`test/glibe_test.gleam`). One-line change; restores compilation.
2. Make `main/0` call the tests, or adopt gleeunit. Until then "tests pass" is not a fact anyone can check. glib runs 63 on the same machine.
3. Remove the 15 unwritten `DataBar` fields, or give each a producer (§4.2). Today they are unverified numbers made of nothing — and glib has deleted ten of them for exactly that reason.

**P1 — resolves a divergence that is now a ruling**
4. Make `end_bar` / `exit_bar` `Option` on the leaf and the branch (I-18). This one change closes I-7, I-9 and I-19.
5. Move the six verdicts off the bar, or compute them where they are decided (I-17).
6. Drop the band floors (I-4) — a user ruling, not a preference.
7. Fix the three off-by-ones with glib: KDJ window includes one bar too many (I-1); σ excludes the bar in hand (I-3); `branch_size` spans `end` instead of `exit` (I-6).
8. Decide D's smoothing explicitly and write the decision down: either delete `kdj_d_period` and use K's alpha like glib, or keep it and record why glib's idib citation does not apply here (I-2).

**P2 — closes remaining gaps**
9. Convert epoch-ms to a real timestamp at the ingest boundary and add glib's `sourcebar_validate` (I-11, §4.1). Without this there is no hourly timeframe at all.
10. Add a `scripts/` directory with at least the two guards whose subject glibe has already touched: compilation, and no minute bar on a trading path (I-22).
11. Collapse the four identical settings blocks (I-13) and add `interval.from_string`/`to_string` (I-12).
12. Update README: five SMAs, no `broadcast_chart`, current field names (I-15, I-16).
13. Remove `DataGenerator` from the supervision tree (§4.3) — one engine, not two.
14. Port glib's rulings into `glibe/docs/` — the four-bar vocabulary, the branch laws, leaf law 3, the storage criterion, the "no `prev_*`" rule, UC-46/UC-47 — **from glib's source and `docs/`**, not from `DEEP-DIFF`, until §6.2's three errors in it are corrected.

---

## 9. Verification appendix

### 9.1 Reproduce the build failure
```
export PATH="/opt/homebrew/bin:$PATH"
cd /Users/jk/gits/hub/tools_ib/glibe && gleam build
# → error: Syntax error  test/glibe_test.gleam:104:2  @test  This is a reserved word
```

### 9.2 Probe copy (no repo files touched)
```
rm -rf /tmp/glibe_probe && mkdir -p /tmp/glibe_probe
cd /Users/jk/gits/hub/tools_ib/glibe
tar cf - --exclude=build --exclude=.git --exclude=apps --exclude=erl_crash.dump . | (cd /tmp/glibe_probe && tar xf -)
cd /tmp/glibe_probe
grep -v "^@test$" test/glibe_test.gleam > /tmp/t && mv /tmp/t test/glibe_test.gleam
gleam build          # now compiles
gleam test           # → Running glibe_test.main   (0 tests)
gleam format --check # → 19 files need formatting
```

### 9.3 Run the tests that `gleam test` misses
```
DIRS=($(find build/dev/erlang -maxdepth 2 -name ebin -type d)); ARGS=()
for d in $DIRS; do ARGS+=(-pa "$d"); done
erl -noshell $ARGS -eval '
  Names = [F || {F,0} <- glibe_test:module_info(exports), F =/= module_info],
  Tests = lists:filter(fun(N) -> lists:suffix("_test", atom_to_list(N)) end, Names),
  Res = [{T, try apply(glibe_test,T,[]) of _ -> pass catch C:E -> {fail,C,E} end} || T <- lists:sort(Tests)],
  lists:foreach(fun({T,R}) -> io:format("~-45s ~p~n",[T,R]) end, Res), halt().'
# → 19/19 pass: asset_class_all_values, asset_class_from_string_{crypto,equity},
#   auction_type_both, bollinger_band_ordering_law, circuit_breaker,
#   default_config_does_not_panic, kdj_flat_market_stays_at_fifty,
#   kdj_rising_market_k_above_fifty, settlement_type_{instant,tplus2},
#   sma_bar_zero_equals_close, sma_full_window_incremental, sma_warmup_true_mean,
#   trading_hours_all_formats, trading_hours_custom, trading_hours_rth,
#   trading_hours_twenty_four_{seven,five}
```

### 9.4 `default_config`
```
erl -noshell $ARGS -eval 'R = try glibe@config:default_config() of _ -> ok catch E:T -> {error,E,T} end, io:format("~p~n",[R]), halt().'
# → ok      (round-2 regression gone)
```

### 9.5 H1 never closes on Binance-shaped input
```
erl -noshell $ARGS -eval '
  Sym = {symbol,"binance_spot_crypto","BTC","BTCUSDT",{asset_ref,"BTC","BTC",crypto},{asset_ref,"USDT","USDT",crypto},[],[],"binance"},
  Bar = fun(D) -> {source_bar,D,100.0,101.0,99.0,100.5,10} end,
  T = glibe@timeframe:new(Sym, h1, crypto),
  {C1,_} = glibe@timeframe:sourcebar_gate(T, Bar("1735704000000")),
  {C2,_} = glibe@timeframe:sourcebar_gate( element(2, glibe@timeframe:sourcebar_gate(T, Bar("1735704000000"))), Bar("1735707600000")),
  io:format("~p ~p~n",[C1,C2]), halt().'
# → none none      (no closing with epoch-ms dates; each further source bar is folded in)
```

### 9.6 glib at this revision (for contrast)
```
export PATH="/opt/homebrew/bin:$PATH"
cd /Users/jk/gits/hub/tools_ib/glib
gleam build                                   # clean
gleam test                                    # 63 passed, no failures
GLEAM=/opt/homebrew/bin/gleam sh scripts/guards.sh --all
# → ok: 10 guard(s) run, all green — the ones with a subject.
#   (without GLEAM set: compiles.sh FAILS — "no gleam at gleam". PATH gap, not a defect.)
```

### 9.7 The `DataBar` field sets, side by side

glib (`src/glib/databar.gleam:159-301`, 40 fields):
`date idx open high low close volume` · `sma_tiny sma_small sma_medium sma_large sma_huge` · `bb_m bb_u3 bb_l3 bb_u2 bb_u1 bb_l1 bb_l2` · `sigma_n sigma_mean sigma_m2` · `k d j m` · `kdj_h kdj_h_idx kdj_l kdj_l_idx` · `yin_leaf_cma yang_leaf_cma` · `signal ai_signals ai_guesses branch_yin branch_yang`

glibe (`src/glibe/databar.gleam:4-64`, 41 fields):
`idx date open high low close volume` · `sma_tiny … sma_huge` · `bb_m bb_u3 bb_l3 bb_u2 bb_u1 bb_l1 bb_l2` · `k d j m` · `bias small_above_tiny cmas_up bars_k_on_d bars_d_on_k` · `yin_leaf_cma yang_leaf_cma inner_yin_leaf_cma inner_yang_leaf_cma inner_inner_yin_leaf_cma inner_inner_yang_leaf_cma` · `kdj_cross_up kdj_bearish_left price_at_lower_band sma_tiny_rising leaf_cmas_rising leaf_cmas_falling` · `signal`

Only in glib (10): `sigma_n sigma_mean sigma_m2`, `kdj_h kdj_h_idx kdj_l kdj_l_idx`, `ai_signals ai_guesses branch_yin branch_yang`.
Only in glibe (11): `bias small_above_tiny cmas_up bars_k_on_d bars_d_on_k`, four `inner_*_cma`, six verdict booleans — **11 fields, none written anywhere** (§4.2).
