# Desk-only model 下归档单 DataBar → View chart widget 机制：研究结论

研究计划：`.planning/phases/03-app-view/03-00-ARCH-RESEARCH.md`
执行日期：2026-11-23

## Summary

结论先行：**chart 只能留在 View 层的 widget state（plushie runtime 持有），绝不进 `Desk`；规划中的唯一正规通道是「归档完成后，向目标稳定 ID 的 chart widget 注入一条 `CustomWidget` 事件，widget 自己的 `handle_event` 把那一根 `DataBar` push 进自己的 `Chart`，返回 `UpdateState` 触发重绘」。** 这不是新发明：owner 2026-11-19 记录的设计就是「一根 bar 按稳定 ID 派发到对应 widget → widget 增量 push → view 只读派生 IR」（`docs/RULINGS.md:5443-5449`；归档 `06-02-CHALLENGES.md:108-152`）。我此前把它误报成「carrier 缺口」并随后又反向写成「chart 放 app model」，两个方向都错；本文件把两边都纠正。

`plushie.dispatch_event(instance, event)`（`plushie.gleam:376`）等价于 renderer 事件，会走完整的 `handle_event → widget 链 → update → view → diff → patch`（`runtime.gleam:774-783, 2085-2118`）。`widget.Emit` 构造的正是 `event.Widget(event.CustomWidget(...))`（`widget.gleam:548-560`）；我过去说「0.6.0 无 Custom」只在**顶层 Event** 为真（`event.gleam:33-58` 确实没有 `Custom` 变体），但 `WidgetEvent.CustomWidget` 真实存在于 `event.gleam:230`——否定结论用错了层级。

待实现的细节是**谁持有 `Instance` 并在归档后注入**：glibe 目前没有任何 `plushie.start` / 启动接线模块（全树 grep 为空），`update` 签名被 `test/app_shape_test.gleam:99` pin 成 `fn(Desk, Msg) -> #(Desk, Command(Msg))`，因此注入应作为 `update` 返回的 effect/命令接线实现，而不是改 model 或改签名。这一层是实现安排，**不是新的 owner 决策**。

## Recommendations

### Primary Recommendation

1. **保持 `Desk` 纯领域**：`Timeframe` 不加 `chart` 字段，不加第二个 model，不把 `Chart`/viewport/mouse 塞进领域类型（owner 2026-11-23 当面纠正；R33/R50；`test/app_shape_test.gleam:99`）。
2. **图表状态继续住 `ChartWidgetState`**，由 plushie 的 widget registry 跨 render 持有（`widget.gleam:68-88, 290-306, 320-368, 375-407`）。这是 06-02 §G2 的官方机制，不是我发明的 composite-widget 方案。
3. **唯一发布序列**：`sourcebar_gate → databar_processing → working_databar_archived` 完成后，从 `Timeframe.databar_list` head 读刚归档的 `DataBar`（owner C2；`06-05-TRIGGER-RULING.md` C1–C2），经 `dashboard.data_bar_to_chart_bar` 映射，注入目标稳定 ID widget 的 `handle_event`，在那里调用已填绿的 `push_one`（`src/glibe/app/dashboard.gleam:150-152`），返回 `EventAction.UpdateState` 触发重绘。
4. **注入用 `CustomWidget` + `EventTarget`**：`event.Widget(event.CustomWidget(kind:…, target: EventTarget(window_id:, id:, scope:, full:), value: dynamic.nil(), data: …))`，从持有 `Instance` 的启动/发布侧调 `plushie.dispatch_event`（`plushie.gleam:376-378`）。widget 链按 id 精确命中（`widget.gleam:426-486`）；`UpdateState`/`Consumed` 会截断链条并触发 rerender（`widget.gleam:544-547`；`runtime.gleam:2111-2116`）。
5. **写入重写后的 03-01/03-02 再动代码**：先用编译探针验证「命令 → 注入 → widget state 更新」的类型形状，再按 GDLTDD 写 RED 测试与 body。任何 `.gleam` 文档改动都必须由重写后的 PLAN 明确授权。

### Alternatives Considered（含拒绝理由与出处）

