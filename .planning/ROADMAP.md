# Roadmap: glibe - Multi-API Trading Library

## Milestones

### v1.0 - Core Stream Processing (In Progress)
- Phase 1: Stream Processing Core ✅ (indicators, leaves, branches, timeframe)
- Phase 2: Binance Live Feed Integration (Not Started)
- Phase 3: Tests & Verification (Not Started)

### v1.1 - IB API Wrapper (Planned)
- Phase 4: IB Client Portal API via Elixir

### v1.2 - Strategy & Trading Separation (Planned)
- Phase 5: Strategy side (signal, adapter)
- Phase 6: Trading side (brokers, execution, risk)

### v1.3 - Integration & Examples (Planned)
- Phase 7: End-to-end examples

---

## Phase 1: Stream Processing Core ✅
**Goal**: Pure Gleam indicator pipeline with SMA, KDJ, Bollinger, Leaf/Branch detection

### Completed
- Types split: `api/` (SourceBar, Interval, MarketType, Asset, Market, Symbol, Rules), `databar.gleam`, `indicators.gleam`
- SMA series (Tiny/Small/Medium/Large) with 3-case incremental logic
- KDJ oscillator (LLV/HHV + SMA for K/D/M)
- Bollinger Bands (selected SMA centre, σ from window, Fibonacci ratios)
- Indicator pipeline: SMA×4 → KDJ → Bollinger
- Leaf detection: Yin/Yang leaves with CMA
- Branch detection: Yin/Yang branches with 9 laws
- Timeframe pipeline: sourcebar_gate → indicators → leaves → branches → strategy → runtime_test → accept
- Config.gleam: Single source of truth with string-based parsing for AssetClass, TradingHours, SettlementType, AuctionType, CircuitBreaker

### Files
- `src/glibe/api/asset.gleam` — Asset, AssetRef, AssetClass, asset_class_from_string
- `src/glibe/api/rules.gleam` — MarketRules, TradingHours, SettlementType, etc. + parsers
- `src/glibe/api/exchange.gleam` — Exchange, MarketType
- `src/glibe/api/symbol.gleam` — Symbol with market_id, asset_id, base/quote assets
- `src/glibe/api/market.gleam` — Market = Exchange + AssetClass + Rules
- `src/glibe/api/sourcebar.gleam` — SourceBar + JSON decode
- `src/glibe/api/interval.gleam` — Interval (7 variants at this phase; all constructors renamed to full descriptive names per R21, 9 variants per plan 04-02)
- `src/glibe/indicators.gleam` — TimeframeSettings, SmaSeries, SmaForBbm
- `src/glibe/sma.gleam` — SMA incremental logic
- `src/glibe/kdj.gleam` — KDJ oscillator
- `src/glibe/bollinger.gleam` — Bollinger Bands
- `src/glibe/leaf.gleam` — Yin/Yang leaf detection
- `src/glibe/branch.gleam` — Yin/Yang branch detection (9 laws)
- `src/glibe/databar.gleam` — DataBar type
- `src/glibe/timeframe.gleam` — Timeframe + full pipeline
- `src/glibe/indicator_settings.gleam` — Indicator settings
- `src/glibe/indicator.gleam` — Indicator runner
- `src/glibe/config.gleam` — AppConfig + default_config

### Verification
- ✅ `gleam build` succeeds with zero warnings

---

## Phase 2: Binance Live Feed Integration 📋
**Goal**: Connect Binance klines (Crypto + BStock) to Timeframe pipeline

### Remaining Tasks
1. **Update `binance.gleam`** — Return `SourceBar` with `Symbol` context, handle Crypto + BStock symbols
2. **Update `timeframe.gleam`** — Replace `symbol: String` with `symbol: Symbol`, use `Market` instead of `MarketType`
3. **Create integration module** — `binance_timeframe.gleam` that feeds klines into Timeframe
4. **Binance WebSocket streaming** — Real-time klines via WebSocket (future)

