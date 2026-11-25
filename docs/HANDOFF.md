# HANDOFF — glibe / `doc-tdd`（2026-11-26 权威交接）

> **新会话第一步：读本文件。** 旧交接（2026-11-13 的「零行实代码」阶段）已作废，
> 本文件是当前唯一交接入口。
>
> owner 本次逐字：*「glibe是一个真实项目，而try_plushie是开路先锋无中生有的试验，
> 你正式项目能做到比试验项目要烂10倍，你的任务很简单，现在写交接班文档，
> 在新会话中继续开发，只能比所有前期项目加起来都好，决不允许更差。」*
>
> 本文件只写**当前代码可验证的事实**与**下一步必须执行的计划**。推断必须标「推断」；
> 不得把我的旧文档当 owner 原话。写成本文件时基线：`doc-tdd`、HEAD `0321f87`、
> 工作树干净；本文件提交后的 HEAD 以 `git log -1` 为准。`src/` 本轮未改。

---

## 0. 新会话必读顺序（不读完不许动 Gleam）

1. **本文件全文。**
2. `.planning/BRIEF.md`、`.planning/ROADMAP.md`、
   `docs/AUDIT-2026-11-25.md`、`docs/AUDIT-2026-11-26.md`。
3. `docs/RULINGS.md` 中 R19 / R20 / R21 / R33 / R41 / R44–R50 / R58 / R80–R82；
   `docs/STATE.md` 只读顶部与相关专题，**不要整文件吞**。两文件已达 50 万/15 万字节级，
   再无节制追加就是违反「doc volume ∝ mistakes」。
4. 动手 judgement 前：载入 `gl-center` 技能，**全文**读
   `~/.workbuddy/skills/gl-center/references/gleam-core.md`
   （仓库镜像 `docs/gleam-thinking-core-to-memory.md`，`cmp` 一致，R19）。
5. 按要改的模块读源码，只读它和它的消费者。`glib/` 是冻结设计源（代码 + `.planning`），
   只读；`glib/docs/` 是禁用的 AI 散文。`try_plushie/` 是试验，README 明言交易/分析
   部分不可借鉴；只读官方 plushie 能力与踩坑，不整段抄业务结构。
6. `docs/PENDING_DECISIONS.md` 决策区当前 **0 项**。**计划内工作不问 owner**；
   owner 2026-11-21 逐字：*「按计划所做的事情，就不用等我的同意了。如果遇到意外，
   遇到你不能决断的危险事件，需要问我。」* 只在意外/危险/改写远端历史时停。

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

CI（`.github/workflows/test.yml`）跑的是 WAE → test → format；本地六门禁是 R48 固定关。
`--warnings-as-errors` 只在 `build` 子命令有，`check` 顶替不了；禁止 `_` 前缀批量静音。

### 1.2 运行与证据

- 真实数据链已通：`data-api.binance.vision` → `src/glibe/binance/rest.gleam` →
  `live_feed` → `wire.sourcebar_event` → ONE App → `desk → broker → instrument → timeframe` →
  `working_databar_archived` → publish → `chart_push` → widget state → `get_tree` → SVG。
- 真跑日志有 `LIVE seed 60 real bars...`；无合成 bar、无 demo_feed、无手工拼图。
- `artifacts/glibe_runtime_tree.svg` 来自 `dev/export_tree_svg.gleam` 的
  `plushie.get_tree` 真运行时导出；`artifacts/glibe_live_chart.svg`（手工拼图）已删。
- 同标准对比（同翻译器 / 同 60 根真实 bar）：glibe vs try_plushie 的 axes 10/10、
  candles 120/120、overlays 178/179、volume 60/60、kdj 177/177；配色一致。
  **图形内容层等价，但机制不等价**（见 §5）。
- 交互已恢复：wheel zoom / drag pan / 方向键 / crosshair；真跑 dispatch Move 后
  crosshair 0→3。静态 SVG 里 crosshair 为 0 只是没发指针事件，不代表交互缺失。
