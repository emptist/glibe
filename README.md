# glibe

**A pure-Erlang-target Gleam trading engine.** *"glibe is the future, pure
erlang target is the future."* / *"BEAM is great. Let's build our success on
it!"* — emptist, 2026-11-07.

It began as a BEAM port of `glib` (JavaScript-target). It is no longer waiting
on glib: glib's unbuilt roadmap is not a dependency, and glibe takes the
owner's rulings and the good code from glib directly. See
[`docs/REVIEW_ROUND5.md`](docs/REVIEW_ROUND5.md) and
[`docs/DEVELOPER_GUIDE.md`](docs/DEVELOPER_GUIDE.md).

## Gleam language references

0. **[`docs/gleam-thinking-core-to-memory.md`](docs/gleam-thinking-core-to-memory.md)**
   — **the Gleam thinking core, preserved in git.** The whole language
   on one card: the type-first reflex, compiler guarantees,
   conventions/anti-patterns, targets, externals, toolchain, docs-first/TDD.
   **Every client — VSCode, Trae, any editor or agent — should include this file
   IN FULL in its context before any Gleam work.** It is a byte-for-byte copy of
   the user-level `gleam-language` skill core, which lives outside git; the
   skill copy is the source of truth. Keep the two identical with
   `cmp ~/.workbuddy/skills/gleam-language/references/gleam-core.md docs/gleam-thinking-core-to-memory.md`.

1. **The Gleam Language Tour — Everything!** — <https://tour.gleam.run/everything/>
2. **The Complete Gleam Guide: From Zero to Expert** —
   <https://www.kodikra.com/2026/03/the-complete-gleam-guide-from-zero-to.html>

3. **Gleam v1.19.0 — "Gleam doesn't compile to Erlang source anymore"** —
   <https://gleam.run/news/gleam-doesnt-compile-to-erlang-source-anymore/>

The tour is the authoritative syntax/semantics reference; the Kodikra guide is
a learning roadmap (its `.gleam → .erl → erlc` diagram is the **pre-1.19.0**
pipeline); the v1.19.0 note is the version fact: modules now compile to Erlang
abstract forms (`.abstr`), not Erlang source. All three are discussed in
[`docs/DEVELOPER_GUIDE.md`](docs/DEVELOPER_GUIDE.md).

**Web layer — two packages, two targets:** the root `glibe` package stays on the
Erlang target. `webclient/` is a **separate Gleam package** with its own
`gleam.toml` declaring `target = "javascript"`; its Gleam source compiles to
`.mjs` with `gleam build`. A hand-written `.mjs` is allowed only inside that
folder. The old Phoenix app is kept in `deprecated/glibe_web/` for comparison
and is not in use. Wisp / Lustre / Mist remain **references only — none adopted,
no dependency added** (`docs/RULINGS.md` R18).

## Status

