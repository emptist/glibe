# REVIEW ROUND 5 — 2026-11-07

**Measured on:** Gleam **1.19.2**, Erlang/OTP **29**, `/opt/homebrew/bin`.
Both repos read as they stand *today*; nothing here is carried over from an
earlier review without re-measuring. Earlier rounds were written against a tree
that had never compiled (Round 4 fixed that); this round starts from a green
tree and asks the larger question: **what is glibe for, now that glib moved?**

---

## 0. What was read

- `glibe`: all 23 `src/glibe/*.gleam`, `test/glibe_test.gleam`, `gleam.toml`,
  `docs/`, `.planning/`, `scripts/`, `README.md`, `.github/workflows/test.yml`,
  `git log` and the four catch-up commits.
- `glib`: `gleam.toml`, `README.md`, `docs/` (DESIGN 207KB, RULINGS 295KB,
  STATE 130KB, SYSTEM_MODEL 94KB, NAMING 58KB, QUESTIONS), `.planning/`
  (ROADMAP 110KB, 58 phase dirs, HANDOFFs), `src/` (39 `.gleam`, 14 `.mjs`),
  `test/` (24 files), `scripts/`, and the untracked phase 56/59 plans.
- **The two Gleam references the owner named** — read before any claim about
  the language was made. See §3.

---

## 1. The headline: **stop waiting on glib**

The owner's words: *"tons of features designed, explained to AI and required
by user have never become changes in codebase of glib yet, this make the
waiting in glibe an endless waste of time."* [2026-11-07]

Measured, that is exactly right — and worse than "slow":

| What glibe is waiting for | What glib's `src/` actually holds today |
|---|---|
| The AI strategy (`ai_s1`, `learn`, `boost`, `knn`, `census --learn`) | **Zero.** The owner ordered *"delete them ALL"* (`a99e615`). `ai_s1_enter_bar`, `AiSignal`, `Unfitted` all grep to 0. glibe's `QUESTIONS.md` Q7 says glib "is building it now" — that is stale and false. |
| `Account` balances / positions | Empty shell: `pub type Account { Account }`. |
| `Desk` / `Broker` / `APIProvider` / `Asset` | `Desk`, `Broker` exist as keyless shells with **zero production callers**; `APIProvider` / `Asset` are **comments only**, no type. |
| Price checker wired into a manual path | `price_checker.gleam` exists, **unwired**, only its own test calls it. |
| Erlang main target | `gleam.toml:3` is still `target = "javascript"`; 14 handwritten `.mjs`, 27 `@external(javascript, …)`, **0** `@external(erlang, …)`. Phase 56 is an *untracked plan*. |
| inner / mini leaves | `databar.gleam:72` says "The four `inner_*` are gone"; `leaf.gleam:153` says "ready for the nested ones when the design adds them". |

**The wait is not a queue; it is a wait for work nobody started.** glib's
movement since October is largely in prose and plans (docs grew to ~800KB,
58 phase directories) while `src/` still holds the shells above. glibe is
smaller, green, and pure Erlang. **glibe is the future** — so the direction
reverses: glibe adopts the *owner's words* and the *good code* from glib, and
stops treating glib's unbuilt roadmap as a dependency.

Two boundary corrections, so the reversal is not overstated:
1. Some absences in glib are **obedience, not debt** — the owner's law 14
   (*"不要写代码，只写文档"*, 2026-10-18) forbids building the trading layer
   before `Broker`/`Account` exist, and the AI layer was deleted on his order.
   Those must not be reported as "missing" or ported into glibe.
2. glib's `src/` does hold genuinely good work (§7). Take the code, not the
   prose.

---

## 2. Authority: **whose words are whose**

`glib/docs/` is mostly **hy4's AI prose**, not the owner's record. Its own
`reference/REVIEW-BY-STEP-5-PREVIEW-2026-10-14.md:10` says hy4 wrote most of
`src/`, most of `docs/` and all 35 daily logs. The 2026-11-05 cleanup
(`35fc648`, `32b7f94`, `67818e4`, `da6b946`) removed hy4-invented vocabulary.

