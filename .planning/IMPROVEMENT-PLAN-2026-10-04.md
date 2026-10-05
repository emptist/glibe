**Status: live.** Started 2026-10-04. Supersedes nothing; it is the first plan
written for glibe from a review rather than from a port.

# Improvement plan — glibe, 2026-10-04

**Scope: everything except the AI strategy.** The AI layer is being built in
glib right now (`ai_s1.gleam`, `learn.gleam`, `boost.gleam`, `knn.gleam`,
`census --learn`). Porting it mid-flight would import a moving target, and
`REVIEW_ROUND3.md §7` records what is missing here. It is deliberately last.

**The one idea this plan is built on.** glib's own docs say a module should hold
one class, and say `timeframe.gleam` is the exception because Gleam refuses the
import cycle. glib is still arguing about which functions to move out
(`STATE.md §11.3`). glibe does not have to have that argument at all: **split
the state record from the pipeline that threads it** and the cycle disappears —
`leaf.gleam` and `branch.gleam` never imported `timeframe`, only `timeframe`
imported them. What is left in `timeframe.gleam` is a record and its accessors,
and what cannot be argued about cannot drift.

**And the part glib does not have: a mechanism.** glib moved three predicates out
of `timeframe.gleam` on 2026-10-03 because the user asked. Nothing stops them
coming back. glibe gets `scripts/no_timeframe_mixture.sh`, which fails the build
if anything but the record lives there. A principle without a mechanism is
decoration.

---

## 1. Where glibe is honestly behind, and where it can be ahead

| axis | glib | glibe | verdict |
|---|---|---|---|
| tests that run | 63 | 0 | behind — fix first |
| guards | 10, executable | 0 | behind — fix second |
| module purity | argued, partly done | not started | **can be ahead** |
| ingest boundary | `sourcebar.validate`, reject not repair | none; epoch-ms leaks in | behind |
| interval as a type | codec + completeness at load | seven constructors, no codec | behind |
| end bars as `Option` | yes, ruling landed | no | behind (ruling) |
| unwritten fields on the bar | 0 | 11 | behind |
| documentation | 3,571 lines, 36 rulings | none | behind |
| **concurrency** | one JS process | **BEAM** | **can be ahead** |
| **real broker connectivity** | paper only | IBKR + Binance modules | **can be ahead** |
| **live dashboard** | hand-written JS + FFI | Phoenix/LiveView | **can be ahead** |

The last three are the reason glibe is worth improving rather than abandoning.
They are also the only three where glib is not the reference.

---

## 2. The plan, in the order it has to happen

Every stage ends with `gleam build` clean, `gleam test` green, and
`sh scripts/guards.sh --all` green. A stage that cannot be verified is not done.

### Stage A — make the tree verifiable

| # | what | why it is first |
|---|---|---|
| A1 | delete the 19 `@test` lines; `main()` calls `gleeunit.main()` | the tree does not compile; nothing below can be checked |
| A2 | `scripts/compiles.sh` — build, test, `format --check` | a guard that cannot see its subject is worse than none |
| A3 | `scripts/guards.sh` — one entry, run what has a subject | glib's shape, glibe's content |

### Stage B — module purity (the part glib has not finished)

`timeframe.gleam` today holds the record, the ingest, the pipeline, a CSV
exporter and three hooks. Everything below `databar_processing` moves:

| moves from `timeframe.gleam` | goes to | reason |
|---|---|---|
| `first_databar`, `fold_databar` | `databar.gleam` (`of_sourcebar`, `fold_sourcebar`) | they build a `DataBar`; that is databar's |
| `bucket_ends`, `bucket_ends_daily`, `bucket_ends_hourly` | `api/interval.gleam` | a question about an interval and a timestamp |
| `sourcebar_gate`, `databar_processing`, `leaves`, `branches`, `accept` | **`engine.gleam`** (new) | the pipeline is composition, not state |
| `to_csv` | **`export/csv.gleam`** (new) | an exporter is not part of the engine |
| `strategy_signal` | **`trading/strategy.gleam`** (new) | a verdict belongs to whoever decides |
| `runtime_test`, `single_bar_test` | **deleted** | both return their argument unchanged |

`timeframe.gleam` keeps: the record, `new`, accessors, `bars_accepted`.

**The mechanism:** `scripts/no_timeframe_mixture.sh` fails if `timeframe.gleam`
declares a function outside an allow-list, or if any other module declares
`pub type Timeframe`.

### Stage C — the ingest boundary