| Component | Status | Notes |
|-----------|--------|-------|
| **Target** | ✅ `erlang` | root package pure BEAM; no handwritten `.mjs`/`.erl`/`.ex` under `src/`. The separate `webclient/` package is the only JavaScript target, declared in its own `gleam.toml` |
| **Binance REST** | ✅ Working | testnet.binance.vision (works from China), `gleam_httpc` |
| **Stream Processing** | ✅ Core Complete | SMA×5, Bollinger, KDJ, Leaf, Branch, Timeframe pipeline |
| **Tests** | ✅ Passing | **64 tests** in the root package — indicators, api, ingest boundary, the ownership chain, the `Interval` closed set, the web layer, addressed multi-instrument monitoring and three Round-5 invariant tests; plus **4 tests** in `probes/parallel-bars/`, a superseded historical experiment (R32). Assertions use bool `assert` / `let assert` with messages, not `panic` |
| **Build** | ✅ Green | gleam **1.19.2** / OTP **29**: 0 errors, 0 warnings |
| **IB Client Portal** | ⚠️ Retired | The handwritten Elixir `ibkr.ex` wrapper had **zero callers** and an undeclared `ibkr_api` dep; it produced 12 build warnings. Removed under *"No handwritten erlangs"*. The FFI contract survives as `ibkr.gleam.disabled` (a design record, not compiled). |
| **Visualization** | ✅ Settled | **JS chart library (R17)**, generated `.mjs` preferred; hand-written `.mjs` only inside `webclient/` (R16). The client exists so a human can spot anomalies by eye, read trends from charts, inspect tabulated fractal data, and see order issue/fill points (R18). `deprecated/glibe_web` is a Phoenix comparison piece, not the implementation. The BEAM web layer is **Mist + Wisp**, chosen by three measured demos (R24) and adopted in phase 04-05: `GET /` renders the real `Desk` as a table, `GET /desk` returns it as JSON. No Lustre server components, no hand-written JS. |
| **Web display time** | 📄 Documented (R30) | The web view shows date-times in the analyst's local time with IANA daylight-saving rules; the standard bar stays unix time, the bucket grid stays UTC-aligned and CSV stays UTC RFC3339. Specification in `src/glibe/web/server.gleam`, plan `.planning/phases/04-domain-cleanup/04-07-PLAN.md`. Implementation not started — docs only this round. |
| **Multi-instrument monitoring** | ✅ Typed (04-08); runtime unstarted | One `IncomingBar` carries a typed `TimeframeAddress(BrokerId, Symbol, Interval)`; the pure `monitor.advance` locates that one `Timeframe`, runs the gate and (on a closed bucket) the full pipeline, and writes back a new `Desk`. Six isolation tests prove other intervals and other brokers stay untouched. **The structure is a garden (R32)**: ONE `Desk`, and every `Timeframe` in an `Instrument`'s `Dict(Interval, Timeframe)` is alive, processing its own bars and making its own trading decisions; adding a real thing is one new field in an existing type, placed by asking what it belongs to. `process.spawn` + a typed `Subject` is the whole BEAM primitive (R31), so no concurrency framework is needed. `probes/parallel-bars/` copied that one `Desk` into six processes; its "merge" conclusion is void (R32). A live feed and a replay CLI remain unstarted. |
| **Guards** | ✅ Added | `scripts/guards.sh --all` — build, test, format, `no_timeframe_mixture`, `no_foreign_source`, plus `test_guards.sh` (7 fixture-based negative tests, no source mutation); also runs in CI |

## Quick Start

```bash
# Build Gleam core
gleam build

# Run tests
gleam test

# Run every guard (build, test, format, module purity, no foreign source,
# plus fixture-based negative tests for the guards)
sh scripts/guards.sh --all

# Build the separate JavaScript-target web client (emits .mjs)
cd webclient && gleam build && cd ..

# Start the BEAM web layer (Mist + Wisp) on port 8610.
# / → HTML table of the configured Desk, /desk → the same chain as JSON.
gleam run -m glibe/web/server

# Reference only — the retired Phoenix app, kept for comparison
cd deprecated/glibe_web && mix phx.server
```

## Architecture

```
┌─────────────────────────────────────────┐
│         Business Logic (Gleam)          │
│   Stream processing, strategies, AI     │
└─────────────────┬───────────────────────┘
                  │ calls
┌─────────────────▼───────────────────────┐
│      API Wrappers (Gleam only)          │
│   Binance (binance/) | IB — retired     │
└─────────────────┬───────────────────────┘
                  │ HTTP/WS
┌─────────────────▼───────────────────────┐
│      External APIs                      │
│   IB Client Portal Gateway (:5001)      │
│   Binance testnet.binance.vision        │
└─────────────────────────────────────────┘
```

## Key Design Decisions