### Files
- `src/glibe/binance/binance.gleam` — Extend for Crypto + BStock symbols
- `src/glibe/binance/types.gleam` — SourceBar, Interval (already exists)
- `src/glibe/binance_timeframe.gleam` — New: Binance → Timeframe integration
- `src/glibe/timeframe.gleam` — Update to use Symbol + Market

### Dependencies
- Phase 1 (core types and pipeline)

### Verification
- [ ] Binance klines (BTCUSDT, TSLAB/USDT) → Timeframe → indicators → leaves → branches
- [ ] `gleam build` succeeds

---

## Phase 3: Tests & Verification 📋
**Goal**: Comprehensive test coverage and TradingView CSV verification

### Tasks
1. **Unit tests** — SMA incremental logic, KDJ math, Bollinger math
2. **Leaf/Branch invariant tests** — 9 branch laws, index ordering
3. **Property tests** — Timeframe state consistency after N bars
4. **Integration test** — Binance data → Timeframe → CSV export
5. **TradingView verification** — Compare CSV output with Pine Script

### Files
- `test/glebe_stream_test.gleam` — Stream processing tests
- `test/glebe_indicators_test.gleam` — Indicator math tests
- `test/glebe_leaf_branch_test.gleam` — Leaf/Branch invariant tests
- `test/glebe_binance_test.gleam` — Binance integration test

### Dependencies
- Phase 2 (Binance integration)

### Verification
- [ ] `gleam test` passes all tests
- [ ] CSV output matches TradingView Pine Script reference

---

## Phase 4: IB API Wrapper (v1.1) 📋
**Goal**: IB Client Portal API via Elixir ibkr_api library

### Tasks
1. **Enable `ibkr.gleam` FFI** — Fix websockex incompatibility or use alternative
2. **Implement `Glibe.Ibkr` Elixir module** — Auth, accounts, positions, orders, market data, historical data
3. **Gleam FFI bindings** — Type-safe Erlang interop
4. **Gleam public API** — `ibkr.gleam` with Result types

### Files
- `src/glibe/ib/ibkr.ex` — Elixir wrapper
- `src/glibe/ib/ibkr.gleam` — Gleam public API (currently disabled)

### Dependencies
- None (independent)

### Verification
- [ ] Gateway auth status returns `authenticated: true`
- [ ] Account data, positions, orders retrievable
- [ ] Market data snapshots work
- [ ] Historical data retrievable
- [ ] Order placement works

---

## Phase 5: Strategy & Trading Separation (v1.2) 📋
**Goal**: Clean architecture boundary between pure strategy logic and trading complexity

### Tasks
1. **Strategy side modules** — `signal.gleam`, `indicators/`, `fractal/`, `timeframe.gleam`, `databar.gleam`
2. **Trading side modules** — `broker/`, `api_provider/`, `execution/`, `market/`, `risk/`, `settlement/`
3. **Adapter layer** — `StrategyAdapter` (Signal → Order)
4. **Security object** — Per-symbol model container (QuantConnect pattern)

### Files
- `src/glibe/strategy/*.gleam`
- `src/glibe/trading/*.gleam`
- `src/glibe/api/*.gleam` (shared minimal types)

### Dependencies
- Phase 1 (core types), Phase 4 (IB client)

### Verification
- [ ] Strategy code never imports trading types
- [ ] Adapter correctly converts Signal → Order

---

## Phase 6: Integration & Examples (v1.3) 📋
**Goal**: End-to-end examples and documentation

### Tasks
1. **IB example** — IB data → indicators → signals
2. **Binance example** — Binance data → indicators → signals
3. **Integration tests** — Full pipeline tests
4. **Documentation** — README, API docs

### Files
- `src/ib_example.gleam`
- `src/binance_example.gleam`
- `test/` — integration tests

