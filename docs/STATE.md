# State — glibe

Measured facts. Each line carries the day it was taken, so a later reader can
tell a measurement from an intention. **The newest section is the state.** Older
sections are kept as history, not as the current answer.

## 2026-11-10 (R34–R37 — 先驱定位、SwiftUI 类比、层次核对与主干判据；当前状态)

> **owner 10:26 更正（逐字）**：*"注意我说的seib的结构是对的，ibOptions结构
> 不好，用settings解决结构问题，按照你的复述，可就变成了seib也不对，他的
> settings也应该是types。这就乱了。"* 本段初稿把两者并列成同一缺陷，已按
> 此更正。

- **owner 逐字裁定**在 `docs/RULINGS.md` R34。两者共同的事实只有
  **都仅支持一个 broker / 数据源**，结构评价完全不同：
  - **seib 的结构是对的**（owner 10:26 逐字）：「大格局都有了，细节
    也有了」。它**只缺一层**「多个经纪商数据提供者」——当时没有
    binance（owner 带「我印象中」：仅 IB 一个数据源）。缺这一层不是
    结构错误；**seib 不存在「settings 应该是 types」这件事**。
  - **ibOptions 结构不好**：Python + pandas 架构不足取，靠配置解决
    结构性问题；它**只能看有哪些设置**，正常手工和自动交易涉及的
    所有细节它都有，但结构不行。它同样只有一个 broker。
- **settings 是被压扁的 type（仅 ibOptions，与 seib 无关）**：那些设置本应由 type 定义，被迫做成了
  settings 文件。在 glibe 里，现实事物是 type，某事物的一方面是已有
  Type 定义里的一个 field（R32 / R26）；不搬 ibOptions 的配置形状、
  不预先批量造 type、不预设 `Asset` / `Exchange` / `Market` 关系。
- **seib 缺的那一层已存在**（补层，不是修 seib 的结构，也不搬 ibOptions
  的 settings）：`Desk(brokers: Dict(BrokerId, Broker))`
  （`src/glibe/desk.gleam:92-93`），`config.default_config()` 建了
  `binance` / `ib` / `futu` 三个 broker（`src/glibe/config.gleam:87-101`）；
  与 R33「`Desk` 是顶层唯一 Value」及管道头 `api provider / data sources`
  相合。R34 **未新增 provider / data-source 类型**，`Broker ▸ Instrument`
  （R26）不变。
- **R33 的规格不变**：系统本来就活、数据动每个 type 就动、无数据则睡觉
  等待、`monitor.advance` 那层不是本系统 type、glib 与先驱不作依据。
  待做仍是各数据源的实时到达接入标准 `SourceBar` + replay CLI。
- **引用限定**：R29 里 `~/gits/hub/ibOptions` 的两处时区实例只是事实
  线索，不是架构依据，IANA / 拒绝固定 offset 的结论不变。
- **10:29 因果补正（R34）**：owner 逐字 *"ibOptions受制于Python+Pandas
  的局限性，才会变成那样"*。**是语言 / 库的局限使结构性关系无法写成
  type，才被迫压进 settings 文件**；不是随意乱做，更**不是 seib 的缺陷**。
  受局限的是 ibOptions，结构对的是 seib，只缺现实层次的是 seib ——
  复述时主语不能串（*"要看仔细"*）。
- **R35（SwiftUI 类比 / 简单验证码）**：相似**只指 View 的定义与实现**
  （纯 functional + value types），不是 Swift 整体；Swift 从 view model
  的 class、model 不限 struct/class/actor 起把简单的事做复杂，数据竞争
  要大量补救 —— 这在 Gleam 里不可能出现。**SwiftUI 的 view 为什么会
  更新 = R33**：type 定义好、函数定义对，系统本身就是活的。并发课题
  遇到再查官网 + 做几个方案 demo 对比解决，即 TDD 落实。
  *「简单是正确的验证码。如果复杂，基本上可以判断type 函数和模块定义
  有错误」* —— 复杂是设计出错信号，回去修定义，不加机制。
