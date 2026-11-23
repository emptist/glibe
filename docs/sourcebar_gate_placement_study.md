# `sourcebar_gate` 归属与 Timeframe 诞生点 — 对比研究

> 触发：owner 2026-11-24 02:03 当面三问。本文只做**事实对照 + 方案代价 + 待裁定项**，
> **不改任何代码、不擅自选择**。所有断言带实测行号；推断显式标注。glib 是冻结设计源
> （R42，只读）；glibe 是当前实现。

## 0. owner 原话（逐字）

1. *"当前glib实现，sourcebar_gate 是放在 timeframe module，但是我已经指出，你需要对比一下，
   如果放在 instrument，是不是更方便？"*
2. *"这里的设计问题是，谁，在哪里，生成 timeframe？"*
3. *"当前glib让 sourcebar_gate 输出 databar 并且交给**他自己生成的** timeframe，可能是在
   sourcebar_gate 设置了 databar.idx"*
4. 方案 B：*"也可以将整理好的，已经close的sourcebar 交给 timeframe，timeframe 接受
   sourcebar但是会转换成databar，在 databar_processing() 接受这个 sourcebar，然后根据
   timeframe databar_list 计算idx，并且转化为databar，交给 working_databar field，展开
   随后的一系列计算"*
5. 方案 C：*"如果是在 Instrument中生成timeframe并且放到 timeframe_dict，同时在
   instrument中定义 sourcebar_gate, 并且在此将 sourcebar 交给 timeframe 的
   databar_processing 处理前，增加一个小的转换函数，或者直接由 databar_processing 负责
   转换成 databar, 这样很多方面的问题，似乎更好解决，包含多个小周期合成大周期sourcebar问题。"*
6. *"对此你需要仔细对比研究。"*

## 1. 现状事实对照（带行号）

| 事实 | glib（冻结源） | glibe（当前实现） |
|---|---|---|
| sourcebar_gate 住哪 | `timeframe.gleam:192` | `timeframe.gleam:181` |
| sourcebar_gate 签名 | `Timeframe × SourceBar → #(Option(DataBar), Timeframe)` | `Timeframe × SourceBar → Result(Timeframe, Rejection)` |
| databar 写进哪 | sourcebar_gate **返回** databar；`databar_processing(tf, databar, publish)` 才写 `working_databar`（`:62,69` / `:351`） | sourcebar_gate **自己**写 `working_databar`（`:195`）；`databar_processing(tf, settings)` 不再接 bar 参数（`:206-209`） |
| idx 在哪算 | sourcebar_gate 内 `to_databar(sourcebar, bars_listed(tf.databar_list))`（`:295`） | sourcebar_gate 内 `sb.to_databar(qualified, bars_listed(tf.databar_list))`（`:194`） |
| 完整性判定 | sourcebar_gate 内做（clock vs period_end + dealt_with_last，`:260-298`） | **不在 sourcebar_gate**；provider 交来的已是 closed `SourceBar`，sourcebar_gate 只做 OHLC `validate`（`api/sourcebar.gleam:225-244`） |
| 谁生成 Timeframe | `ingest.new_timeframe` → `timeframe.new(settings)`（`:33-40` / `:156-171`），在顶层装配期生成（`glib.gleam:268,281,419`） | **无 `new`**（R49/R64）；`src/` 里 `Timeframe(...)` 全是 `..timeframe` 记录更新，生产代码**零创建点**（R65 §3） |

**澄清 owner 描述与代码的两处出入（如实指出，不改原话）**：
- owner 原话见 §0.3：sourcebar_gate *"输出 databar 并且交给他自己生成的 timeframe"* —— 实测 **sourcebar_gate 不生成 timeframe**。glib 的
  `timeframe.new` 在 `ingest.new_timeframe`（由顶层装配调用）；sourcebar_gate 只返回一个更新后的
  `Timeframe`（`Timeframe(..timeframe, sourcebar_buffer: ...)`，glib:232-239）。glibe 更没有
  new。所以 *"谁生成 timeframe"* 是一个**真实且未解决的缺口**（R65 §3：空 Desk 永远长不大，
  今天 app 一根 bar 也处理不了），不能靠"sourcebar_gate 顺手生成"糊过去。
