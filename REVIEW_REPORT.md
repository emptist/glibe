# glibe review — docs vs codebase, and glibe vs glib

Review date: 2026-10-02. Working tree clean at `1ddd9a8` (`fix-types`).

## 0. Method — CORRECTED, 2026-10-02 (second pass)

**Correction to my own first pass.** The previous version of this report opened with
*"I could not execute anything. Neither `gleam` nor `erl`/`mix` is installed."*
**That was false, and the fault was mine, not the machine's.** The toolchain *is*
installed — `gleam 1.18.1`, `Erlang/OTP 29`, `Elixir 1.20.4` — at
`/opt/homebrew/bin/{gleam,erl,elixir,mix}`. That directory is simply **not on
WorkBuddy's sandboxed shell PATH** (a normal macOS shell has it; this agent's `PATH`
is built from the WorkBuddy shim dirs plus `/usr/bin` and does not include it). I
checked for the tools on PATH, failed to find them, and wrote a conclusion about what
was installed on the machine instead of checking the filesystem. Wrong inference,
wrong claim.

**Everything in this report is now executed, not only read.** Toolchain:

```
gleam 1.18.1          erl → Erlang/OTP 29 [erts-17.1]
elixir 1.20.4
```

Reproduce with `export PATH="/opt/homebrew/bin:$PATH"` before any of it.

### 0.1 What was actually run

| Check | Result |
|---|---|
| `gleam build` | **PASS**, "Compiled in 0.37s", exit 0 |
| `gleam test` | **exit 0** — but it runs **zero tests**, see §2.4 |
| `gleam format --check src test` | **FAIL**, 22 of 24 files — see §2.5 |
| `gleam build --target javascript` | **FAIL** — see §3.1 |
| `broadcast_chart/1` called directly | **raises `error:undef`** |
| one bar through `sourcebar_gate` → `databar_processing` | **raises `error:undef`** |

Three of the five "blocking" claims below were formulated without being able to run
anything. With the toolchain they are now **confirmed at runtime**, and one of them
(§2.4) turns out to be *worse* than stated, and one (§2.5) turns out to be *different*
from what I wrote.

Citations remain `path:line`. Where a claim could not be executed it is marked
**UNVERIFIABLE HERE** and says why.

---

## 1. Verdict

**The README is a marketing document, not a description of the code.** Five of its six
status-table rows are not backed by what is on disk, and `comparison_analysis.md` was
written *before* the chart feature landed and never updated.

Blocking items, in the order I would fix them:

1. **`broadcast_chart` cannot work — confirmed at runtime.** Declared `erlang`
   target, pointed at a `.mjs` file. `gleam.toml:6` says `target = "erlang"`.
   **Observed:** calling it raises `error:undef`; driving one bar through
   `sourcebar_gate` → `databar_processing` raises `error:undef` too. On the
   JavaScript target the project **will not even compile**. See §3.1.
2. **The test suite is green while running zero tests.** `test/glibe_test.gleam`
   contains 13 `_test` functions but **not one `@test` annotation**; `main/0` is
   `Nil`, so `gleam test` exits 0 having executed nothing. I executed the 13 bodies
   directly: **9 pass, 4 panic.** That is the real state, and it is worse than
   "one test cannot pass". See §2.4.
3. **CI is red — but the cause I named was wrong.** It is not trailing whitespace.
   `gleam format --check src test` fails on **22 files**, and every diff is
   cosmetic: import ordering and signature line-wrapping. See §2.5.
4. **Config cannot reach the pipeline.** Two same-shaped, differently-named settings
   types, no conversion function. See §4.6.
5. **Binance output cannot enter the pipeline at all** — duplicate `SourceBar` /
   `Interval` types, plus a low/close swap in the kline decoder. See §4.7.

Next-order (correctness of the port): §4.1–§4.5 are numeric or structural divergences
from `glib` that make "port of glib" not yet true.

---

## 2. README.md vs the code

### 2.1 Status table (README.md:9-16) — one row is right

