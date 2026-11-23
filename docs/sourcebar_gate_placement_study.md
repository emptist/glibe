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

---

## 7. 追加（2026-11-24 02:18）：owner 倾向"留在 timeframe + 仅输出 SourceBar"，逐条利弊

**更正 §6.3**：owner 明说 sourcebar_gate 搬 instrument 的障碍是 `growing_target_sourcebar`
的配对——*\"一个field就不够用了，要生成字典，感觉很丑\"*。所以 §6.3 我"倾向搬 instrument"
的判断**作废**（那是我上次没把配对代价算进去）。owner 现在要评估的是**方案 B/C2：
留在 timeframe，仅改签名为输出 SourceBar**。下面是这个改法的真实利弊。

### 7.1 编译探测（`/tmp/place_probe`，Gleam 1.19.2，exit 0）
两种签名都编译通过：
- 现状：`sourcebar_gate(tf, sb) -> Result(Timeframe, Rejection)`（内部 validate+to_databar+写 working）；
  `processing(tf) -> Timeframe`（不接 bar）。
- 提议：`gate_only_output(sb) -> Result(SourceBar, Rejection)`（只 validate）；
  `processing_takes_sourcebar(tf, sb, extra) -> Timeframe`（第一行写 working，后面照常 pipe）。
⇒ **type 层没有障碍**：`databar_processing(tf, sb, settings)` 仍是 subject-first 的 pipe 容器，
新增参数是 pipe-call 参数（R40-A 允许"任意多个 extra 参数"）。**R40/R41 pipe 形状不受损**——
pipe 的 steps（indicator/leaves/...）仍全是 `Timeframe → Timeframe`，bar 只在第一行写进
working_databar 字段。这一点与此前担心相反：**改签名不破坏 pipe**。

### 7.2 这个改法解决的问题（确实是净收益）
1. **R67 违规消除**：sourcebar_gate 只读 sourcebar、不再读 `databar_list`；idx 由
   `databar_processing` 读自己的字段算（门内居民读自家账），合规。
2. **配对关系不动**（owner 的核心关切）：`growing_target_sourcebar` 留在 Timeframe，
   instrument 照旧读写它；不生成字典、不破坏 timeframe↔sourcebar 配对（R65 形状 A′ 的好处保住）。
3. **签名更贴 glib 冻结源**：glib 的 `databar_processing(tf, databar, publish)` 本来就接一个
   bar 入参（`:338-342`）；owner 这个改法等于把 bar 的诞生从 sourcebar_gate 挪回 processing 的开头，
   更接近 glib 原设计。

### 7.3 潜在问题 / 不方便 / 不合理（如实列，不推销）
1. **sourcebar_gate 变薄**（最大的"不合理"观感）：改后它只剩 `validate` 一层皮
   （`Result(SourceBar, Rejection)` = validate 的直接结果），完全不碰 Timeframe。
   它会变成一个**与 Timeframe 无关的函数**，却仍住在 `timeframe.gleam`——按 R50，
   一个只读 sourcebar 的函数应归 `api/sourcebar.gleam`（那里已有 validate）。
   ⇒ 要么接受"sourcebar_gate 是 validate 的薄转发、留在 timeframe 只为叙事"；要么把它改名/搬走。
   这是 owner 问"不合理之处"时最该摆出来的一条。
2. **idx 的读取时机后移，但要小心同源**：idx 必须在**归档前**算（读当前 `databar_list` head）。
   放在 `databar_processing` 第一行算，与放在 sourcebar_gate 里算，中间隔着 runtime 的一次函数调用
   （`:158`→`:162`），期间 `databar_list` 不变（纯函数、immutable），所以 **idx 值相同**——
   探测已确认无 type 问题，语义上也一致。但约束要说清：idx 计算的唯一正确位置是
   "写 working_databar 的同一处"，不能散落到后续 step。
3. **validate 的拒绝语义位置不变**：不合格 bar 仍在 sourcebar_gate 被拒（runtime `:156-161` 的
   `result.try` 不变），只是 Error 里装的是 Rejection 而非 Timeframe——调用面的 `map_error` 不用改。
4. **测试面改动（机械但必须）**：`test/glibe_test.gleam:1074-1082` 的 sourcebar_gate 测试断言的是
   `updated.working_databar.idx`；改后 sourcebar_gate 不写 working 了，这个断言要迁到
   `databar_processing` 的测试。生产调用点只有 `runtime.gleam:158/162` 两处（已实测），改动面小。
5. **"完整性判定"不在 sourcebar_gate 这一事实被强化**：glibe 的 closed 判定早在 provider 合成层
   （`ib/sourcebar` / kline），sourcebar_gate 本就只做 OHLC validate；改后 sourcebar_gate 连 bar 都不产，更纯。
   这不是问题，是 clarity 收益。
6. **与 R65 §3 创建缺口无关**：这个方案不解决"谁生成 Timeframe"（空 Desk 长不大）。
   它只改签名，不碰创建点。**创建缺口仍是独立待办**——owner 若只要解决 R67，这个方案够；
   若要 app 真能收 bar，还得另定创建点。

### 7.4 结论（待 owner 裁定，未改码）
- 若 owner 最看重"配对不动 + 不生成字典" ⇒ 这个"留在 timeframe、仅输出 SourceBar"的改法
  **可行、代价小、且不破坏 pipe**，主要代价是 sourcebar_gate 变薄后归属略尴尬（§7.3.1）。
- 一个折中建议（供选择，不强加）：让 `databar_processing` 接 SourceBar，**但把 validate 也挪进
  processing 的第一行**，sourcebar_gate 则彻底删除——这样没有"薄转发"的尴尬，职责按
  "processing 拥有 bar 的整个诞生+加工"一条直线走。这与 glib 的两函数结构不同，属更大改动，
  仅作备选摆出。
