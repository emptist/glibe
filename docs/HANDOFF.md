# HANDOFF — glibe / `doc-tdd`（2026-11-26 权威交接）

> **新会话第一步：读本文件。** 旧交接（2026-11-13 的「零行实代码」阶段）已作废，
> 本文件是当前唯一交接入口。
>
> owner 本次逐字：*「glibe是一个真实项目，而try_plushie是开路先锋无中生有的试验，
> 你正式项目能做到比试验项目要烂10倍，你的任务很简单，现在写交接班文档，
> 在新会话中继续开发，只能比所有前期项目加起来都好，决不允许更差。」*
>
> 本文件只写**当前代码可验证的事实**与**下一步必须执行的计划**。推断必须标「推断」；
> 不得把我的旧文档当 owner 原话。写成本文件时基线：`doc-tdd`、HEAD `0ae9a77`、
> 工作树干净；本文件提交后的 HEAD 以 `git log -1` 为准。`src/` 本轮未改。
> 本文件每次更新都要把 §0.1 的资料地图保持可用，不能只留「去读某个文档」却不给路径。

---

## 0. 新会话必读顺序（不读完不许动 Gleam）

1. **本文件全文。**
2. `.planning/BRIEF.md`、`.planning/ROADMAP.md`、
   `docs/AUDIT-2026-11-25.md`、`docs/AUDIT-2026-11-26.md`。
3. `docs/RULINGS.md` 中 R19 / R20 / R21 / R33 / R41 / R44–R50 / R58 / R80–R82；
   `docs/STATE.md` 只读顶部与相关专题，**不要整文件吞**。两文件已达 50 万/15 万字节级，
   再无节制追加就是违反「doc volume ∝ mistakes」。
4. 动手判断前：载入 `gl-center` 技能，**全文**读
   `~/.workbuddy/skills/gl-center/references/gleam-core.md`
   （仓库镜像 `docs/gleam-thinking-core-to-memory.md`，`cmp` 一致，R19）。
5. 按要改的模块读源码，只读它和它的消费者。`glib/` 是冻结设计源（代码 + `.planning`），
   只读；`glib/docs/` 是禁用的 AI 散文。`try_plushie/` 是试验，README 明言交易/分析
   部分不可借鉴；只读官方 plushie 能力与踩坑，不整段抄业务结构。
6. `docs/PENDING_DECISIONS.md` 决策区当前 **0 项**。**计划内工作不问 owner**；
   owner 2026-11-21 逐字：*「按计划所做的事情，就不用等我的同意了。如果遇到意外，
   遇到你不能决断的危险事件，需要问我。」* 只在意外/危险/改写远端历史时停。

### 0.1 资料地图（按权威级别读，不靠搜索碰运气）

谱系（owner 历史陈述，已记入项目记忆）：Smalltalk（三维嵌套 Kline，View 是 Model 的映射）
→ seib（CoffeeScript）→ glib / idib → **glibe**；`ibOptions`（Python + Pandas）是旁支，
其结构不移植（R34/R42）。**只有 glibe 是未来项目**；其余是参考或历史，不是当前实现目标。