### Dependencies
- Phase 3 (tests), Phase 5 (strategy/trading)

### Verification
- [ ] Examples run successfully
- [ ] All tests pass

---

## Architecture Summary

| Layer | Technology | Status |
|-------|------------|--------|
| Core Types | Gleam (`api/`) | ✅ |
| Indicators | Gleam (SMA, KDJ, Bollinger) | ✅ |
| Fractal | Gleam (Leaf, Branch) | ✅ |
| Timeframe Pipeline | Gleam | ✅ |
| Config | Gleam (`config.gleam`) | ✅ |
| Binance Client | Gleam (`gleam_httpc`) | 🔄 Needs integration |
| IB Client | Elixir (`ibkr_api` + Finch) | 📋 FFI disabled |
| Business Logic | Gleam (pure) | 📋 |
| Visualization | Phoenix LiveView + Lightweight Charts | ✅ Compiles |

---

## Progress Summary

| Phase | Status | Completed |
|-------|--------|-----------|
| 1. Stream Processing Core | Complete | 2026-09-25 |
| 2. Binance Live Feed Integration | Not Started | - |
| 3. Tests & Verification | Not Started | - |
| 4. IB API Wrapper | Not Started | - |
| 5. Strategy/Trading Separation | Not Started | - |
| 6. Integration & Examples | Not Started | - |

---

## Key Improvements Made (2026-09-25)

1. **Zero Gleam warnings** — Fixed panic-as-function, unused imports, detached doc comments
2. **Zero Phoenix warnings** — Fixed unused imports, duplicate @doc, missing @impl
3. **Config.gleam** — Single source of truth with string-based variant parsing
4. **AssetClass/TradingHours/etc. parsing** — String-based parsers for config
5. **Phoenix app** — LiveView + Lightweight Charts compiles clean

---

## 2026-11-07 addendum — Phase 04-01 (typed ownership chain)

Added `.planning/phases/04-domain-cleanup/04-01-PLAN.md` and its SUMMARY.
R20 rules that `Desk` / `Broker` / `Account` / `Instrument` are must-have because
`config.gleam`'s `symbols` and `timeframe_settings` lists need typed owners;
`REVIEW_ROUND5.md`'s exclusion of those shells is reversed for this chain only.
The plan lands `src/glibe/desk.gleam` as the first documentation-first / TDD
module with a `////` link to the plan. **`config.gleam` itself is unchanged** —
migrating its two String-keyed tables is a separate plan and an owner decision.
Name: `Desk`, not `Deck`. See `docs/RULINGS.md` R20.

> 2026-11-09 status: the two tables no longer exist. Phase 04 Plan 03 (R22,
> R23) deleted them, their `"BTCUSDT_H1"` composite keys and both `list.find`
> accessors; `AppConfig` now holds a typed `Desk`. The "separate plan / owner
> decision" line above was true when written and is history now.

## Phase 04 Plan 02 — typed intervals (2026-11-08)
Added `.planning/phases/04-domain-cleanup/04-02-PLAN.md` and its SUMMARY.
`Interval` is now a 9-variant closed set with fully named constructors (R21);
the 14 per-interval limit tables in `config.gleam` are `Dict(Interval, Int)`;
`rules.LimitError` is the typed lookup failure. Second measured docs-first/TDD
cycle: RED 37 passed / 7 failures, GREEN 44 passed / 0 warnings / guards 0.
The thinking core's own short-code example was corrected and re-mirrored.
**`config.gleam`'s `symbols` / `timeframe_settings` tables are still untouched** —
their migration and the `Symbol` / `Instrument` naming question remain owner
rulings. See `docs/RULINGS.md` R20, R21.

> 2026-11-09 status: both items are settled, not open. R22 ruled `Symbol` is
> never `Instrument`; R23 ruled `TimeframeSettings` is not an entity and moved
> settings into `Timeframe`. Both tables were deleted. See Plan 03 below.