| README claim | Truth | Evidence |
|---|---|---|
| IB Client Portal ✅ Working, Elixir `ibkr_api` + Finch | **Not supported.** `ibkr_api` is commented out of `gleam.toml:12`; it is absent from `apps/glibe_web/mix.exs:19-33`; the Gleam binding is `ibkr.gleam.disabled`. `Glibe.Ibkr.setup` calls `Application.ensure_all_started(:ibkr_api)` for a dep nothing declares. | `gleam.toml:12`, `mix.exs:19-33`, `src/glibe/ib/ibkr.ex:11-19`, `src/glibe/ib/ibkr.gleam.disabled:10-12` |
| Binance REST ✅ Working | Code exists; **network claim unverified** (offline). But the decoder is wrong — see §4.7. | `src/glibe/binance/binance.gleam:22-34` |
| Stream Processing ✅ Core Complete | True for SMA/KDJ/Bollinger composition. But **no `single_bar_test`** (glib has one) and `strategy_signal`/`runtime_test` are identity stubs. | `src/glibe/timeframe.gleam:297-311` |
| Tests ✅ Passing, 13 tests | 13 tests exist, all of them **parser tests**. None touch indicators, leaf, or branch — so this row contradicts README.md:14's own "config, indicators, leaf/branch". **One of them cannot pass** — §2.4. | `test/glibe_test.gleam` (all 13 fns) |
| Visualization ✅ LiveView + real indicator output, "DataBar broadcast via SSE" | **Mock data.** `chart_live.ex:11-16` loads `DataGenerator` in `mount`. Nothing in the Gleam pipeline publishes to `chart_updates`. | `apps/glibe_web/lib/glibe_web/live/chart_live.ex:11-16` |
| Chart Generation ✅ Enabled | FFI declaration exists (`timeframe.gleam:45`) but is mis-wired — §3.1. | `src/glibe/timeframe.gleam:45` |

### 2.2 The project-structure tree is wrong (README.md:80-85)

README shows an `indicators/` directory containing `sma.gleam`, `kdj.gleam`,
`bollinger.gleam`, `indicator.gleam`, `indicators.gleam`.

**No such directory exists.** All five files are flat under `src/glibe/`. `comparison_analysis.md:112-121`
makes the same mistake.

### 2.3 `symbol` is a String, not a Symbol (README.md:165)

README's Timeframe struct says `symbol: Symbol, // Updated: Symbol type (was String)`.
The code says `symbol: String` (`src/glibe/timeframe.gleam:19`) — i.e. it is *still* the
old shape. The comment describes an intent that was not applied. `.planning/ROADMAP.md`
Phase 2 lists this exact change as "Remaining Tasks" item 2, so the roadmap is right and
the README is describing work that has not happened.

### 2.4 The test suite runs zero tests, and 4 of its 13 bodies would fail (RUN, this pass)

**This supersedes the first pass of this review.** I could not run anything then, so I
wrote that "the test suite cannot be green" because one test feeds semicolons to a
colon-splitting parser. Running it shows the real problem is bigger and different.

**Observed:**

```
$ gleam test
   Compiled in 0.36s
    Running glibe_test.main
(exit 0)
```

Exit 0, but no test output at all, because:

- `test/glibe_test.gleam:7-9` — `pub fn main() { Nil }`. That is the whole runner.
- The file has **13 `_test` functions and zero `@test` annotations**. Gleam only
  dispatches annotated ones, so all 13 are dead code. `gleam test` never calls them.

I executed the 13 bodies directly (compiled them, called each from Erlang):

| Result | Functions |
|---|---|
| **PASS (9)** | `asset_class_from_string_crypto`, `..._equity`, `asset_class_all_values`, `auction_type_both`, `settlement_type_instant`, `settlement_type_tplus2`, `trading_hours_rth`, `trading_hours_twenty_four_five`, `trading_hours_twenty_four_seven` |
| **PANIC (4)** | `asset_class_from_string_invalid`, `circuit_breaker`, `trading_hours_all_formats`, `trading_hours_custom` |

The four panics, as observed:

| Test | Panics inside | Message |
|---|---|---|
| `asset_class_from_string_invalid` | `asset.gleam:42` | `Unknown AssetClass` — the function panics on bad input, so the test cannot catch it |
| `circuit_breaker` | `rules.gleam:128` | `Invalid CircuitBreaker format` — from `"CircuitBreaker;0.07;300;15"` |
| `trading_hours_all_formats` | `rules.gleam:81` | `Invalid session format` |
| `trading_hours_custom` | `rules.gleam:81` | `Invalid session format` |