| 候选 | 判定 | 证据 |
|---|---|---|
| `Chart` 进 `Desk`/`Timeframe` / 第二个 app model | **拒绝** | owner 2026-11-23「chart 作为 View 你要把它变成 Desk model 的一部分？？？？」；R33/R50（`docs/RULINGS.md:1090-1123`）；`test/app_shape_test.gleam:99` 编译期 pin |
| `Command.Done` / `SendAfter` 把 bar 送回 `update` 后直接写 widget state | **拒绝** | `runtime.gleam:2296-2332` 只发 `DispatchedMsg`；`:815-825` 进入 `handle_msg`（直接调 update），**不经 widget 链**，因此到不了 widget state |
| `view(desk)` 通过 props 把 bar 交给 widget 并在 view 内累积 | **拒绝** | `widget.gleam:73` 的 view 是 `fn(String, props, state) -> Node`，无返回值通道写 state；`render_placeholder` 只用已有 state 重建 entry（`:332-345`）；纯 view 无法累积 |
| `Command.Renderer(NativeCommand(...))` 触发自定义 widget | **拒绝** | 该命令被编码成 renderer wire `Command`（`command_encode.gleam:192-196`），目标是原生 renderer widget，不是 Gleam `widget.Registry` 里的自定义 widget |
| widget `subscriptions` 定时器轮询 | **拒绝** | `runtime.gleam:834-838` 虽会走 `handle_widget_timer` → widget handler，但 poll 违反 R33「系统本来就活，无数据则睡」与 06-05 C1 |
| 外部进程 / ETS 保存 chart map，view 去读 | **拒绝** | 第二份状态副本，违反 R50 与 06-05 C3「widget state 里的 Chart 是表现层派生，不回写 Desk，不是第二份 model」 |
| app 代码直接调 `widget.Registry` API 改 state | **拒绝** | registry 存在 runtime 的 `LoopState.cw_registry`（`runtime.gleam:2094-2096`），app 侧拿不到；且每轮 render 后由 `derive_registry` 重建（`:375-407`） |
| 照抄 try_plushie「一图一 App、chart 在 app model」 | **拒绝** | owner 2026-11-19 逐字「try_plushie 重在探路…type 结构业务流程可能都有问题…不照抄」（`docs/RULINGS.md:5380-5384`）；三 App = 三 renderer（`beam-plushie-concurrency-measured.md:222-229,274-279`） |
| **归档后注入 targeted `CustomWidget` 事件** | **采纳** | `event.gleam:230`（变体存在）、`widget.gleam:426-486`（按 target 精确路由）、`:544-560`（UpdateState 截断 + rerender）、`plushie.gleam:376-378`（外部注入）、`runtime.gleam:774-783,2085-2118`（注入走完整 MVU） |

## Key Findings

### A. 权威层：owner 裁决与冻结 glib 设计记录

- **C1 唯一触发点**：owner 2026-11-20「完全使用 model 方面的 `working_databar_archived` 作为 plushie update 的触发点」，理由「working_databar 如果还在工作…model 不完整，怎么更新 view？」全文在 `docs/RULINGS.md:5565-5590` 与归档 `06-05-TRIGGER-RULING.md`。`working_databar` 为 `Some` = 各层 field 半成品 = 禁止 view；归档后 `None` + head 完整才可画。
- **C2 取 bar 点**：owner 选「归档后读 history head」，见 `docs/RULINGS.md:5582-5583`、`06-05-TRIGGER-RULING.md` C2。**bar 的来源必须是 model 的归档结果，不是入站 Msg payload**——这一条与「注入事件的 payload 携带已归档 bar」并不矛盾：后者是归档后的出向传递，前者是入向数据来源。
- **C3 不另搞一套**：`Desk` 唯一；chart 是表现层派生，不回写（`06-05` C3；`SYSTEM_MODEL.md:626-639` "a shadow is a second copy of state"）。
- **多×多×多 view 方案**：owner 2026-11-19 08:35 追问后记入 `docs/RULINGS.md:5440-5450` 与 `06-02-CHALLENGES.md:91-152`：每 (broker,symbol,interval) 一个稳定 ID widget；运行时持有 widget state；view 只读 `SpecShape` IR；图表状态只由逐根 `push` 增长，不持有调用方的列表。
- **一个 App / Dashboard 命名**：官方 "All windows share the same model, update, and view"（`docs/RULINGS.md:5408`）；view 叫 Dashboard、对应 model 的 Desk（`:5384`、R20）。
- **2026-11-23 当面纠正（本会话，尚未写入稳定文档）**：「chart 作为 View 你要把它变成 Desk model 的一部分？？？？」——明确否决把 chart 写进 `Timeframe`。`docs/PENDING_DECISIONS.md:24-54` 的撤销记录中「图表状态在 model 里，不在 runtime 持有的 widget state 里」一句与 owner 本轮话冲突，需在重写计划时更正为「图表状态在 View 的 widget state 里」。这是**文档漂移**，不是待裁决项。
- **旧结论需更正**：`docs/RULINGS.md:5416` 与 `src/glibe/app/message.gleam:24` 的「0.6.0 无 `Custom`」应精确化为「顶层 `Event` 无 `Custom`；`WidgetEvent.CustomWidget` 存在（`event.gleam:230`）」。