## Phase 04 Plan 03 — one name, one entity, one owner (2026-11-09)
Added `.planning/phases/04-domain-cleanup/04-03-PLAN.md` and its SUMMARY.
R22 rules that `Symbol` is a name and never the `Instrument`; the false
`Symbol = Instrument = Asset on specific Market` line and its nine unread
fields are deleted. R23 rules that `TimeframeSettings` is not an entity: the
second `Dict(Interval, TimeframeSettings)`, the `"BTCUSDT_H1"` composite
string table and both `list.find` accessors are deleted; settings become
`Timeframe.settings` and `Timeframe` stops carrying `symbol` / `interval` /
`market_type`. R24 makes the web-layer framework comparison the AI's demo
work, not an owner ruling. R25 keeps `TPlus1` / `TPlus2` — an industry term
is not an exchange wire code. Third measured docs-first/TDD cycle:
RED 41 compile errors, GREEN 50 passed / 0 warnings / guards 0.
See `docs/RULINGS.md` R22–R25.

## R26 — catalogue relations are open (2026-11-09)

Owner ruled that only `Broker ▸ Instrument` is settled from the data-source
argument; relations among `Asset` / `Exchange` / `Market` and to `Instrument`
are hard to settle now, so types are added one at a time when a consumer needs
one. No advance identity-typing plan, no speculative `Market` level on
`Instrument`. Measured: `get_asset` and `get_exchange` have zero callers,
`get_market` one (a test). Full text: `docs/RULINGS.md` R26;
current shape: `docs/DESIGN.md` "The catalogue tables are NOT in the ownership
chain".

## Phase 04 Plan 04 — BEAM web-layer demos (2026-11-09)

Added `.planning/phases/04-domain-cleanup/04-04-PLAN.md`, its SUMMARY, and
three runnable Erlang-target demos in `probes/web-layer/`. R24 discharged:
Mist+Wisp (72 Gleam lines / 22 Hex), +Lustre server component (124 / 23), bare
Mist (82 / 14); all with 0 hand-written JS and 0 npm deps. Real HTTP requests
proved one settled bar reached both the HTML view and the JSON endpoint; demo
B's `/poll` returned a real Lustre `Mount` patch. Node imports the generated
`webclient.mjs`. Recommendation A recorded in `docs/DESIGN.md`: thin Mist+Wisp
data endpoints, view in the generated `.mjs`, no Lustre server components by
default. **Not adopted at the time** — root `gleam.toml` and `src/` untouched.

## Phase 04 Plan 05 — adopt R24 A (2026-11-09)

Added `.planning/phases/04-domain-cleanup/04-05-PLAN.md`, its SUMMARY,
`src/glibe/web/server.gleam` and `test/web_server_test.gleam`. Root
`gleam.toml` gains `mist` + `wisp` (Hex only); no npm dep, no `target` change,
no new package. A closed `Route` type names the endpoints; `GET /` renders the
real configured `Desk` as an HTML table, `GET /desk` returns the same
`Desk ▸ Broker ▸ Instrument ▸ Interval` chain as JSON. Run with
`gleam run -m glibe/web/server` on port 8610 so the root library keeps no
global `main` slot. Fourth measured docs-first/TDD cycle: RED 50 passed /
4 `todo` failures, GREEN 54 passed / 0 warnings / guards 0; real HTTP
200 / 200 / 404. `package-interface.json` carries the `04-05-PLAN` link.
This adoption is AI work under R24, not a new owner ruling; owner items stay
at zero. Chart, streaming and SPA interaction remain out of scope.


## Phase 04 Plan 06 — unix time at the ingest boundary (2026-11-09)

