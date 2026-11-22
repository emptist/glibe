# 待裁决事项 — glibe

> **只看「需要你决定」这一节。** 下面 `# REFERENCE` 起全部是已裁定结论、实测数字
> 和背景指针，不需要看，也不影响做决定。
>
> 本文件是临时的、单向的：裁决后整条删除，结论写进 `docs/RULINGS.md` 等稳定
> 文档；**其他文档一律不引用本文件**（它会被清空替换，反向引用只会留下悬空
> 链接）。引用一律写「文件全路径 + 条目名」，不用裸编号（"Q" 加数字那种既像
> Question N 又不是的写法）。
>
> **owner 2026-11-15 08:27 逐字：*"你不可再使用这种提问方式，有决策问题
> 写入 单独文档，我会去看。"*** ⇒ 本文件是决策问题的唯一落点；不在对话里
> 弹选择卡片、不催答复、选项不预设推荐。全文见 `docs/RULINGS.md`
> 「2026-11-15 08:27」。
>
> 最后更新：2026-11-19 00:03

---

## 需要你决定（只看这一节）

### 当前 1 项（2026-11-23 02:xx，carrier）

**决策 1 — identity keys 与 archived bar 如何到达 chart widget（03-01 BLOCKED）**。
这是自 2026-11-19 清空以来第一个够格的架构决策项，不是工作项（R.5）、不是可推断的实现细节。

- **为什么必须你决定**：`runtime.update` 的 body 被两处 carrier 缺口堵死，两处都在 pinned
  `plushie_gleam` 0.6.0 源码里实测（详见 `.planning/phases/03-app-view/03-01-SUMMARY.md`）：
  1. **入口**：`app/message.gleam:67-69` 的 `SourceBarArrived` 只有 placeholder
     构造器，不带 `BrokerId`/`Symbol`/`Interval` → update 无法路由到目标 Timeframe；
  2. **出口**：app `update` 签名 `fn(model,msg)->#(model,Command(msg))`
     （`plushie/app.gleam:143-148`）只拿到 model，拿不到 widget state；chart state 由
     runtime 持在 `WidgetDef` 里，只能经 `handle_event` 改（`widget.gleam:68-89`）；
     `command.dispatch`/`Done` 把值送回 app.update 而非 widget（`command.gleam:20-51,291`）；
  3. `Event` 无 `Custom`（`plushie/event.gleam:33-58`）——冻结 owner 裁定 06-02 B3
     原文（归档 `06-02-CHALLENGES.md:41-44`）已明说："shared-actor 广播若要用 Custom，
     须先核对包版本"。我不发明 `event.Custom`。
- **我不能自己定的原因**：create-plans deviation rule 4（结构性改动→停下问）+ owner 逐字
  "遇到不能决断的危险事件，需要问我"。骨架原有 KNOWN GAP（`runtime.gleam:41-47`）也从一开始
  就声明 carrier 待裁决。
- **待你指定**：用哪种 carrier 把 identity keys + archived bar 从数据流送到 widget 的 chart。
  选项由你裁定，我在这里不预设、不挑选（候选方向仅供你参考：扩充 `SourceBarArrived` payload
  并让 BEAM 侧注入 / 升级 plushie 版本取得 Custom-like 广播 / 别的机制）。
- **不阻塞**：03-02（dashboard 的 WidgetDef/view 投影）不依赖 carrier，`view` 投影 `Desk`、
  `push_one` 已填，可独立推进。

---

**历史 — 决策区曾为 0 项（2026-11-19 00:03）。最后一项（原「"拒绝 JS target"要不要一并收紧 `webclient/`?」）**
由 owner 2026-11-19 00:03 裁定撤出。owner 逐字："你如果采用 bar_stream_chart
就不在需要web front了是不是？这还需要裁决吗？" 结论：**不走 web front 路线**——
web front 出局是既有「拒绝 JS target / BEAM 专属」裁定（11-15 08:16）的推论，
不是新问题；自有 `bar_stream_chart` 图表层（11-18）+ plushie renderer（erlang
target）已把视觉这半闭合。精确因果链与诚实边界见 `docs/RULINGS.md`「2026-11-19 00:03」。

