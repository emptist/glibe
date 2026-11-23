# 三项目的并发 / 线程方案对比：glib · try_plushie · glibe

> 触发：owner 2026-11-24 "对比 glib try_plushie 思考自己的方案，或者采纳
> 较好的线程方案"。全部断言带 file:line；编译探针先跑后写，不靠 prose 判断。
> 结论先行：**不采纳任何一家作为整体**；glibe 保持 ONE App + 输出侧具名
> subject（R58/R60），但可以、且只该补上 glib/try_plushie 都有的那个东西——
> **一个真正的输入边界（feed）**。探针已证：官方 `command.stream` 能直接喂
> glibe 的闭集 Msg，不需要新 variant、不动 R58 的输出回路。
>
> **本文不是从零分析 try_plushie。** 它早已被逐条审过（`beam-plushie-concurrency-measured.md`
> §2.3/§4.1/§5.5/§5.6、`.planning/phases/03-app-view/03-00-ARCH-FINDINGS.md` §G、
> R60）。本文的增量只有三样：**glib 的 JS target 事实**、**R74 后 glibe 的缺口更新**、
> **编译探针**。其余是引用，不是新发现——重复论证本身就是错误，见 R76。

## 0. 先正名：三个"线程方案"不是同一个问题

`beam-plushie-concurrency-measured.md` §0（gl-center skill）已经测过：plushie
**没有** Elm 运行时，"plushie 多线程"是个被表述错的问题。真实结构是
BEAM 进程（轻量、mailbox、不可变值）+ 一个独立 OS 进程里的 Rust renderer。
所谓"线程方案"落到代码上只有三个具体问题：

1. **入口**：谁启动 App、谁持有 `Instance`、谁让进程不退出（`main()`）。
2. **输入边界**：bar 从哪来，怎么进 `update`（feed / stream / inject）。
3. **输出边界**：归档后的 bar 怎么进 chart widget state。

三家在这三题上的答案完全不同，因为**它们的 target 就不同**：

| | glib（冻结设计源） | try_plushie（参考实现） | glibe（当前） |
|---|---|---|---|
| `gleam.toml target` | **`javascript`** | `erlang`（默认） | **`erlang`** |
| 并发宿主 | JS 事件循环 + Web Worker | BEAM 进程 + plushie runtime actor | BEAM 进程 + plushie runtime actor |
| 外部桥 | 27 个 `@external(javascript, …)` → `.mjs` | 1 个 Erlang Port → Rust renderer | 1 个 Erlang Port → Rust renderer（同 plushie） |
| 入口 | `src/glib.gleam:73 main()`，CLI argv 子命令 + JS `sleep_forever()` FFI | `src/try_plushie.gleam:773 main()`，3× `plushie.start` + switcher + `process.sleep_forever()` | **无 `main`**（只有 `src/glibe.gleam:72 start()`）；`gleam run` 报 "Module does not have a main function" |
| 输入边界 | `ingest.run/feed` 同步 fold 历史 + JS WebSocket FFI（`binance_ws_ffi.mjs`）回调 | `command.stream(live_feed.stream(mc), "feed")`（`try_plushie.gleam:191,200`）：REST poll + collie WS actor，emit 走 `process.send(runtime_self, StreamEmit)` | **无**：`wire.sourcebar_event` 只在测试里被构造（`grep` 生产零调用）；没有任何 provider / feed / poll 模块 |
| 输出边界 | `publish: fn(Timeframe) -> Nil` 闭包在组合根 baked（`glib/trading/ingest.gleam:57-71`），经 `databar_processing` 管道参数传下去 | 无独立输出回路：chart 是 App 自己的 model（`ChartModel.tf/.chart`），update 改 model → view 直接画 | 具名 `Subject(ChartPushRequest)` + ONE publisher 进程 + `command.task` + `plushie.dispatch_event(instance, chart_push_event)`（`src/glibe.gleam:72-85`、`app/publish.gleam`） |
| App 数量 | n/a（CLI 每次一个子命令） | **3 个**（BTCUSDT / SOXL / Desk，各一个 runtime actor + renderer） | **1 个**（R60：never one App per chart） |

## 1. glib：它的"并发"根本不在 Gleam 里