- **SourceBar vs DataBar**: Raw API data (`SourceBar`) vs computed bars (`DataBar`) — per DESIGN.md §2
- **testnet.binance.vision**: Default Binance endpoint (works from China without VPN)
- **Pure Gleam HTTP**: `gleam_httpc` for Binance; no Elixir/FFI HTTP wrapper (no curl shell-outs)
- **Target**: Erlang (`target = "erlang"` in gleam.toml) — **no JavaScript target**
- **Types**: closed sets are custom types, never `String` (`trading/signal.gleam`, `api/interval.gleam`); one type, one module
- **Config as Code**: Single `config.gleam` — type-safe, no JSON

## Project Structure

```
src/
├── glibe/
│   ├── api/                      # Market types and the ingest boundary
│   │   ├── asset.gleam           # Asset, AssetRef, AssetClass
│   │   ├── exchange.gleam        # Exchange, MarketType
│   │   ├── market.gleam          # Market = Exchange + AssetClass + Rules
│   │   ├── rules.gleam           # MarketRules, TradingHours, SettlementType, parsers
│   │   ├── symbol.gleam          # Symbol = a NAME, not the instrument (RULINGS.md R22)
│   │   ├── sourcebar.gleam       # standard SourceBar: unix-time Timestamp + OHLCV
│   │   └── interval.gleam        # Interval + codec (to_string/from_string/all) + bucket_ends
│   ├── binance/
│   │   ├── types.gleam           # legacy SourceBar/Interval (superseded by api/ — see DESIGN.md)
│   │   ├── kline.gleam           # native 12-field Kline + to_sourcebar
│   │   └── binance.gleam         # Binance public API (gleam_httpc)
│   ├── sma.gleam                 # SMA series (Tiny/Small/Medium/Large/Huge) — five windows
│   ├── kdj.gleam                 # KDJ oscillator (LLV/HHV + SMA for K/D/M)
│   ├── bollinger.gleam           # Bollinger Bands (SMA centre, σ, Fibonacci ratios)
│   ├── indicator.gleam           # Pipeline: SMA×5 → KDJ → Bollinger
│   ├── indicator_settings.gleam  # TimeframeSettings (a value), SmaForBbm (RULINGS.md R23)
│   ├── databar.gleam             # DataBar — born from SourceBar, folded; 33 fields
│   ├── leaf.gleam                # DataLeaf — grown one bar at a time + CMA
│   ├── branch.gleam              # DataBranch — grown one bar at a time, rides a leaf
│   ├── timeframe.gleam           # Timeframe record + new — NO symbol/interval (RULINGS.md R23)
│   ├── desk.gleam                # Desk ▸ Broker ▸ Instrument ▸ Interval ▸ Timeframe (R20/R23)
│   ├── monitor.gleam             # TimeframeAddress + IncomingBar + pure advance (04-08)
│   ├── engine.gleam              # The pipeline: gate, processing, leaves, branches, accept
│   ├── trading/
│   │   └── strategy.gleam        # The manual verdict (manual_signal)
│   ├── export/
│   │   └── csv.gleam             # CSV export, one row per accepted bar
│   ├── web/
│   │   └── server.gleam          # Mist + Wisp endpoints; view of the real Desk (R24)
│   └── config.gleam              # AppConfig + default_config (single source of truth)
├── probes/
│   ├── web-layer/                # three measured BEAM web demos (R24 / 04-04)
│   └── parallel-bars/            # 04-09 historical probe, shape wrong; superseded by R32
├── webclient/                    # separate JS-target Gleam package (own gleam.toml)
│   └── src/webclient.gleam       # → build/dev/javascript/webclient/webclient.mjs
├── deprecated/glibe_web/         # Phoenix LiveView, kept for comparison only
│   ├── lib/glibe_web/live/chart_live.ex
│   ├── lib/glibe_web/data_generator.ex
│   └── assets/js/chart_hook.js
└── test/
    ├── glibe_test.gleam          # engine / indicator / config invariants
    ├── sourcebar_time_test.gleam  # unix time at the ingest boundary (R27/R28)
    ├── desk_test.gleam           # the ownership chain (R20, R23)
    ├── monitor_test.gleam        # one addressed bar, one timeframe (04-08)
    ├── interval_test.gleam       # the Interval closed set and its codec (R21)
    ├── symbol_test.gleam         # a name is not the thing named (R22)
    └── web_server_test.gleam     # routes, JSON, HTML view and real Wisp requests
```