> **08:30 更新（执行，非新裁决）**：owner 08:30 逐字"webclient删除"——`webclient/` 已
> `git rm -r` 删除（00:03「出局」裁定的执行收尾）。上文"保留空壳、不专门删除"是 00:03
> 当时陈述，至此作废；R16–R18 历史裁定原文不动。见 `docs/RULINGS.md`「2026-11-19 08:30」。

**已裁定、整条撤出决策区的项（历史，结论均在 `docs/RULINGS.md`）**：

- plushie / `try_plushie` 选型（owner 2026-11-15 08:13）。
- 导出格式 ETF term（owner 2026-11-17 09:40）。
- `sourcebar_list` 合法 / `sourcebar_buffer` 非法（owner 2026-11-17 10:16）。
- web front 路线 + `webclient/` 收紧（owner 2026-11-19 00:03，本条）。

owner 逐字全文与查证链：`docs/RULINGS.md` 对应各日期节。现在决策区为 0 项——
没有需要你回答的问题。

---

### 上一轮（2026-11-09）已裁定，不再是待决项

2026-11-09 的四项全部由你裁定并已落地（`docs/RULINGS.md` R22–R25）：

| 上一轮的问题 | 你的裁定 | 落地 |
|---|---|---|
| `Symbol` 与 `Instrument` 是否同一东西 / 要不要 `InstrumentId` | **`Symbol` 永不是 `Instrument`**；名字不是实体。不统一、不设别名、不建中间层 | `src/glibe/api/symbol.gleam` 重写；`= Instrument =` 那句与 9 个从未被读的字段整句删除（R22） |
| `config.gleam` 两张复合字符串表按什么形状搬迁 / `TimeframeSettings` 是什么 | **彻底纠正，不绕圈子**。（11-12 11:46 更正：owner 逐字 *「TimeframeSettings 是AI搞出来的东西，我不知道是什么玩意」* —— 它不是参数块，是 AI 造的名字，见 **R46**） | 两张表、`"BTCUSDT_H1"`、两个 `list.find` 访问器、第二本 settings 字典全部删除；`Timeframe` 不再自带 `symbol` / `interval` / `market_type`；`AppConfig` 直接持有 `Desk`（R23）。**R46 追加**：`indicator_settings.gleam`、`Timeframe.settings`、`timeframe.new` 一并删除 |
| web 层框架（Mist / Wisp / Lustre） | **由我写 demo 对比测试决定**，不是 owner 裁决项 | R24；三个 demo 已跑完，结论与实测数字在 `docs/DESIGN.md`、`04-04-SUMMARY.md` |
| `TPlus1` / `TPlus2` 是否改名 | **保持原名**。行业公认术语不是线路码 | R25；R21 §3 的「等他一句话」关闭，不再追问 |

**不需要你决定（我按已定规则继续做）：**

- 三张目录表与 `Instrument` 的**关系**：按 R26 不定，不预先做一整套 identity 类型化，等真正有消费方时按需逐个加 type。已确认的只有 `Broker ▸ Instrument`。
- `interval.sourcebar_closed`（11-15 前旧名 `bucket_ends`）的
  `date: String` → `gleam_time.Timestamp`、5 个 `*_from_string` + `panic`
  的 codec、日/周/月恒 `True` 的旧行为：这些是**已作废的历史债务**，
  不是当前待办。`Timestamp` 已在 doc-tdd 骨架落地（R27 / R29），
  `sourcebar_closed` 的函数体仍是 `todo`，按 R19 / R48 逐条填。
  命名逐字与判据见 `docs/RULINGS.md` 2026-11-15 执行注记。