### B. 已安装 plushie 0.6.0 实测（接口契约）

- 版本确认：`build/packages/plushie_gleam/gleam.toml:2` = `0.6.0`。以下行号均对应该安装版本。
- `WidgetDef(state, props)` 五字段：`init: fn() -> state`、`view: fn(String, props, state) -> Node`、`handle_event: fn(Event, state) -> #(EventAction, state)`、`subscriptions`、`cache_key` —— `widget.gleam:68-88`。
- `EventAction` 四变体：`Ignored` / `Consumed` / `Emit(kind, data)` / `UpdateState`，其中 `UpdateState` 意为「state 已改，触发 re-render」——`widget.gleam:146-160`。
- registry：`make_entry` 用闭包捕获 typed def/props/state（`:290-306`）；`render_placeholder` 对已存在 widget **保留 state、换入新 def/props**（`:320-368`）；`derive_registry` 每轮从渲染树重建 registry（`:375-407`）。⇒ widget state 是 plushie runtime 持有的 View 状态，跨 render 存活，app 不可直接写。
- 事件链：`dispatch_through_widgets`（`:426-454`）按 `EventTarget.window_id + scope + id` 构造 handler chain（`:462-486`）；`walk_chain`（`:531-578`）里 `Ignored` 继续、`Consumed`/`UpdateState` 截断、`Emit` 构造 `CustomWidget` 后继续。
- runtime 注入：`plushie.dispatch_event`（`plushie.gleam:376-378`）只做 `process.send(instance.runtime, runtime.InternalEvent(event))`；`InternalEvent` 在 `runtime.gleam:774-783` 调 `handle_event`；后者先过 widget 链，再 `on_event → update → view`（`:2085-2118`）。被 widget 截断时走 `rerender_with_rollback`（`:1938-1951`），保证 state 与树不脱同步。
- `Command` 边界：`Done`/`SendAfter` 只回到 `update`（`:2296-2332`、`:815-825`）；`Renderer`/`NativeCommand` 进 renderer wire（`command_encode.gleam:192-196`）；widget 定时器经 `handle_widget_timer`（`runtime.gleam:834-838`）。
- `Event` 顶层 12 变体、`WidgetEvent.CustomWidget(kind, target, value, data)` 在 `event.gleam:230`；`EventTarget(window_id, id, scope, full)` 在 `:553-555`；`make_target` 在 `:580-591`。

### C. 候选机制矩阵（逐项 accept / reject）

见上面「Alternatives Considered」表；八项候选逐项给出 accept/reject 与源码行。核心判定句：**widget state 只能由 `WidgetDef.handle_event` 写；能触发它的公共入口只有 widget 链（`dispatch_through_widgets`）和 widget 定时器（`handle_widget_timer`）；前者可由 `plushie.dispatch_event` 从外部注入，后者是 poll。** 否定结论均有 `file:line`：view 无写 state 通道（`widget.gleam:73`）、app 拿不到 registry（`runtime.gleam:2094-2096`）、`Done` 不进 widget 链（`:815-825`）。

### D. 稳定 ID 与事件路由契约

- registry key = `widget_key(window_id, scoped_id)`（`widget.gleam:863-865`，分隔符 `\u{001F}`）。
- handler chain 先按 `scope` 逐层拼 ID 并过滤已注册项；scope 为空时用 `target.id` 直接拼（`:462-486`）。⇒ 注入事件必须携带与 `view` 生成的节点 ID 完全一致的 `window_id`/`id`/`scope`，否则是**静默 no-op**（`Bypassed` → 直接进 update，`runtime_core.gleam:233-239`）。
- `EventTarget.full` 是 wire 形态（`event.gleam:552-554`）；`make_target` 会把 window 追加进 scope（`:580-591`），构造 target 时要防止 scope 与 window 重复。
- 身份来源是 R23/R37 的 Dict key（BrokerId / Symbol / Interval），不是被持有者的 field。编码为稳定字符串 ID 的具体格式属实现细节，须在重写后的 03-02 计划里定，并用测试证明两个不同 triple 产生两个不同 ID（原 03-02-PLAN Task 1(b) 的断言可保留）。

