# 待裁决事项 — glibe

> **只看「需要你决定」这一节。** 下面 `# REFERENCE` 起全部是已裁定结论、实测数字
> 和背景指针，不需要看，也不影响做决定。
>
> 本文件是临时的、单向的：裁决后整条删除，结论写进 `docs/RULINGS.md` 等稳定
> 文档；**其他文档一律不引用本文件**（它会被清空替换，反向引用只会留下悬空
> 链接）。引用一律写「文件全路径 + 条目名」，不用裸编号（"Q" 加数字那种既像
> Question N 又不是的写法）。
>
> 最后更新：2026-11-09

---

## 需要你决定（只看这一节）

### 当前 0 项 —— 没有需要你裁决的事。

2026-11-09 的四项全部由你裁定并已落地（`docs/RULINGS.md` R22–R25）：

| 上一轮的问题 | 你的裁定 | 落地 |
|---|---|---|
| `Symbol` 与 `Instrument` 是否同一东西 / 要不要 `InstrumentId` | **`Symbol` 永不是 `Instrument`**；名字不是实体。不统一、不设别名、不建中间层 | `src/glibe/api/symbol.gleam` 重写；`= Instrument =` 那句与 9 个从未被读的字段整句删除（R22） |
| `config.gleam` 两张复合字符串表按什么形状搬迁 / `TimeframeSettings` 是什么 | **彻底纠正，不绕圈子**。`TimeframeSettings` 不是实体，是 `Timeframe` 的参数块 | 两张表、`"BTCUSDT_H1"`、两个 `list.find` 访问器、第二本 settings 字典全部删除；`Timeframe` 不再自带 `symbol` / `interval` / `market_type`；`AppConfig` 直接持有 `Desk`（R23） |
| web 层框架（Mist / Wisp / Lustre） | **由我写 demo 对比测试决定**，不是 owner 裁决项 | R24；三个 demo 已跑完，结论与实测数字在 `docs/DESIGN.md`、`04-04-SUMMARY.md` |
| `TPlus1` / `TPlus2` 是否改名 | **保持原名**。行业公认术语不是线路码 | R25；R21 §3 的「等他一句话」关闭，不再追问 |

**不需要你决定（我按已定规则继续做）：**

- 三张目录表与 `Instrument` 的**关系**：按 R26 不定，不预先做一整套 identity 类型化，等真正有消费方时按需逐个加 type。已确认的只有 `Broker ▸ Instrument`。
- `bucket_ends` 的 `date: String` → `gleam_time.Timestamp`；5 个 `*_from_string` + `panic` 的 codec；日/周/月 bucket 恒 `True` 的旧行为。各自单独计划，按 R13 / R19 / R21 / R23 推进。
- 真实数据下 SVG / JS 图表能力对比试验：**推迟**到 databar processing 其余部分做完（你 2026-11-07 定的时机）。
- BEAM Stage F（每个 `(symbol, interval)` 一个受监督 actor、replay CLI、退役 `data_generator.ex`、`no_minute_trading.sh`）：工作，不是裁决。
- 已裁定、不要再看：JS 图表库 + 生成 `.mjs` 优先（R17）、小范围手写 JS（R16）、Phoenix 去留与 `webclient/`（R18）、`Desk` 而非 `Deck`（R20）、`Interval` 九值 + 全名构造子（R21）、SVG 自绘不再是默认路线、WASM 不采用。

---

# REFERENCE（不用看）

以下全部是**已裁定结论、实测数字和背景指针**，不含任何待裁决项。需要细节按
全路径去稳定文档查，本文件不再重复搬运长文。

## R.1 已裁定索引

| 事项 | 结论 | 原文位置 |
|---|---|---|
| 名字与实体 | `Symbol` 是名字（key），`Instrument` 是被拥有的值；错了就整条改正，不留兼容层 | `docs/RULINGS.md` R22 |
| 参数块与归属链 | `TimeframeSettings` 不是实体；`Instrument` 只有一本 `Dict(Interval, Timeframe)`；interval 只在 key 里；settings 随 engine 走 | `docs/RULINGS.md` R23 |
| web 框架 | AI 写 demo 对比决定，不是 owner 裁决 | `docs/RULINGS.md` R24 |
| 术语 vs 线路码 | CPU / T+1 / T+2 公认术语保留；`H4` / `M1` / `"1h"` 只在 codec/adapter | `docs/RULINGS.md` R25 |
| 目录表与关系 | 只有 `Broker ▸ Instrument` 已确认；`Asset` / `Exchange` / `Market` 之间及与 `Instrument` 的关系**不定**，按需逐个加 type，不预先造一整套 | `docs/RULINGS.md` R26 |
| 手写 `.mjs` 范围 | 仅页面/图表设置 + 一根 settled bar 的更新 | `docs/RULINGS.md` R16 |
| JS 图表库 | 采用；优先 Gleam 源码 → 生成 `.mjs` | `docs/RULINGS.md` R17 |
| Phoenix / webclient | 旧应用移 `deprecated/glibe_web/` 备考不删；`webclient/` 独立 JS-target package | `docs/RULINGS.md` R18 |
| 文档先行 / TDD | 代码内 `////` 模块文档（点名 `.planning` 计划）→ 类型 → `///` → `todo` → 测试 → 填体；`package-interface.json` 是防漂移检查 | `docs/RULINGS.md` R19 |
| 所有权链 / 命名 | `Desk ▸ Broker ▸ Instrument ▸ Timeframe` 必须有；名字是 `Desk`；构造子写全名带类型前缀 | `docs/RULINGS.md` R20 / R21 |
| 其它早期裁定 | 下轨一个 `1e-6·bb_m` 地板、闭集是类型、`src/` 只放 Gleam、IB 仅历史股票/ETF | `docs/RULINGS.md` R12–R15 |