| 资料 | 真实路径 / 入口 | 权威与读法 |
|---|---|---|
| 冻结参考 `glib` | `/Users/jk/gits/hub/tools_ib/glib/src/**`、`/Users/jk/gits/hub/tools_ib/glib/.planning/**`；重点 `.planning/BRIEF.md`、`ROADMAP.md`、`HANDOFF-2026-11-03.md`、`SESSION_CONTEXT.md` | 设计源、只读；`glib/docs/` 是另一模型的 AI 散文，禁止引用（R38/R42） |
| 试验项目 `try_plushie` | `/Users/jk/gits/hub/tools_ib/try_plushie/README.md`、`plushie-architecture.md`、`plushie-capabilities.md`、`fusion-design.md`、`chart-package-plan.md`、`docs/*.md` | 开路先锋，证明能力并记录坑；README 明言交易/分析不可借鉴；§30/§31 的多 App 与它自己 §26.1 冲突。只学官方 plushie 能力、`command.stream` 接线和交互 API |
| 图表库 `bar_stream_chart` | `/Users/jk/gits/hub/tools_ib/bar_stream_chart/README.md`、`src/**`；本项目经 `gleam.toml` 的 path override 使用 | 作者设计是 `push(chart, bar)` 单根增量，`push` / `push_generating` / `shapes` 是唯一输入面，每次一根 `DataBar` 到达即生成该根的形状；`zoom_at` / `pan_by_pixels` / `zoom_step` / `pan_step` 是交互 API；每个 shape 必须显式唯一 id，无信号 `DataBar` 不发文本 |
| 知识中心 `gl-center` | 源 `/Users/jk/gits/gl-center/`（`README.md`、`knowledge/**`、`gleam-thinking-core.md`）；技能消费者 `~/.workbuddy/skills/gl-center/`（`SKILL.md`、`references/**`） | Gleam/BEAM 实测语言事实的家；`references/gleam-core.md` 动手前必读全文。部分知识文件（如本项目 `docs/externals.md`）用**单文件硬链接**消费，实测与源 inode 相同；核心卡本体是 byte-equal 镜像（`cmp` exit 0）。禁止符号链接/目录链接（owner 2026-11-15） |
| Gleam 官方文档 | `https://tour.gleam.run/`（语言导览）、`https://hexdocs.pm/gleam_stdlib/`、`https://hexdocs.pm/gleam_erlang/`、`https://hexdocs.pm/gleam_otp/`；本地版本事实 `build/packages/gleam_*/src/**` | 语言与 stdlib 接口契约；`gleam-lang.org/docs.html` 实测 404，别再当入口。与本地安装版本冲突时，本项目以 `build/packages/` 的 pin 版本为准 |
| plushie 官方文档 | `https://plushie-ui.com/`、`https://hexdocs.pm/plushie_gleam/`、`https://github.com/plushie-ui/plushie-gleam`；本地版本事实 `build/packages/plushie_gleam/src/plushie/**` | 接口契约与组合模式；本项目用 `0.6.0`，**本地源码高于网页泛论**。官方「多窗口共享 model/update/view」原话已记在 `docs/RULINGS.md:5413-5416` |
| iced 官方文档 | `https://book.iced.rs/`、`https://docs.rs/iced/latest/iced/`、`https://iced.rs/`；本地分析 `try_plushie/plushie-architecture.md` §2/§14、`gl-center/knowledge/plushie-cross-platform-measured.md` | 只看能力边界与作者意图；plushie 使用 fork `plushie-iced 0.8.4`，版本号独立于上游 iced 0.14，不能按数字比新旧；renderer 不由本项目手写 |
| Elm 官方文档 | `https://guide.elm-lang.org/architecture/`；本地纠偏 `gl-center/knowledge/beam-plushie-concurrency-measured.md:19-46` | **Model / View / Update 架构范式**，不是 plushie 的运行时；plushie 没有 Elm 运行时。只借四件套语义，不引 Elm 词库或运行时假设 |

**自有重要文档索引（本项目内）**：

| 路径 | 用途 |
|---|---|
| `docs/HANDOFF.md`（本文件） | 新会话唯一交接入口 |
| `docs/RULINGS.md` / `docs/STATE.md` | owner 裁定全文 / 状态快照；只读相关条目，禁止整文件膨胀 |
| `docs/PENDING_DECISIONS.md` | **唯一**决策队列；当前 0 项，裁决后整条删除 |
| `docs/AUDIT-2026-11-25.md` / `docs/AUDIT-2026-11-26.md` | 系统自评 / 大结构对比与同标准图像证据 |
| `.planning/BRIEF.md` / `ROADMAP.md` / `phases/**/*PLAN.md` + `*SUMMARY.md` | 当前 GDLTDD 计划链；`.planning-archived-2026-11-20/` 是废弃树 |
| `docs/threading-model-comparison.md`、`docs/sourcebar_gate_placement_study.md`、`docs/timeframe-layer-audit.md`、`docs/how-hy4-flash-poluted-glibe.md` | 具体专题论证；引用时带文件路径，不凭记忆转述 |
| `DEVELOPER_GUIDE.md` / `README.md` | 导航与旧总览，不是规格；冲突时以代码 + RULINGS 为准 |
| `docs/gleam-thinking-core-to-memory.md` / `.workbuddy/memory/YYYY-MM-DD.md` / `.workbuddy/memory/MEMORY.md` | 核心卡镜像（本轮 `cmp` exit 0）/ 日志（append-only）/ 项目索引 |

---

## 1. 当前真状态（2026-11-26 实测，不是估计）

### 1.1 六门禁

