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

## Phase 04 Plan 09 更正 / R32 — 结构是花园（2026-11-10，历史；并发框架经 R33 作废）

> **R33 更正**：本段「每个 Timeframe 都活着 / 花盆自己的生命 / glib 核实：
> 已落地」三处作废 —— 系统本来就活，「叶子」特指 `YinLeaf` / `YangLeaf`，
> glib 不是权威。原文保留为历史；花园方法论仍成立。现行规格见下面 R33 段。

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
  决策区仍 0 项。~~让叶子活起来的运行时是后续工作~~ **R33 作废**：
  该系统本来就活，没有「让叶子活起来」这一步。

---

## R33 — 系统本来就是活的（2026-11-10，当前）

owner 09:57 / 09:59 / 10:04 / 10:09 四条逐字原话在 `docs/RULINGS.md` R33。

- **管道本来就是活的**：*`api provider / data sources → history + live data
  → sourcebar_gate → databar_processing → model ↔ view`*。history 与 live
  是同一条数据流；`view` 是 `model` 的投影。**每一个 type 都是活的：数据动，
  它就动，因为定义好了**（纯值随数据重算），不是进程 / actor / 调度 /
  「让叶子活起来的运行时」。
- **数据为什么会动**：订阅了数据源的实时数据；推送 / 订阅 / 主动获取各家
  用自己的方式，属输入边界事实，汇合点只有标准 `SourceBar`（R28）。
  **没有数据系统就不动了，睡觉，等待** —— 静止正常，无需时钟 / 轮询 /
  心跳补救。
- **Desk 是唯一顶层 Value**，逐层嵌套成完整系统（`Desk ▸ Broker ▸
  Instrument ▸ Interval ▸ Timeframe`，Broker 另有 `accounts`）。
  *"在Gleam世界里面，你唯一要做的就是定义types，基本结构对了，什么都有了"*。
- **撤回**：`monitor.advance` / `TimeframeAddress` / `IncomingBar` /
  `MonitorError` 非本系统 type；actor 是结构没设计对才找的补救；
  「叶子」特指 `YinLeaf` / `YangLeaf`，此前泛指 Timeframe 的用法作废；
  R31 并发框架、R32「每个 Timeframe 活着」措辞作废。**R32 花园方法论
  （加 field / 倒推隶属 / 集合对比 / R26）仍成立**。
- **glib 不是权威**：可能只记录设计与计划、未必落实，已落实的也未必对；
  唯一权威是 owner 当前陈述。上面「glib 核实：已落地」类断言全部降级为
  「读过 glib，不作依据」。seib → glib → glibe 是思路沿革，不是正确性证明链。
- **本轮范围**：记裁定 + 撤回 + 清理词汇；**不删生产代码、不新增 type、
  不写 probe、不加依赖**。`monitor.gleam` 的处置由 owner 定。决策区仍 0 项。

---

## R34 — seib 结构对（只缺多 broker 层）；ibOptions 结构不好（2026-11-10，当前）

owner 逐字原话与 **10:26 / 10:29 两次更正**在 `docs/RULINGS.md` R34。
初稿把两者并列成同一缺陷是错的，已改正。

- **结构评价（分开看）**：两者共同的事实只有**都仅支持一个 broker**。
  **seib 的结构是对的**（owner 10:26 逐字）：「大格局都有了，细节也有了」；
  它**只缺一层「多个经纪商数据提供者」**（当时没有 binance，owner
  「我印象中」仅 IB 一个数据源），缺层不是结构错误。**seib 不存在
  「settings 应该是 types」这件事。** ibOptions 结构不好，同样单 broker。
  seib → glib → glibe 仍是思路沿革，不是正确性证明链（R33）。
- **ibOptions 的定位 + 因果（10:29）**：owner 逐字 *"ibOptions受制于
  Python+Pandas的局限性，才会变成那样"* —— **是语言 / 库的局限使结构性
  关系无法写成 type，才被迫压进 settings 文件**；不是随意乱做，更不是
  seib 的缺陷。它**只能看里面涉及哪些设置**：正常手工与自动交易的细节
  需求它都有，是**需求清单**，不是可搬的架构。那些设置本应是 type
  定义，在 glibe 里是 type 或已有 Type 定义里的一个 field
  （R13 / R19 / R32），不建通用配置表 / 字符串键 / 解析器。
