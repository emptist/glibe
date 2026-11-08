# 待裁决事项 — glibe

> **只看「需要你决定」这一节。** 下面 `# REFERENCE` 起全部是已裁定结论、实测数字
> 和背景指针，不需要看，也不影响做决定。
>
> 本文件是临时的、单向的：裁决后整条删除，结论写进 `docs/RULINGS.md` 等稳定
> 文档；**其他文档一律不引用本文件**（它会被清空替换，反向引用只会留下悬空
> 链接）。引用一律写「文件全路径 + 条目名」，不用裸编号（"Q" 加数字那种既像
> Question N 又不是的写法）。
>
> 最后更新：2026-11-08

---

## 需要你决定（只看这一节）

**共 4 项。真正需要你现在回一句的只有前 2 项**（它们挡住下一阶段 04-03 配置表
迁移）；后 2 项不挡工作，你不回我就按每项写明的默认继续，不再追问。每项都自带
做决定所需的上下文，不用去别处找。

### 1. `Symbol` 与 `Instrument` 是不是同一个东西？要不要 `InstrumentId`？

**事实：** `src/glibe/api/symbol.gleam:1` 的模块文档写着 `Symbol = Instrument =
Asset on specific Market`，但 `src/glibe/desk.gleam:68-96`（R20 已落地）里
`Symbol` 是 `Broker.instruments` 的 **Dict key**，`Instrument` 是**被拥有的值**
（两本账：`Dict(Interval, TimeframeSettings)` 与 `Dict(Interval, Timeframe)`）。
同一个「=」把两个不同角色说成一个东西。`docs/RULINGS.md` R20「明确未决、未做的事」
写的是「不擅自改名、不擅自统一」，所以只能由你定。

**为什么现在问：** 04-03 要动 `config.gleam` 的表，键的类型必须先定下来。

| 选项 | 内容 | 代价 |
|---|---|---|
| **A（建议）** | `Symbol` = 品种身份（key），`Instrument` = 该品种在 broker 名下的配置与状态；删掉 `api/symbol.gleam` 里那句 "= Instrument"，**不引入**新 id 类型 | 只改文档与注释，不碰已落地的类型 |
| B | 两者是同义词，统一叫 `Instrument`；另建 opaque `InstrumentId` 作 key | 新类型 + 全链条改名 |
| C | 维持现状，等真实数据接进来再说 | 04-03 只能绕开这两张表 |

**你只要回：** `1: A` / `B` / `C`。

**依据：** `docs/RULINGS.md` R20「明确未决、未做的事」；`src/glibe/desk.gleam:68-96`；
`src/glibe/api/symbol.gleam:1-5`。

### 2. `config.gleam` 那两张复合字符串表，按什么形状搬进 `Desk` 链？

**事实：** `src/glibe/config.gleam:22-30` 的 `AppConfig` 仍有
`symbols: List(#(String, symbol.Symbol))` 与
`timeframe_settings: List(#(String, TimeframeSettings))`，键是 `"BTCUSDT_H1"`
这类**一个 `String` 装两个事实**（品种 + 周期）的复合串，读取靠 `list.find`。
R20 已经把 typed 目的地建好（`Desk ▸ Broker ▸ Instrument ▸ Interval`），但这两
张表**原样保留、尚未搬迁**。注意别混：04-02 / R21 改的是 `rules.DataRequestLimits`
里另外 14 张 per-interval 限量表，**不是**这两张。

**为什么现在问：** 这是配置形状 + 全部调用点的架构变更，按「计划和文档先行」
必须先定形状再写计划；`docs/RULINGS.md` R21 结尾写明「本条定的是命名，不是
配置表迁移的许可」。

| 选项 | 内容 |
|---|---|
| **A（建议）** | 拆键成 `Dict(Symbol, Dict(Interval, TimeframeSettings))`，`AppConfig` 持有 `Desk`，删掉复合串；一次迁完，另立 04-03 计划（docs-first + tests-first） |
| B | 两步走：先加 typed 读取层并保留旧表兼容，确认没有调用点后再删旧表 |
| C | 暂不迁移，先做引擎与 replay CLI |

**你只要回：** `2: A` / `B` / `C`（可附「现在做 / 以后做」）。

**依据：** `docs/RULINGS.md` R20「明确未决、未做的事」、R21「执行边界」；
`.planning/phases/04-domain-cleanup/04-02-PLAN.md`「Explicitly out of scope」；
`src/glibe/config.gleam:22-30`。

### 3. BEAM 侧 web 层框架（不挡当前工作）

