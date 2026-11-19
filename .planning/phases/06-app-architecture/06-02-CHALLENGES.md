# 06-02 — app 技术难点 / 非熟知差异笔记（gd 前置）

2026-11-19 08:35。owner 指令（逐字）："首先找出技术难点，和与你熟知的系统不同的地方，
重点笔记下来，然后在 gd这一步，写好codefile中的文档，引用你的笔记内容，把这些非熟知的
特别设计，技术难点全部在文档层面先解决掉。"

**这份只记"非熟知 + 难点"**：即与我（AI 训练里熟悉的 Web/React/传统 MVC GUI）**不同**、
照常识写就会错的地方。已懂的 MVU 三段式本身不记。每条带官方源证据。
本文件供 `06-01-PLAN.md` 与各 codefile 的 `////`/`///` 引用。**是笔记，不是设计、不是裁定。**

---

## A. 进程与所有权（最反常识）

- **A1. 应用是 BEAM 进程，state 全在它里面；renderer 是另一个 OS 进程。**
  官方 guide 01 逐字："Your application is a Gleam process running on the BEAM that owns all
  the state. A separate Rust binary handles rendering, input, and platform integration."
  我熟知的 Web 是浏览器单进程 + JS 状态；这里**默认两进程**，逻辑与显示物理分离。
- **A2. 两进程走 wire protocol（MessagePack 默认 / JSON 调试），不是函数调用。**
  runtime 对 view 树做 diff，**只发 patch 过线**。同机走 stdio，也可 SSH / socket 跨机——
  "the Gleam app runs on one machine, the renderer runs on another; only the transport differs"
  （configuration）。这直接支撑 owner"眼一个耳一个可分可合"。
- **A3. renderer 崩了不丢 model。** spawn 传输下 bridge 指数退避重启（100ms·2^n，5s 上限，
  5 次放弃）；重启后重发 settings、全量快照、重开窗口。**app-side state 保住，renderer-side
  state（滚动位置/光标/编辑器状态/图片）重置**（app-lifecycle）。⇒ 不能把状态只放 renderer。
- **A4. OTP supervisor 是 `rest_for_one`**，子进程顺序 Bridge → Runtime → (DevServer)。
  update/view panic 被 `platform.try_call` 捕获并回退到前一 model / tree，**不靠我写 try**。
  这与"库里禁止 panic"（core §6）不冲突：框架兜底 ≠ 我们主动用 panic。

## B. 消息与类型边界（项目的 type-first 怎么落到 UI）

- **B1. `app.simple` 的 msg 就是框架的 `Event`（12 个变体：Widget/Key/Window/Timer/Async/
  Stream/Effect/System/Ime/ModifiersChanged/Error/Session），源码 `event.gleam:33`。**
  **`app.application` 才有自定义 `msg` + `on_event: fn(Event) -> msg`**（`app.gleam:143`）。
  ⇒ 本项目要"输入/眼/耳口归一成自有 Msg"，必须用 `app.application`，不能用 try_plushie 的
  `app.simple`（它把 Event 直接当 msg，是 try 的简化，不是我们要的边界）。
- **B2. `Event` 是**开放给框架扩展的**大类型——官方明说 update 末尾用
  `_ -> #(model, command.none())` 兜底（app-lifecycle）。这与 core §4「不对自己的闭集写
  catch-all」不矛盾：这是**框架的** Event，不是我们的 Msg。我们的 Msg 仍要穷举。
  ⇒ `on_event` 是把「开放的框架 Event」收敛到「我们穷举的 Msg」的那道闸。
- **B3. 版本坑（实证）**：当前官方 guide 16 用 `event.Custom(tag:, payload:)` 做广播注入，
  但本地 0.6.0 包全树**无 `Custom` 变体**（只有 `theme.Custom` / `font.CustomFont`）。
  ⇒ 官方 docs 在重梳，版本领先于 pinned 包。**on_event 归一只用 `fn(Event)->Msg`，不依赖
  Custom**，所以骨架不受影响；但 shared-actor 广播若要用 Custom，须先核对包版本。