## Testing

```bash
# All tests
gleam test

# Individual modules
# (tests in test/glibe_test.gleam)
```

## Stream Processing (Phase 3 - Complete)

The `Timeframe` module (`src/glibe/timeframe.gleam`) implements the streaming data pipeline per the design in glib's `DESIGN.md`.

### Two Entry Points (in `engine.gleam`)

```gleam
// 1. Feed raw exchange data — validates + normalizes; only function that touches SourceBar
//    The Interval is handed in by the caller that selected this Timeframe from
//    Instrument.timeframes; the Timeframe itself never stores it (RULINGS.md R23).
sourcebar_gate(timeframe: Timeframe, interval: Interval, sourcebar: SourceBar)
  -> Result(#(Option(DataBar), Timeframe), String)

// 2. Process a completed bar — all computation happens here.
//    No settings argument: the engine reads timeframe.settings (RULINGS.md R23).
databar_processing(timeframe: Timeframe, databar: DataBar) -> Timeframe
```

`timeframe.gleam` holds the `Timeframe` record and `new` only; every step that
moves it lives in `engine.gleam` (RULINGS.md R7). The `Result` from
`sourcebar_gate` is how a malformed bar is rejected, not repaired (RULINGS.md R8).

### `sourcebar_gate` — Time bucket aggregation
- Folds incoming `SourceBar`s into `working_databar` (OHLCV accumulation)
- Returns `Some(closed_databar)` when time bucket completes, `None` otherwise
- Decision `bucket_ends` uses ONLY timestamp + interval (proper hourly/daily bucket logic)

### `databar_processing` — The computation pipeline (holds NO arithmetic)
```gleam
pub fn databar_processing(tf: Timeframe, db: DataBar) -> Timeframe {
  let settings = tf.settings
  let db = indicator.run(db, tf.databar_list, settings)  // JOB 1: Indicators
  let #(db, tf, yin_settled, yang_settled) = leaves(tf, db) // JOB 2: Leaves
  let tf = branches(tf, db, yin_settled, yang_settled, settings.branch_exit_leaf_size)
  let #(tf, db) = strategy(tf, db)                       // JOB 4: Manual verdict
  accept(tf, db)                                         // JOB 5: Commit to history
}
```

**All jobs and where they live:**

| Job | Module | Function | What it does |
|-----|--------|----------|--------------|
| **Indicators** | `indicator.gleam` | `run/3` | SMA×5 → KDJ → Bollinger (writes measured fields to `DataBar`) |
| **Leaves** | `leaf.gleam` | `next_yin_leaf/3`, `next_yang_leaf/3`, `leaf_cma/3` | Streaming Yin/Yang leaf detection, CMA |
| **Branches** | `branch.gleam` | `next_yin_branch/6`, `next_yang_branch/6` | Streaming Yin/Yang branch detection (rides a leaf) |
| **Strategy** | `trading/strategy.gleam` | `manual_signal/2` | The manual verdict, written on the bar |
| **Accept** | `engine.gleam` | `accept/2` | Prepend finished bar to `databar_list` (newest-first) |

### Data Flow
```
SourceBar → sourcebar_gate → working_databar (Option)
  → bucket closes → databar_processing
    → indicator.run()        [JOB 1: SMA×5/KDJ/Bollinger]
    → leaves()               [JOB 2: Yin/Yang leaf + CMA]
    → branches()             [JOB 3: Yin/Yang branch]
    → strategy()             [JOB 4: manual_signal → written on the bar]
    → accept()               [JOB 5: commit to databar_list]
```