```
export PATH="/opt/homebrew/bin:$PATH"
gleam format --check src test          # exit 0
gleam check                            # exit 0
gleam test                             # 149 passed, no failures
gleam docs build                       # exit 0
gleam export package-interface --out /tmp/glibe-interface.json   # exit 0
gleam build --warnings-as-errors       # exit 0（0 Todo + 0 unused）
```

持续集成（CI，`.github/workflows/test.yml`）跑的是 warnings-as-errors（WAE）→ gleam test →
gleam format --check；本地六门禁是 R48 固定关。
`--warnings-as-errors` 只在 `build` 子命令有，`check` 顶替不了；禁止 `_` 前缀批量静音。

### 1.2 运行与证据

- 真实数据链已通：`data-api.binance.vision` → `src/glibe/binance/rest.gleam` →
  `live_feed` → `wire.sourcebar_event` → 单一 App（`plushie.start` 一次） →
  `desk → broker → instrument → timeframe` → `working_databar_archived` →
  `ChartPushRequest` → `chart_push` → widget 的 `ChartWidgetState` → `get_tree` → SVG。
- 真跑日志有 `LIVE seed 60 real bars...`；生产运行路径无合成 `SourceBar`、
  无 `demo_feed`、无手工拼图（测试夹具里的手工值不是生产数据源）。
- `artifacts/glibe_runtime_tree.svg` 来自 `dev/export_tree_svg.gleam` 的
  `plushie.get_tree` 真运行时导出；`artifacts/glibe_live_chart.svg`（手工拼图）已删。
- 同标准对比（同翻译器 / 同 60 根真实 `SourceBar`）：glibe vs try_plushie 的 axes 10/10、
  candles 120/120、overlays 178/179、volume 60/60、kdj 177/177；配色一致。
  **图形内容层等价，但机制不等价**（见 §5）。
- 交互已恢复：滚轮缩放（`zoom_at`）、拖拽平移（`pan_by_pixels`）、方向键导航
  （`zoom_step` / `pan_step`）、十字光标（`crosshair`）；真跑派发 `Move` 事件后
  `crosshair` 0→3。静态 SVG 里 `crosshair` 为 0 只是没发指针事件，不代表交互缺失。
- `screencapture` 在本机被沙箱挡；同环境 try_plushie 能 1 秒出图，所以**禁止再用
  「沙箱不能运行」当借口**。证据只能是 get_tree / 真 renderer 图，不冒充像素截图。

### 1.3 已知唯一大结构差（`docs/AUDIT-2026-11-26.md` B）

| | plushie 官方 / owner 裁决机制（`try_plushie` 接线示例） | glibe（当前） |
|---|---|---|
| 入口 | `init()` 返空 chart + `command.stream` | `runtime.gleam:94-96` `init()` 返 `command.none()` |
| 数据驱动 | runtime 内部 stream 逐根 emit | 外部 process `live_feed.pump` 逐根 `dispatch_event` |
| Msg | `Event.Stream(StreamEvent)` → update | `message.from_event` 只解 `CustomWidget` → `MsgSourceBarArrived` |
| 单根增量更新 UI（一次一根 `DataBar`） | 是 | 是，但由外部输入进程逐根驱动 |

结果等价、机制不同。正式项目必须采用官方机制；下一步就是 Phase 07，不是可选项。

---

## 2. 不可破坏的结构不变量

1. **单一 App**：全系统一次 `plushie.start`；多图是同一个窗口内的稳定标识 widget，
   不是每图一个 App。`try_plushie` §30/§31 的「多 App 实例」与它自己 §26.1 冲突，
   且 README 声明交易部分不可借鉴；官方原话已记在 `docs/RULINGS.md:5413-5416`：
   *"All windows share the same model, update, and view. That's the whole multi-window story; there is no separate window-manager state."*
2. **单一 Desk**：`Desk → Broker → Instrument → Timeframe` 单向持有；`view` 是 `Desk` 的
   投影，Chart 存放在 widget 的 `ChartWidgetState`，**不得写回 `Desk`**。没有第二个 model、
   影子 `Desk` 或 `databar_list` 搬运。
3. **唯一发布点**：`timeframe.working_databar_archived`。每根归档后只取 `databar_list`
   head 的一根 `DataBar` 推给图；图形按到达顺序逐根生长。
4. **事件路由**：plushie 用 `EventTarget.id + scope`，`full` 不参与；`chart_push`
   target id 必须是 `dashboard#<widget_id>`（R82）。裸 id 会被路由旁路（Bypassed），
   结果是空窗口。