`target = "javascript"`。全仓 27 个 external **全是 javascript**，没有一个是
erlang。`src/glib/` 下零 `process.spawn`、零 `process.Subject`、零 `gleam/otp`。

- 历史段：`ingest.run(inst, sym, interval, 4800)` 是**同步 fold**
  （`glib.gleam:412`），跑完才 `connect_engine_stream`。
- 实时段：`@external(javascript, "./glib/binance_ws_ffi.mjs", "connect_engine_stream")`
  （`glib.gleam:34-38`）把 engine 交给 JS；WebSocket、定时器、并发全在 `.mjs` 里。
- 保活：JS 侧 `sleep_forever()` FFI（`glib.gleam:437-438`）。
- 发布：`publish` 是组合根 baked 的闭包，作为**管道步骤参数**透传
  （R58 §1 已认定为权威依据）。

⇒ glib 的"线程方案"是 **JS 事件循环 + FFI**，不是 BEAM 进程。它作为**设计源**
（数据流、类型、管道形状）有效，作为**并发方案**对 BEAM target 的 glibe 不适用。
owner 冻结 glib、R16–R18/R42 禁 JS 目标，正是这条边界。

## 2. try_plushie：BEAM 上"三 App + 官方 stream"是自洽的

- 入口：`main()` 三个 `plushie.start`（`try_plushie.gleam:774-793`），一个
  `window_switch.new_switch_name()` 具名邮箱，一个 switcher 进程持有三个
  `Instance`，`process.spawn` + `process.sleep_forever()`。
- 输入边界：`chart_init` 返回 `command.stream(live_feed.stream(mc), "feed")`
  （`:191`）。plushie runtime 把 work 放进一个 `process.spawn` 的轻量进程
  （`runtime.gleam:2362-2387`），emit = `process.send(runtime_self, StreamEmit(tag, nonce, value))`，
  再经 `handle_event` → `event.Stream(StreamEvent)` → `on_event` mapper
  （`runtime.gleam:880`、`runtime_core.gleam:206-211`）。
  - REST poll 是尾递归循环，WS 另起一个 collie actor（`live_feed.gleam:116`），
    两路独立；水位线只在 poll 这一路局部（`live_feed.gleam:20-29`）。
- 输出边界：**没有**。chart 是 App model 的字段（`ChartModel.tf/.chart`，
  `try_plushie.gleam:163-196`），update 改 model，view 从 model 画 —— 不需要
  把 bar 跨进程注入 widget。

并发实测文档 §4.1 判它 ✅ 对；三 renderer 的 GPU 成本是它自己记的代价。

## 3. glibe：输出回路是对的，缺的是入口和输入边界

glibe 现在的并发拓扑（R58/R60 已裁定，本文不推翻）：

```
main: start()  →  ONE plushie.start  →  Instance（只在 publisher 闭包里）
                     ├─ runtime actor：update = 纯 Desk→Desk
                     └─ bridge actor → Port → Rust renderer
input:  ???（无生产调用点）
output: update 得 ChartPushRequest → command.task → 具名 Subject
        → publisher 进程 receive_forever → dispatch_event(instance, event)
        → widget state（按 stable node ID）
```

**三个事实，逐条带证据：**

1. **没有 `main`**：`gleam run` 实测报 "Module does not have a main function"。
   `src/glibe.gleam` 只有 `start()`（`:72`），返回 `Instance` 但无人调用它。
   `03-03-PLAN.md:8` 自己写着 *"glibe still has no main: nothing starts the App"*。
   ——注意：03-03 把"ONE start + publisher"当作完成标志，**但 `main` 本身从没落地**。
2. **没有输入边界**：`grep` 生产代码零 `command.stream`、零 feed/poll/provider
   模块；`wire.sourcebar_event` 只在 `test/` 被构造。即上一轮 R74 补了
   "空 Desk 能长"，但 **bar 从哪里来**这半段仍空着。
3. **输出回路是必要的，不是过度设计**：因为 R20/R60 裁定 chart state 在
   widget 自己的 state 里、不在 Desk model 里（owner 逐字骂过把 chart 塞进
   model），所以必须有一条从 update 到 widget state 的跨进程注入路径。
   try_plushie 没有这条回路，是因为它把 chart 放进了 model —— 那正是 glibe
   被禁止的形状。所以两家输出侧的差异是 **R20 的后果，不是谁更聪明**。