- **R36（type 系统与断层核对）**：owner 记忆里的主要 type 系统，glib
  的记录在 `~/gits/hub/tools_ib/glib/docs/SYSTEM_MODEL.md` §2 `:102-119`
  与 `domain-hierarchy-2026-10-22.md`（README 只有 `:907` 一行 Phase 32）；
  **glib 不作依据**（R33）。glibe 现有链逐项对上、**没有缺少**。
  断层判断：**`Market` 与 `Broker` 两个方向都不隶属 → 否决**，
  `Desk` 直接持有 Brokers 合乎事实、**无断层**；`Asset` / `Exchange` /
  `Market` 关系按 R26 开放、`APIProvider` 与 broker 同物（R26）、
  `Account` 已由 Broker 持有（当前 keyless，等消费方）、`Symbol` /
  `Interval` 是 key 不是层。**当前链无断层，不新增 type / field / 关系**。
- **R37（主干判据；owner 10:34 逐字）**：举 Desk/Market/Broker 是
  **教怎么思考 type 架构**，不是只要一个否决结论。构成层次某一层的
  type **必须跟上下级有两个隶属关系**（既隶属上层、又拥有下层）；
  其他 type 不属主干：**依附于某 type 但不是隶属**（不插进上下级、
  不产生层级），**谁也不依附就放 `Desk`**（至少属于我们系统）。
  **身份在持有者的 Dict key**：`interval` 不是 `Timeframe` 的 field、
  `brokerId` 不是 `Broker` 的 field，分别是 `Instrument.timeframes` 与
  `Desk.brokers` 的 key。owner 指路的 glib 思路记录在
  `~/gits/hub/tools_ib/glib/docs/NAMING.md:575-589`
  （*"the owner holds what it owns, and the owned never names its owner"*、
  "A collection is not an owner-pointer"）与
  `~/gits/hub/tools_ib/glib/docs/DESIGN.md` §18.2 `:3269-3299`
  （owner 2026-11-04 关于 interval 作 key 的逐字）；glib 文档写
  `Desk → List(Broker)`，glibe 的 `Dict(BrokerId, Broker)` 是 R32 按
  访问方式选的，**不是搬来的**。这是判定法则，不重构 `src/`。
- **本轮范围**：只记裁定、只读核对、同步稳定文档；**不删、不改 `src/`、
  不加依赖、不写 probe、不新增待裁决项**。决策区仍 **0 项**。

## 2026-11-10 (R33 — 系统本来就是活的；现行规格)

- **owner 09:57 / 09:59 / 10:04 / 10:09 四条逐字裁定**在 `docs/RULINGS.md` R33。
  一句话：*`api provider / data sources → history + live data → sourcebar_gate
  → databar_processing → model ↔ view`* 这条管道本来就是活的；**数据动，
  每一个 type 就动，因为定义好了**。`Desk` 是顶层唯一的 Value，逐层嵌套即
  完整系统；在 Gleam 里唯一要做的就是定义 types，基本结构对了什么都有了。
- **数据为什么会动**：订阅了数据源的实时数据；各家推送 / 订阅 / 主动获取
  用各自的方式，属输入边界事实。**没有数据系统就不动了，睡觉，等待**——
  静止是正常状态，不需内部时钟、轮询或心跳补救。
- **撤回三层外来概念**：`monitor.advance` / `TimeframeAddress` /
  `IncomingBar` / `MonitorError` 不是这个系统的 type（*"哪有这些type"*）；
  actor 是结构没设计对才去找的补救；「每一个叶子活起来」既用错了「叶子」
  （特指 `YinLeaf` / `YangLeaf`）也用错了「活」。R31 并发框架、R32
  「每个 Timeframe 活着 / 让叶子活起来的运行时」措辞一并作废。
  **R32 花园方法论仍成立**：加 field、倒推隶属、集合对比、R26 不预设层级。
- **glib 不是权威**：可能只记录了设计与计划、未必落实，已落实的也未必对。
  唯一权威是 owner 当前陈述；此前「glib 核实：四类型链已落地」类断言降级
  为「读过 glib，不作依据」，不得作为设计正确或已落实的证据。
- **本轮范围**：只记裁定、撤回错误结论、清理词汇；**不删生产代码、
  不新增 type、不写 probe、不加依赖**。`monitor.gleam` 那层的处置由
  owner 定，在此之前不作为结构依据。决策区仍 0 项。

## 2026-11-10 (R32 — 结构是花园；历史记录，并发框架经 R33 作废)

> **R33 更正**：下面「每一个 Timeframe 都活着」「当前缺口：运行时还没让
> Timeframe 活起来」「glib 核实：已落地」三处均作废 —— 系统本来就活，
> 「叶子」特指 `YinLeaf` / `YangLeaf`，glib 不是权威。原文保留为历史。
> 花园方法论（加 field / 倒推隶属 / 集合对比 / R26）仍然成立。