5. **shape 生成归 push，view O(1)**；每个 shape 显式全局唯一 id；无信号的 `DataBar` 不发
   `Size(0.0)` 文本节点；颜色遵循中国市场：涨红 `#ff4d4f` / 跌绿 `#00c853`。
6. **归属**：一个文件一条 ownership 关系（R50/R80），同类函数跟着 owner 走（R81）。
   动手前问「谁读写这个具体值」，答不出就不创建 type/module。
7. **真实数据**：失败只记日志重试，永不回退到合成数据（fallback）；历史与实时是一条流（R33）。
   取数窗口 ≠ emit 数据；poll 每次取数只把水位线之上的新 `SourceBar` 交给正常到达路径。
8. **复杂度/列表**：列表最新在前，取更旧元素用 `list.drop(xs, 1)`，不用 O(n) 的
   `list.last`；禁止 O(n²) 全窗重算 / `Σx²−(Σx)²/n`。owner 的「Qn2」永远指 O(n²)。
9. **命名/词法**：构造器写全名；Gleam 没有 enum，写自定义类型（custom type）或
   闭合类型（closed type）（R45）；不用 `new`/`create`/`make`（R49）；
   `LEAF` 是专有名词，只指 `leaf.gleam` 里
   `DataLeaf` 的 `YinLeaf` / `YangLeaf` 构造器，不用于其他「最底层」含义。
10. **BEAM 原生**：`target = "erlang"`；`@external(erlang, …)` 正常且必要；禁止手写
    `.erl` / `.ex` / `.mjs` 进 `src/`，禁止 JS/webclient/前端框架。
11. `config.gleam` 只放用户可设值；派生数学、wire 编码字符串、UTC 网格、递归算术不是设置。
12. `bar_stream_chart` 当前是本地路径覆盖（path override，KDJ fix 未重新发布）；升级前不要
    顺手改回 hex 版本。renderer 期望 `plushie_rust_version = "0.7.1"`。
13. **流的单向性（R83）**：一根 `SourceBar` 到达即处理、归档、生成该根的形状，之后不再
    进入数据路径。`command.stream` 只向一个方向走；任何带「再做一次」含义的 `re-`
    前缀说法都不用于描述本系统的数据、状态或接口。描述只写系统是什么。

---

## 3. 模块归属图（先读再改）

| 模块 | 拥有什么 | 不搬到哪里 |
|---|---|---|
| `src/glibe.gleam` | 组合根：一次 `plushie.start`、publisher 注册、进程入口 | 不放业务域计算、不放图表状态 |
| `app/runtime.gleam` | Model / View / Update（MVU）：`init` / `update` / `step` / `route`；唯一 publish 点 | 不放 `ChartWidgetState`、不放时钟/轮询 |
| `app/message.gleam` | 开放的 `Event` → 闭合的 `Msg` 的唯一解码器 | 不放 wire 编解码 |
| `app/wire.gleam` | 两个 `CustomWidget` kind、带类型 payload、`EventTarget` 作用域 | 不放业务规则、不放第二套 identity |
| `app/publish.gleam` | 命名 channel + `ChartPushRequest` + serve（R81 已合并） | 不放 runtime 逻辑 |
| `app/dashboard.gleam` | `WidgetDef` / `viewport` / `mouse` / `drag` / `translate` / `view` | 不放 `Desk` 写操作 |
| `live_feed.gleam` | 输入边界：获取、水位线、去重、emit | 不放 `sourcebar_gate`、不放 view |
| `binance/rest.gleam` | HTTP + JSON → `SourceBar` 的唯一数据源边界 | 不放通用数据源框架 |
| `desk/broker/instrument/timeframe` | 各层 Dict 与自己的读写对 | 不跨层代写 |
| `config.gleam` | 用户可设值 | 不放派生值 |
| `dev/export_tree_svg.gleam` | 常驻 get_tree→SVG 诊断 | 不是 app，不冒充运行截图 |

---

## 4. 失败模式（自己查，不等别人指出来）

- **假绿**：只断言 `SpecShape` 列表长度 / 图形节点数量而不断言 `viewport`、`mouse`、
  `crosshair` 的测试不算过；「单元测试绿 ≠ 窗口里有图形」。R82 空窗口能活这么久就是这个盲区。