Owner rulings R27 (standard bar time is unix time), R28 (native provider bars
stay native and standardise themselves, names included), R29 (US daylight
saving needs an IANA library, not a fixed offset). Standard `SourceBar` /
`DataBar` hold `gleam_time.Timestamp`; `binance/kline.gleam` keeps all twelve
native `Kline` fields and `to_sourcebar`; `bucket_ends` is unix-second
arithmetic. An early `BarClock` draft was voided by R27 and deleted with no
compatibility layer. Fifth docs-first cycle: RED 54 passed / 11 `todo`
failures, GREEN 58 passed / 0 warnings / guards 0 / docs 0. `tzif` is
deliberately not a dependency yet (R26).


## Phase 04 Plan 07 — local time in the web view (2026-11-09)

Owner ruling R30: date-times in the web interface are shown in local time so
analysis is readable, which requires time-zone conversion and daylight saving;
the owner asked for documentation in the corresponding modules first. R30 is
the output-side projection of the same unix-time `Timestamp` (R27) that R29
converts on the input side; neither changes the standard bar, the UTC-aligned
bucket grid or the CSV UTC RFC3339 export. `tzif` 2.0.0 stays a verified
library, not a dependency (R26). This round delivers only `////` module docs
linking `.planning/phases/04-domain-cleanup/04-07-PLAN.md` in four modules
across both packages; `package-interface.json` in each carries the link. No
implementation, no new type, no test, no owner decision item.


## Phase 04 Plan 08 — one addressed bar, one timeframe (2026-11-09)

Owner asked whether the type structure can already monitor many instruments,
each with many intervals, at the same time, and said to continue if not. The
static `Desk ▸ Broker ▸ Instrument ▸ Interval ▸ Timeframe` chain was already
complete (six independent states in `config.gleam`); the arrival of a bar was
not. New `src/glibe/monitor.gleam` gives a bar a typed `TimeframeAddress`,
pairs it once with the standard bar as `IncomingBar`, replaces the gate's
`String` failure with `SourceBarRejection` / `MonitorError`, and provides the
pure `advance(desk, incoming) -> Result(Desk, MonitorError)`. One bar advances
exactly one `Timeframe`; no interval fan-out, no field on `SourceBar` or
`Timeframe`, no `Market` relation (R26), no actor or stream (Stage F).
Sixth docs-first cycle: RED 58 passed / 6 `todo` failures, GREEN **64 passed**
/ 0 warnings / guards 0 / format 0 / docs 0; `package-interface.json` carries
the `04-08-PLAN` link on all four touched modules. Not an owner ruling.


## Phase 04 Plan 09 — Gleam 的天然并行（2026-11-09，DEFERRED，仅记录）

Owner 指出：Gleam 天然并行、并行任务非常简单自然，不需要把「受监督 actor /
订阅 / 行情流」当成一整套复杂补救机制；要求看官网与 Wisp / Lustre 等著名代码。
**owner 06:07 指示今天浅尝即止，明天继续，今天只记录。**
Owner 06:09 纠正研究范围：*"你去看什么javascript target完全不对路，我们是erlang
和 BEAM专属项目"* —— 只看 Erlang / BEAM，不考察 JavaScript target。
已查到的官网原文、v0.12 发布文、`gleam_erlang/process` 与 `gleam_otp/actor`
的 API、Wisp（0 处 `process.`）/ Mist-glisten（每连接一进程 + 监督池）/
Lustre（服务端 runtime 恰一个 actor + factory supervisor）的 file:line 证据，
以及我自己的两处事实错误，全部写在
`.planning/phases/04-domain-cleanup/04-09-PLAN.md`。
**今天没有改代码、没有建 probe、没有加依赖、没有改既有结论。** 明天按该文件
§4 继续。不是待裁决项。


## Phase 04 Plan 09 — 完成（2026-11-10，R31）

