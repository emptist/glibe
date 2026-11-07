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

**Web-layer references under evaluation — none adopted, no dependency added:**
[Wisp](https://gleam-wisp.github.io/wisp/), [Lustre](https://hexdocs.pm/lustre/),
[Mist](https://hexdocs.pm/mist/). See `DEVELOPER_GUIDE.md` and
`REVIEW_ROUND5.md` §10. `apps/glibe_web` (Phoenix) is an unowned AI choice and
open decision Q8, not part of the Gleam engine.

## Status

| Component | Status | Notes |
|-----------|--------|-------|
| **Target** | ✅ `erlang` | pure BEAM; no JS target, no handwritten `.mjs`/`.erl`/`.ex` under `src/` |
| **Binance REST** | ✅ Working | testnet.binance.vision (works from China), `gleam_httpc` |
| **Stream Processing** | ✅ Core Complete | SMA×5, Bollinger, KDJ, Leaf, Branch, Timeframe pipeline |
| **Tests** | ✅ Passing | **26 tests** — indicators, api, ingest boundary, and three Round-5 invariant tests |
| **Build** | ✅ Green | gleam **1.19.2** / OTP **29**: 0 errors, 0 warnings |
| **IB Client Portal** | ⚠️ Retired | The handwritten Elixir `ibkr.ex` wrapper had **zero callers** and an undeclared `ibkr_api` dep; it produced 12 build warnings. Removed under *"No handwritten erlangs"*. The FFI contract survives as `ibkr.gleam.disabled` (a design record, not compiled). |
| **Visualization** | ⚠️ Debt | `apps/glibe_web` is a Phoenix/Elixir + JS app. It is **outside** the `src/` guard and is an open owner decision (QUESTIONS.md Q8). The Gleam core does not broadcast. |
| **Guards** | ✅ Added | `scripts/guards.sh --all` — build, test, format, `no_timeframe_mixture`, `no_foreign_source`; also runs in CI |

## Quick Start

```bash
# Build Gleam core
gleam build

# Run tests
gleam test

# Run every guard (build, test, format, module purity, no foreign source)
sh scripts/guards.sh --all

# Optional, and currently DEBT: the Phoenix/Elixir visualisation
# (see QUESTIONS.md Q8 — it is not part of the Gleam engine)
cd apps/glibe_web && mix phx.server
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
│   │   ├── symbol.gleam          # Symbol = Instrument on specific Market
│   │   ├── sourcebar.gleam       # SourceBar + decode + validate + normalize_date (boundary)
│   │   └── interval.gleam        # Interval + codec (to_string/from_string/all) + bucket_ends
│   ├── binance/
│   │   ├── types.gleam           # legacy SourceBar/Interval (superseded by api/ — see DESIGN.md)
│   │   ├── kline.gleam           # Binance kline → SourceBar
│   │   └── binance.gleam         # Binance public API (gleam_httpc)
│   ├── sma.gleam                 # SMA series (Tiny/Small/Medium/Large/Huge) — five windows
│   ├── kdj.gleam                 # KDJ oscillator (LLV/HHV + SMA for K/D/M)
│   ├── bollinger.gleam           # Bollinger Bands (SMA centre, σ, Fibonacci ratios)
│   ├── indicator.gleam           # Pipeline: SMA×5 → KDJ → Bollinger
│   ├── indicator_settings.gleam  # TimeframeSettings, SmaForBbm
│   ├── databar.gleam             # DataBar — born from SourceBar, folded; 33 fields
│   ├── leaf.gleam                # DataLeaf — grown one bar at a time + CMA
│   ├── branch.gleam              # DataBranch — grown one bar at a time, rides a leaf
│   ├── timeframe.gleam           # Timeframe record + new (state only — see RULINGS.md R7)
│   ├── engine.gleam              # The pipeline: gate, processing, leaves, branches, accept
│   ├── trading/
│   │   └── strategy.gleam        # The manual verdict (manual_signal)
│   ├── export/
│   │   └── csv.gleam             # CSV export, one row per accepted bar
│   └── config.gleam              # AppConfig + default_config (single source of truth)
├── apps/glibe_web/               # Phoenix LiveView visualization
│   ├── lib/glibe_web/live/chart_live.ex
│   ├── lib/glibe_web/data_generator.ex
│   └── assets/js/chart_hook.js   # Lightweight Charts hook
└── test/
    └── glibe_test.gleam          # 23 tests
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
sourcebar_gate(timeframe: Timeframe, sourcebar: SourceBar)
  -> Result(#(Option(DataBar), Timeframe), String)

// 2. Process a completed bar — all computation happens here
databar_processing(timeframe: Timeframe, databar: DataBar, settings: TimeframeSettings)
  -> Timeframe
```

`timeframe.gleam` holds the `Timeframe` record and `new` only; every step that
moves it lives in `engine.gleam` (RULINGS.md R7). The `Result` from
`sourcebar_gate` is how a malformed bar is rejected, not repaired (RULINGS.md R8).

### `sourcebar_gate` — Time bucket aggregation
- Folds incoming `SourceBar`s into `working_databar` (OHLCV accumulation)
- Returns `Some(closed_databar)` when time bucket completes, `None` otherwise
- Decision `bucket_ends` uses ONLY timestamp + interval (proper H1/D1 bucket logic)

### `databar_processing` — The computation pipeline (holds NO arithmetic)
```gleam
pub fn databar_processing(tf: Timeframe, db: DataBar, settings: TimeframeSettings) -> Timeframe {
  let db = indicator.run(db, tf.databar_list, settings)  // JOB 1: Indicators
  let #(db, tf) = leaves(db, tf, settings)               // JOB 2: Leaf detection
  let #(db, tf) = branches(db, tf, settings)             // JOB 3: Branch detection
  accept(tf, db)                                         // JOB 4: Commit to history
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
    symbol: Symbol,              // Symbol type (not String)
    interval: Interval,
    market_type: MarketType,     // Stock | Crypto | BStock
    working_databar: Option(DataBar),  // None after close until next source bar
    databar_list: List(DataBar),       // newest-first

    // Leaf state — Option: a leaf is born on a bar, so before any bar there is none
    growing_yin_leaf: Option(DataLeaf),
    growing_yang_leaf: Option(DataLeaf),
    yin_leaf_list: List(DataLeaf),
    yang_leaf_list: List(DataLeaf),

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

Each `Timeframe` = one (symbol, interval, market_type), fully independent:
- No shared state, no locks
- Each has its own `TimeframeSettings` (per market: Stock vs Crypto have different calendars, hours, params)
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

### Visualization (Phoenix LiveView)

```
cd apps/glibe_web
mix phx.server
# http://localhost:4000
```

Real-time BTCUSDT 1h chart with:
- Candlesticks + SMA Tiny (blue) / SMA Medium (orange)
- Yin leaves (green ▲) / Yang leaves (red ▼)
- Yin/Yang branch markers (circles with entry/exit info)
- Updates every 2 seconds via Phoenix PubSub

## Visualization

The web app (`apps/glibe_web`, Phoenix LiveView + Lightweight Charts) renders the
engine's output. **The Gleam core does not broadcast** — `broadcast_chart` was
removed; nothing in `src/glibe` sends bars over SSE. The web app obtains bars from
the engine and draws candlesticks with indicator overlays.

The engine's one exporter is `export/csv.gleam` (`to_csv`), which writes one row
per accepted bar, oldest first — for checking the engine against something that is
not the engine (TradingView, a spreadsheet, another implementation). An exporter is
not part of the engine (RULINGS.md R7).

## Roadmap

See `.planning/ROADMAP.md` for detailed phases, and
[`docs/QUESTIONS.md`](docs/QUESTIONS.md) for the current open items (the old
Stage D items were withdrawn in Round 5 — they were already fixed).
- Phase 1: Stream Processing Core ✅
- Phase 2: Binance Live Feed Integration (next)
- Phase 3: Tests & Verification
- Phase 4: IB API Wrapper
- Phase 5: Strategy & Trading Separation
- Phase 6: Integration & Examples

## Recent Fixes (2026-09-25)

1. **TradingHours parsing** — Fixed `:` delimiter bug for RTH/Custom formats (now uses `;`)
2. **Timeframe bucket_ends** — Implemented proper H1/D1 bucket logic (was always `True`)
3. **Leaf/Branch detection** — Fixed O(n²) full regeneration bug (now incremental)
4. **Zero warnings** — `gleam build` / `gleam test` clean, `gleam format --check` clean
5. **Tests added** — 23 tests (config, asset, rules, indicators, ingest boundary)

## Recent Fixes (2026-10-04)

1. **Module purity** — `timeframe.gleam` now holds the record and `new` only; the
   pipeline moved to `engine.gleam`. `scripts/no_timeframe_mixture.sh` fails the
   build if the mixture returns (RULINGS.md R7).
2. **Ingest boundary** — `api/sourcebar.gleam` `validate` rejects a malformed bar
   (never repairs); `normalize_date` turns epoch-milliseconds into ISO-8601 at the
   boundary, fixing the H1 bug where an hourly bar never closed on Binance data.
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
   the lower edge **before** interpolation, not three clamps. `QUESTIONS.md` Q3
   had misquoted the ruling as "no floor" (RULINGS.md R12).
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