| Owner's word | hy4 invention — **do not reintroduce** |
|---|---|
| `sourcebar_gate` (the **only** real gate) | generic "gate" everywhere |
| **price checker** | "price gate" |
| **risk manager** | "risk gate" |
| five SMA windows | the "**ladder**" / "**Rung**" metaphor |

**A miss found here:** glibe's `README.md:78,274` still says *"5 rungs"*, and
commit `4c2e280` is titled *"fifth rung"*. That framing was purged in glib on
2026-11-05. It is removed from glibe's README in this round.

**Owner quotes adopted verbatim into glibe this round** (full list in
`DEVELOPER_GUIDE.md`):

| Date | Verbatim | Source |
|---|---|---|
| 2026-11-07 | *"BEAM is great. Let's build our success on it!"* | this session |
| 2026-11-07 | *"No handwritten erlangs or even worse JS source files, keep the system clean and beautiful!"* | this session |
| 2026-11-07 | *"Use types everytime a type is needed in nature, let gleam make your thinking correct and coding reliable!"* | this session |
| 2026-11-01 | *"target erlang 无需手写任何erlang代码，无需ffi，ffi是JS专属的"*; *"如果手写就说明你错了"* | glib `RULINGS.md` §1.28, `:2066`, `:2070-2072` |
| 2026-10-14 | *"就是说当下轨小于等于0时，给他一个人为的极小的正数"*; *"修正步骤应该在插值之前完成"* | glib `RULINGS.md` §1.13 `:496`, §1.14 `:525` |
| 2026-10-12 | *"Gleam is a typed language, don't you know?"* | glib `RULINGS.md` §1.11 `:265` |
| 2026-11-03 | *"记住类型的事情不要偷懒，必须用type解决"* | glib `.planning/HANDOFF-2026-11-03.md:153-160` |

---

## 3. The two Gleam references — what they actually say

**Tour (`https://tour.gleam.run/everything/`) — authoritative.**

1. **Import syntax, exact:** `import gleam/string_tree.{type StringTree}` for a
   type only; `import gleam/option.{type Option, None, Some}` for a type plus
   constructors. **There is no `Type(..)` import form in Gleam.**
   → **Correction to my own Round-4 statement.** I wrote that "Gleam 1.18.1
   rejects the `(..)` constructor-import form", implying a version change.
   The truth is version-independent: `(..)` was never Gleam syntax; the
   correct form lists constructor names. Round 4's chosen fix (type-only
   import + qualified `indicator_settings.SmaForBbmTiny`) is valid; so would
   `import glibe/indicator_settings.{type SmaForBbm, type TimeframeSettings,
   SmaForBbmTiny, …}` have been.
2. **`@external` fallback — the mechanism that kills handwritten Erlang.**
   One function may carry *both* `@external(erlang, "lists", "reverse")` and a
   **Gleam body**. If the current target has an external, it wins; otherwise
   the Gleam body runs. Therefore glib's phase-56 Task 3, which proposes "a
   small `*_ffi.erl` or an inline erlang string" for BEAM externals, is
   **unnecessary**: give those functions a Gleam fallback and declare the
   IB-only ones JS-only. Zero `.erl` written by hand.
3. **`@external` is for calling existing BEAM modules** (`"calendar"`,
   `"lists"`), not for writing a foreign module of your own. That is the
   precise reading of the owner's "无需ffi".
4. Warnings the compiler emits: unused variables, `@deprecated`, `todo`,
   redundant `case` clauses. Exhaustiveness checking is the mechanism that
   makes a closed custom type worth having.

**Kodikra guide (`https://www.kodikra.com/2026/03/the-complete-gleam-guide-from-zero-to.html`) — a roadmap, not a spec.**
Read in full (481KB HTML → article text). It is a **chapter index** for a
learning curriculum (Parts I–VII), generic "v1.x", with no 1.19-specific
content. Valuable for the BEAM/OTP mental model ("let it crash", supervisors,
lightweight processes) and for the FAQ statement that **Erlang is the primary
target and JavaScript an additional one**. Its compilation-flow diagram
`.gleam → generated .erl → erlc → .beam` describes the old pipeline and
contradicts the owner's §1.28.