### E. 类型化 payload 与 `Dynamic` 边界

- `CustomWidget.data: Dynamic`（`event.gleam:230`）是 SDK 的 catch-all 形态；无法在类型层把它改成 `Bar`。
- 生产方（归档后的注入侧）与消费方（chart widget 的 `handle_event`）都在 glibe app 层，闭包同源；建议把 `dynamic.from` / `dynamic.unsafe_coerce` 限制在一个带 `kind` 判别的小函数里，对外仍暴露 `fn(Event) -> Result(Bar, Nil)` 之类的 typed 边界。写成自己的 string parser 反而违反 core §0/§2（已有 Gleam 值不需要 parser）。
- 只发身份信号、让 widget 自己去读 Desk 不可行：widget 没有 Desk 引用，且那会形成第二数据源。
- **诚实标注**：`Dynamic` 在这里是 plushie 事件协议的既成边界，不是我选的形状；该处必须写清楚「谁写、谁读、为什么是同一个 kind」，符合 R47。

### F. 无渲染器测试路径

- 纯函数级：`widget.empty_registry()` + `widget.make_entry(def, props, state)` + `dict.insert` + `widget.dispatch_through_widgets(registry, event)` 都是 pub（`widget.gleam:284-306, 426-454`），可在 gleeunit 中直接跑，无需 renderer。注意 `RegistryEntry.state` 是 `Dynamic`，断言 updated state 需要经 widget 发出的语义事件或另设可观察出口。
- harness 级：`widget_harness.harness(widget_id, def, props)` 生成宿主 App 并记录语义事件（`plushie/testing/widget_harness.gleam:69-93`），配合 testing mock backend 可测事件链；是否引入该依赖由重写后的计划决定。
- 结论：**RED 测试不需要启动 renderer**；但「从 `update` 返回值一路到 widget state」的端到端断言需要先做类型探针，避免把不可观察的东西写成假测试。

### G. try_plushie 正反例

- 事实：`main()` 三次 `plushie.start`（`../try_plushie/src/try_plushie.gleam:773-794`），每图一个 App、`ChartModel` 持 chart；gl-center 实证三 renderer（`beam-plushie-concurrency-measured.md:222-229,274-279`）。
- 判定：能证明 plushie 走得通，但「一图一 App」不是最佳，官方多窗口是「一次 start，view 返回多个 window」（同文 `:274-279`）；§4.1 的「对」语境是「三套独立 MVU loop 的探路」，§5.6 自承与 glibe 并发裁决未合流。
- 可复用：`window_switch.gleam:151-184` 的「具名进程持 Instance、外部 `dispatch_event` 注入信号」形态；**不复用**其 type / 业务流程 / 每图一 App。

### H. bar_stream_chart 边界

- `push`/`push_generating`/`shapes` 是唯一输入面，每次一根 `DataBar` 到达即生成该根的形状（`../bar_stream_chart/README.md:61-74`；`src/bar_stream_chart.gleam:357-403, 807`）；`Chart` opaque，只持生成形状与 O(1) carried bounds（`:201, 362-403`）。
- 本地依赖符合 owner 要求：`gleam.toml:22` = `bar_stream_chart = { path = "../bar_stream_chart" }`，`manifest.toml:10` = 1.2.1；发布后再切回 hex（owner 2026-11-23 之前指令）。

## Code Examples（仅抄自已核实源码，逐条给出 file:line）

```gleam
// plushie/widget.gleam:548-560 — Emit 构造 CustomWidget；UpdateState 截断链并更新 registry
Emit(kind:, data:) -> {
  let #(window_id, id, scope) = resolve_emit_identity(ev, widget_id)
  let emitted = event.Widget(event.CustomWidget(
    kind:, target: EventTarget(window_id:, id:, scope:, full: id),
    value: dynamic.nil(), data:,
  ))
  walk_chain(registry, emitted, rest)
}
```

```gleam
// plushie/plushie.gleam:376-378 — 外部注入的唯一入口
pub fn dispatch_event(instance: Instance(_), event: Event) -> Nil {
  process.send(instance.runtime, runtime.InternalEvent(event))
}
```

```gleam
// plushie/event.gleam:230 — 变体确实存在（顶层 Event 无 Custom，层不同）
CustomWidget(kind: String, target: EventTarget, value: Dynamic, data: Dynamic)
```