- owner 09:45 逐字裁定：*"结构复述正确，不过这是一个花园，不断根据需要往里面加新的花盆。实际上就是在Type定义中加新field而已 … 那就倒推他和其他type现实中什么关系呢？隶属于谁呢？如果谁也不隶属，是其他关系，那么可能放在Desk里面就好了，那么用dict还是list还是其他东西放呢？根据需要来对比研究决定。"* 全文在 `docs/RULINGS.md` R32。
- **结构确认**：`Desk` 只有一个；Desk 里若干 Broker（binance、ib）；每个 Broker 有一组 `Instruments` 和一组 `accounts`；每个 `Instrument` 有 `Dict(Interval, Timeframe)`；**每一个 Timeframe 都活着**，各自处理数据、进行交易。glibe `src/glibe/desk.gleam:74-94` 已有这条静态链，`config.gleam:75-101` 建了 3 broker × 3 品种 × 2 周期。
- **glib 核实**：`glib/src/glib/desk.gleam:11-13`、`broker.gleam:29-34`、`domain/instrument.gleam:76-82` 已落地同一四类型链（含 `accounts` 与 `Dict(Interval, Timeframe)`），`55-02-SUMMARY.md` 标 done；`glib/docs/DESIGN.md:3264-3286` 逐字记了 owner 2026-11-04 的 "instrument with a dictionary of timeframes using interval as key"。但 glib 是 `target = "javascript"`，其 `.planning/HANDOFF-2026-11-03.md:297-305` 自承 runtime 是 single-stream walls，「每个 Timeframe 活着」**未做到**。
- **撤回 04-09 的错误结论**：`probes/parallel-bars/` 把一份 `Desk` 复制进 6 个进程、返回 6 份 partial `Desk`；由此写出的「0/6 合并 / 所有权决定」是伪问题。R31 该段、`docs/DESIGN.md` 04-09 节、`04-09-SUMMARY.md` §4、README / ROADMAP / PENDING 的相应结论作废；官方 BEAM 证据与 `gleam_otp` 事实更正保留。probe 留作带 `////` 作废注记的历史实验。
- **当前缺口**：静态链已有，运行时还没有让任何一个 `Timeframe` 活起来（无进程、无行情流、无交易输出）。按 R32 这是往类型里加 field 的正常生长，不是新框架；按 R26 等真实消费方，本轮**不新增生产类型、不改 `src/` 逻辑、不写新 probe**。
- 本轮没有新增待裁决事项。

## 2026-11-10 (phase 04-09 — BEAM 并行实测 / R31，历史记录；结论见 R32 作废)

- 按 `.planning/phases/04-domain-cleanup/04-09-PLAN.md` §4 复工；范围严格
  **Erlang / BEAM**（owner 06:09）。
- 新建 `probes/parallel-bars/`（独立 Erlang-target 包，`glibe` 为 path 依赖）。
  按 R19：骨架 + `////` 点名 04-09 计划 + 类型 + `///` 签名 + `todo` → 4 个
  测试 RED（0 passed / 4 failures / 0 编译错误 / 5 todo warnings）→ 填体
  GREEN（**4 passed**，`build --warnings-as-errors` 0/0）。
- `gleam run -m parallel_bars` 实测输出：6 个带 `TimeframeAddress` 的 bar →
  **6 个不同 BEAM Pid**（`<0.117.0>`…`<0.122.0>`），回复顺序与发出顺序相反；
  **0 actor / 0 supervisor / 0 lock / 0 FFI**；
  `partial Desks equal to the single-owner fold: 0 / 6`。
- **诚实结论（不是同步问题，是所有权问题）**：每份并行 `Desk` 只改了自己一个
  地址，另外五个仍是原值；N 份不可变值不会自己合并。要么单一 owner 按到达
  顺序 fold，要么每个地址自己持有 `Timeframe`（不需要全局 `Desk`）。按 R26
  等真实消费方决定，**不新增生产类型**；生产代码逻辑未改（`monitor.gleam`
  仅同步 `////` 模块文档到 R31 / 04-09），依赖未加。