**Measured locally on 1.19.2 (corrected 2026-11-07, §11):** the official
v1.19.0 note (2026-10-05) reads *"Previously Gleam generated Erlang source
code, now it generates Erlang abstract forms."* A clean `gleam new` probe on
1.19.2 produces one `.abstr` per module plus `.beam`, and **no `.erl` per
module**. It still writes exactly one `@@main.erl` — the `gleam run` runner
stub; deleting it and rebuilding makes 1.19.2 write it again, so it is
**current, not a leftover from a former compiler**. Round 5's phrase "module
code goes straight to `.beam`" was wrong: the path is `.gleam → .abstr`
(Erlang abstract forms) → the Erlang compiler's back half → `.beam`. Other
`.erl` under `build/` ship with Hex dependencies (handwritten package FFI, or
`compile-package` output for rebar3/mix consumers). **Conclusion unchanged and
now better grounded:** no Erlang source is written, generated or read by a
human in this project; `src/` is Gleam only.

---

## 4. State of the two trees, measured

| axis | glibe | glib |
|---|---|---|
| branch | `fix-types`, clean before this round | `retry-by-space-bunny-on-modules-cleanup`, **17 modified + 2 untracked dirs** |
| `gleam.toml` target | **`erlang`** (pure) | **`javascript`** (dual-target only *planned*, phase 56 untracked) |
| handwritten foreign source in `src/` | **0 compiled** after this round (2 `.disabled` records) | **14 `.mjs`**, 0 `.erl` |
| `src` | 23 `.gleam` | 39 `.gleam` |
| tests | **26 pass, 0 fail** | 171 recorded (`c021030`), 24 test files |
| build on 1.19.2 | **exit 0, 0 errors** | not re-measured (JS target, out of scope) |
| docs | 7 small files, ~30KB | 6 main docs ~800KB + 52 reference + 40 archive + 58 phase dirs |
| CI | pinned 1.19.2 / OTP 29 (was 1.16.0 / OTP 28) | — |

**First 1.19.2 build of glibe emitted 16 warnings**: 11 × undefined
`IbkrApi.ClientPortal.*`, 1 redundant clause — all from the orphan
`src/glibe/ib/ibkr.ex` — plus 4 detached doc comments inside the
`gleam_erlang` dependency. Retiring the orphan (§6.6) removed our 12; the 4
dependency warnings may reappear on a clean rebuild and are not our code.

---

## 5. The catch-up commits — what they imported

Four commits (October 2026) tried to make glibe match glib *as glib was then*.
They are the "latest several commits" the owner flagged.

| commit | what it did | mistake imported / status today |
|---|---|---|
| `ddf8714` branch: `corner_bar→enter_bar`, list swap, `prev_bb_m` | copied glib's phase-37 branch work | naming now matches the owner's four words. No live defect found. |
| `b0f5f33` KDJ: true mean M, RSV **9→7**, `kdj_m_period` | copied glib's idib-sourced `kdjPeriod = 7` | **value is right** (idib `Types.idr:178`). It also carried `kdj_d_period`, a dead setting glib still declares and never reads — removed in Round 4. |
| `e7f2834` remove `prev_*`, KDJ reads `databar_list` | copied glib's 2026-09 cleanup | correct. |
| `4c2e280` add `sma_huge` (504), "**fifth rung** — matches glib's five SMAs" | copied glib's five SMA windows | the **window is right**; the *word* "rung" is hy4's metaphor, purged in glib on 2026-11-05 and still present in glibe's README. Fixed here. |

**The deeper import** is not in those four commits but in what they froze:
glibe's Bollinger band still used the **pre-47-07 seib form** — compute six
lines by direct subtraction, then clamp three lower lines separately with
`0.001/0.0001/0.00001`. glib's owner ruled that form wrong on 2026-10-14
(§1.14) and glib **fixed it on 2026-10-18**; glibe kept the old one. Round 4
then replaced the three magic numbers with `0.0` — still wrong, and it
collapses the staff onto zero. **That is the concrete implementation mistake
the owner meant, and glib has since corrected it.** See §6.1.