```gleam
// plushie/runtime.gleam:2094-2116 — 先 widget 链，后 update；被截断则 rerender
let #(result, new_registry) = widget.dispatch_through_widgets(state.cw_registry, ev)
...
None -> rerender_with_rollback(state, registry_before)
```

## Metadata

<confidence level="high">
SDK 层结论均为本机 0.6.0 源码逐行核实；owner 裁决与冻结设计记录均给出 `docs/RULINGS.md` / 归档计划的文件行。唯一 medium 项是「从 `update` 返回到注入的具体命令载体」（需要编译探针定形），已在 open_questions 中标出，不影响架构选择。
</confidence>

<dependencies>
- 重写 `03-01-PLAN.md` / `03-02-PLAN.md`，删去「chart held in app model」等与 owner 2026-11-23 冲突的表述。
- 更正 `docs/PENDING_DECISIONS.md:34-38` 与 ROADMAP 03-01 描述中的同类漂移；不改裁决本身。
- 编译探针：验证 `Command` → 发布/注入 → targeted `CustomWidget` → widget `handle_event` → `UpdateState` 的类型形状。
</dependencies>

<open_questions>
1. `update` 返回的命令如何携带 `Instance` 与归档 bar：专用发布进程 + 具名 `Subject`，还是在接线处闭包捕获？两案都需编译探针，不靠 prose 选择。
2. `data: Dynamic` 的解码边界放在哪个模块，kind 字符串集合如何闭集化（R13）。
3. stable-ID 字符串从 BrokerId/Symbol/Interval 的具体编码，及 `EventTarget.full` 是否需要填写。
4. RED 测试用 registry 级纯函数还是 testing harness；能否在不引入新 dev 依赖下断言 widget state 已变。
</open_questions>

<assumptions>
- 假设 owner 2026-11-23「chart 是 View」当面纠正继续有效，且 06-02 §G2 的 widget-state 机制仍是唯一获准的 View 状态承载方式；两者在本次会话中均由 owner 明确。
- 假设 `plushie_gleam` 保持 0.6.0 pin；升级会让上述行号失效，须重新核对本计划。
</assumptions>

<quality_report>
  <sources_consulted>
    docs/RULINGS.md（2026-11-19 08:35 / 2026-11-20 C1–C4 / 2026-11-23 会话纠正）、归档 06-02-CHALLENGES.md / 06-05-TRIGGER-RULING.md、glib SYSTEM_MODEL.md、build/packages/plushie_gleam/src/{widget,event,plushie,runtime,runtime_core,command,command_encode}.gleam、plushie/testing/widget_harness.gleam、~/.workbuddy/skills/gl-center/references/beam-plushie-concurrency-measured.md、try_plushie/src/{try_plushie,window_switch}.gleam、bar_stream_chart/README.md 与 src。
  </sources_consulted>
  <claims_verified>
    WidgetEvent.CustomWidget 存在；dispatch_event 走完整 MVU；widget state 只能由 handle_event 写；Done/SendAfter 不到 widget 链；renderer NativeCommand 与 Gleam widget registry 分离；try_plushie 三次 start；chart 库的输入面只有逐根 `push`；本地 path 依赖 1.2.1。
  </claims_verified>
  <claims_assumed>
    「归档后注入 event 不算 bar 经 Msg payload 直喂 widget」是对 owner C1/C2 的解释（bar 源是 model head，入站 Msg 不带 bar）；若 owner 另有解读，需更正后再写 body。其余候选拒绝均基于源码而非推断。
  </claims_assumed>
  <confidence_by_finding>
    - A 权威层: High（owner 原文 + 文件行）；2026-11-23 纠正为 High（当面逐字），但尚未落稳定文档。
    - B SDK 事实: High（安装版本逐行）。
    - C 候选矩阵: High（每项有源码行）。
    - D 稳定 ID: High（路由源码）；具体编码格式未定（Medium）。
    - E Dynamic: High（签名事实）；边界写法为建议（Medium）。
    - F 测试路径: Medium（API 已核实，断言方式待探针）。
    - G/H: High。
  </confidence_by_finding>
</quality_report>
</metadata>

---

本次研究**未修改任何 `.gleam` 文件**；仅新增 `03-00-ARCH-RESEARCH.md` 与本文。下一步是按研究结论重写 03-01/03-02 执行计划，之后才进入 doc-first 骨架与 RED→GREEN。