- **seib 缺的那一层已在树里**（补层，不是修 seib 的结构，也不搬
  ibOptions 的 settings）：`Desk(brokers: Dict(BrokerId, Broker))`
  （`src/glibe/desk.gleam:92-93`）+ `config.default_config()` 的
  `binance` / `ib` / `futu`（`src/glibe/config.gleam:87-101`）。
  对应 R33 顶层唯一 Value 与管道头 `api provider / data sources`；
  **不另架 provider 框架、不新增 provider 类型**，R26 关系不变。
- **执行边界**：不因 settings 清单批量预造 type（R26 / R32）；
  某个设置有真实消费方时才按倒推隶属加 field。R29 的 ibOptions
  引用降级为时区事实线索，不作架构依据。**本轮只写文档与记忆**：
  不改 `src/`、不加依赖、不写 probe、决策区仍 0 项。R33 规格不变。

---

## R35 — SwiftUI 的 View 是同类；简单是正确的验证码（2026-11-10，当前）

owner 逐字原话在 `docs/RULINGS.md` R35。

- **相似只指 View 的定义和实现**（纯 functional + value types），不是
  Swift 整体：view model 有 class、model 不限 struct/class/actor，把
  简单的事做复杂，数据竞争要大量补救 —— **Gleam 里不可能出现**。
- **SwiftUI 的 view 为什么会更新 = R33**：type 定义好、函数定义对，
  系统本身就是活的；view 是值的投影，数据动就重算，不需运行时 / actor。
- **并发课题遇到再查官网资料 + 做几个不同方案 demo 对比研究解决**，
  即 TDD 的落实（R19 / R24）；不预先搭并发框架。
- *「简单是正确的验证码。如果复杂，基本上可以判断type 函数和模块定义
  有错误」* —— 复杂是设计出错信号，回去修 type / 函数 / 模块定义，
  而不是加机制补救（根法 / R33）。

---

## R36 — type 系统核对：当前链无断层，Market 不持有 Broker（2026-11-10，当前）

owner 逐字原话在 `docs/RULINGS.md` R36。

- **glib 记录位置（只作线索，R33 不作依据）**：owner 要求 AI 记的主要
  type 系统在 `~/gits/hub/tools_ib/glib/docs/SYSTEM_MODEL.md` §2
  `:102-119` 与 `docs/reference/domain-hierarchy-2026-10-22.md`；
  `glib/README.md:907` 只有 Phase 32 一行清单。glib 文档里
  `Market = Exchange + AssetClass + MarketRules`、
  `Instrument = Asset on Market` 是 AI prose / 旧设计，R22 / R26 已否定。
- **glibe 现有链与 owner 记忆逐项对上、没有缺少**：`Desk ▸ Broker
  (instruments + accounts) ▸ Instrument ▸ Dict(Interval, Timeframe)
  ▸ Timeframe`，`Desk` 顶层唯一 Value（R20 / R23 / R33）。
- **断层判断（逐项）**：**`Market` 与 `Broker` 两个方向都不隶属 →
  否决**，`Desk` 直接持有 Brokers 合乎事实、**无断层**；
  `Asset` / `Exchange` / `Market` 按 R26 开放且与 `Desk` 无类型连接；
  `APIProvider` 与 broker 同物（R26）；`Account` 已由 Broker 持有
  （当前 keyless，等消费方的开放项）；`Symbol` / `Interval` 是 key 不是层。
- **结论：无断层、不新增 type / field / 关系**（R26 / R32 / R34 / R35）。
  「如此等等」= 每个新候选都按 R32 倒推隶属，双向都不隶属就像
  `Market` 一样否决；本轮只读核对，不改 `src/`、决策区仍 0 项。

---

## R37 — 主干层判据 / 依附 ≠ 隶属 / 身份在持有者的 key（2026-11-10，当前）

owner 逐字原话在 `docs/RULINGS.md` R37。他举 Desk/Market/Broker 是**教
思考方法**，R36 只记结论不够，本段补判据。

- **主干判据**：构成层次某一层的 type，必须**跟上下级存在两个隶属关系**
  （既隶属上层、又拥有下层）。`Desk ▸ Broker ▸ Instrument ▸ Timeframe`
  每层满足；`Market` 与 `Broker` 双向都不隶属 → 不是主干的一层。