Also imported from old glib and still present until this round:
`window_kdj_size` (glib renamed it `kdj_window_size` on 2026-09-23), and the
duplicate `SmaSeries` type. See §6.3 / §6.4.

---

## 6. Findings in glibe, and what landed

### 6.1 **The lower-band floor contradicts the owner's ruling** — fixed
`QUESTIONS.md` Q3 claimed *"The user's ruling is no floor"*. It is not. The
owner ruled (2026-10-14, settled 2026-11-02): **one artificially tiny
positive number, a fraction of `bb_m` (`1e-6`), applied to the lower edge
BEFORE interpolation.** glib `RULINGS.md §1.13/:496`, `§1.14/:525`, and
`src/glib/bollinger.gleam:199-225`. Three floors can disagree — glib measured
`bb_l3 = 0.00001 > bb_l2 = 0.0000047` on real data.
**Landed:** `src/glibe/bollinger.gleam` now computes the classic edges, floors
the single lower edge, then interpolates the four inner lines as convex
combinations. `band_floor_ratio = 0.000001`. New test
`bollinger_one_tiny_positive_floor_before_interpolation_test` proves the three
lower lines stay **positive, distinct and ordered** when the raw edge is
negative — the old `0.0` clamp fails it.

### 6.2 **The signal is a String, where a type is needed in nature** — fixed
`DataBar.signal: String` with `"buy" / "sell" / ""`; `manual_signal` returned
`String`. The owner's §1.11: *"Gleam is a typed language, don't you know?"*
**Landed:** new `src/glibe/trading/signal.gleam` with
`pub type Signal { Buy Sell NoSignal }` and a `to_string` wire codec used only
by `export/csv.gleam`. One type, one module, exactly three constructors — no
dead fourth case. `signal_is_a_closed_type_test` pins it.

### 6.3 **Two `SmaSeries` types, one with the wrong cardinality** — fixed
`indicator_settings.gleam` declared `SmaSeries` with **4** constructors;
`sma.gleam` declared it with **5** (including `SmaSeriesHuge`) and is the one
actually used. A closed set duplicated, with one copy lying about its size.
**Landed:** the dead copy is gone; one set, one home.

### 6.4 **`window_kdj_size`** — fixed
Renamed to `kdj_window_size` in `indicator_settings.gleam`, `config.gleam`
(4 sites), `kdj.gleam`, `test/`. Matches glib's settled `kdj_` prefix.

### 6.5 **KDJ cached extreme assumes consecutive `idx`** — fixed
`rsv_extrema` used `leaving_idx = working.idx - w`. A holiday or a dropped bar
makes `idx` non-consecutive; that arithmetic then names a bar that never
existed and the stale extreme is carried forever. Round 4 flagged this as a
guard worth adding; it is now fixed.
**Landed:** the leaving bar is found by **position** (`list.drop(list, w-1)
|> list.first`) and its real `idx` compared to the cached extreme.
`kdj_gapped_indices_retire_the_cached_extreme_test` uses a feed where
`working.idx - w = 101` but the leaving bar's `idx = 10`; the old code keeps
the stale 200.0 high, the new one returns 101.0.

### 6.6 **Handwritten foreign source in `src/`** — fixed
`src/glibe/ib/ibkr.ex` — a 12-function Elixir wrapper, **zero callers**, whose
`ibkr_api` dependency is commented out of `gleam.toml` and absent from
`mix.exs`; its Gleam twin is `ibkr.gleam.disabled`. It caused 12 of the 16
build warnings and is exactly what *"No handwritten erlangs"* forbids.
**Landed:** retired (recoverable from git). The FFI contract is preserved as a
design record in `ibkr.gleam.disabled` and the phase-01 plans — satisfying
the owner's *"when facing with some code which seems to be correct but not
used … at least log it in docs"*.

### 6.7 **A principle without a mechanism** — fixed
Added `scripts/no_foreign_source.sh` (fails on `.erl/.hrl/.ex/.exs/.mjs/.js/.ts`
under `src/`), registered in `guards.sh --all` and in CI. CI pin moved
**1.16.0 → 1.19.2**, OTP **28 → 29**, and `guards.sh` now runs in CI.