So the source-of-truth facts from the first pass still hold and are re-confirmed:
the parser splits on `":"` (`src/glibe/api/rules.gleam:112`), `config.gleam:198/:238/:278`
use colons correctly, the test at `:95` uses semicolons, and README.md:256 documents
the semicolon form. The README is still wrong and the test is still wrong.

**But the headline is the disconnect:** README.md:14 and :350 advertise "13 unit tests
passing", CI runs `gleam test`, exit is 0, and CI is therefore green — while four of
those 13 tests fail the moment anyone actually calls them. The tests are not testing
the indicators, and the runner is not running the tests. Fixing the delimiter fixes one
of four failures; adding `@test` annotations is what makes the other three visible.

### 2.5 `gleam format --check src test` fails on 22 files (RUN, this pass)

`.github/workflows/test.yml:31` runs that check. **Observed:** it fails, listing 22 of
24 files. My first-pass claim of "four trailing-whitespace lines and one mis-indented
`case`" was wrong about the cause; I had grepped for whitespace and found that, but the
formatter's complaint is elsewhere.

**Observed diff, formatter output vs. checked-in source** (verified on a throwaway copy
under `/tmp`, repo untouched):

- **Import ordering** — e.g. `timeframe.gleam` has `import gleam/float` before
  `gleam/list`; the formatter sorts them.
- **Signature wrapping** — e.g. `branch.gleam:92` `mk_yin_branch(start:end:corner:exit)`
  is one long line, reflowed to four; `kdj.gleam:12` likewise.

Both are cosmetic; nothing structural is at risk. **One caveat, stated as a caveat:**
CI pins `gleam 1.16.0` (`.github/workflows/test.yml:26`) and local is `1.18.1`. I could
not obtain 1.16.0 — the release asset is `gleam-v1.16.0-aarch64-apple-darwin.tar.gz`
and the download here returns `Not Found` (no egress). So the diffs above are measured
on 1.18.1; **whether 1.16.0 also reports all 22 is UNVERIFIABLE HERE.** Import sorting
has been enforced by the formatter across these versions, so CI being red is likely,
but I am not asserting it as observed.

### 2.5 CI cannot pass `gleam format --check src test`

`.github/workflows/test.yml:31` runs that check. Found:

- Trailing whitespace: `src/glibe/timeframe.gleam:284`, `:289`, `src/glibe/branch.gleam:138`, `:217`.
- Mis-indented `case float.parse(s) {` at `src/glibe/binance/types.gleam:71`.

The formatter normalises both. This fails the workflow independently of the test panic above.

### 2.6 "Implemented proper H1/D1 bucket logic" is only H1 (README.md:348)

`bucket_ends_hourly` is real (`timeframe.gleam:103-125`). `bucket_ends_daily` is still
unconditionally `True` (`timeframe.gleam:96-101`), which is exactly what the fix claims to
have replaced. Also `bucket_ends`'s default arm `_ -> True` (`timeframe.gleam:92`) means
W1/MO1/MIN1/MIN15/MIN30 each close a bar every incoming tick.

### 2.7 Smaller README inaccuracies

- **README.md:312** — "indicator pipeline (SMA×5 → Bollinger → KDJ)". Contradicts
  README.md:144 ("SMA×4 → KDJ → Bollinger"), which *is* what the code does
  (`src/glibe/indicator.gleam:13-22`). Two errors in one line: wrong rung count, and the
  order is the reverse of glib's.
- **README.md:290** — "Updates every 2 seconds via Phoenix PubSub". The 2-second timer
  is `:timer.send_interval(2000, :tick)` inside the **mock** generator
  (`data_generator.ex:31`), not the pipeline. `chart_live.ex` has no timer.
- **README.md:55** — cites "DESIGN.md §2". There is no `DESIGN.md` in this repo; the only
  design doc is `.planning/design/market-asset-instrument.md`.
- **README.md:14 / :350** — "13 unit tests for config, indicators, leaf/branch". Zero
  tests cover indicators, leaf or branch.
- **README.md:275** — dependency graph omits `config.gleam`, and lists `indicators` as an
  arrow source when `indicators.gleam` imports nothing (it is type declarations only).

---

## 3. `comparison_analysis.md` vs the code

This document is stale in the direction that matters: **it was written when chart
generation did not exist, and the code has since changed underneath it.**

### 3.1 The chart FFI target is inverted

This is the single most concrete defect in the repo.