- **假图**：手工 SVG / 静态拼图 / 旧截图不能叫「运行结果」；只能用 get_tree 或真 renderer。
- **假借口**：「沙箱无 GUI，用户自己运行才看得到」已在 R82 作废。同环境 try_plushie 可跑。
- **假对称**：拿 try_plushie 的多 App、JSON wire、调速/队列当范式。它只是试验，
  业务部分 README 明令不可借鉴；只学 `command.stream` 和交互 API 的用法。
- **假归属**：凭「统一措辞」批量改文档，或把不同 ownership 塞进一个文件；每句 `////`/`///`
  必须重新对着本模块事实写。
- **工具错**：怀疑结果时先查过期的构建产物（删除 `build/dev` 后重新执行门禁），再查 `sed`/`awk`
  调用，最后才查代码。`sed` 在本机是 toybox，`-i ''` 会静默不生效；优先用编辑器精确替换，
  其次 `/bin/ed` 或 `/usr/bin/awk`；**禁止盲删行号**。**禁止任何 Python 文件操作**
  （owner 逐字：*「禁止在任何情况下使用Python！只会干扰，没有任何可取之处。」*）。
- **文档漂移**：改了代码就同步 ROADMAP/SUMMARY；决策区保持 0；不要把 PENDING 当
  待办清单；不要把历史裁定复制进新的散文式文档。
- **用词污染（R83）**：曾有 AI 用不存在的概念描述单向流，导致文档与计划连锁污染并被
  owner 多次阻止。判据：每句只写系统里真实发生的事；遇到说不清的词就删掉重写成正面
  陈述，不扩大任何词的使用范围。历史裁定原文是唯一可引用原词的地方。
- **提交**：普通 fast-forward push 直接做；`--force` / `--force-with-lease` / rebase 后强推 /
  删远端分支必须先问 owner。绝不 `rm -rf build`（构建产物过期时只删 `build/dev`）。

---

## 5. 下一步：Phase 07 `native-stream`（新会话必须按 GDLTDD 做）

### 5.1 目标

把外部 `live_feed.pump → plushie.dispatch_event` 换成官方机制
`init → command.stream → Event.Stream(StreamEvent) → on_event → Msg → update`，
**保持单一 App 与 §2 全部不变量**。这不是风格调整：结果虽然等价，但正式项目不能在
机制上比试验项目弱。禁止顺手重做业务域、多窗口、语音/视觉边界（R24 演示级），避免一锅粥。

### 5.2 先写计划，再写代码

GDLTDD = 文档先行 + 计划 + `////`/`///` 与 todo 骨架 + RED 测试 + GREEN 实现 + 六门禁；
不得用「先写后补」代替。

新建 `.planning/phases/07-native-stream/07-01-PLAN.md`、`07-02-PLAN.md`、
`07-03-PLAN.md`（每个含 `////` 引用、归属关系（ownership）、RED 测试清单、GREEN 步骤、门禁），
完工各自写 `SUMMARY.md`，再更新 `.planning/ROADMAP.md` Phase 07。
**文档先于代码；不允许先改 `src/` 再补计划。**

### 5.3 07-01 读书与接线定案（只落盘，不改 src）

实读并带行号记录：
- `build/packages/plushie_gleam/src/plushie/command.gleam:35-38, 302-310`（`Stream` 语义）
- `build/packages/plushie_gleam/src/plushie/app.gleam:143-158`（`application` 的 `on_event`）
- `build/packages/plushie_gleam/src/plushie/event.gleam:44-45, 310-311`（`StreamEvent`）
- `try_plushie/src/try_plushie.gleam:163-195, 377-381`、`try_plushie/src/live_feed.gleam:58-64, 81-118`
- `src/glibe/app/runtime.gleam:84-96`、`src/glibe/app/message.gleam:41-56, 89-97`、
  `src/glibe/live_feed.gleam:129-180`、`src/glibe.gleam:63-125`

定案要点（写入 PLAN，不在对话里拍脑袋）：
- `runtime.app(publisher, binding)` 在接线时捕获**带类型的输入绑定**
  （`BrokerId` / `Symbol` / `Interval` / stream tag），不把它塞进每根 `SourceBar` 的 payload（R58）。
- `init()` 返 `command.stream(live_feed.stream(binding), tag)`；`on_event` 变成闭包，
  只把 `Stream(StreamEvent(tag: tag, value:))` 解成 `MsgSourceBarArrived`，其余仍 `MsgEye`。
  不要新增无真实消费方的 Msg 变体；如果需要状态文本，先证明 view 有读者。