- **非主干只有两种去处**：**依附于某 type 但不是隶属** → 附着在该 type
  上，不插进上下级、不产生层级；**不依附任何 type** → 放 `Desk`
  （*"因为他至少属于我们系统吧"*，给 R32 补上理由）。
  `Asset` / `Exchange` / `Market` 具体放哪仍按 R26 等消费方，本条不预定。
- **身份在持有者的 Dict key**：`interval` 不是 `Timeframe` 的 field，
  `brokerId` 不是 `Broker` 的 field；分别是 `Instrument.timeframes`、
  `Desk.brokers` 的 key（`Symbol` 同理）。被持有者不命名持有者，
  也不知道自己的方位 —— owner 10:37 逐字 *"你的左手不知道他是左还是右，
  同样，Timeframe不应该知道他是什么interval"*：左 / 右是持有者给的
  方位标签，谁持有谁命名。
- **owner 指路的 glib 思路记录（仅线索，R33）**：
  `~/gits/hub/tools_ib/glib/docs/NAMING.md:575-589`
  （"the owner holds what it owns…"、"A collection is not an
  owner-pointer"）、`~/gits/hub/tools_ib/glib/docs/DESIGN.md` §18.2
  `:3269-3299`（owner 2026-11-04 关于 interval 作 key 的逐字、每层
  集合按真实访问方式选）。glib 写 `Desk → List(Broker)`；glibe 的
  `Dict(BrokerId, Broker)` 是 R32 的选择，不是搬来的。
- **执行边界**：判定法则，不重构 `src/`、不改现有 key、不加 type /
  field / 依赖 / probe；决策区仍 0 项。（10:42 起按 04-10 落代码文档 /
  测试 / 一个纯读取；结构本身不变。见下一段。）

---

## 04-10 — 裁定进入代码：概念 → type definition → unit test → implementation（2026-11-10 10:42，当前）

owner 逐字原话在 `docs/RULINGS.md` 文末执行注记与
`.planning/phases/04-domain-cleanup/04-10-PLAN.md`。结果在
`04-10-SUMMARY.md`。

- **制作流程（R19）**：「实际完成方式」就是**一个 module 文件的制作
  流程** —— 描述 → 空架子（没有实际东西）→ test（设计目标在此）→
  逐步实现；逐字全文在 `docs/RULINGS.md` 文末同名段。
- **11:05 批评（逐字在 `docs/RULINGS.md` 11:05 段）**：04-10 **不是**
  流程示例 —— 代码先有、文档与测试后补，是「倒过来整」的反向补课；
  不得把 retrofit 包装成按流程制作。今后新建 module 必须从描述开始。
- **本轮实际做了什么（retrofit）**：`////` 模块文档命名 04-10 计划 + 逐项 `///` →
  不新增 type、只留带 `todo` 的签名 → `test/level_judgement_test.gleam`
  （RED 68/2）→ 填 `desk.timeframe_under`（GREEN 70/0）。
- **概念按模块归位**：`desk.gleam` = R33 / R36 / R37（含「Market 尚未定」
  旧句的更正）；`config.gleam` = R34；`timeframe.gleam` / `symbol.gleam` /
  `interval.gleam` = R37；`web/server.gleam` = R35。
- **没有新 type、新 field、新关系**：`Desk ▸ Broker ▸ Instrument ▸
  Timeframe` 本就是裁定描述的定义，加 type 反而违反 R35「简单是正确的
  验证码」。唯一新实现是纯读取，不是 R33 作废的 `monitor.advance`。
- **验证**：`package-interface.json` 两包核对，六个模块文档与函数文档
  全文渲染、带 04-10 链接；`BUILD_WAE=0` / `TEST=0`（70 passed）/
  `FORMAT=0` / `guards: all green` / `DOCS=0` / `cmp=0`。
- **范围不变**：不碰三张目录表、不改 `monitor.gleam`、不预设
  Asset / Exchange / Market 关系、不加依赖、不写 probe、决策区仍 0 项。
  真正待做的工作仍是 R33 的实时数据源接入标准 `SourceBar` 入口 +
  replay CLI；`monitor.gleam` 处置由 owner 定。