- **R31 已写入 `docs/RULINGS.md`**：逐字记录 owner 06:01 / 06:09 原话、官方
  证据、actor 的准确位置、值住在各进程自己的堆（不存在的是共享可变内存）、
  04-09 实测与两处事实更正。
- **两处事实错误已纠正**：① `gleam_otp` 早就是根 `gleam.toml` 的直接依赖；
  ② `docs/DESIGN.md` 04-08 段末 "no … `gleam_otp` dependency" 同错。
  `:101` 表格与 04-08 段末「Stage F 的受监督 actor」框架已重写；
  `README.md`、`.planning/ROADMAP.md` 与临时待裁决文档同步。
- **待裁决事项仍为 0 项**；R31 不是待裁决项。
  历史 review / session 文档（含 04-08 PLAN/SUMMARY、10-04 改进计划）按惯例
  保留旧措辞作为记录。
- 全套绿灯、核心镜像 `cmp`、`package-interface.json` 计划链接、反向引用检查
  均已在收尾提交前跑完（全 0）；按逻辑即时提交，**不 push**。

## 2026-11-09 (Gleam 天然并行研究 — DEFERRED，本日只记录状态)

- owner 06:01 指出：Gleam 天然多线程、并行任务非常简单自然，不必把「受监督
  actor / 订阅 / 行情流」当成复杂补救措施；要求查官网与 Wisp / Lustre 等著名代码。
  owner 06:07 追加：**今天浅尝即止，明天免费 token 到手再继续，今天只把任务和
  现有发现记下来**。owner 06:09 再纠正：*"你去看什么javascript target完全不对路，
  我们是erlang 和 BEAM专属项目"* —— 本项研究范围收窄为 **Erlang / BEAM**，
  JavaScript target / promise 的旁证已从记录中删除。
- 本日**只做了查证与记录**：`https://gleam.run/` 首页 "multi-core actor based
  concurrency system … millions of concurrent green threads" 与三行
  `new_subject` / `spawn` / `receive` 示例；官方 v0.12 发布文「no need for an
  `async/await` syntax or callbacks」「no special types such as futures or
  promises」「don't have mutable state so locks and shared mutable state is not
  an option」以及 actor / supervisor 的定位；本机
  `build/packages/gleam_erlang/src/gleam/erlang/process.gleam:36,78,138,194,227`
  与 `gleam_otp/actor.gleam:1-14`；Wisp `wisp.gleam` 0 处 `process.`；
  glisten `:274,397,435,446`；Lustre `runtime/server/runtime.gleam:81-122`。
  完整引文与 URL 在 `.planning/phases/04-domain-cleanup/04-09-PLAN.md` §2。
- **发现我自己的两处错误**：① 上一轮答复说「`gleam_otp` 也没引入」是错的，
  根 `gleam.toml` 早有 `gleam_otp = ">= 1.3.0 and < 2.0.0"` 直接依赖；
  ② `docs/DESIGN.md` 04-08 段末 "no … `gleam_otp` dependency" 同错。
  `:101` 表格与 04-08 段末把并发写成「Stage F 的受监督 actor」的框架也待复核。
- **本日未改动**：`src/`、`gleam.toml`、`docs/DESIGN.md`、`docs/RULINGS.md`、
  无 probe、无编译、无测试、无 R31。工作树只有记录类文件。
- 明天按 `04-09-PLAN.md` §4 继续：编译实测 spawn + Subject → 诚实回答 N 份新
  `Desk` 的合并/所有权 → 重写 Stage F 框架 → 纠正两处事实 → 验证与即时提交。
  不是 owner 待裁决项，临时待裁决文档的决策区仍 0 项。

## 2026-11-09 (phase 04-08 — one addressed bar advances one timeframe)

- Measured answer to "can the type structure monitor many instruments, each
  with many intervals, at the same time?": the STATIC chain was already
  complete (`desk.gleam:74-94`, `config.gleam:75-101`: 3 brokers × 3
  instruments × 2 intervals = six independent `Timeframe` states), but a bar's
  ARRIVAL had no address and gate-path errors were `String`.
- New `src/glibe/monitor.gleam`: `TimeframeAddress(BrokerId, Symbol,
  Interval)`, `IncomingBar(address, bar)`, `MonitorError` (address + typed
  lower-level reason), and the pure
  `advance(desk, incoming) -> Result(Desk, MonitorError)`. One bar advances
  exactly one `Timeframe`; no fan-out to all intervals.