- `live_feed.stream(binding)` 返回 `fn(fn(Dynamic) -> Nil) -> Dynamic`；沿用
  `rest.fetch_klines` + `newer_than` + `advance_boundary`；每根真实 `SourceBar` emit 一次。
  `command.stream` 一次 send 一根到达的 `SourceBar`（R38 的直接 emit），poll 间隔是取数频率。
- `main` 不再启动输入轮询进程；publisher 进程仍需 `Instance` 来派发 `chart_push` 事件。
- `feed_sourcebar` 若除 `dev/export_tree_svg.gleam` 外无消费者，随本阶段删除或改为
  测试专用的注入边界；不留半死 API。诊断工具必须去掉手工 60 根注入，改为等待
  `command.stream` 自己灌满。

### 5.4 07-02 RED → GREEN

RED 测试至少钉住：
1. `runtime.init()` 的 command 是 `command.Stream`，tag 与 binding 一致，不再是 `None`。
2. 用 `plushie/testing/command_processor.gleam` 的 `process_commands` 喂入一个测试用
   `Dynamic` 值，断言 `databar_list` 长度增加 1、恰好产生 1 个 `ChartPushRequest`；
   tag 不等于绑定 tag 的 `StreamEvent` 不进入 `Msg`。
3. `message.from_event` 对 `StreamEvent` 与 `CustomWidget` 两条入口都闭合，不用兜底分支
   漏掉应进入 `MsgEye` 的事件。
4. `live_feed` 的水位线/去重纯函数仍保持「取数窗口 ≠ emit 数据」。
5. 真 `binance/rest.gleam` 的解码测试不动；网络不可用时只重试，不合成。

实现转绿后：`gleam test` 必须 **>149 passed**，warnings-as-errors（WAE）为 0。

### 5.5 07-03 端到端回归 + 真跑证据

- 把「数据→窗口有图形」固化成常驻测试/诊断：驱动真实 App，从 `plushie.get_tree` 或
  `plushie/testing` 的树逐层统计（设 `N` = 注入的 `SourceBar` 数量）：`axes>0`、
  `candles≥2*N`、`overlays>0`、`volume>0`、`kdj>0`；派发带作用域的 `Move` 事件后
  `crosshair>0`。**故意保留一个 R82 回归断言**：`EventTarget.id` 去掉 `dashboard#` 时必须转红。
- 真跑：`gleam run` 看 `LIVE seed 60 real bars...`；`gleam run -m export_tree_svg`
  导出 `artifacts/glibe_runtime_tree.svg` 并打印 crosshair before/after。
  与 §1.2 基线对比；若出现 renderer 重启，如实记录，不掩盖。
- 更新 ROADMAP / SUMMARY / 本文件 §1 数字；**不写长篇散文式文档，不膨胀 STATE/RULINGS**。

### 5.6 验收线（低于任何一项 = 未完成）

- 六门禁全绿，测试数 >149，warnings-as-errors（WAE）为 0，`format --check` 为 0。
- 单一 App、单一 `Desk`、单一 publish 点、单根 `DataBar` 增量，
  到达一根处理一根，不 panic。
- 生产路径零合成数据、零 `demo_feed`、零手工 SVG、零假绿测试。
- 真跑有真实 Binance 日志 + `get_tree` 图形计数 + 交互 `crosshair` 证据。
- 官方 `command.stream` 机制已接线，且 `app/wire.gleam`、身份键（identity keys）、
  `Desk` model 的不变量未被破坏。
- `docs/PENDING_DECISIONS.md` 决策区仍 0；owner 不需要替我找任何问题。

---

## 6. 常用命令

```
export PATH="/opt/homebrew/bin:$PATH"

# 六门禁（见 §1.1）
gleam format --check src test
gleam check
gleam test
gleam docs build
gleam export package-interface --out /tmp/glibe-interface.json
gleam build --warnings-as-errors

# 真应用（阻塞；后台跑并记日志，别留失控进程）
gleam run

# 运行时树导出与交互诊断（会拉 60 根真实 `SourceBar`）
gleam run -m export_tree_svg

# 文本校验
git diff --check
git status --short
git log -1 --oneline
```

新会话如果按本文件做完 Phase 07，应在本文件 §1 更新实测数字与 HEAD，并在
`.planning/ROADMAP.md` 留 Phase 07 收口记录；交接链不能断。