## C. update/view 的形状（与我熟知的 React 差异）

- **C1. `update(model, msg) -> #(model, Command(msg))`**——返回**（新 model, 命令）二元组**，
  副作用不直接做，而是返回 Command 由 runtime 执行（`app.gleam:143`）。**`command.Command(msg)`
  是普通类型**（`command.gleam:18`），`command.none()` 是空命令（:274）。
- **C2. `view(model) -> List(Node)`**：返回**顶层窗口列表**，不是单个 UI。返回 `[]` 关闭所有
  窗口并干净退出（guide 01 / app-lifecycle）。`ui.window(id, opts, children) -> Node`
  （`ui.gleam:57`），`window.build(w) -> Node`（`widget/window.gleam:260`）。
- **C3. view 每次成功 update 后都跑，即使 model 结构没变**；wire 流量靠 diff 阶段拦：
  归一化树相同就不发 patch。**不要自己写"model 没变就不 view"的优化**（app-lifecycle）。
- **C4. 多窗口共享同一个 model/update/view**——官方逐字 "All windows share the same model,
  `update`, and `view`. That's the whole multi-window story; there is no separate window-manager
  state."（composition-patterns）。多 runtime / shared actor 是**多 renderer/客户端**的事
  （guide 16），不是多窗口的事。这是我上轮设计记错、本轮纠正的点。

## D. 与领域模型（R33 / Desk）的接口——最需要在文档层钉死

- **D1. view 层命名 = `Dashboard`，对应 model 的 `Desk`**（owner 本轮 08:28 逐字）。
  我熟知的叫法可能是 View / Screen / Page——**本项目用 Dashboard**。R20 `RULINGS.md:487`
  早有此意。不跟随 try 把 view 也叫 Desk。
- **D2. Model 不另存领域数据**。`Desk` 是唯一 source of truth（Elm 的 Model + R33）。
  App 的 model 可以**引用 / 包裹** `Desk`，但不能复制一份 brokers/instruments 树——
  否则两处真相。state helper（selection/route/undo）是纯数据结构，存进 model、在 update 更新
  （guide 14）。
- **D3. 领域重算仍是纯 `Desk -> Desk`**（R33：一条流、无 actor/scheduler/clock/poll）。
  MVU 的 update 是**表现层事件循环**，只是把消息转成对 `Desk` 的读写调用；它**不是** R33
  禁止的调度器。这条边界必须在 codefile `////` 里写死，否则会被读成"引入了 actor 调度"。
- **D4. `bar_stream_chart` 产框架中立的 `SpecShape`（`bar_stream_chart.gleam:122`），
  不是 Node**；`Chart` opaque（:201）、`empty(geometry, scale)`（:289）、
  `push(chart, bar)`（:400）/ `push_generating`（:362）、`shapes`（:805）。
  ⇒ chart 层不依赖 plushie；把 SpecShape 翻成 Node 的是上层翻译壳。领域→图表的桥是
  `Bar` / `Geometry` / `PriceScale`，这些 type 的形状要在文档层定清（owner 设计 / glib 实现参考）。

## E. 测试与坑（非熟知验收）

- **E1. 三后端**：mock（协议-only、跳 GPU）/ headless（软件渲染+像素）/ windowed（真 GPU、
  需显示服务）。官方明说测试跑真实 renderer 二进制。**测试绿 ≠ 窗口能跑**——字号 0 崩
  renderer 的坑印证。验收 = 三后端 + 真窗口启动，缺一不可（guide 15 / configuration）。
- **E2. `receive` 必须在 Subject owner 进程，包一层 `command.task` 会 panic 且被吞**
  （speak_engl "一行改动，最大收益"）。声控边界的进程归属要写进文档。