**事实：** R18 已把 Phoenix 应用移进 `deprecated/glibe_web/` 备考、`webclient/`
独立成 `src/` 之外的 JS-target package（Gleam 源码编译出 `.mjs`，零手写 JS）；
R17 已采用 JS 图表库、生成 `.mjs` 优先。**唯一没定的是 BEAM 侧用哪套框架**。
Mist / Wisp / Lustre 在 `docs/DEVELOPER_GUIDE.md` 里只是评估用参考；Wisp 你没
读过也没用过，我不能替你采用。

| 选项 | 内容 |
|---|---|
| A | Mist + Wisp 只做数据端点，UI 全交给 `webclient/` 生成的 `.mjs`（依赖面最小） |
| B | Mist + Wisp + Lustre server components |
| **C（建议，默认）** | 现在不引入框架，先做引擎与 replay CLI；等有真实数据端点再选 A / B |

**你只要回：** `3: A` / `B` / `C`；**不回按 C 继续**。

**依据：** `docs/RULINGS.md` R17 结尾「仍未裁定」、R18；`docs/DEVELOPER_GUIDE.md`。

### 4. `TPlus1` / `TPlus2` 要不要改名（一句话确认，不挡工作）

**事实：** `src/glibe/api/rules.gleam:99-102` 的 `SettlementType` 构造子把行业
标准术语 T+1 / T+2 拼了出来，**不是**交易所线路码，不违反 R21。但 `docs/RULINGS.md`
R21 §3 写了「已向 owner 标出，等他一句话」，所以在这里一次问清，之后不再提。

**选项：** 保持原名（**建议，默认**，我不动）／按 R21 前缀规则改成
`SettlementOneDay` 一类。

**你只要回：** `4: 保持` / `改`；**不回按保持处理，此后不再问**。

**依据：** `docs/RULINGS.md` R21 §3；
`.planning/phases/04-domain-cleanup/04-02-PLAN.md`「Explicitly out of scope」。

### 不需要你决定（我按已定规则继续做，不列选项）

- 真实数据下 SVG / JS 图表能力对比试验：**推迟**到 databar processing 其余部分做完（你 2026-11-07 定的时机）。
- `bucket_ends` 的 `date: String` → `gleam_time.Timestamp`、5 个 `*_from_string` + `panic` 的 codec、日/周/月 bucket 恒 `True` 的旧行为、`Timeframe` 去掉自带 key：各自单独计划，按 R13 / R19 / R21 推进。
- BEAM Stage F（每个 `(symbol, interval)` 一个受监督 actor、replay CLI、退役 `data_generator.ex`、`no_minute_trading.sh`）：工作，不是裁决。
- **已裁定、不要再看**：JS 图表库 + 生成 `.mjs` 优先（R17）、小范围手写 JS（R16）、Phoenix 去留与 `webclient/`（R18）、`Desk` 而非 `Deck`（R20）、`Interval` 九值 + 全名构造子（R21）、SVG 自绘不再是默认路线、WASM 不采用。

---

# REFERENCE（不用看）

以下全部是**已裁定结论、实测数字和背景指针**，不含任何待裁决项。需要细节按
全路径去稳定文档查，本文件不再重复搬运长文。

## R.1 已裁定索引

| 事项 | 结论 | 原文位置 |
|---|---|---|
| 手写 `.mjs` 范围 | 仅页面/图表设置 + 一根 settled bar 的更新；不含 SSE、tab/symbol 切换、业务逻辑、第二个引擎 | `docs/RULINGS.md` R16 |
| JS 图表库 | 采用；优先 Gleam 源码 → 生成 `.mjs`；SVG 自绘不再是默认路线 | `docs/RULINGS.md` R17 |
| Phoenix / webclient | 旧应用移 `deprecated/glibe_web/` 备考不删；`webclient/` 独立 JS-target package，手写 `.mjs` 仅限该目录 | `docs/RULINGS.md` R18 |
| 文档先行 / TDD | 代码内 `////` 模块文档（点名 `.planning` 计划）→ 类型 → `///` → `todo` → 测试 → 填体；`gleam docs build` 的 `package-interface.json` 是防漂移检查 | `docs/RULINGS.md` R19 |
| 所有权链 | `Desk ▸ Broker ▸ Instrument ▸ Interval` 必须有；名字是 `Desk` 不是 `Deck`；owner 2026-11-03 的 "Deck" 引文记为拼写漂移，原样保留 | `docs/RULINGS.md` R20 |
| 构造子命名 | 类型名前缀 + 英文全名（`IntervalOneDay`）；`"1h"` 等线路码只活在 codec/adapter | `docs/RULINGS.md` R21 |
| 其它早期裁定 | 下轨一个 `1e-6·bb_m` 地板（插值前）、闭集是类型、`src/` 只放 Gleam、IB 仅历史股票/ETF | `docs/RULINGS.md` R12–R15 |
| Desk vs Deck、Interval 7 → 9 | 已关闭，无需再议 | `docs/RULINGS.md` R20 / R21 |