- 真实数据下 SVG / JS 图表能力对比试验：**推迟**到 databar processing 其余部分做完（你 2026-11-07 定的时机）。
- 各数据源的实时到达接入（推送 / 订阅 / 主动获取，各家用自己的方式）、
  退役 `data_generator.ex` / `no_minute_trading.sh`：工作，不是裁决；
  历史批次是同一条流的前段，不是重放（R38）。**不是「让系统活起来」的
  运行时**（R33：系统本来就活，无数据则睡觉等待），也不需要 actor /
  调度框架。`monitor.gleam` 那层 type 的处置由
  owner 定。
- ibOptions 的 settings 清单**不是待办清单**：按 R26 / R32，某个设置
  只有在出现真实消费方时才按倒推隶属加一个 field，不预先批量发明
  一整套 type，也不搬 Python / pandas 形状（R34）。
- `Market` 是否该在 `Broker` 之上持有它：**已否决**（两个方向都不隶属），
  `Desk ▸ Broker` 无断层。其余 `Asset` / `Exchange` / `Market` 关系按
  R26 等真实消费方，不预先加 type（R36）。
- 已裁定、不要再看：JS 图表库 + 生成 `.mjs` 优先（R17）、小范围手写 JS（R16）、Phoenix 去留与 `webclient/`（R18）、`Desk` 而非 `Deck`（R20）、`Interval` 九值 + 全名构造子（R21）、SVG 自绘不再是默认路线、WASM 不采用。

---

# REFERENCE（不用看）

以下全部是**已裁定结论、实测数字和背景指针**，不含任何待裁决项。需要细节按
全路径去稳定文档查，本文件不再重复搬运长文。

## R.1 已裁定索引

| 事项 | 结论 | 原文位置 |
|---|---|---|
| 两个先驱 / 多 broker 层 | **完全两码事**（owner 11:10 定稿）。唯一共同点只是数量上**都只有一个 broker**。**seib = CoffeeScript、owner 的系统设计**：没有 Python/pandas 局限、不存在「连类型都搞不清楚」，结构是对的，只缺「多个经纪商数据提供者」这一层，**没有 settings 问题**；此前把它读成「也是 python、只不过没受限制」是错的。**ibOptions = 为了迁就语言凑合的**（Python + pandas），**五脏俱全但都不对劲**，结构性关系写不成 type 才被迫压进 settings，只作需求清单；那些设置在 glibe 是 type 或 field，不批量预造、不预设关系 | `docs/RULINGS.md` R34（含 10:26 / 10:29 / 11:10 更正） |
| SwiftUI View / 简单验证码 | 相似**只在 View 的定义与实现**；view 会更新 = R33 系统本来就活；并发遇到再查官网 + 做几个 demo 对比 = TDD；**简单是正确的验证码**，复杂则 type / 函数 / 模块定义有错 | `docs/RULINGS.md` R35 |
| 层次关系与断层 | 核对 owner 记忆的 type 系统：链完整无缺少；**Market 与 Broker 双向都不隶属 → 否决**，`Desk ▸ Broker` 无断层；Asset / Exchange / Market 按 R26 开放、Account 已有、Symbol / Interval 是 key；不新增 type / field / 关系 | `docs/RULINGS.md` R36 |
| 主干判据 / 身份在 key | 构成主干某一层的 type 要有**上下两个隶属关系**；其他 type **依附但不隶属**（不插层）或谁也不依附 → 放 `Desk`；身份在持有者的 Dict key，不在被持有者身上（*"你的左手不知道他是左还是右"*），`interval` / `brokerId` 都不是 field | `docs/RULINGS.md` R37 |
| 制作流程与 04-10 的如实定位 | 「概念 → type definition → unit test → implementation」**就是一个 module 文件的制作流程**：先写描述 → 空架子（没有实际东西）→ test（**设计目标在此**）→ 逐步实现；逐字全文 `docs/RULINGS.md` 文末同名段。**owner 11:05：04-10 没有照此走** —— 代码先有、文档与测试后补，是反向补课（"倒过来整…补充test充门面"），不得包装成流程示例。实际动作：判据写进 `////` / `///` → 不新增 type → `test/level_judgement_test.gleam`（RED 68/2）→ 填 `desk.timeframe_under` 纯读取（GREEN 70/0）；`package-interface.json` 已核对。今后新建 module 必须从描述开始。**owner 11:11：`docs/` 下大量文档是「差生补课笔记」，不是权威；流程做对，很多文档不需要；本轮不新建文档，概念进 `////` / `///`、test 定目标、实现最后**。不是待裁决项，边界不变 | `.planning/phases/04-domain-cleanup/04-10-PLAN.md`、`04-10-SUMMARY.md`、`docs/RULINGS.md` 文末执行注记 |
| 名字与实体 | `Symbol` 是名字（key），`Instrument` 是被拥有的值；错了就整条改正，不留兼容层 | `docs/RULINGS.md` R22 |
| 归属链 | `Instrument` 只有一本 `Dict(Interval, Timeframe)`；interval 只在 key 里。**R46 作废**：`TimeframeSettings` 与「settings 随 engine 走」都是 AI 造的，不是 owner 设计 | `docs/RULINGS.md` R23 / R46 |
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