- **E3. `os:cmd` 要 charlist 不要 binary；atom 用 `create` 不是 `get`**（glib 声控栈实测）。
  平台能力走 `@external(erlang, …)`，不手写 `.erl`（owner 08:16/08:28）。
- **E4. 重资源（whisper 模型）用 `persistent_term` 按引用缓存**省 ~500ms（speak_engl），
  不复制进 model。

## G. 多 broker × 多 instrument × 多 timeframe 同时跑，view 层怎么办（owner 08:35 追问）

owner 逐字："比如多 broker 多 instrument 多 timeframe同时跑，model层可能解决了，view层
（app 层）如何解决？view model通信与你熟知的做法有何不同？如何做到在View层绝不出现搬运
model层各种list过去的现象？都要从书上找到官方的设计方案。"

**这节全部从官方源找方案，不凭我熟悉的做法（React 把 state 数组 map 成组件）。**

### G1. 我熟知的做法是什么、为什么在这是错的

- 我训练里熟悉的 Web/React：`view(state) = state.items.map(item => <Row data=item>)` —— **每次
  render 把整个集合从 model 搬到 view，逐项构造节点**。这正是 owner 禁止的"搬运 list"。
- 官方 canvas guide 12 的例子也这么写：`ui.canvas("chart", ..., [canvas.Layer("bars",
  bar_shapes(model.series))])`、bar chart "one `shape.rect` per value in `model.series`"。
  **诚实说明：这是官方 tutorial 的简化写法，不是大规模场景的方案。** 若照它做，多 timeframe
  每帧重算全部 bar 形状 = owner 明确禁止的搬运。不能拿 demo 当架构。

### G2. 官方给的两个机制（都从书上来）

1. **Composite widget 自持 state**（reference/custom-widgets 逐字）：`WidgetDef(state, props)`
   有 `init / view / handle_event / subscriptions`；"The runtime **instantiates the widget per
   node ID, threads state through renders**, and routes events through the widget handler before
   delivering them to the app's `update`"。`state` 逐字 "arbitrary and opaque to the runtime.
   **Keep it small and pure; it participates in view memoisation** ... gets copied across
   `handle_event` calls."
   ⇒ 一个 timeframe 一个 widget 实例，用稳定 node ID（`BrokerId/Symbol/Interval` 编码，身份在
   key，R23/R37），增量状态住在 widget 自己的 state 里，**由 runtime 跨 render 持有**，不回灌
   app model、更不从 model 搬 list 进 view。事件在 widget 层被 `Consumed`/`UpdateState` 就地消化
   或 `Emit` 成小 payload 才上到 app。
2. **bar_stream_chart 的增量 Chart**（README 逐字设计规则）：`push(chart, bar)` 是唯一输入，
   "no batch API, no replay, and no way to **load a list of bars**"；`Chart` opaque，"stores
   generated shapes, O(1) carried bounds, and the one previous point set ... **never a copy of
   the caller's bar list**"；`shapes` 只装配已生成形状，zoom/pan 一次仿射不重访旧 bar；
   "**View and model are separate: the caller owns its own data model**, translates one bar into
   `bar_stream_chart.Bar`, and consumes the returned shape IR."

### G3. 三个问题的精确答案

- **view 层如何解决多×多×多**：每个 (broker, symbol, interval) 是**一个稳定 ID 的 chart widget**；
  widget 的 state 里持有一个 opaque `Chart`，数据到达时 `push(chart, bar)`（一根），view 只把
  `shapes(chart, viewport, mouse)` 的 **SpecShape IR** 翻成 Node。多图隔离由 node ID + scoped ID
  保证（try_plushie 48 测试实测多图互不干扰，这是"走得通"的证据，不抄它的业务 type）。