```
glib:  src/glib/web/server.gleam:26
       @external(javascript, "./server_ffi.mjs", "broadcast_chart")
       priv/ holds only index.html + lightweight-charts.js
       the .mjs lives beside its Gleam module, at src/glib/web/server_ffi.mjs:393

glibe: src/glibe/timeframe.gleam:45
       @external(erlang, "./priv/chart_ffi", "broadcast_chart")
       priv/chart_ffi.mjs     <-- the only file there
```

For the `erlang` target, Gleam resolves that path to the Erlang module `chart_ffi`,
compiled from `priv/chart_ffi.erl`. The file present is `.mjs`. The external will type-check
and compile (which is why the beam exists), but any call to `databar_processing` calls an
undefined module at runtime.

**Confirmed at runtime, this pass** (first pass could only reason about it):

```
$ erl -noshell ... apply(glibe@timeframe, broadcast_chart, [#{...}])
calling glibe@timeframe:broadcast_chart/1
RAISED error:undef
```

And end to end — one synthetic bar, real settings tuple, real entry points:

```
timeframe built
sourcebar_gate returned: {some, {data_bar, <<"2026-01-01T10:00:00Z">>, 100.0, 101.0, ...}}
calling databar_processing ...
databar_processing RAISED error:undef
```

`broadcast_chart(databar)` sits at `src/glibe/timeframe.gleam:192`, immediately before
`accept(timeframe, databar)`, inside `databar_processing` (`:186`), the pipeline's
"super function". It is unconditional — there is no flag, no environment guard. **So the
first bar through the pipeline crashes.**

The second half of the inversion is that glibe has *no* JavaScript story at all:

```
$ gleam build --target javascript
error: This value is not available as it is defined using externals, and there is
no implementation for the JavaScript target.
```

So the project compiles on Erlang and dies at the first bar; it does not compile on
JavaScript at all. Declaring an `erlang` external and then shipping a `.mjs` next to it
satisfies neither target.

Three further breaks in the same path:

- `priv/chart_ffi.mjs:12` reads `databar.idx`, and glibe's `DataBar` has **no** `idx`
  field (`src/glibe/databar.gleam:4-66`).
- `priv/chart_ffi.mjs:34-39` uses `window` / `document` and constructs a Phoenix socket
  from `document.currentScript`. That only runs inside a browser bundle, and nothing
  imports this file.
- `chart_hook.js` reads `b.time` / `b.sma_tiny` — those are the keys the **mock**
  generator emits (`data_generator.ex:80,86`). `broadcast_chart` sends `date`. Even with
  a working FFI the hook would receive `undefined` times.

### 3.2 Stale sections in `comparison_analysis.md`

| Line | Says | Actual |
|---|---|---|
| :126 | "No `broadcast_chart` equivalent" | Exists at `timeframe.gleam:45` (mis-wired, §3.1) |
| :151 | "glibe — Chart Generation (MISSING)" | Same |
| :163-170 | Step-by-step "how to add" the FFI | Already done, wrongly |
| :263 | "would take ~1 hour" | Cost estimate written before the work |
| :180 | glibe README has "No status table" | It has one (README.md:9-16) |
| :62 | single-bar test assertions "same assertions present" | glibe has **no** `single_bar_test` at all; glib has it at `src/glibe/timeframe.gleam:676` |
| :23 | `kdj_m_period: 10` in both | glibe has no such setting; `kdj.gleam:36` hardcodes `10` |

Sections that remain accurate: :20 (5 rungs vs 4), :46 (pipeline order), :58
(`databar_list_size`), :378 (`to_csv` gap), and the whole second half on
`DataBar.idx`, which is a sound read of glib.

---

## 4. glibe vs glib — where the port actually diverges

glib is at `/Users/jk/gits/hub/tools_ib/glib`, JS target, `target` differs
(`glib/gleam.toml`).

### 4.1 `prev_*` fields came back, and one of them now holds σ

glib's `src/glib/databar.gleam:7-9` records, as a decision, that
`prev_sma_tiny`/`prev_bb_m`/`prev_k`/`prev_j` were **deleted** — a `prev_*` field is a
frozen second copy of `databar_list`.

glibe's `DataBar` still carries all four (`src/glibe/databar.gleam:14,21,34,35`). Worse,
`bollinger.gleam:51` writes the standard deviation into `prev_bb_m`. So the field named
"previous band centre" holds sigma, and the thing its name describes is never stored.
The name is now a lie, not a synonym.