- `SourceBarRejection` closed set replaces five `Error("…")` arms in
  `sourcebar.validate`; `engine.sourcebar_gate` propagates it.
  `binance.fetch_klines` now takes `Symbol`, not `String` (R22); its return
  type is unchanged and no provider↔broker relation was invented (R26).
- Six new tests in `test/monitor_test.gleam`: addressed timeframe advances,
  other interval / other brokers untouched, two instruments keep their own
  closes, non-boundary bar only opens a bucket, same bar closes 1h but not 4h,
  and both error paths carry the address.
- RED 58 passed / 6 `todo` failures (0 compile errors, 3 skeleton warnings).
  GREEN `gleam build --warnings-as-errors` 0/0, `gleam test` **64 passed**,
  `gleam format --check src test` 0, `guards.sh --all` 0, `gleam docs build` 0;
  `package-interface.json` carries `04-08-PLAN.md` on all four touched modules.
- Deliberately NOT done: actors / subscriptions / streams / replay CLI /
  `gleam_otp` (Stage F), `Market` / `Asset` / `Exchange` relations (R26), any
  field on `SourceBar` or `Timeframe` (R23 / R27 / R28).
- Owner items waiting for a ruling: **0**. This is R26 work, not a ruling.

## 2026-11-09 (R30 / phase 04-07 — local time in the web view, documentation only)

- Owner ruling R30: the web interface shows date-times in **local** time so
  analysis is readable, which requires time-zone conversion and daylight
  saving; the requested deliverable is documentation in the corresponding
  modules so the implementation can be done later.