按 11-09 的接手点复工，范围严格 Erlang / BEAM。`probes/parallel-bars/`
（独立 Erlang-target 包，`glibe` path 依赖）按 R19 走完 RED→GREEN：
骨架 + `////` 点名 `04-09-PLAN.md` → 4 个测试 RED（0 passed / 4 failures /
0 错误）→ 填体 GREEN（4 passed / `--warnings-as-errors` 0/0）。
`gleam run -m parallel_bars` 实测 **6 个带地址 bar → 6 个不同 BEAM Pid**、
回复逆序到达、**0 actor / 0 supervisor / 0 lock / 0 FFI**、4 tests green。
**0/6 份并行 `Desk` 等于单一 owner fold 的结果**：不可变值不会自己合并，
要么一个 owner 顺序 fold，要么每个地址自持 `Timeframe`；这是所有权/数据流
决定，不是同步补救措施（R26，不新增生产类型）。生产代码逻辑未改
（`monitor.gleam` 仅同步 `////` 模块文档），依赖未加。
`docs/RULINGS.md` 新增 **R31**（owner 原话逐字 + 官方证据 + actor 定位 +
值住在各进程自己的堆 + 实测 + 两处事实更正）；`docs/DESIGN.md` 新增
「Parallel addressed steps are already natural」并重写 `:101` 表格、
04-08 段末与「What glibe does not do yet」的 Stage F 框架；`README.md`、
`docs/STATE.md`、`docs/PENDING_DECISIONS.md`（仅 `# REFERENCE`）、记忆同步。
`gleam_otp` 早已是根包直接依赖，已纠正「没引入」的错误说法。
决策区仍 0 项；历史计划/总结保留旧措辞。详见
`.planning/phases/04-domain-cleanup/04-09-SUMMARY.md`。
**2026-11-10 更正（R32）**：本条「0/6 合并 / 所有权决定」的结论作废 —— 该 probe
复制了 `Desk`，而真实结构里 Desk 只有一个。

## Phase 04 Plan 09 更正 / R32 — 结构是花园（2026-11-10，当前）

owner 09:45：*"结构复述正确，不过这是一个花园，不断根据需要往里面加新的花盆。实际上就是在Type定义中加新field而已 … 那就倒推他和其他type现实中什么关系呢？隶属于谁呢？如果谁也不隶属，是其他关系，那么可能放在Desk里面就好了，那么用dict还是list还是其他东西放呢？根据需要来对比研究决定。"* 逐字全文在 `docs/RULINGS.md` R32。

- **结构**：一个 `Desk` → 若干 Broker（binance、ib）→ 每个 Broker 有
  `Instruments` 与 `accounts` → 每个 `Instrument` 有 `Dict(Interval, Timeframe)`
  → **每个 Timeframe 都活着**，处理数据、进行交易。并发不是外部机制，是花盆
  自己的生命；没有 N 份 `Desk`、没有合并。
- **方法**：加一个新事物 = 在已有 Type 定义里加一个 field；位置靠倒推「现实中
  隶属于谁」，谁也不隶属就放 `Desk`（`exchanges` 是 owner 的例子）；集合用
  `Dict` / `List` / 其他，按真实访问方式对比研究决定。R26 仍成立：不预先把
  `Asset` / `Exchange` / `Market` 塞进链里。
- **glib 核实**：四类型链与 `accounts` / `Dict(Interval, Timeframe)` 已在
  glib 源码落地（`desk.gleam:11-13`、`broker.gleam:29-34`、
  `domain/instrument.gleam:76-82`），但 glib 是 JS target，运行时仍是
  single-stream，「每个 Timeframe 活着」未做到。
- **撤回**：04-09 的 `probes/parallel-bars/` 形状错误（复制 `Desk`），其
  「0/6 合并 / 所有权」结论及写进 R31、DESIGN、README、STATE、PENDING 的
  相应框架作废；官方 BEAM 证据保留。probe 保留为带作废注记的历史实验。
- 本轮只记录裁定与撤回，**不加生产类型、不改 `src/` 逻辑、不写新 probe**；
  决策区仍 0 项。让叶子活起来的运行时是后续按 R32「加 field」的按序工作。