### 6.8 **Stale documents** — corrected
`STATE.md` (said 1.18.1 / 23 tests / 0 warnings / "lagging glib"),
`QUESTIONS.md` (Q1–Q5 and Q7 were stale or wrong), `DESIGN.md` ("5 rungs",
Phoenix as a *virtue*, three numeric lags already fixed), `README.md`
(IB "✅ Working", 23 tests, "5 rungs", duplicated Quick Start and Roadmap
lines, "waiting for glib" framing). All updated to measured facts.

---

## 7. Adopted from glib — and deliberately NOT adopted

**Adopt (code, verified):**
- `Symbol` 6-constructor custom type (`domain/instrument.gleam:43-57`) and
  `Interval` 9-constructor closed set (`interval.gleam:59-78`) as the **shape**
  to aim for: identity and closed sets in types, codecs at the boundary.
- `SourceBar` 9-variant family by interval (`sourcebar.gleam:115-188`) — the
  grade lives **in the type**, not in a field.
- Phase-55's *"identity is a key, not a field; owned entities are keyless"*
  (`bc6eadc`) as a **principle**, not its three empty record shells.
- `compute_bar` order and `single_bar_test` band-ordering invariant
  (`indicator.gleam:35-54`, `:84-135`).
- Welford σ with the bar in hand; KDJ single alpha `1/kdj_k_period` and
  `M = SMA(k, 10)`; the five SMA windows 7/70/140/252/504.
- The §1.13/§1.14 floor ruling and its `1e-6·bb_m` value.
- Guard discipline: `compiles.sh` is itself a guard; guards run in CI.

**Do NOT adopt:**
- `Desk` / `Broker` / `Account` empty shells; `SignalBundle` / `evaluate_bar`
  (zero production callers, **4 of its 6 verdicts are AI-invented with no
  source anywhere** — `trading/strategy.gleam:46-59` admits it).