## 4. 编译探针（先跑后写，不是 prose 判断）

问题：若采纳 try_plushie 的 `command.stream` 作为 glibe 输入边界，是否要改
闭集 `Msg` 或推翻 R58 的输出回路？

探针（`test/probe_stream_test.gleam`，已跑、已删）：manufacture 一个
`event.Stream(StreamEvent(tag: "sourcebar", value: Dynamic))`，用一个扩展的
`from_event` 分支解成 `MsgSourceBarArrived`，断言 round-trip 相等。

**实测**：编译通过，`133 passed, no failures`（探针一个测试 + 原 132）。
结论：

- `Stream(StreamEvent)` 经过 plushie runtime 的 `on_event` mapper
  （`runtime_core.gleam:206-211`），可以在 `from_event` 里被识别。
- BEAM 上 Dynamic 就是 term，沿用 `wire.gleam:192-199` 的单态 identity cast
  即可 round-trip **零 codec、零 string parser**。
- `Msg` 保持三 variant 闭集；**不需要新 variant**。R58 的输出侧 named subject
  **一个字不用改**。输入与输出正交。

## 5. 结论：采纳什么、不采纳什么

### 不采纳
- **try_plushie 的三 App**：R60 明确否决 one App per chart；三 renderer 的 GPU
  成本实测未量化，且 glibe 只有一个 Dashboard view。
- **glib 的 JS 并发**：target 不同，R16–R18/R42 冻结。
- **推翻 R58 输出回路**：它是 R20（chart 是 view 不是 model）的必然结果。

### 采纳（且已有编译证据）
- **`command.stream` 作为唯一输入边界**：它是 plushie 官方能力，在 BEAM 上运行，
  与 glibe 已有的 MVU 形状完全兼容；探针证明不破坏闭集 Msg、不碰输出回路。
  它替代的是当前"测试手工构造 `wire.sourcebar_event`"的假输入。
- **补 `main`**：让 `gleam run` 真正启动 ONE App 并保活（glib/try_plushie 都有，
  glibe 独缺）。

### 真正的缺口（不是线程方案，是前置条件）
两家的输入边界都需要一个**数据源**：glib 有 Binance `.mjs` WebSocket FFI +
`ingest.run` 历史 fold；try_plushie 有 `live_feed`（REST + collie WS）。
**glibe 两者都没有。** 所以"采纳 stream 方案"不是换个线程库就能完成的 ——
它先要有 provider / symbol / interval 的来源（R26 开放集、R46 config 该长出来
的地方）。这一层是**既定的输入边界工作，不是待裁决项**（`PENDING_DECISIONS.md`
REFERENCE 段 R.5 已写明）：接哪个 broker、哪些 symbol、REST 还是 WS、要不要
历史段，按 R26 随真实消费方逐个落，不预先造一整套、不臆造假 provider。
本文只定并发形状并给出编译证据，不提前铺开数据源实现。

## 6. 落地顺序（方案已定，前置条件一到即可执行）

1. `config.gleam` 长出 provider / watchlist 值（R26/R46 的既定输入边界工作，
   不是待裁决项 —— `PENDING_DECISIONS.md` REFERENCE 段 R.5；按真实消费方逐个落，
   不预先造一整套）。
2. 新增 BEAM-native feed 模块（`command.stream` work）：REST poll 为主、WS 为
   延迟优化，照 `live_feed.gleam` 已被验证的两路独立形状；不抄整窗重放
   （try_plushie 自己记录过的 bug）。
3. `from_event` 加 `Stream(StreamEvent)` 分支（探针形状），闭集 Msg 不变。
4. `src/glibe.gleam` 补 `main()`：ONE `start()` + feed stream + 保活。
5. 全门禁（format / check / WAE / test / docs / export）。

第 3 步的编译形状已由本次探针钉死；第 1 步是唯一阻塞。

## 7. Landing
- 本文：三方案对比 + 探针证据 + 结论。
- 探针 `test/probe_stream_test.gleam`：跑过、删掉，未留生产代码改动。
- `docs/RULINGS.md`：R75 记本次裁定。