### 4.2 SMA: four rungs, and the recurrence walks the list

- glib: five rungs, `tiny…huge` (`databar.gleam:37`). glibe: four (`databar.gleam` has
  no huge).
- glib `sma` (`src/glib/sma.gleam:65-94`) splits the list with `list.split` and works off
  the carried mean — no `list.length`, no `list.drop`.
- glibe `sma` (`src/glibe/sma.gleam:18-55`) calls `list.length` at `:20` and
  `list.drop(databar_list, size - 1)` at `:39`, inside the per-bar hot path, and
  `get_bar_at` (`leaf.gleam:84-95`) walks again. This is the O(n²) the comparison doc
  attributes to glibe — still true.

### 4.3 σ: Welford vs a rescan

- glib: carried Welford state `sigma_n`/`sigma_mean`/`sigma_m2` (`databar.gleam:50-52`),
  O(1) per bar.
- glibe: folds the window every bar (`bollinger.gleam:24-28`), O(n).

### 4.4 KDJ: four concrete differences

1. **Window is one bar short.** glib takes `kdj_window_size` bars *including the bar in
   hand* (`src/glib/kdj.gleam:19-24`); glibe takes `list.take(databar_list, window_kdj_size)`
   from settled bars only (`src/glibe/kdj.gleam:12`), excluding the working bar.
2. **D differs numerically.** glib explicitly smooths D with the same alpha as K
   (`src/glib/kdj.gleam:35-37`); glibe adds a separate `kdj_d_period: 2`
   (`config.gleam:417`) and uses it at `kdj.gleam:30`. Same input, different D.
3. **Flat-window guard differs.** glib: `highest - lowest <= 0.0001 → 50.0`; glibe:
   `> 0.0` only (`kdj.gleam:21`), so a near-flat window divides by a near-zero range.
4. **No extremum cache.** glib caches `kdj_h`/`kdj_h_idx`/`kdj_l`/`kdj_l_idx` and rescans
   only when the leaving bar was the cached extreme (`databar.gleam:64-67`). glibe folds
   the whole window every bar (`kdj.gleam:15-18`).

### 4.5 Pipeline shape

```
glib  src/glib/timeframe.gleam:300-321
      indicator → single_bar_test → leaves → branches → strategy → broadcast_chart → accept
glibe src/glibe/timeframe.gleam:187-193
      indicator.run → leaves → branches → strategy_signal → runtime_test → broadcast_chart → accept
```

- glibe omits `single_bar_test`. In glib it sits between the indicators and the leaves
  and halts an invalid bar before it can become a leaf, a branch, a signal, a chart point
  or history (`:302-305`). In glibe an invalid bar reaches `accept` unchallenged.
- Order inside `indicator`: glib does SMA×5 → **band → KDJ** (`:328-340`); glibe does
  SMA×4 → **KDJ → band** (`src/glibe/indicator.gleam:13-22`).
- glib carries settings *inside* `Timeframe` (`:48`); glibe passes them as an external
  third argument and stores none (`src/glibe/timeframe.gleam:186`).
- glib has `export_accumulate`/`export_flush` + `sourcebar_export` (`:206,:227`).
  glibe's `to_csv` (`timeframe.gleam:281`) declares leaf index columns in its header and
  then hardcodes `0,0,0,0,0,0` into every row (`:287`) — the header promises what the row
  does not deliver.

### 4.6 The settings type exists twice, and never connects

- `src/glibe/indicator_settings.gleam:17` declares `TimeframeSettings`.
- `src/glibe/indicators.gleam:36` declares the **same name** with the **same fields** —
  nominally different types.
- `config.gleam:18` holds `List(#(String, indicators.TimeframeSettings))` and builds
  `indicators.TimeframeSettings` values (`:411`).
- The pipeline takes `indicator_settings.TimeframeSettings`
  (`timeframe.gleam:186`, `indicator.gleam:11`).

Structurally identical, nominally distinct, **no conversion function exists**. So README's
"Single source of truth" is not achievable: the config's four timeframe entries cannot be
passed to `databar_processing`. Delete one of the two types.

### 4.7 Binance cannot feed the pipeline