- **view-model 通信的不同**：不是"view 读 model 整棵树然后 map"。真正的门在 model 层——
  **唯一触发点是 `timeframe.working_databar_archived`**（owner 2026-11-20 裁定，见 `06-05`）：
  **(a)** 一根合格 SourceBar 经 `sourcebar_gate` 成为 `working_databar`；
  **(b)** `databar_processing` 这条纯 `Timeframe -> Timeframe` 直线跑完（R40/R41）；
  **(c)** `working_databar_archived` 把那根 bar 放进 `databar_list` head 并清空 `working_databar`；
  **(d)** update 在这个归档**完成之后**，从 `Timeframe.databar_list` head 取刚归档的那根 bar，
  经 `push(chart, bar)`（一根）送进对应稳定 ID 的 widget chart state；
  **(e)** view 只把 `shapes(...)` 的 IR 翻成 Node。
  model 仍是 `Desk` 唯一 source of truth（R33）——view 读到的是派生/增量后的 IR，不是
  brokers/instruments 的原始 list。
  **⚠ 本节 original 文本曾写"bar 经 Msg 直接派发到 widget push"，那是我的推断，与 owner 设计
  不符，2026-11-20 由 owner 纠正并作废**：app 不经 Msg 把 bar 直接喂给 widget；bar 只能从
  归档完成后的 model history head 来（同 glib `SYSTEM_MODEL.md:527/1344/1356`：one writer,
  one door, no dedup；model changes at `working_databar_archived` and the view follows）。
  **职责分工**：领域重算（leaf/branch/timeframe）在 L1 纯核 `Desk -> Desk`；图表形状的增量累积
  是表现层派生，放 widget state，不回写 Desk。这条必须在 codefile `////` 写死。
- **绝不搬运 list 的机制（是类型设计，不是纪律）**：chart 库**根本没有 load-list/batch API**，
  `push` 一根本上是唯一入口；widget state opaque 由 runtime 持有，`Emit` 只发小 payload。
  想搬运在类型上就做不到——这就是"原则要有机制承接"（SOUL / skill：a principle without a
  mechanism is decoration）。**不是靠人自觉不 map。**

### G4. 落点

这一节写进 `app/dashboard.gleam` 的 `////`（Dashboard = Desk 的投影；每 timeframe 一个稳定 ID
的 chart widget；view 只收 SpecShape IR 不搬 list；领域纯核 vs 表现层派生的分工）。`ui.memo`
（composition-patterns：按 dependency `==` 跳过子树 normalize/diff）作为未变图的额外优化，
但主机制是 widget state + chart 增量，不是 memo。

## F. 这些难点在 gd 阶段怎么处理（交给 codefile 文档）

| 难点 | 落在哪个 codefile 的 `////` / `///` |
|---|---|
| A1–A4 两进程 / wire / 崩溃恢复 / OTP | app 入口模块的 `////`（声明进程边界、model 归属、不靠手写 try） |
| B1–B3 Event→Msg 归一 / 开放 vs 闭集 / 版本坑 | `app/message.gleam` 的 `////`（Msg 闭集 + on_event 闸；注明不依赖 Custom） |
| C1–C4 Command / List(Node) / diff / 多窗口共享 | `app/runtime.gleam` 的 `////` + 相关 `///` |
| D1–D4 Dashboard 命名 / Model 不另存 / 纯核边界 / SpecShape | `app/dashboard.gleam` 的 `////`（最重：Dashboard=Desk 投影，不另存数据） |
| **G1–G4 多×多×多 / 不搬 list / view-model 通信差异** | `app/dashboard.gleam` 的 `////`（chart widget 自持 state + 增量 push + SpecShape IR；类型层禁止 load-list） |
| E1–E4 三后端 / owner 进程 / FFI / 缓存 | 各模块 `////` 的验收段 + `app/voice/<platform>` 边界注释 |

**gdltdd 纪律**：以上全部**先在 `////`/`///` 里写成断言式规格**（谁读/写哪个值、为什么这样），
body 一律 `todo as "…"`；编译 → 测试 RED → 逐个填 GREEN。文档层没解决的不往下写 body。