### Timeframe Structure
```gleam
pub type Timeframe {
  Timeframe(
    settings: TimeframeSettings,       // the numbers THIS engine runs on (R23)
    working_databar: Option(DataBar),  // None after close until next source bar
    databar_list: List(DataBar),       // newest-first

    // NO `symbol`, NO `interval`, NO `market_type`: the interval is the key in
    // Instrument.timeframes and the symbol is the key in Broker.instruments.
    // The owned value never names its owner (RULINGS.md R22 / R23).

    // Leaf state — Option: a leaf is born on a bar, so before any bar there is none
    growing_yin_leaf: Option(DataLeaf),
    growing_yang_leaf: Option(DataLeaf),

    // Branch state — Option: a branch exists only once a leaf settles (RULINGS.md R1)
    growing_yin_branch: Option(DataBranch),
    growing_yang_branch: Option(DataBranch),
    yin_branch_list: List(DataBranch),
    yang_branch_list: List(DataBranch),

    // The manual strategy's enter/exit points, carried as bars (UC-62)
    manual_enter: Option(DataBar),
    manual_exit: Option(DataBar),
  )
}
```

**Key invariant**: `working_databar` is the bar being built (present — decision making, trading, research); `databar_list` contains only COMPLETED bars (history — immutable facts). When bucket closes, `working_databar` moves to `databar_list` via `accept()`.

### Architecture: Parallel Timeframes for Free

Each `Timeframe` = one interval of one instrument, fully independent:
- No shared state, no locks
- Its identity is the pair of keys above it (`Symbol` in `Broker.instruments`,
  `Interval` in `Instrument.timeframes`), not fields on the record (R22 / R23)
- Each carries its own `TimeframeSettings` value in `settings`
- Multiple instruments/intervals run simultaneously
- Same pure functions process all timeframes

### Leaf Indexing Rules (Critical)

Two key facts that save hours of debugging:

1. **Working bar index = `databar_list.length`** — The bar currently being computed is NOT in `databar_list` yet. Its global index equals the list length.

2. **Leaf start/end indices**:
   - New leaf `start_idx = databar_list.length` (working bar index)
   - Closed leaf `end_idx = databar_list.length - 1` (previous settled bar)
   - Leaf is "new" when `leaf.start_idx == databar_list.length`

This means a 1-bar leaf has `start_idx == end_idx == databar_list.length - 1` after it closes.

### Count-Back Index (Newest-First List)

Since `databar_list` is **newest-first** (head = latest settled bar), global index `i` maps to list index:

```
list_index = databar_list.length - 1 - global_index
```

Examples for list of length 5 (global indices 0..4, newest at head):
- Global 4 (newest) → list index 0 (head)
- Global 2 → list index 5 - 1 - 2 = 2
- Global 0 (oldest) → list index 4 (last)

This applies to ALL list accesses by global index: SMA leaving bar, leaf start/corner values, etc.

### Branch Indexing Rules

Branch detection runs after Leaf detection, using completed leaf lists.

**Index semantics (per DESIGN.md §6):**
- `start_idx` / `end_idx`: trend **FACTS** (where trend actually started/ended)
- `exit_idx` / `enter_idx`: trading **SIGNALS** (where we exit/enter, known only later)
  - `exit_idx` = discrimination bar where over-long leaf detected
  - `enter_idx` = previous branch's `exit_idx` = over-long leaf's `corner_idx`