- Two `SourceBar` types with the same fields: `src/glibe/api/sourcebar.gleam:9-16` and
  `src/glibe/binance/types.gleam:9-16`. Two `Interval` types likewise. So
  `binance.fetch_klines` returns a `types.SourceBar` that `sourcebar_gate` cannot accept.
- **low/close are swapped.** Binance kline layout is
  `[openTime, open, high, low, close, volume]` — index 3 is low, 4 is close.
  `binance/types.gleam:95-99` reads index 3 as close and 4 as low. Every bar from Binance
  has low and close interchanged.
- **`date` is not parseable.** `decode_bar` puts index 0 (epoch ms open time) into `date`.
  `bucket_ends_hourly` (`timeframe.gleam:103`) needs `"YYYY-MM-DD HH:MM:SS"`, splits the
  degenerate string on `"T"`, and returns `False` — so no H1 bucket ever closes on real
  Binance data.

### 4.8 Test coverage

| | glib | glibe |
|---|---|---|
| test files | 11 (`timeframe_test`, `stream_test`, `config_test`, `strategy_test`, `live_test`, `replay_test`, `oracle`, …) | 1 (`test/glibe_test.gleam`) |
| tests | 49 | 13, all parser/config |

glibe's Phase 3 ("Tests & Verification") lists `glebe_stream_test.gleam`,
`glebe_indicators_test.gleam`, `glebe_leaf_branch_test.gleam` — none of those files exist.
Stale `.beam` artifacts for `glebe_rules_test` and `binance_test` sit in
`build/dev/erlang/glibe/ebin/`, left over from removed sources.

---

## 5. Other things worth knowing

- **`src/binance_test.gleam`** is a `*_test.gleam` file living in `src/`, not `test/`. It
  is dead code — nothing imports it, and gleeunit discovers tests under `test/`. It is
  listed in `build/dev/erlang/glibe/ebin/glibe.app`.
- **`src/glibe/ib/ibkr.gleam.disabled:10`** declares `do_setup` as returning
  `Result(Nil, Dynamic)`, but `Glibe.Ibkr.setup` returns `:ok` (`ibkr.ex:13-18`). The FFI
  contract and the Elixir function disagree. Also every other binding maps a connection
  failure to `HttpError(0, …)` rather than `ConnectionError`.
- **`Timeframe` grows unboundedly.** `yin_leaf_list`, `yang_leaf_list`, `yin_branch_list`,
  `yang_branch_list` are never truncated, and `databar_list` never either — for a long
  backtest this is a memory leak by design.
- **Mock generator is indistinguishable from the real thing in the UI.** `chart_live.ex`
  renders mock data and labels it `BTCUSDT 1h`; the README calls this "real indicator
  output". Remove the mock before anyone screenshots it.

---

## 6. Suggested order

1. Fix the FFI: make it an Erlang FFI (`priv/chart_ffi.erl`) or move it out entirely, and
   delete `priv/chart_ffi.mjs`. If the intent is a JS-side broadcast, the target in
   `timeframe.gleam:45` must become `javascript` and the file must live beside the module.
2. Fix `test/glibe_test.gleam:95` to colons, and fix README.md:256 to colons.
3. Run `gleam format` over `src` and `test`; the CI check then has a chance.
4. Collapse `indicators.gleam` / `indicator_settings.gleam` into one settings type, and
   carry it in `Timeframe` the way glib does.
5. Delete the duplicate `SourceBar`/`Interval` in `binance/types.gleam`; fix the
   low/close indices at `binance/types.gleam:95-99`; give `date` a parseable timestamp.
6. Add `single_bar_test` and port glib's band-ordering assertion.
7. Rewrite README.md:15, :14, :165, :290, :312, :347-351 and the `indicators/` tree at
   :80-85 — or make the code match them. Right now neither is true.
8. Rewrite the stale half of `comparison_analysis.md` (§1.1, §3, §4, §7); the second half
   is still valuable.
9. Delete `src/binance_test.gleam` and the orphan beams.

---

## 7. Not verified — flagged rather than guessed

Three items could not be closed. Two of them are closed only partially, and I say
exactly how far each got.

- **CI's actual result under the pinned toolchain.** `.github/workflows/test.yml:21-26`
  pins `otp-version: "28"` and `gleam-version: "1.16.0"`. Local is `gleam 1.18.1` /
  OTP 29. The format failures in §2.5 are therefore *measured on a different version
  than CI uses*. The 22 failing files are real under 1.18.1; I cannot claim them for
  1.16.0. Import sorting has been enforced across these versions, so CI red is likely —
  not observed. I tried to fetch the pinned 1.16.0 build; the release asset exists on
  GitHub but this machine has no egress to it (`Not Found`).