## R.6 `Symbol` 的归属 —— 按 R28 已定，不是待裁决项（2026-11-17）

owner 逐字（2026-11-17）：*"Symbol 分开定义根本不可能出错，也不可能增加
负担，因为各自使用的 Symbol 永远随着某一个broker 数据源跑，根本不存在串门
的情况，而系统则是定义一个标准的Symbol，这跟个自定义自己的外部sourcebar，
然后定义系统标准SourceBar type逻辑完全相同"*。

这是**裁定，不是问题**——R28 已经定过的形状，Symbol 照抄。`api/symbol.gleam`
的 human 注记里那句 *"you should compare the two approaches to see which is
more suitable"* 至此关闭：答案不是「比较后选一个」，而是「没有取舍，与
sourcebar 同构」。

**R28 在代码里已实现的同构（核对过，不是想象）：**
- `api/sourcebar.gleam:106` 标准 `SourceBar`：9 个变体按时段，**不含任何
  provider 名**；标准层不知道各家原生 bar 长什么样。
- `binance/kline.gleam:108` 原生 `BinanceKline`：带 Binance 字段名，
  `:250` 的 `to_sourcebar` 是它唯一的出口，转进标准 `SourceBar`。
- `ib/sourcebar.gleam` 同理（IB 自己的名字、自己的转换）。

**Symbol 照此：**
- 每家 broker 在自己的模块定义**自己的原生 symbol**，随自己的数据源跑；
  各家 `to_symbol` 转成系统那一个标准 `Symbol`。
- 原生 symbol **从不进** `Broker.instruments` 的字典，字典 key 只有标准
  `Symbol` ⇒ **串门无从发生**。owner 的关键判据就是这句：*"各自使用的
  Symbol 永远随着某一个broker 数据源跑，根本不存在串门"*。
- 因此「哪种形状能挡住串门」是个伪命题——我为它造过 accessor 错配探针，
  是虚构战场，作废。

**我制造并已作废的三件错事（诚实保留，防止复发）：**
1. symcmp_b 把 `Broker` 写成泛型 `Broker(k)` → 断言「B 逼 Desk 变形、要加
   union」。owner：*"Desk dict is for Brokers, why should it have anything to
   do with how Symbol type is defined?"* —— 自造的耦合，结论错。
2. owner 问「哪种情况 type 让错误无可遁形」，我答「B 的 accessor 错配」——
   答的正是那个不存在的串门场景。错。
3. 把「Symbol 归属」登记进决策区当第 4 项待裁决——它按 R28 已定，不该进。
   决策区已恢复为 3 项。

**仍未定、但不阻塞的**：变体命名需 R15 / R21 核（IB 仅历史股票/ETF，
`IbOptionSymbol` / `IbForexSymbol` 疑似超范围）。这是命名，不是归属。

## R.5 待做工作（不需要裁决）