- `screencapture` 在本机被沙箱挡；同环境 try_plushie 能 1 秒出图，所以**禁止再用
  「沙箱不能运行」当借口**。证据只能是 get_tree / 真 renderer 图，不冒充像素截图。

### 1.3 已知唯一大结构差（`docs/AUDIT-2026-11-26.md` B）

| | try_plushie（作者机制） | glibe（当前） |
|---|---|---|
| 入口 | `init()` 返空 chart + `command.stream` | `runtime.gleam:94-96` `init()` 返 `command.none()` |
| 数据驱动 | runtime 内部 stream 逐根 emit | 外部 process `live_feed.pump` 逐根 `dispatch_event` |
| Msg | `Event.Stream(StreamEvent)` → update | `message.from_event` 只解 `CustomWidget` → `MsgSourceBarArrived` |
| 单 bar 更新 UI | 是 | 是，但由外部批量循环驱动 |

结果等价、机制不同。正式项目必须采用作者机制；下一步就是 Phase 07，不是可选项。

---

## 2. 不可破坏的结构不变量

1. **ONE App**：全系统一次 `plushie.start`；多图是同一 window 内的稳定-ID widget，
   不是每图一个 App。try_plushie §30/§31 的「多 App 实例」与它自己 §26.1 冲突，
   且 README 声明交易部分不可借鉴；官方原话已记在 `docs/RULINGS.md:5413`：
   *"All windows share the same model, update, and view. That's the whole multi-window story"*。
2. **ONE Desk**：`Desk → Broker → Instrument → Timeframe` 单向持有；`view` 是 Desk 的
   投影，Chart 是 widget state，**不得写回 Desk**。没有 second model、shadow、bar 搬运。
3. **唯一发布点**：`timeframe.working_databar_archived`。每根归档后只取 `databar_list`
   head 的一根 `DataBar` 推给图；没有 batch / replay / list push。
4. **事件路由**：plushie 用 `EventTarget.id + scope`，`full` 不参与；`chart_push`
   target id 必须是 `dashboard#<widget_id>`（R82）。裸 id 会 Bypassed 成空窗口。
5. **translate 归 push，view O(1)**；每个 shape 显式全局唯一 id；无信号 bar 不发
   `Size(0.0)` text；颜色遵循中国市场：涨红 `#ff4d4f` / 跌绿 `#00c853`。
6. **归属**：一个文件一条 ownership 关系（R50/R80），同类函数跟着 owner 走（R81）。
   动手前问「谁读写这个具体值」，答不出就不创建 type/module。
7. **真实数据**：失败只记日志重试，永不合成 fallback；历史与实时是一条流（R33）。
   取数窗口 ≠ emit 数据；poll 拉回整窗只 emit 水位线之上的新根。
8. **复杂度/列表**：列表最新在前，取更旧元素用 `list.drop(xs, 1)`，不用 O(n) 的
   `list.last`；禁止 O(n²) 全窗重算 / `Σx²−(Σx)²/n`。owner 的「Qn2」永远指 O(n²)。
9. **命名/词法**：构造器写全名；Gleam 没有 enum，写 custom/closed type（R45）；
   不用 `new`/`create`/`make`（R49）；`LEAF` 是专有名词，只指 `leaf.gleam` 的
   `YinLeaf`/`YangLeaf` DataLeaf 构造器。
10. **BEAM 原生**：`target = "erlang"`；`@external(erlang, …)` 正常且必要；禁止手写
    `.erl` / `.ex` / `.mjs` 进 `src/`，禁止 JS/webclient/前端框架。
11. `config.gleam` 只放用户可设值；派生数学、wire code、UTC 网格、递归算术不是设置。
12. `bar_stream_chart` 当前是本地 path override（KDJ fix 未重新发布）；升级前不要
    顺手改回 hex 版本。renderer 期望 `plushie_rust_version = "0.7.1"`。

---

## 3. 模块归属图（先读再改）

