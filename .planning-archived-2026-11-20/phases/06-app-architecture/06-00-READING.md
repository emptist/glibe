# 06-00 — app 架构读书笔记（Elm / iced / plushie 官方文档）

2026-11-19 08:30。**这份是读书笔记，不是设计、不是裁定。** owner 指令（逐字）：
"要想设计好，必须先读书，写好读书笔记，什么书，我告诉过你，想不起来就问我。"
书单来自 owner 2026-11-19 00:26 逐字："用plushie你要去读Elm 读iced 读plushie的官方文档"。
全部读**当前官方源原文**（GitHub `plushie-ui/plushie-gleam` docs、guide.elm-lang.org、
iced-rs/book），不引 try_plushie 的二手记录。本文件是 `06-01-PLAN.md` 的前置输入。

---

## 一、Elm Architecture（guide.elm-lang.org/architecture/）

- 逐字三段：**"Model — the state of your application / View — a way to turn your state into
  HTML / Update — a way to update your state based on messages"**；"Model = source of truth"；
  update 收消息、返回新 model。
- 单向数据流：事件 → update → 新 model → view → 画面。**没有双向绑定、没有隐藏 mutation**。
- 一句诊断法则（逐字意）：画面错了看 model，model 错了看改它的那个 message——"Every bug has
  a short trail."
- **对本项目的映射**：glibe 的 `Desk` 就是那个唯一 Model / source of truth（R33）。view 是它
  的投影，不是第二份领域数据。

## 二、iced 哲学（iced-rs/book `philosophy.md`）

- 逐字：iced **"decouples itself from your types, data structures, and business logic"**；
  "all of layout, styling, and logic are written directly in Rust as a cohesive whole"；
  "completely and utterly rejects" web 的 HTML/CSS/JS 三层分离。
- **对本项目的映射**：renderer 只管显示、不碰业务模型——与 glibe「不用 web / 类型到家 /
  BEAM 原生」同向。注意 plushie 把 iced 藏在后面，开发者**从不直接碰 iced**
  （guide 01 逐字 "You never interact with Iced directly"）。所以 iced 是底座知识，不是
  glibe app 直接依赖的 API。

## 三、plushie 官方 guides（当前版，17 篇索引全读；精读与架构相关的 01/14/15/16 + reference）

### 3.1 guide 01 Introduction — 进程拓扑（地基）

- 逐字：**"Your application is a Gleam process running on the BEAM that owns all the state.
  A separate Rust binary handles rendering, input, and platform integration."**
- **"The renderer is built on Iced... You never interact with Iced directly."**
- MVU 三件：Model 可是任意 Gleam 类型（"Plushie does not impose a schema"）；update 收 model
  + message 返回 `#(model, Command(msg))`；view 收 model 返回 `List(Node)` 顶层窗口，
  **返回 `[]` 关掉所有窗口并干净退出**。
- 主循环逐字：**`event -> update -> new model -> view -> UI tree -> render`**。
- 两进程用 stdio 交换消息（默认），MessagePack wire（JSON 调试）。runtime 是 OTP-supervised
  actor。**renderer 崩了指数退避重启、model 不丢；update panic 则 OTP 捕获、回退到前一个
  model**——"Neither process can take the other down."
- 两进程走字节流 ⇒ **不必同机**：BEAM 可跑在无显示无 GPU 的服务器，renderer 跑在有屏幕处。
- 官方明列用例含 **"Dashboards and data visualization: connect to your Gleam or Erlang backend
  directly, no API layer needed"** 和 **"Multi-window applications"**——正对本项目。

### 3.2 reference App Lifecycle — App 签名与回调（本轮重点）

- 核心构造子（逐字签名）：
  - `app.simple(init, update, view)`：msg 类型是 `Event`；
    `init: fn() -> #(model, Command(Event))`，`update: fn(model, Event) -> #(model, Command(Event))`，
    `view: fn(model) -> List(Node)`。
  - **`app.application(init, update, view, on_event)`**：自定义 `msg`；
    `on_event: fn(Event) -> msg` 把 renderer 事件映射成应用自己的类型消息。
    **← 这是本项目"眼耳口消息归一成 Msg"的官方形态**（比我上轮写的 on_event 更准）。
- `update` 返回 `#(model, Command(msg))`；**官方明说末尾用 catch-all
  `_ -> #(model, command.none())`**（注意：这是**对框架 `Event`** 的兜底，不违反 core §4
  "不对自己的自定义类型写 catch-all"——两种类型要分清）。
- `view` 每次成功 update 后都跑，即使 model 结构没变；**diff 阶段若归一化树相同就不发 patch**。
- `subscribe(model) -> List(Subscription)` 每次 update 后 diff、自动增删。
- 启动 `plushie.start(app, opts)` 建 **OTP `rest_for_one` supervisor**：Bridge → Runtime →
  (DevServer)。Runtime 拥有 app model、跑 Elm loop。返回 `Instance(model)` 带类型。
- 运行时查询含 **`plushie.dispatch_event(instance, event)`**（绕过 renderer 注入事件）、
  `get_model` / `get_health` / `wait` / `stop`。
- **纠正我上轮认知的一句**：官方 update/view panic 会被 OTP 捕获、回退状态、计数——不是
  "panic 就崩"。但 core §6/§7 仍禁止库内 panic；两者不冲突：框架兜底 ≠ 我们主动用 panic。