- *"在 sourcebar_gate 设置了 databar.idx"* —— **准确**。两代都在 sourcebar_gate 内用
  `bars_listed(databar_list)`（head.idx+1，O(1)）设 idx（`bars_listed` 定义 glibe:543-548）。

## 2. 依赖方向（实测 import，决定"搬 sourcebar_gate 会不会成环"）

- `timeframe` imports：`list, option, api/sourcebar, branch, config, databar, indicator, leaf, trading/signal`。
  **不 import `instrument`**。
- `instrument` imports：`dict, option, api/interval, api/sourcebar, ib/sourcebar, timeframe`。
- ⇒ `instrument → timeframe` **单向，无环**。把 sourcebar_gate 搬进 instrument 后它调
  `timeframe.databar_processing` 仍是这个方向，**不成环**。反之若 timeframe 反过来 import
  instrument，会成环（R50 §3 实测的硬约束 `Import cycle`）。
- 注意 R50 的微妙处：sourcebar_gate 若住 instrument 且读 `instrument.timeframes` Dict 做路由/拒绝，
  合规（instrument 是 Dict 持有者）；但**读 `timeframe.databar_list` 算 idx 就不合规**——见 §3。

## 3. 核心分析：R67 的真正解法是「idx 归属」，不是「sourcebar_gate 搬家」

R67（owner 2026-11-24）裁定：SourceBar 是门外的 foreigner，**无权读门内 `databar_list`**。
违规点正是 `sourcebar_gate` 里的 `bars_listed(timeframe.databar_list)`。

关键洞察（**本研究的中心结论**）：谁算 idx，谁就要读 `databar_list`。所以合规与否只取决于
**"算 idx"这个动作发生在哪一层**，与 sourcebar_gate 住哪个模块无必然关系：

| idx 计算主体 | 读 databar_list | R67 | 备注 |
|---|---|---|---|
| 现状：sourcebar_gate（持 foreign sourcebar） | sourcebar_gate 读 | **违规** | 已确认的违规点 |
| owner 方案 C 的子选项 C1：instrument 的"小转换函数" | instrument 读 | **仍违规** | 只是把违规者从 sourcebar_gate 换成"转换函数"；instrument 同是 foreigner |
| owner 方案 B / C 的子选项 C2：`timeframe.databar_processing` | timeframe 读**自己的**字段 | **合规** | 门内居民读自家账；且按 R50，读 databar_list 的函数本就该归 timeframe |

⇒ **owner 方案里"增加一个小的转换函数"若放在 instrument 并读 databar_list，仍踩 R67**；
合规的做法是让转换发生在 `timeframe.databar_processing` 内部（owner 说的"直接由
databar_processing 负责转换成 databar"那条）。这是三个方案里必须区分的陷阱。

## 4. 三维度深入

### 4.1 谁/在哪生成 Timeframe（补 R65 §3 缺口）

- 现状 glibe 无创建点：空 Desk 长不大。owner 方案 C 明确 *"在 Instrument 中生成 timeframe
  并且放到 timeframe_dict"* —— 这**正好补上缺口**，且符合 R50（instrument 持
  `timeframes` Dict、持 `Interval` key，是合法的 writer）。
- 这与 R65 我上次的分析互补：R65 形状 B 说"sourcebar_gate 写 `Instrument.timeframes` 故归 instrument"；
  今天 owner 把这一步从"推测"变成"明确要求"。
- 代价（R65 §2 已记）：若同时要求"第一根完整 bar 才诞生"，`growing_target_sourcebar`
  要搬出 Timeframe → **一个 type 改动**。owner 本次未要求搬该字段，可保持不动（形状 A′ 的
  那部分仍成立），只把"创建"落在 instrument。

### 4.2 多周期合成与 sourcebar_gate 位置（owner 特别关心）

- 合成现状：`instrument.compose_ib_realtime_bar`（`:156-232`）按 `Interval` key 派发到
  `ib/sourcebar.five_second_to_*`（函数定义在 `ib/sourcebar.gleam`，R50：call site 不是 owner），
  产出 closed `SourceBar`。半根 bar 状态 `growing_target_sourcebar` 住在 Timeframe 字段里，
  但**只有 instrument 读写它**，timeframe 自己从不碰（归属错位：字段住民是 Timeframe，主人是 instrument）。