| # | what |
|---|---|
| C1 | `sourcebar.validate` — reject a bar that cannot be right, with a reason, never repair it (glib's recorded decision) |
| C2 | `sourcebar.normalize_date` — epoch-milliseconds in, ISO-8601 out, at the boundary. This is the fix for the H1 bug: today a Binance kline's `openTime` reaches `bucket_ends_hourly` as `"1735704000000"` and no hourly bar ever closes |
| C3 | `engine.sourcebar_gate` refuses an invalid bar instead of folding it in |

### Stage D — the rulings glib has landed and glibe has not

| # | what | closes |
|---|---|---|
| D1 | `end_bar` / `exit_bar` become `Option(DataBar)` on the leaf **and** the branch. *"a structure doesn't have an end_bar unless it is ended"* [user 2026-10-03] | I-7, I-9, I-18, I-19 — four rows, one change |
| D2 | delete the 11 unwritten `DataBar` fields; the six verdicts reappear in `trading/strategy.gleam` **with producers**, or not at all | I-17, §4.2 |
| D3 | `branch_size` spans `start → exit`, both ends inclusive | I-6 |
| D4 | the branch dies when the riding leaf is `>=` `branch_exit_leaf_size` bars, not `>` | off-by-one found while reading for this plan |
| D5 | KDJ window is `w` bars including the bar in hand, not `w + 1` | I-1 |
| D6 | σ over the window ending at the bar in hand | I-3 |
| D7 | no floor under the lower bands | I-4 |
| D8 | one alpha for K and D; `kdj_d_period` deleted or justified | I-2 |
| D9 | `window_kdj_size` → `kdj_window_size` | I-14 |

### Stage E — documentation

glibe has no `docs/`. glib has 3,571 lines, most of them the user's own words
with dates. The port is **curated, not copied** — glib's `DEEP-DIFF` reading of
glib is wrong in three places (`REVIEW_ROUND3.md §6.2`), so nothing is ported
from it.

| file | what it holds |
|---|---|
| `docs/RULINGS.md` | every ruling that binds glibe, quoted, dated, with where it landed |
| `docs/DESIGN.md` | glibe's own design: the module law, the pipeline, the BEAM story, and every deviation from glib with its reason |
| `docs/NAMING.md` | the naming rules glibe adopts |
| `docs/STATE.md` | measured state: build, test count, guard count, with the day each was taken |
| `docs/QUESTIONS.md` | open questions, dated |
| `README.md` | corrected: five SMAs, no `broadcast_chart`, the new module layout |

### Stage F — the BEAM part (where glibe passes glib)

| # | what |
|---|---|
| F1 | one `Timeframe` actor per `(symbol, interval)`, supervised. `gleam_otp` is already a dependency. glib is one JS process with one engine; glibe can run many instruments without sharing state |
| F2 | a replay CLI over stored klines — glib has `census`; glibe has nothing, so no claim about the engine can be checked |
| F3 | delete `DataGenerator` from the supervision tree — a second engine in another language, running, wired in. One engine (UC-56) |
| F4 | `no_minute_trading.sh` — the ruling, as a guard |

---

## 3. What is explicitly not in this plan

- the AI strategy (see the header);
- the `ibkr` disabled module and the 11 undefined `IbkrApi.ClientPortal.*`
  warnings — they need the network to resolve, and are their own job;
- `apps/glibe_web` beyond F3;
- pushing anything anywhere.

---

## 4. Definition of done for this session

Stages A, B, C, E and the guard scripts. D is staged next; F after it. Each
stage ends green, and the numbers are written into `docs/STATE.md` on the day
they were taken.

---

## 5. Progress log

### 2026-10-04 — session done

- **A** — tree verifiable: removed the 19 `@test` lines, `main()` calls
  `gleeunit.main()`; **23 tests run and pass** (19 original bodies + 4 new
  ingest-boundary tests).
- **B** — module purity: `timeframe.gleam` is record + `new` only. The pipeline
  moved to `engine.gleam`; `strategy_signal` → `trading/strategy.gleam`;
  `to_csv` → `export/csv.gleam`; `bucket_ends*` → `api/interval.gleam`;
  `first_databar`/`fold_databar` → `databar.gleam` (`of_sourcebar`/`fold_sourcebar`).
  `scripts/no_timeframe_mixture.sh` enforces it.
- **C** — ingest boundary: `api/sourcebar.gleam` `validate` (reject, never repair)
  + `normalize_date` (epoch-ms → ISO-8601 at the boundary); `engine.sourcebar_gate`
  uses both. The H1 never-closes bug is fixed and pinned by a test.
- **E** — docs: `docs/` tree created (`STATE`, `RULINGS`, `NAMING`, `DESIGN`,
  `QUESTIONS`); `README.md` corrected (module layout, five SMAs, no
  `broadcast_chart`, 23 tests).
- **Guards** — `scripts/compiles.sh`, `scripts/no_timeframe_mixture.sh`,
  `scripts/guards.sh`; `sh scripts/guards.sh --all` is green.

- **D1–D3 folded in** (low-risk, ruled): `end_bar`/`exit_bar` are `Option` on leaf
  and branch (R1); the 15 unwritten `DataBar` fields are deleted (R10); branch
  size/close semantics are the ruled ones (R5/R6). **D4–D9 remain** (KDJ window,
  σ window, lower-band floor, single alpha, `window_kdj_size` rename) — pending.
- **D4–D9 and F not started.**