## R.2 实测数字（背景，不是结论）

- 04-03（R22/R23）：RED `gleam test` exit 1、**41 个编译错误**；GREEN
  `--warnings-as-errors` 0 / 0 warnings、**50 passed**、`format --check` 0、
  `guards.sh --all` 0、`gleam docs build` 0；6 个被改模块的
  `package-interface.json` 都带 `04-03-PLAN` 链接；24 个模块里 15 个模块文档
  仍为空（如实保留）。`config.gleam` 删掉 131 行复合字符串表。
- 采用 JS 图表库的**额外成本 = 手写外来源码行数**：整页照搬 glib `priv/index.html` 760 行；保留库 + Gleam 重写 65–85 行（R16 已允许）；**Gleam 源码生成 `.mjs` 0 行**。series 定义 / 选项 / `DataBar → bar` 映射是固有工作，**不算额外成本**。
- 生成 `.mjs` 探针（Gleam 1.19.2）：`chart.gleam` → 154 行 `chart.mjs`，`src/` 下零手写 `.mjs`。`gleam build` **不解析 npm 依赖**，构建绿 ≠ 能跑；LightweightCharts v5 的 `addSeries` / `updateSeries` 是实例方法，带点号的 `@external` 编译期被拒 → 落地要 2–5 行转发（R16 范围内）。**以后要加运行时导入检查。**
- glib 除图表库外无别的运行时依赖：`priv/index.html:7` 是唯一 `<script src>`；760 行内联 JS 是页面工作。JS-target 的成本是 `glib/src/` 下 14 个手写 `.mjs`，**glibe 纯 erlang 引擎不付**。
- R20 / 04-01 循环：RED 26 passed / 10 failures，GREEN 36 passed。R21 / 04-02 循环：RED 37 passed / 7 failures，GREEN 44 passed。
- WASM：Popcorn 1.0 把完整 OTP/BEAM 跑进浏览器，但 DOM/canvas 仍走 JS、Gleam 无 WASM 后端。**不采用、不排期**。`psipi` 未核实，只作 example-level 线索。
- SVG vs JS：**「不需要 JS 库」是依赖声明，不是能力等价**；真实数据试验要测 15 条 series 的值、DOM 节点数、每 bar patch 延迟、crosshair 响应、是否要有界窗口。

## R.3 原话与全文指针

owner 原话（逐字引用、`[user 日期]`、UC 编号）及全部论证在：
`docs/RULINGS.md` R12–R25、`docs/REVIEW_ROUND5.md` §10 / §12 / §13（含 §13.8 /
§13.9 / §13.10）/ §14 / §15、`glib/docs/RULINGS.md` §1.17 / §1.30、
`glib/docs/reference/domain-hierarchy-2026-10-22.md` §1、
`glib/.planning/HANDOFF-2026-11-03.md` §1 / §2、`docs/DEVELOPER_GUIDE.md`。
本文件不重复抄录。

## R.4 已撤回项

`docs/QUESTIONS.md` 只保留 2026-10-04 版清单里 5 个已撤回条目与 1 个假前提，
以及撤回理由。本文件不重复。

## R.5 待做工作（不需要裁决）

- ~~web 层 demo 对比（R24）~~ 已完成；实测数字与结论在 `docs/DESIGN.md`、
  `.planning/phases/04-domain-cleanup/04-04-SUMMARY.md`、`probes/web-layer/`。
- BEAM Stage F：受监督 `Timeframe` actor、真实 klines 的 replay CLI、退役
  `data_generator.ex`、`no_minute_trading.sh`。
- 真实数据图表对比试验（时机见上面「不需要你决定」）。