### 3.3 guides 14 State Management / 15 Testing

- 14：state helper（routing / undo / selection / data pipeline）是 **"pure data structure.
  No processes, no side effects, no framework coupling"**——存进 model、在 update 里更新。
  ⇒ 领域状态用纯数据，不塞进程。
- 15：三后端 **mock（协议-only、跳过 GPU）/ headless（软件渲染+像素）/ windowed（真 GPU）**；
  真 renderer 二进制跑测试。**测试跑真实渲染、可点击可截图**；但窗口能否真起还需 windowed 验证
  （与 try_plushie 字号 0 崩 renderer 的坑印证：测试绿 ≠ 窗口能跑）。

### 3.4 reference Composition Patterns — 多窗口（**纠正我上轮设计**）

- 逐字：**"All windows share the same model, `update`, and `view`. That's the whole multi-window
  story; there is no separate window-manager state."**
- ⇒ **纠正**：我上轮 06-01-PLAN 写"眼耳口各起一个独立 runtime"——**对"多窗口"是错的**。
  同一 app 的多窗口共享一个 model/update/view，没有窗口管理器状态。多 runtime 是 guide 16
  的"多 renderer / 多客户端"场景，不是"多用一个 app 多开窗口"的理由。两者要分开写。
- 覆盖层（modal / toast / context menu）放**窗口级 stack**；`ui.memo(key, dependency, fn)`
  用 `==` 比 dependency、跳过子树 normalize/diff——图表子树可按数据快照 memo。

### 3.5 reference Configuration — transport（眼耳可分可合的机制）

- 三种 transport（逐字）：
  - **Spawn**（默认）：SDK 用 Erlang Port spawn renderer、`gui.run` 用；崩了指数退避重启、model 保。
  - **Stdio**：renderer 是父进程，Gleam app 读写自己的 stdin/stdout（`stdio.run`）；SSH 场景。
  - **`Iostream(adapter)`**：Subject-based 适配器，桥接 SSH / TCP / Unix socket / WebSocket；
    `socket_adapter` 是内置 adapter。**"enables remote rendering: the Gleam app runs on one
    machine, the renderer runs on another... only the transport layer differs."**
- ⇒ 这正是 owner"眼一个耳一个、可分可合"的官方机制：**model 在 BEAM 侧一份，多个 renderer
  按 transport 接进来**。不必把眼耳做成两个各自拥有领域数据的 app。

### 3.6 guide 16 Shared State — 多 renderer 的权威模型（当前版）

- 逐字：**"One authoritative process owns the model. Each connected renderer gets its own
  `plushie` runtime talking to it."**
- **"Each runtime is a full Elm loop: its own subscriptions, event coalescing, error isolation.
  The shared actor only holds the model and broadcasts."**
- 权威模型在 **gleam_otp actor**；`Apply(event)` → actor 跑 `update` → 存新 model →
  `Broadcast` 给每个 runtime；runtime 只做 `Broadcast(new_model) -> #(new_model, none())`
  纯替换 + 本地 diff/patch。
- **per-client state**：model 拆 `Model(shared:, local:)`，broadcast 只带 shared，`update` 合并时
  不碰 local（如 dark mode / 焦点 / 滚动位置）。
- 路由：`on_event` 把状态变更事件转发给 shared actor、本地 no-op；纯装饰事件（焦点/滚动）本地处理。
- **注意**：try_plushie §30.1 记的旧措辞（"wrong shape = single MVU loop / right shape = N MVU
  loops"）不在当前版 guide 16 原文里——当前版讲的是 shared actor + 每 renderer 一个 runtime。
  方向一致（单 loop 服务多客户端不成立），但**措辞必须引当前官方源**，不引旧二手。

---

## 四、读书得出的"设计输入"（不是设计本身，交给 06-01 修订时消费）

1. **唯一 Model = `Desk`**：Elm source of truth + R33，view 不另存领域数据。
2. **消息归一用 `app.application` + `on_event`**：renderer `Event` → 应用自有 `Msg`（眼耳口
   各自来源归一到一个闭集）。官方形态，比我上轮写的更准。
3. **多窗口 ≠ 多 runtime**：多窗口共享一个 model/update/view；多 runtime 只对应多 renderer /
   多客户端（guide 16）。上轮 06-01 的"眼耳口各一 runtime"要按此改正。
4. **眼耳可分可合 = transport 选择**：model 一份在 BEAM，renderer 经 Spawn/Stdio/Iostream 接入。
5. **黑板/底座**：iced 是被 plushie 藏起来的底座，glibe 不直接依赖它；读书是为了懂边界，
   不是为了调它的 API。
6. **view 层命名 = Dashboard**（owner 本轮明确）：glib 与 glibe 的 view 一直是 Dashboard，
   对应 model 的 `Desk`；**不跟随 try 把 view 也叫 Desk**。常用且实际作用都是 Dashboard。
7. **测试**：三后端 + 真窗口启动才算验收；图表子树可用 `ui.memo` 按数据快照跳过 diff。

## 五、边界

- 本文件只记读书所得，**不输出 app 架构设计、不改 06-01-PLAN（那是下一步）**。
- 未改任何 tree 源码；决策区仍 0 项。