- ~~web 层 demo 对比（R24）~~ 已完成；实测数字与结论在 `docs/DESIGN.md`、
  `.planning/phases/04-domain-cleanup/04-04-SUMMARY.md`、`probes/web-layer/`。
- ~~依该结论采用 A（04-05）~~ 已完成；根包加入 `mist` / `wisp`，
  `src/glibe/web/server.gleam` 服务真实 `Desk`。这是我按 R24 自己该做的决定，
  细节在 `.planning/phases/04-domain-cleanup/04-05-SUMMARY.md`。
- 真实数据源的实时到达接入、行情流、退役
  `data_generator.ex`、`no_minute_trading.sh`：输入边界工作；
  历史批次不是重放（R38）。
  **没有并发机制 / actor / 调度前置**（R33），也没有「让结构活起来的运行时」：
  数据不来系统就睡觉等待，这是正常状态。
- 真实数据图表对比试验（时机见上面「不需要你决定」）。

- ~~04-06 标准 bar 时间类型化~~ **已完成**（R27–R29）：标准 `SourceBar` 用
  unix time `Timestamp`；provider 原生结构与名字各自保留，各自 `to_sourcebar`。
- R29 市场日历（US/Eastern 夏令时、09:30 开盘的桶网格）：等美股消费方出现时
  单独立计划，用 `tzif` 2.0.0，**不是待裁决项**，是 R26 的按序工作。
- R30 web 界面本地时间显示（IANA 时区 / 夏令时）：owner 已裁定，本轮只在相应
  模块的 `////` 文档里写好规格，实现是 04-07 的按序工作，**不是待裁决项**。
  见 `docs/RULINGS.md` R30 与
  `.planning/phases/04-domain-cleanup/04-07-PLAN.md`。
- 04-08 多品种 × 多周期同时监控的类型结构（地址 / 到达 bar / 领域错误 /
  纯 `advance`）：已完成，是 R26 按序工作，**不是待裁决项**，见
  `.planning/phases/04-domain-cleanup/04-08-PLAN.md` 与 `docs/DESIGN.md`。
- R31 / R32（2026-11-09 / 11-10）：并发框架与「每个 `Timeframe` 各自活起来」的
  措辞**已由 R33 作废**；R32 的花园方法论（新事物 = 已有 Type 定义
  里的一个 field、倒推隶属、集合形状对比、R26 不预设层级）仍然成立。
  04-09 的「6 份 partial `Desk` / 合并属所有权」结论形状错误，已作废。
- **R33（2026-11-10 owner 指示）**：系统本来就活 —— *"api provider / data
  sources → history + live data → sourcebar_gate → databar_processing →
  model ↔ view"*；`Desk` 是唯一顶层 Value，每一个 type 随数据而动；
  数据会因订阅实时数据源而不断到来，无数据则睡觉等待；`monitor.advance`
  等 type 非本系统设计；「叶子」特指 `YinLeaf` / `YangLeaf`；glib 不是权威。
  **不是待裁决项**，全文在 `docs/RULINGS.md` R33、`docs/DESIGN.md`
  「The system is already live」。