- 若 sourcebar_gate 也搬进 instrument：外部原料链路 **合成 → validate/sourcebar_gate → 交接** 全在 instrument 层，
  timeframe 只剩纯领域流水线（sourcebar→databar→indicator→leaf→branch→strategy→archive）。
  边界更整齐（**推断**：owner 说的"很多方面的问题更好解决"应指此；待其确认）。
- 这条独立于 R67：即使 sourcebar_gate 留在 timeframe，合成也仍在 instrument；sourcebar_gate 搬家主要收益是
  **职责边界 + 创建点归位**，而 R67 的违规靠 §3 的 idx 归属解决。两者是两个旋钮，不要混成一个。

### 4.3 与已定规则的相容性

| 规则 | 方案 B（sourcebar 进 databar_processing） | 方案 C（sourcebar_gate 在 instrument + instrument 创建） |
|---|---|---|
| R67 foreign 不读 databar_list | 合规（idx 在 timeframe 内算） | 合规**仅当** idx 也在 timeframe 内算（C2）；C1 违规 |
| R40/R41 pipe 形状 | databar_processing 接 SourceBar 入参 = 回到 glib super-function 形状；**glibe 现在不接 bar 参数**，改回需 owner 明确 | 不变，databar_processing 仍可不接 bar（sourcebar_gate/交接把 sourcebar 变成 working_databar） |
| R49 无 new | 不涉及 | instrument 用构造函数直接写记录（R64），不叫 new，合规 |
| R50 一个模块一层 | validate 归 sourcebar，idx 归 timeframe，各归其位 | sourcebar_gate 读写 instrument.timeframes、不读 databar_list ⇒ 归 instrument 合规 |
| 依赖环 | 无 | 无（实测 §2） |

## 5. 方案代价总表

| 维度 | 现状（保留） | 方案 B：sourcebar 直入 timeframe | 方案 C：sourcebar_gate 在 instrument + instrument 创建 |
|---|---|---|---|
| R67 违规 | 保留（违规） | 解决 | 解决（须 C2，禁止 C1） |
| 创建缺口 R65 §3 | 保留（空 Desk 长不大） | 未解决 | **解决** |
| 多周期合成衔接 | 合成在 instrument，sourcebar_gate 在 timeframe（分家） | 不变 | 合成与 sourcebar_gate 同层（更整齐，推断） |
| sourcebar_gate 职责 | validate + idx + 写 working | 退化为 validate/转发甚至删除 | validate + 交接；idx 移出 |
| type 改动 | 无 | 无 | 无（只要不搬 growing_target_sourcebar） |
| 与 R40/R41 | 现状 | 需回退"不接 bar 参数" | 不动 |
| 我的评价（推断，待裁定） | 两个真缺口都在 | 解决 R67，未解决创建 | **两缺口都解决，边界最清晰** |

## 6. 我的判断与待 owner 裁定（不擅改代码）

1. **R67 的解法与 sourcebar_gate 搬家是两件事**。无论 sourcebar_gate 最终住哪，`bars_listed(databar_list)` 必须
   从 sourcebar_gate 移到 `timeframe.databar_processing`（或它调用的私有函数）——因为读 self 字段才合规。
   owner 方案里"小转换函数放 instrument"会继续违规，建议排除；采用"直接由
   databar_processing 负责转换"。
2. **创建点应落在 instrument**（owner 方案 C），补 R65 §3 缺口，符合 R50；用构造函数直接写记录，
   不引入 new（R49）。这一条与 sourcebar_gate 是否搬家可分别裁定。
3. **sourcebar_gate 搬 instrument 的主要收益是职责边界**（合成+准入都在 instrument，timeframe 纯计算），
   不是 R67；代价是 R65 我上次的 A′ 判断需重评——其前提"sourcebar_gate 读 databar_list 合规"已被 R67
   推翻，我如实更正（上次判断不作数，以本次 owner 裁定为准）。
4. **待 owner 明确的三点**（type/signature 层，我不猜）：
   - (a) sourcebar_gate 最终住 `timeframe.gleam` 还是 `instrument.gleam`？
   - (b) `databar_processing` 是否改为接 SourceBar 入参（回退 R40/R41 的"不接 bar 参数"）？
     还是保持不接、由交接处写 working_databar？
   - (c) `growing_target_sourcebar` 是否随 sourcebar_gate 搬进 instrument（type 改动，R65 形状 B）？
     本次 owner 未提，默认不动。