- `kdj_d_period` and `pdt_protect_fund_level` (dead settings),
  `RiskTrade` / `RiskState` / `TradeLog` (hy4's type names).
- Any `String` used for `symbol` / `interval` / `action` / `check`, and any
  `"gate"` outside `sourcebar_gate`, "ladder", "Rung", "price gate", "risk gate".
- The 14 `.mjs` files and the trading/clock/geometry logic inside them.
- The assumption that glib's docs are the owner's record (§2).

**Still a design debt, not yet code (a decision, not a wait):**
- glibe's `config.gleam` keys timeframes as `List(#(String, TimeframeSettings))`
  with strings like `"BTCUSDT_H1"`. The owner's phase-55 principle says
  identity is a **key of a typed `Dict`**. Adopting `Symbol` + `Interval` as
  the key is the next type-level step, but it is an architectural change and is
  deliberately left for a plan, not slipped into a review.
- glibe's `Interval` has **7** constructors; the owner's settled closed set is
  **9** (`MIN1 MIN3 MIN15 MIN30 H1 H4 D1 W1 MO1`, glib `interval.gleam:59-78`).
  Adding `MIN3`/`H4` needs bucket-end rules and is likewise a planned step.
- `apps/glibe_web` is a tracked **Phoenix/Elixir + JS** app (23 files,
  `data_generator.ex`, `chart_hook.js`) — the largest remaining violation of
  *"No handwritten erlangs or even worse JS source files"*. It is outside the
  new guard's `src/` scope. **Owner's decision needed:** port the live view to
  a pure-Gleam BEAM path or retire it. It is not silently forgiven.

---

## 8. Verification

```
gleam build            → exit 0, 0 errors, 0 warnings
gleam test             → 26 passed, 0 failures
gleam format --check   → exit 0
sh scripts/guards.sh --all
  compiles.sh             green
  no_timeframe_mixture.sh green
  no_foreign_source.sh    green
```

Tests added this round: **3** (band floor, closed-set signal, gapped KDJ
indices). No test was weakened; the pre-existing band-ordering law still
holds.

## 9. Git state

Local `fix-types` is **16 commits ahead** of `origin/fix-types`
(`4c2e280`); the push attempted on 2026-10-05 was interrupted and **never
landed**. This round's commits are local; nothing is pushed without an
explicit instruction.

---

## 10. Addendum, 2026-11-07 — the view layer was an AI's framework choice

Two questions after this review: *why Phoenix rather than Lustre*, and *what is
Wisp*. Both point at the same miss. §7 recorded `apps/glibe_web` as debt but
**never asked who chose it, nor what the Gleam-native shape would be**. That
is the point the earlier reviews missed.

### 10.1 Who chose Phoenix

- `5e91f44` (2026-09-24, `visu: Add Phoenix LiveView + Lightweight Charts
  visualization`) added all 23 files in one commit. Its message is a feature
  list; there is no ruling, quote, or plan behind it. The commit carries the
  owner's git identity — every commit does — but no document of his names
  Phoenix or LiveView. `git grep` across every `docs/` revision finds the word
  only in **reviews**, never as a requirement. glib says the same about its
  own web layer: `web/state_ffi.mjs` — *"Neither name is in any document of
  his"* (`glib/docs/RULINGS.md:101`).
- **The chart itself is the owner's.** UC-56 / UC-57 / UC-60
  (`glib/docs/RULINGS.md:401, 403, 408`, 2026-09-26 and 2026-10-06) rule how
  bars reach it: one stream, one bar at a time, `series.update(oneBar)` and
  never a `setData` bulk load; a bar that fails the runtime test never reaches
  the page; and *"Creating view is not the work of the model … 你顶多是发一个
  event"*. What is **not** his is the implementation language — Elixir, HEEx,
  Phoenix PubSub, and hand-written `app.js` / `chart_hook.js`.
- **Fair on timing:** `5e91f44` predates the 2026-10-02 ruling *"no manual
  written JS except inevitable FFI mjs files"* and the 2026-11-07 *"No
  handwritten erlangs or even worse JS source files"*. It became debt; it was
  not born a violation. But the earlier `DESIGN.md` (`8f65609`) listed
  *"Phoenix / LiveView"* in the **advantage** column as *"the live view"* —
  AI prose praising its own choice. Round 5 downgraded it to debt without
  auditing the choice itself.
- **Cost measured:** 23 tracked files; 12 Elixir dependencies in `mix.exs`
  (Ecto, Postgrex, LiveDashboard, esbuild …) for a page fed by
  `data_generator.ex`, which is a **second engine in another language** —
  precisely what UC-56 forbids. Wisp/Lustre/Mist would compile into the same
  BEAM application as the engine, not a second runtime.

### 10.2 What a pure-Gleam view layer is made of

Lustre and Wisp are **not alternatives**; they are two different layers.

| layer | package | what it is | what it is not |
|---|---|---|---|
| HTTP / WS / SSE | **Mist** | pure-Gleam BEAM HTTP server: `mist.websocket`, `mist.server_sent_events`, chunked responses, OTP-supervised | not a framework, not UI |
| request edge | **Wisp** | *"A practical web framework for Gleam"*: handler `fn(Request) -> Response`, composable middleware via `use`, type-safe routing by pattern matching, JSON/urlencoded/multipart parsing, tamper-proof signed cookies, static assets, logging, body-size limits and upload streaming. Hex **2.2.2**, `gleam >= 1.11.0`, deps include `gleam_erlang` / `gleam_otp` → BEAM. `wisp_mist.handler` adapts a Wisp handler to Mist. | not an HTTP server, not a UI framework, not a pub/sub |
| UI | **Lustre** | typed HTML as Gleam functions, MVU over a `Model` custom type, `element.to_string` SSR; server components are `gleam/otp/actor`s with `lustre.supervised` / `lustre.factory`, DOM patches over WebSocket / SSE / polling. **v5.7.1**. | not a router, no built-in PubSub |

Lustre's own full-stack guide
(`hexdocs.pm/lustre/guide/06-full-stack-applications.html`) uses **Wisp + Mist
on the Erlang target**, with a third `shared/` Gleam package holding the types
both halves use. That is R13's *"Gleam is a typed language"* carried across the
network: one definition, compiler-enforced on both sides — the same idea as
this round's `Signal` custom type, one layer up.

### 10.3 What this section does **not** claim

- **No owner ruling names Lustre or Wisp.** He has said he has not read or used
  Wisp. This is an answer to *"what would the port even be"*, not a decision;
  **Q8 stays open**. Links sit in `docs/DEVELOPER_GUIDE.md` under *references
  for evaluation (none adopted)*.
- The browser still runs JS. With Lustre it is **generated by Gleam** (the
  client bundle) or **shipped inside the Hex package**
  (`lustre-server-component.mjs`, ~10 kB vs LiveView's ~50 kB client runtime);
  neither is hand-written project source. The ruling forbids *hand-written*
  foreign code, not the browser's instruction set. A candlestick chart drawn
  with Lustre's SVG DSL would need no JS charting library at all.
- Lustre's own LiveView cheatsheet names the real gaps: no built-in PubSub
  (the engine publishes an event / `Subject` instead), manual routing, and no
  `phx-hook` — DOM access goes through `effect.after_paint`.
- Wisp is for ordinary HTTP request/response work, adds ~13 dependencies, and
  must **not** enter the streaming core. UC-57 keeps the view a separate
  consumer of an event from `working_databar_archived`.

Q8 now has a concrete *"port"* shape: retire `apps/glibe_web`, keep the
chart's **behaviour** as UC-56/57/60 ruled it, and rebuild the view in Gleam
on Mist + Wisp + Lustre. *"Retire with no chart"* is the other option. Both
still need his word.

---

## 11. Addendum, 2026-11-07 — four follow-up questions, measured

### 11.1 `lpil` is Louis Pilfold, the author of Gleam

**Yes.** The handle is `lpil` (lower-case **L**, not `Ipil`), short for
**Louis Pilfold**, who created Gleam and still leads it. Evidence, all
first-party: the v1.19.0 release post on `gleam.run` is by Louis Pilfold;
Gleam's own `feed.xml` names him with `https://github.com/lpil`; Hex lists
`lpil` as Wisp's publisher; the repo is `gleam-wisp/wisp` (formerly
`lpil/wisp`); the sponsor link is `github.com/sponsors/lpil`. In the Changelog
interview he describes Wisp himself: *"So we've got Wisp, which is a nice
framework … more of the sort of core of your backend application."*

So Wisp is not a third party's guess at Gleam idiom — its "no confusing magic,
regular Gleam programming" philosophy is the language author's own. **But the
rest of the stack is not his:** Lustre is Hayleigh Thompson's, Mist's Hex
publisher is `rawhat`, and Giacomo Cavalieri rewrote the 1.19 Erlang code
generator. All three share `gleam_http`'s types, which is why they compose.

### 11.2 A Lustre app is live by default; static is one opt-in mode

**Yes — live, not static.** Three distinct Lustre modes:

| mode | live? | where state lives |
|---|---|---|
| `lustre.simple` / `lustre.application` (MVU) | **live** — every message runs `update` and re-renders | browser |
| server component | **live** — DOM patches stream over WebSocket / SSE / polling | **BEAM actor** (`gleam/otp`, `lustre.supervised` / `lustre.factory`) |
| `element.to_string` / `to_document_string` (SSR) | static — one HTML string | none |

On a **pure Erlang target** the live path is **server components**, not
"compile Gleam to JS and run it in the browser". That is the direct answer to
the worry behind Q3: live view does not require a JS target.

glib's chart is already live by the owner's ruling: `priv/index.html:287`
opens `new EventSource('/events')`, `:768` handles `chart_data`, and
`appendBar` (`:658`) does one `series.update` per bar — never `setData`
(`:644`, `:1038`), which is UC-56 / UC-60. So the behaviour is not a framework
feature to be re-invented.

**One honest complication.** "The chart lib from glib" is not a library you
import into Lustre: it is `priv/lightweight-charts.js` (198 KB minified,
TradingView v5.2.1, **vendored**) plus `priv/index.html` — **1,047 lines of
hand-written JS** containing the SSE handling, tabs, symbol switching and
markers. Porting that file is importing the debt R14 forbids. And Lustre has
**no `phx-hook` equivalent** (its own LiveView cheatsheet says DOM access goes
through `effect.after_paint`), so an imperative canvas chart needs a bridge.
The clean options are: draw the candles with Lustre's SVG DSL in Gleam (zero
JS, live via server-component patches), or wrap the vendored chart as a custom
element with a generated bridge. "Simple" is achievable — but not by carrying
`index.html` across.