**Key rules:**
1. **No branch at bar 0** — cannot determine until first leaf completes
2. **Opposite polarity**: YinBranch tracks YangLeaf list, YangBranch tracks YinLeaf list
3. **Continuation = length test** (not price): `branch_exit_leaf_size` from settings
4. **New leaf** (1-bar): if no growing branch → start new branch at leaf's `corner_idx`
5. **Old leaf too large** (> `branch_exit_leaf_size`): close current branch (`exit_idx` = current bar, `end_idx` = leaf's `start_idx`); start new at newest opposite leaf's `corner_idx`
6. **Retrospective recognition**: branch facts (`start_idx`/`end_idx`) determined after the fact
7. **AI improvement** (Phase 4): AI strategy does NOT change branch definitions. Main target: POST-APPROVE both enter_idx AND exit_idx earlier than structural signals.
   - enter_idx: structural = 100 bars after start_idx; AI post-approves at 80 bars
   - exit_idx: end_idx marks highest SMA in yang_branch (we're in yin_leaf, opposite polarity). Structural exit_idx comes late; AI post-approves earlier to capture more profit.
   Prediction (guessing before confirmation) is riskier and less trustworthy.
   Analogy: like a good doctor who DIAGNOSES issues earlier, not PREDICTS disease in healthy patients.
   扁鹊也只是早起诊断，不是预测蔡桓公将要生病。

   **Note (Round 5):** this describes a future design, not running code. The AI
   layer is deliberately absent — the owner ordered glib's AI modules deleted,
   so there is nothing to port and nothing to wait for.

### Config (Single Source of Truth)

`config.gleam` — type-safe, no JSON. Uses string-based parsing for enum variants:

```gleam
asset_class_from_string("Crypto")
trading_hours_from_string("RTH;09:30;16:00;America/New_York")
settlement_type_from_string("TPlus2")
circuit_breaker_from_string("CircuitBreaker;0.07;300;15")
```

### Module Split

| Module | Responsibility |
|--------|----------------|
| `api/` | Core types: Asset, Market, Symbol, Rules, Exchange — and the ingest boundary (`sourcebar.validate`, `normalize_date`) |
| `sma.gleam` | SMA series (Tiny/Small/Medium/Large/Huge) — five windows |
| `kdj.gleam` | KDJ oscillator (LLV/HHV batch + SMA for K/D/M) |
| `bollinger.gleam` | Bollinger Bands (selected SMA centre, σ via Welford online recurrence, Fibonacci ratios) |
| `indicator.gleam` | Pipeline composition: SMA×5 → KDJ → Bollinger |
| `leaf.gleam` | DataLeaf types + streaming detection (Yin/Yang leaves, CMA) |
| `branch.gleam` | DataBranch types + streaming detection (Yin/Yang branches, rides a leaf) |
| `timeframe.gleam` | Timeframe record + `new` (state only) |
| `engine.gleam` | `sourcebar_gate`, `databar_processing`, `leaves`, `branches`, `accept` (the pipeline) |
| `trading/strategy.gleam` | The manual verdict |
| `export/csv.gleam` | CSV export, one row per accepted bar |
| `config.gleam` | AppConfig + default_config |

Dependency graph (no cycles):
```
api, databar → sma, kdj, bollinger → indicator → leaf → branch → engine → timeframe
```

### Visualization (webclient)

```
cd webclient
gleam build          # emits build/dev/javascript/webclient/webclient.mjs
```

**Why there is a web front end at all (R18):** a human needs to see the output,
not read logs — to spot anomalies and logic errors by eye, read price trends
from charts to form trading ideas, inspect non-graphical but tabulated
fractal-structure data, research market behaviour and new manual strategies,
and see where an order was issued and where it was filled. A Gleam GUI would be
harder to build.

## Visualization

`deprecated/glibe_web` (Phoenix LiveView + Lightweight Charts) is kept **for
comparison only**, not as the implementation. Its BTCUSDT 1h candlesticks,
SMA overlays, yin/yang leaf and branch markers and 2-second PubSub updates
document one earlier shape of the view; do not read it as the current design.

**The Gleam core does not broadcast** — `broadcast_chart` was removed; nothing
in `src/glibe` sends bars over SSE. The active client is the separate
`webclient/` package.

The engine's one exporter is `export/csv.gleam` (`to_csv`), which writes one row
per accepted bar, oldest first — for checking the engine against something that is
not the engine (TradingView, a spreadsheet, another implementation). An exporter is
not part of the engine (RULINGS.md R7).

## Roadmap

See `.planning/ROADMAP.md` for detailed phases. The rulings and measurements
behind the remaining decisions are in [`docs/RULINGS.md`](docs/RULINGS.md) and
[`docs/REVIEW_ROUND5.md`](docs/REVIEW_ROUND5.md); withdrawn Stage D items are
recorded in [`docs/QUESTIONS.md`](docs/QUESTIONS.md).
- Phase 1: Stream Processing Core ✅
- Phase 2: Binance Live Feed Integration (next)
- Phase 3: Tests & Verification
- Phase 4: IB API Wrapper
- Phase 5: Strategy & Trading Separation
- Phase 6: Integration & Examples

## Recent Fixes (2026-09-25)

1. **TradingHours parsing** — Fixed `:` delimiter bug for RTH/Custom formats (now uses `;`)
2. **Timeframe bucket_ends** — Implemented proper hourly/daily bucket logic (was always `True`)
3. **Leaf/Branch detection** — Fixed O(n²) full regeneration bug (now incremental)
4. **Zero warnings** — `gleam build` / `gleam test` clean, `gleam format --check` clean
5. **Tests added** — 23 tests (config, asset, rules, indicators, ingest boundary)

## Recent Fixes (2026-10-04)

1. **Module purity** — `timeframe.gleam` now holds the record and `new` only; the
   pipeline moved to `engine.gleam`. `scripts/no_timeframe_mixture.sh` fails the
   build if the mixture returns (RULINGS.md R7).
2. **Ingest boundary** — `api/sourcebar.gleam` `validate` rejects a malformed bar
   (never repairs); `normalize_date` turns epoch-milliseconds into ISO-8601 at the
   boundary, fixing the hourly-bar bug where an hourly bar never closed on Binance data.
3. **Verdict ownership** — dropped 15 `DataBar` fields no module wrote; the manual
   verdict lives in `trading/strategy.gleam`. `DataBar` now carries 26 measured
   fields only.
4. **Optional end/exit bars** — `end_bar` / `exit_bar` on leaf and branch are
   `Option` (RULINGS.md R1); no sentinel, no false size.
5. **Guards** — `scripts/guards.sh --all` runs build, test, format, and the mixture
    check.
6. **Bollinger σ ported to Welford recurrence** — replaced batch `sum_sq_diff / count`
   with online Welford mean/variance recurrence (`SigmaState(n, mean, m2)`) per plan
   31-02 §3 (2026-10-01). eliminates window cache, avoids catastrophic cancellation
   (DESIGN.md §14.6), and carries σ forward bar-to-bar on `DataBar`. sigma_n /
   sigma_mean / sigma_m2 fields added to `DataBar`.

## Recent Fixes (2026-11-07 — Round 5)

1. **Band floor follows the owner's ruling** — one `1e-6·bb_m` positive floor on
   the lower edge **before** interpolation, not three clamps. The withdrawn
   *floor under the lower bands* item in `docs/QUESTIONS.md` had misquoted the
   ruling as "no floor" (RULINGS.md R12).
2. **`Signal` is a custom type, not a `String`** — `trading/signal.gleam`
   (`Buy | Sell | NoSignal`), the wire spelling only in `export/csv.gleam` (R13).
3. **One closed set, one home** — deleted the dead 4-constructor `SmaSeries`
   duplicate; renamed `window_kdj_size` → `kdj_window_size`.
4. **KDJ survives a gapped feed** — the leaving extreme is found by list
   position, not `idx - w`.
5. **`src/` is Gleam only** — retired the orphan `ibkr.ex`; added
   `scripts/no_foreign_source.sh`, wired into guards and CI; CI now pins
   gleam 1.19.2 / OTP 29 (R14).
6. **Documents re-measured** — `docs/REVIEW_ROUND5.md`,
   `docs/DEVELOPER_GUIDE.md`, and updated `STATE / DESIGN / QUESTIONS / RULINGS`.

## License

MIT