- R30 = output side (instant → viewer's local wall clock); R29 = input side
  (market local → instant). Both use IANA rules, never a fixed offset; they
  are separate conversions and are not merged.
- Standard `SourceBar.timestamp` / `DataBar.timestamp` (unix time, R27),
  `interval.bucket_ends` (UTC-aligned unix grid) and CSV UTC RFC3339 are
  unchanged. No `tzif` dependency, no new type, no conversion code, no test.
- `////` module docs in `src/glibe/web/server.gleam` (main specification),
  `webclient/src/webclient.gleam`, `src/glibe/export/csv.gleam` and
  `src/glibe/api/sourcebar.gleam` all link plan 04-07; verified in **both**
  packages' `package-interface.json`.
- Also measured this round: the 04-06 module docs of `databar.gleam` and
  `export/csv.gleam` had been truncated mid-sentence where a `////` block
  broke into `//` lines. `gleam docs build` exposed it; both are whole now.
- Measured: `gleam build --warnings-as-errors` 0/0, `gleam test` **58 passed**,
  `format --check src test` 0 (root and `webclient/`), `guards.sh --all` 0,
  `gleam docs build` 0 in both packages; core mirror `cmp` 0; no document
  references the temporary decisions file.
- Owner items waiting for a ruling: **0**.

## 2026-11-09 (R27–R29 / phase 04-06 — unix time at the ingest boundary)

- Standard `SourceBar.timestamp: gleam_time.Timestamp`; `DataBar.timestamp`
  likewise. `date: String`, `normalize_date`, `date_to_iso`, `epoch_ms_to_iso`,
  `civil_from_days`, `clock_of`, `minute_of`: all deleted.
- `binance/kline.gleam` keeps a native twelve-field `Kline`; `decode_klines`
  returns `List(Kline)`; `to_sourcebar` converts `openTime` to unix time.
  `binance/binance.gleam` is the standardisation exit.
- `bucket_ends` is a unix-second remainder grid. Bare dates and unreadable
  labels are `SourceBarTimeError` rejections; the old `False` fallback is gone.
- Compiler-found bug fixed at the wire edge: `float.parse("100")` is
  `Error(Nil)`, so `get_float` / `get_int` had never read Binance's integer
  strings. `parse_number` widens an `Int` to `Float` at the boundary.
- Measured: `gleam build --warnings-as-errors` 0/0, `gleam test` **58 passed**,
  `format --check` 0, `guards.sh --all` 0, `gleam docs build` 0; core mirror
  `cmp` 0; no document references the temporary decisions file.
- Owner items waiting for a ruling: **0**.

## 2026-11-09 (phase 04-05 — the product web layer, adopted)

| axis | value | how it was taken |
|---|---|---|
| framework | **Mist 6.0.3 + Wisp 2.2.2** in the root `gleam.toml`; no Lustre server components, no npm deps | R24 demo conclusion adopted by `04-05-PLAN.md` |
| new module | `src/glibe/web/server.gleam` — closed `Route` set, `desk_to_json`, `page`, `handle_request`, `main` | `gleam docs build` → `package-interface.json` carries `04-05-PLAN` |
| data served | the REAL `config.default_config().desk`, not a demo fixture | `GET /desk` returned binance/BTCUSDT, futu/SPY_FUTU, ib/SPY, each `["1h","1d"]` |
| HTTP | `GET /` 200 (371 B, `<table` + `BTCUSDT` + `futu`), `GET /desk` 200 (236 B valid JSON), `GET /nope` 404 | `gleam run -m glibe/web/server` on port 8610, real requests; port released afterwards |
| GREEN | `gleam test` **54 passed / 0 failures**, `--warnings-as-errors` 0, `format --check` 0, `guards.sh --all` 0, `docs build` 0 | RED was 50 passed / 4 `todo` failures |
| docs coverage | `glibe/web/server` documented; empty module docs 15 / 25 | `package-interface.json` |
| owner rulings | **0** | adoption is AI work under R24, not a ruling |

## 2026-11-09 (R24 / phase 04-04 web demos)

| axis | value | how it was taken |
|---|---|---|
| demos | **3 runnable Erlang-target projects** in `probes/web-layer/` | `gleam run` + real HTTP GET on ports 8601/8602/8603 |
| Gleam / Hex / JS | A 72 lines / 22 pkgs; B 124 / 23; C 82 / 14; **all 0 hand-written JS, 0 npm** | non-blank source count + `manifest.toml` |
| one settled bar | `GET /` and `GET /bar` 200 with `123.5` in all three; B `GET /poll` returns Lustre `Mount` (`kind:0`) | HTTP response bodies |
| runtime import | `webclient.mjs` → `IMPORT_OK exports=["main"]`, exit 0 | `node --input-type=module -e "import(...)"` |
| GREEN | 3 × `gleam test` 1 passed, `--warnings-as-errors` 0, `docs build` 0, plan link in `package-interface.json` | forced recompile after `touch src/*.gleam` |
| conclusion | **recommend A**, not adopted; recommendation in `docs/DESIGN.md` | R24 boundary kept |
| open owner rulings | **0** | R24 was AI work, not a ruling |

## 2026-11-09 (R26 / catalogue types)

| axis | value | how it was taken |
|---|---|---|
| settled relation | **only `Broker ▸ Instrument`**, from the data-source argument | `glib/docs/reference/domain-hierarchy-2026-10-22.md` §1 + §1.18; `src/glibe/desk.gleam` |
| `assets` | 9 `Asset(id, name, class)` catalogue entries; `get_asset` has **0 callers** | `src/glibe/config.gleam:139-212,583` + repo-wide Grep |
| `exchanges` | 3 connection-parameter records; `get_exchange` has **0 callers** | `src/glibe/config.gleam:101-138,568` + repo-wide Grep |
| `markets` | rule sets; `get_market` has **1 caller**, a test | `src/glibe/config.gleam:213-559,595`; `test/interval_test.gleam:99` |
| open owner rulings | **0** | R26 is a ruling, not a new question |

**Owner's direction:** *"其他type之间的关系，比较难确定，可以按需要逐步增加
type，届时关系可能就比较明晰了"* — no advance identity-typing plan, no
speculative relations. Full text: `docs/RULINGS.md` R26.

## 2026-11-09 (R22–R25 / phase 04-03)

| axis | value | how it was taken |
|---|---|---|
| build | **exit 0, 0 errors, 0 warnings** | `gleam build --warnings-as-errors` |
| tests | **50 pass, 0 fail** | `gleam test` (was 44) |
| format / guards | clean / **exit 0** | `gleam format --check src test`, `sh scripts/guards.sh --all` |
| docs | **exit 0**; 6 touched modules carry the `04-03-PLAN` link; empty module docs **15 of 24** | `gleam docs build` + `package-interface.json` |
| `Symbol` | an opaque **name** with a 2-function codec; no instrument fields | `src/glibe/api/symbol.gleam` (R22) |
| ownership | `Desk ▸ Broker ▸ Instrument ▸ Interval ▸ Timeframe`, **one** dictionary on `Instrument` | `src/glibe/desk.gleam` (R23) |
| `Timeframe` | carries `settings`; **no** `symbol` / `interval` / `market_type` | `src/glibe/timeframe.gleam` (R23) |
| config | `AppConfig` holds a typed `Desk`; the two `List(#(String, …))` tables, `"BTCUSDT_H1"` and both `list.find` accessors are **gone** | `src/glibe/config.gleam` (R23) |
| engine | `sourcebar_gate(tf, interval, bar)`; `databar_processing(tf, bar)` reads `tf.settings` | `src/glibe/engine.gleam` (R23) |
| open owner rulings | **0** | `docs/RULINGS.md` R22–R25 closed all four |

**Owner's direction this day:** a name is not the thing; wrong things are
corrected cleanly, never worked around; type problems are solved with types.
`Desk ▸ Broker ▸ Instrument ▸ Timeframe` is the shape, and the web-layer
framework choice is the AI's demo work, not an owner ruling. Full text and
verbatim quotes: `docs/RULINGS.md` R22–R25.

## 2026-11-07 (Round 5)

| axis | value | how it was taken |
|---|---|---|
| toolchain | **gleam 1.19.2, OTP 29** | `gleam --version`, `erlang:system_info(otp_release)` |
| target | **`erlang`, pure** | `gleam.toml:3`; no JS target, no `@external(javascript, …)` |
| build | **exit 0, 0 errors, 0 warnings** | `gleam build` |
| tests | **26 pass, 0 fail** | `gleam test` — 23 prior + 3 Round-5 invariant tests |
| format | clean | `gleam format --check src test` |
| guards | **3 scripts, all green** | `sh scripts/guards.sh --all` (compiles, mixture, no_foreign_source) |
| CI | pins **1.19.2 / OTP 29**, runs guards | `.github/workflows/test.yml` |
| handwritten foreign source under `src/` | **0 compiled** | `ibkr.ex` retired; 2 `.disabled` design records remain |
| `src/glibe` modules | **23 `.gleam`** | `git ls-files src` |
| closed sets as types | `Signal` (3 constructors), `Interval` (7), `SmaForBbm` (5), `SmaSeries` (5, one home) | code read |
| duplicate `SmaSeries` | **0** | dead 4-constructor copy deleted |
| lower-band floor | **one `1e-6·bb_m` floor, before interpolation** | `bollinger.gleam`, owner §1.13/§1.14 |

**Owner's direction this day:** glibe is the future; **it stops waiting on
glib**. See `REVIEW_ROUND5.md` §1 and `DEVELOPER_GUIDE.md`. The two Gleam
references the owner named are recorded in `DEVELOPER_GUIDE.md` and `README.md`.

## 2026-10-04 (historical)

| axis | value | how it was taken |
|---|---|---|
| build | clean, **0 warnings** | `gleam build` (gleam 1.18.1, OTP 29, erl/erlc/escript at `/opt/homebrew/bin`) |
| tests that run | **23 pass, 0 fail** | `gleam test` — 19 original bodies + 4 ingest-boundary tests |
| format | clean | `gleam format --check` |
| guards | **3 scripts, all green** | `sh scripts/guards.sh --all` |
| unwritten `DataBar` fields | **0** | deleted in `databar.gleam`; every remaining field is written by a module |
| module purity | enforced by a script | `scripts/no_timeframe_mixture.sh` |
| interval codec | present | `api/interval.gleam` `to_string` / `from_string` / `all()` |
| ingest boundary | present | `api/sourcebar.gleam` `validate` + `normalize_date` |

**Not taken here (environment):** CI (`.github/workflows/test.yml`) pins
gleam 1.16.0 / OTP 28. The download could not be fetched (no network in the
sandbox), so the pinned-version build is unverified. The guards scripts default
`GLEAM` to `/opt/homebrew/bin/gleam` for the same reason.

**Lagging glib on this day (since withdrawn — see the withdrawn records in `docs/QUESTIONS.md`):**
KDJ window is `w+1` (glib `w`); D uses alpha ½ (glib's is dead); σ excludes the
bar in hand; lower bands still clamped; `kdj_d_period` still a field;
`window_kdj_size` not yet renamed to `kdj_window_size`. These are Stage D, next.

## What "green" means

A stage is done only when all three are true: `gleam build` clean, `gleam test`
green, and `sh scripts/guards.sh --all` green. A stage that cannot be verified
is not done — that rule is why the guard scripts exist before the work they
guard.