### 11.3 IB historic data needs no JS target; the condition to drop IB does not fire

The owner ruled (R15): *"We will only use ib api to get historic data for
stocks(ETFs), so if this will cause JS target dependence, I would rather give
up ib entirely."*

**Measured: no JS dependence.** IB's **Client Portal Web API** is plain HTTPS
REST on a local gateway:
`GET https://localhost:5000/v1/api/iserver/marketdata/history?conid=&period=&bar=`
returning JSON `data: [{o,c,h,l,v,t}]` with epoch-ms timestamps. glibe already
depends on `gleam_httpc` (bindings to Erlang's `httpc`, Erlang target only) and
`gleam_json`, and `binance/binance.gleam:23` already calls `httpc.send`. A
historic-bar client is one request + one decoder — no FFI, no `.mjs`, no JS
target, no handwritten Erlang.

Where the JS dependence actually lives is **glib's** `ib_ffi.mjs`, which
imports `@stoqey/ib` — the **TWS socket API**, a different product serving
live quotes/orders/accounts, all outside the owner's stated scope. glibe's
retired `ibkr.gleam.disabled` used `@external(erlang, "Elixir.Glibe.Ibkr",
...)` — an Elixir module, not JS, and already retired.

**Two real frictions, neither a JS dependence:** the gateway uses a
self-signed certificate (OTP 29 verifies TLS by default; `gleam_httpc` has
`verify_tls(False)` but that disables verification and must not be the
default — a CA or an explicit decision is needed), and the Web API requires an
authenticated SSO session with keepalive. Both are HTTP/session work.

`scripts/no_foreign_source.sh` now fails on any `@external(javascript, ...)`
under `src/` and on `target = "javascript"` in `gleam.toml`, so the priority
is enforced rather than promised.

### 11.4 The `.erl` correction: right in substance, not a stale artefact

The owner's point: *"the only .erl you still see may be the product of former
gleam version, in new version, it's said no erl is produced anymore."*

**The substance is right, and Round 5's wording was wrong.** Gleam **v1.19.0**
(2026-10-05) is titled *"Gleam doesn't compile to Erlang source anymore"*:
> *"Previously Gleam generated Erlang source code, now it generates Erlang
> abstract forms."*

Those forms (`.abstr`, Erlang's external-term encoded parse tree) are loaded
by `compile:forms`, skipping the Erlang compiler's front half. So module
compilation is `.gleam → .abstr → compiler back half → .beam`. Round 5 said
"module code goes straight to `.beam`"; that was inaccurate, and the Kodikra
diagram `.gleam → .erl → erlc → .beam` is now confirmed as **the pre-1.19.0
pipeline**, not a vague "old" one.

**But that one `@@main.erl` is not a leftover.** Clean probe on 1.19.2
(`gleam new /tmp/erl_probe`, build, delete the file, rebuild): 1.19.2 wrote it
again at 14:46 today. It is the `gleam run` runner stub, generated by the
current compiler — the official post simply does not list it as an exception.
A fresh project produced 25 `.abstr`, 30 `.beam`, **zero `.erl` per module**,
and exactly one `@@main.erl`.

Other `.erl` in `build/` are not our compiler output either: Hex packages ship
generated `.erl` sources for rebar3/mix consumers (epoch-stamped `1970-01-01`,
straight out of the tarball), some packages ship handwritten Erlang FFI
(`gleeunit_ffi.erl`), and glibe retains a stale `build/dev/javascript/` tree
from an earlier JS-target experiment (build cache, not source). The
`gleam compile-package` command also still emits `.erl` for downstream build
tools — that regression was fixed before 1.19.0 shipped (issue #6281 / PR
#6291).

**Net:** "no Erlang source is produced anymore" is true of **module
compilation on the normal build path**, which is what the owner's §1.28 means.
It is not literally true of every file under `build/`. `src/` remains Gleam
only, and no Erlang source here is written, read, or maintained by a human.