| 模块 | 拥有什么 | 不搬到哪里 |
|---|---|---|
| `src/glibe.gleam` | 组合根：ONE `plushie.start`、publisher 注册、进程入口 | 不放 domain 计算、不放 chart 状态 |
| `app/runtime.gleam` | MVU：`init` / `update` / `step` / `route`；唯一 publish 点 | 不放 widget state、不放时钟/轮询 |
| `app/message.gleam` | 开放 `Event` → 闭合 `Msg` 的唯一解码器 | 不放 wire codec |
| `app/wire.gleam` | 两个 `CustomWidget` kind、typed payload、scoped target | 不放业务规则、不放第二套 identity |
| `app/publish.gleam` | 命名 channel + request + serve（R81 已合并） | 不放 runtime 逻辑 |
| `app/dashboard.gleam` | WidgetDef / viewport / mouse / drag / translate / view | 不放 Desk 写操作 |
| `live_feed.gleam` | 输入边界：fetch、水位线、去重、emit | 不放 domain gate、不放 view |
| `binance/rest.gleam` | HTTP + JSON → `SourceBar` 的唯一 provider edge | 不放通用 provider 框架 |
| `desk/broker/instrument/timeframe` | 各层 Dict 与自己的读写对 | 不跨层代写 |
| `config.gleam` | 用户可设值 | 不放派生值 |
| `dev/export_tree_svg.gleam` | 常驻 get_tree→SVG 诊断 | 不是 app，不冒充运行截图 |

---

## 4. 失败模式（自己查，不等别人指出来）

- **假绿**：只断言 spec 长度 / shape 数量而不断言 viewport、mouse、crosshair 的测试
  不算过；「unit green ≠ window has shapes」。R82 空窗口能活这么久就是这个盲区。
- **假图**：手工 SVG / 静态拼图 / 旧截图不能叫「运行结果」；只能用 get_tree 或真 renderer。
- **假借口**：「沙箱无 GUI，用户自己运行才看得到」已在 R82 作废。同环境 try_plushie 可跑。
- **假对称**：拿 try_plushie 的多 App、JSON wire、调速/队列当范式。它只是试验，
  业务部分 README 明令不可借鉴；只学 `command.stream` 和交互 API 的用法。
- **假归属**：凭「统一措辞」批量改文档，或把不同 ownership 塞进一个文件；每句 `////`/`///`
  必须重新对着本模块事实写。
- **工具错**：怀疑结果时先查 stale build（`rm -rf build/dev` 再跑），再查 sed/awk 调用，
  最后才查代码。`sed` 在本机是 toybox，`-i ''` 会静默不生效；优先 editor 精确替换，
  其次 `/bin/ed` 或 `/usr/bin/awk`；**禁止盲删行号**。**禁止任何 Python 文件操作**
  （owner 逐字：*「禁止在任何情况下使用Python！只会干扰，没有任何可取之处。」*）。
- **文档漂移**：改了代码就同步 ROADMAP/SUMMARY；决策区保持 0；不要把 PENDING 当
  待办清单；不要把历史裁定复制进新 prose。
- **提交**：普通 fast-forward push 直接做；`--force` / `--force-with-lease` / rebase 后强推 /
  删远端分支必须先问 owner。绝不 `rm -rf build`（stale 时只删 `build/dev`）。

---

## 5. 下一步：Phase 07 `native-stream`（新会话必须按 GDLTDD 做）

### 5.1 目标

把外部 `live_feed.pump → dispatch_event` 换成作者原生的
`init → command.stream → StreamValue → on_event → Msg → update`，**保持 ONE App 与
所有 §2 不变量**。这不是风格调整：结果虽然等价，但正式项目不能在机制上比试验项目弱。
禁止顺手重做 domain、多窗口、voice/vision，避免一锅粥。

### 5.2 先写计划，再写代码

新建 `.planning/phases/07-native-stream/07-01-PLAN.md`、`07-02-PLAN.md`、
`07-03-PLAN.md`（每个含 `////` 引用、ownership、RED 测试清单、GREEN 步骤、门禁），
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
- `runtime.app(publisher, binding)` 在 wiring 时捕获** typed feed binding**
  （broker_id / symbol / interval / stream tag），不塞进每根 bar 的 payload（R58）。