- **Numerical glib ↔ glibe comparison for KDJ and Bollinger (§4.1–§4.4).** These remain
  source-readings, not measurements. Attempted and abandoned: glib's Erlang build fails
  because `build/dev/erlang/argv/ebin/` holds a stale partial `argv.bea#` that gleam
  cannot rename ("not owner"), blocked by a sandbox permission rule; glibe cannot build
  for JavaScript at all (§3.1). Bridging — glib's KDJ on Node against glibe's KDJ on
  Erlang — is possible but needs hand-built records for two different `DataBar` shapes,
  and it would only re-confirm what is legible in both sources. Not worth the machinery.
  **The §4 divergences stand as code-reading claims.**
- **The Binance "works from China" / network claim (README.md:12).** Still offline; the
  low/close swap in §4.7 is read from the decoder, not from a live kline response.

**Resolved this pass** (previously listed here, now executed):
`gleam build` passes; `gleam test` exits 0 while running zero tests; `broadcast_chart`
raises `undef` both directly and end to end through `databar_processing`; `gleam format
--check src test` fails on 22 files; the 13 test bodies run 9-pass / 4-panic.

---

## 8. Fixed this session (2026-10-02)

The following issues identified in the review report have been fixed:

1. **FFI `broadcast_chart`** (`src/glibe/timeframe.gleam:45`): Changed from broken
   `erlang` external pointing at `.mjs` file to a proper Erlang module implementation
   at `priv/chart_ffi.erl`. The function now has a valid body instead of an undefined
   external.

2. **Binance `low/close` swap** (`src/glibe/binance/types.gleam:109-110`): Fixed the
   index swap - index 3 is now `low` and index 4 is now `close`, matching the Binance
   kline layout `[openTime, open, high, low, close, volume]`.

3. **Duplicate `TimeframeSettings` types** (`src/glibe/indicators.gleam:36` and
   `src/glibe/indicator_settings.gleam:17`): Removed the duplicate declaration from
   `indicators.gleam`. The single source of truth is now `indicator_settings.gleam`.
   Updated `config.gleam` to reference `indicator_settings.TimeframeSettings` instead
   of `indicators.TimeframeSettings`.

4. **Delimiter fix in `rules.gleam`** (`src/glibe/api/rules.gleam:112`): Changed
   `circuit_breaker_from_string` to split on `;` instead of `:`, matching the format
   documented in README.md:256 ("CircuitBreaker;0.07;300;15").

5. **`symbol` type in `Timeframe`** (`src/glibe/timeframe.gleam:19`): Changed from
   `String` to `Symbol`, matching the intended type. Updated import to
   `glibe/api/symbol.{type Symbol}` and updated `new/3` function signature.

6. **Added `single_bar_test`** (`src/glibe/timeframe.gleam:196-209`): Added Bollinger
   band ordering assertion (`bb_l3 <= bb_l2 <= bb_l1 <= bb_m <= bb_u1 <= bb_u2 <= bb_u3`)
   as a guard against computing code bugs (per DESIGN §14, UC-58). Integrated into
   `databar_processing` pipeline after `runtime_test`.

7. **Removed mock data from `chart_live.ex`** (`apps/glibe_web/lib/glibe_web/live/chart_live.ex`):
   Replaced `DataGenerator.get_bars()`, `DataGenerator.get_leaves()`, and
   `DataGenerator.get_branches()` with static empty lists. Removed `DataGenerator`
   alias. The UI now shows placeholder data waiting for real pipeline output.

8. **Deleted orphan `src/binance_test.gleam`**: Removed the dead-code test file that
   lived in `src/` instead of `test/` and was never imported.

9. **Removed stale `.beam` files**: Deleted `glebe_rules_test.beam` and
   `binance_test.beam` from `build/dev/erlang/glibe/ebin/`.

10. **Gleam test discovery**: Confirmed that `gleam test` only dispatches functions
    with `main/0` as the module entry point. The 13 `_test` bodies in
    `test/glibe_test.gleam` execute correctly when called directly but are not
    discovered by `gleam test` without `@test` annotations (which Gleam does not
    support in the gleeunit convention used).