- **R19④ 填 body 进度（2026-11-17）**：doc-tdd 空架子逐模块填实。
  已填 `id` / `interval` / `sourcebar` / `symbol` / `databar` / `signal` /
  `desk` / `broker` / `kline` / `ib/sourcebar`（9 个合成函数）/
  `instrument`（Dict 读写 + compose 分派）/ `leaf`（8 个）/ `branch`（10 个）/
  `timeframe`（3 个）。测试 **46 passed**。
  - **`sma_tiny` 字段已落 `DataBar`**（R3 owner 逐字 *"CMA 当然同样是选定
    均线的均值呀"* 点名的 selected MA）。此前写成「无均线字段、等消费方」
    是我把 R46 误读成「字段也被删」——R46 删的是 `TimeframeSettings` 和
    12 个窗口大小数字，不是 `sma_tiny` 这个测量值；骨架 `///` 早已写明这些
    函数读它，glib 也有现成实现。`to_databar` 出生时种 `0.0`，writer 是
    `timeframe.indicator`（仍是 todo）。
  - **已填的 3 个新 body**（R3 规格自足，glib 有参考实现）：
    `leaf.leaf_depth`（yin 顶=start、yang 顶=corner，取 share 不是差）、
    `branch.move_between`（`(to-from)/from` + idx 两端 inclusive 的 bar 数）、
    `branch.recognised_move`（enter→exit 窗口，无 exit_bar 则 `None`）。
  - **真实规格缺口（不是待裁决项、不臆造），12 个 todo = leaf 3 + branch 5 +
    timeframe 4**：
    - ~~`leaf.leaf_cma` 需要「twin 的均值 reader」——`yin_leaf_cma` /
      `yang_leaf_cma` 两个字段在本设计里未声明（R46 把携带它们的 settings
      容器删了，没说这两字段落在哪）；不猜。~~ **2026-11-20 更正**：这两个
      字段已按 glib 原始 DataBar 补进 `databar.gleam`（本轮，chart 是真实消费方），
      writer 是 `timeframe.indicator`；「R46 删了携带它们的容器」是错误泛化——
      R46 只删空壳 `TimeframeSettings`，config.gleam 是 must（owner 逐字）。
    - ~~`leaf.next_yin_leaf` / `next_yang_leaf` 需要叶子何时死亡/转向的判据~~
      **2026-11-23 已填**：判据在冻结 glib `leaf.gleam:207-247` 完整给出（yin 死在新高
      sma_tiny、corner 跟新低；yang 镜像），阈值读 leaf 自己 start_bar 的 sma_tiny。
      02-02 按 GDLTDD 用 5 个测试 RED→GREEN 填入。R38 说的是 glib 不作「设计正确」的
      证据，不等于 02-02-PLAN「用冻结实现规则填」这条授权失效。
    - `branch.branch_size` / `branch_stat` 的**签名本身有问题**：growing branch
      无 exit_bar / end_bar，签名却返回裸 `Int` / 裸三元组，不是 `Option`
      （glib 用库内 `let assert` 掩盖，core §7 禁止库 panic）。正确的类型修复要让
      参数本身携带「已结束」这一事实（牵动 `DataBranch` 定义），超出 02-02 范围，
      属架构决策；`timeframe.strategy` 仍是 todo、无真实调用方。保留 todo，不擅自改签名。
    - ~~`branch.next_yang/yin_branch`~~ **2026-11-23 已填**：关闭规则在冻结 glib
      `branch.gleam:346-424` 完整（按 recognition 出生、leaf_size>=exit_size 关闭、
      growing 原样 carry），签名已带 `branch_exit_leaf_size: Int` 参数（R40-A 消费方传入）。
      02-02 用 5 个测试 RED→GREEN 填入。
    - `branch_exit_leaf_size()` 无参，但关闭计数按 interval 取值（D1=40 / W1=8 /
      MO1=2），值已在 active `config.gleam` 的 `branch_exit_leaf_size: Dict(Interval,
      Int)`（照 glib `config.gleam:259-274`）。无参签名无法表达按 interval 变化；
      改签名需真实消费方（`timeframe.branches`）落地时定。保留 todo，不臆造。
    - `timeframe` 4 步 `indicator` / `leaves` / `branches` / `strategy`：`indicator`
      2026-11-23 已填完整指标集；其余 3 步依赖上面仍开放的签名/规则，留白。
  - 这些不是「需要你决定」项：owner 的原则是字段与值随真实消费方一个一个加
    （R26/R32），不预造、现在不臆造实现。**domain 层 R.5 todo（02-02 后）**
    = branch 3（`branch_size`/`branch_stat`/`branch_exit_leaf_size`）+ timeframe 3
    （`leaves`/`branches`/`strategy`）= 6；leaf helper 0。WAE 实测 13 Todo 另含
    app 层（`runtime.update` 等）与别处骨架 todo。02-01/02-02 已填 indicator + 4 个
    leaf/branch helper。