- `init()` 返 `command.stream(live_feed.stream(binding), tag)`；`on_event` 变成闭包，
  只把 `Stream(StreamEvent(tag: tag, value:))` 解成 `MsgSourceBarArrived`，其余仍 `MsgEye`。
  不要新增无真实消费方的 Msg 变体；如果需要状态文本，先证明 view 有读者。
- `live_feed.stream(binding)` 返回 `fn(fn(Dynamic) -> Nil) -> Dynamic`；沿用
  `rest.fetch_klines` + `newer_than` + `advance_boundary`；每根真实 bar emit 一次。
  **禁 send_after、队列、调速、合成 bar、整窗 replay**；poll 间隔是取数频率，不是画图节奏。
- `main` 不再 spawn feed process；publisher process 仍需 `Instance` 来 dispatch chart_push。
- `feed_sourcebar` 若除 `dev/export_tree_svg.gleam` 外无消费者，随本阶段删除或改为
  测试专用 seam；不留半死 API。诊断工具必须去掉手工 60 根注入，改为等待 stream 自己灌满。

### 5.4 07-02 RED → GREEN

RED 测试至少钉住：
1. `runtime.init()` 的 command 是 `command.Stream`，tag 与 binding 一致，不再是 `None`。
2. 用 `plushie/testing/command_processor.gleam` 的 `process_commands` 喂一根假 stream value，
   断言模型增长 1 根、publish request 恰好 1 个；外国 tag 不进 Msg。
3. `message.from_event` 对 `StreamEvent` 与 `CustomWidget` 两条入口都闭合，无 catch-all
   漏掉 eye event。
4. `live_feed` 的水位线/去重纯函数仍保持「取数窗口 ≠ emit 数据」。
5. 真 `binance/rest.gleam` 的 decode 测试不动；网络不可用时只重试，不合成。

GREEN 后：`gleam test` 必须 **>149 passed**，WAE 0。

### 5.5 07-03 端到端回归 + 真跑证据

- 把「数据→窗口有图形」固化成常驻测试/诊断：驱动真实 App，从 `get_tree`/testing tree
  逐层 count：axes>0、candles≥2N、overlays>0、volume>0、kdj>0；发 scoped Move 后
  crosshair>0。**故意保留一个 R82 回归断言**：target id 去掉 `dashboard#` 时必须 RED。
- 真跑：`gleam run` 看 `LIVE seed 60 real bars...`；`gleam run -m export_tree_svg`
  导出 `artifacts/glibe_runtime_tree.svg` 并打印 crosshair before/after。
  与 §1.2 基线对比；若出现 renderer restart，如实记录，不掩盖。
- 更新 ROADMAP / SUMMARY / 本文件 §1 数字；**不写长篇 prose，不膨胀 STATE/RULINGS**。

### 5.6 验收线（低于任何一项 = 未完成）

- 六门禁全绿，测试数 >149，WAE 0，format 0。
- ONE App、ONE Desk、ONE publish 点、单 bar 增量、无 batch/replay/panic。
- 生产路径零合成数据、零 demo_feed、零手工 SVG、零假绿测试。
- 真跑有真实 Binance 日志 + get_tree 图形计数 + 交互 crosshair 证据。
- 作者机制 `command.stream` 已接线，且 wire/identity/Model 不变量未被破坏。
- `docs/PENDING_DECISIONS.md` 决策区仍 0； owner 不需要替我找任何问题。

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

# 真 app（阻塞；后台跑并记日志，别留失控进程）
gleam run

# 运行时树导出与交互诊断（会拉 60 根真实 bar）
gleam run -m export_tree_svg

# 文书法
git diff --check
git status --short
git log -1 --oneline
```

新会话如果按本文件做完 Phase 07，应在本文件 §1 更新实测数字与 HEAD，并在
`.planning/ROADMAP.md` 留 Phase 07 收口记录；交接链不能断。