## R.2 实测数字（背景，不是结论）

- 采用 JS 图表库的**额外成本 = 手写外来源码行数**：整页照搬 glib `priv/index.html` 760 行；保留库 + Gleam 重写 65–85 行（R16 已允许）；**Gleam 源码生成 `.mjs` 0 行**；Lustre SVG 0 行。series 定义 / 选项 / `DataBar → bar` 映射 / 单 bar 更新在任何语言都是固有工作，**不算额外成本**（owner 2026-11-07 口径）。
- 生成 `.mjs` 探针（Gleam 1.19.2，`/tmp/gleam_js_probe/probe`）：`src/probe/chart.gleam` → 154 行 `build/dev/javascript/probe/chart.mjs`，导出 `specs / chart_options / setup / paint`，`src/` 下零手写 `.mjs`。
- `gleam build` **不解析 npm 依赖**：构建绿 ≠ 能跑（先 `ERR_MODULE_NOT_FOUND`，装库后占位绑定失败）。LightweightCharts v5 真实导出有 `createChart` / `LineSeries` / `CandlestickSeries` / `createSeriesMarkers`；`addSeries` / `updateSeries` 是实例方法，带点号的 `@external` 编译期被拒 → 落地要 2–5 行转发（R16 范围内）。**以后要加运行时导入检查。**
- glib 除图表库外无别的运行时依赖：`priv/index.html:7` 是唯一 `<script src>`（vendored 197,922 字节 IIFE，非 ESM）；760 行内联 JS 是页面工作。JS-target 的成本是 `glib/src/` 下 14 个手写 `.mjs`（`web/server_ffi.mjs` 434 行等），**glibe 纯 erlang 引擎不付**。
- R20 循环：骨架 0 errors / 49 warnings、`gleam test` RED 26 passed / 10 failures；填体后 36 passed、0 warnings。`gleam docs build` 的 `package-interface.json` 里 `glibe/desk` 有 32 行模块文档且含计划路径。
- R21 / 04-02 循环：骨架 0 errors / 14 warnings（10 `Todo`）、RED 37 passed / 7 failures；GREEN `--warnings-as-errors` 0 / 0 warnings、**44 passed**、`format --check` 0、`guards.sh --all` 0；24 个模块中 19 个模块文档仍为空（如实保留的债务）。
- WASM：Popcorn 1.0（2026-10-27）把完整 OTP/BEAM 跑进浏览器，但 DOM/canvas 仍走 JS、Gleam 无 WASM 后端。**不采用、不排期**。`psipi` 本机未找到目录、历史会话无记录，只作 example-level 线索。
- SVG vs JS：**「不需要 JS 库」是依赖声明，不是能力等价**；真实数据试验要测 15 条 series 的值、DOM 节点数、每根 settled bar 的 patch 延迟、crosshair/tooltip 响应、是否必须有界窗口。

## R.3 原话与全文指针

owner 原话（`[user 日期]`、UC 编号、逐字引用）及全部论证在：
`docs/RULINGS.md` R12–R21、`docs/REVIEW_ROUND5.md` §10 / §12 / §13（含 §13.8 /
§13.9 / §13.10）/ §14 / §15、`glib/docs/RULINGS.md` §1.28、
`docs/DEVELOPER_GUIDE.md`、`docs/DESIGN.md`。本文件不重复抄录。

## R.4 已撤回项

`docs/QUESTIONS.md` 只保留 2026-10-04 版清单里 5 个已撤回条目（KDJ 窗口、σ
窗口、下轨地板、K/D 单一 alpha、`window_kdj_size` 改名）与 1 个假前提，以及
撤回理由。本文件不重复。

## R.5 待做工作（不需要裁决）

- BEAM Stage F：每个 `(symbol, interval)` 一个受监督的 `Timeframe` actor、真实
  klines 的 replay CLI、退役 `data_generator.ex`、`no_minute_trading.sh`。
- 真实数据图表对比试验（时机见上面「不需要你决定」）。
