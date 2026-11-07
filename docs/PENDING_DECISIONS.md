# 待裁决事项 — glibe

本文件路径：`docs/PENDING_DECISIONS.md`（自引用，其他文档不得引用本文件）。

**这是唯一需要 owner 翻阅的文档。** 所有待裁决的点，以及每个点做决定所需的
上下文（背景、选项、你的原话、相关裁定、实测数字、相关文件），都在这里；
不用去别处找。

**本文件是临时的、单向的：**
- 它可以**从其他文档搬运内容进来**，重复不是问题——裁决后整条删除，结论
  落到 `docs/RULINGS.md` / `docs/DESIGN.md` / 代码与测试里，再换上新的待裁决项。
- **其他文档一律不引用本文件。** 它会被清空、替换，反向引用只会留下悬空
  链接。README、DESIGN、DEVELOPER_GUIDE、RULINGS、STATE、REVIEW_ROUND5、
  QUESTIONS 都只引用稳定文档，指向本文件的链接已全部移除。
- 引用规则：**文件全路径 + 条目名**（如 *`docs/RULINGS.md` R16*），**不用裸
  编号**（"Q" 加数字那种既像 Question N 又不是的写法），旧编号已废止。

最后更新：**2026-11-07**

| 条目 | 分区 | 状态 |
|---|---|---|
| web 层形状 / apps/glibe_web 去留 | 已裁定 | **R18，已生效**：Phoenix 移入 `deprecated/` 备考；`webclient/` 独立 JS-target package。仅 web 层框架仍未裁定 |
| JS 图表库 / 生成 mjs 优先 | 已裁定 | **R17，已生效** |
| 手写 `.mjs` 的可接受范围 | 已裁定 | **R16，范围限定，已生效**（R17 的兜底） |
| SVG 图表真实数据试验 | 已定，不需裁决 | 推迟，等 databar processing 其余部分 |
| config.gleam 类型化 identity keys | 已裁定方向 | **R20，部分生效**：所有权链 `Desk → Broker → Instrument → Interval` 已在 `src/glibe/desk.gleam` 落地为 shell；`config.gleam` 两张 String 表的**实际迁移仍未决**，另立计划 |
| Symbol = Instrument 命名冲突 / 是否需要 InstrumentId | 命名待裁决 | **未决**，R20 明确不擅自改名、不擅自统一 |
| Interval 闭集 7 → 9 | 设计待定 | 未决，类型变更 |
| BEAM Stage F | 待做，不需裁决 | 未开始 |

---

## 需要你裁决

### 1. web 层形状 / apps/glibe_web 去留 — **已裁定，见 R18**（背景保留供对照）

**图表库已经定了，不需要再看（R17，2026-11-07）：** *"我们是开发应用的，不是
开发框架，所以能用js chart，成本不高的话，还是用。"* 实测额外成本为 **0 行手写
外来源码**，条件成立 → **采用 JS 图表库**（glib 在用的 TradingView
LightweightCharts 是唯一实测对象）；客户端代码优先写成 Gleam 源码、由
`gleam build` 编译成 `.mjs`（*"尽量用Gleam编译的mjs取代手写这件事"*，R16 只作
小范围兜底）。**自己写 SVG 图表引擎不再是默认路线**——那是做图表框架，不是做
应用。原文与执行结论在 `docs/RULINGS.md` R17。

**已裁定（R18，2026-11-07）：** web 前端需要；Phoenix app 不删除、移动到
`deprecated/glibe_web/` 备考；`webclient/` 作为独立 JS-target package 放在
`src/` 之外，Gleam 源码编译成 `.mjs`，手写 `.mjs` 仅限该目录内。以下背景
保留作技术抉择时的对照，**不再是待裁决项**。
**仍待裁定：web 层框架（Mist / Wisp / Lustre）——Lustre / Wisp 仍不是你的裁定。**

**背景（不用去别处查）：**
- `apps/glibe_web` 是 **23 个文件**的 Phoenix/Elixir + JS 应用
  （`chart_live.ex`、`data_generator.ex`、`assets/js/chart_hook.js`），由提交
  `5e91f44`（2026-09-24）一次性加入。**框架是 AI 自选的**：所有 `docs/`
  历史版本里 "Phoenix" 只出现在评审中，从没作为你的要求出现过。
- **图表行为是你的**：UC-56（历史数据当流处理、一根 settled bar 一次
  `series.update`、永不 `setData`）、UC-57（view 不是 model 的工作，最多发一个
  event，且在 accept 之后）、UC-60（无效 bar 不进图表、已画的 bar 保留）。
  「实现语言」不是你的：Elixir、HEEx、Phoenix PubSub、手写 `chart_hook.js` 都不是。
- `data_generator.ex` 是**另一门语言里的第二个引擎**，UC-56 明确禁止。
- 它是 `scripts/no_foreign_source.sh` 管辖范围（`src/`）之外最大的违规残留；
  guard 比裁定窄，过了 guard 不等于合规。

**你的原话 / 相关裁定（原文）：**
- 2026-11-07：*"No handwritten erlangs or even worse JS source files, keep the
  system clean and beautiful!"*
- 2026-11-07：*"glibe is the future, pure erlang target is the future."*
- glib `docs/RULINGS.md` §1.28（2026-11-01）：*"为什么要迁移大部分到 erlang
  target呢，目的就是不让你手写 mjs，因为erlang不用你手写，如果手写就说明你
  错了"*；其 law 4：*"Hand-written foreign code on the erlang target is the
  error signal … Never write the file."*
- UC-57 深化版（2026-10-06）：*"Creating view is not the work of the model …
  你顶多是发一个event"*。

**采用 JS 图表库的成本（2026-11-07 实测，`docs/REVIEW_ROUND5.md` §13）：**

**先把「成本」口径说清楚（你的 2026-11-07 原话）：** *"因为可能是0成本（额外
成本），因为不管你用什么语言，用绘图库都是要写一点配置的。这部分不是额外成本。"*
下表第二列只量**手写外来源码**这一个维度。series 定义、图表选项、
`DataBar → bar` 映射、一根 settled bar 的更新，是任何语言用任何绘图库都要写的
固有工作，在生成路线里是 Gleam 工作，**不是采用 JS 库带来的额外成本**；真正的
额外成本只有「手写外来源码」这一项，生成路线是 **0**。

| 路线 | 手写外来源码行（唯一额外成本） | 说明 |
|---|---|---|
| 整页照搬 glib `priv/index.html` | **760 行** | 该文件共 1,047 行，其中 196 行 CSS + HTML + 一个外链 script 标签；真正内联 JS 是 `:286-1045` 的 760 行。等于把 R14 债务搬进来 |
| 保留 TradingView 库、页面逻辑改用 Gleam 重写 | **65–85 行** | 两个实测 bridge 原型；补齐七字段双 tooltip 约 +20–25 行。**已由 R16 允许** |
| **Gleam 源码 → 编译器生成的 `.mjs`**，绑定 npm ESM 包 | **0 行** | 见下面「生成 mjs」；代价是引入一个独立 JS-target client 包 |
| Lustre SVG DSL 纯 Gleam | **0 行** | 定义与映射写成类型化 Gleam 值，`DataBar -> Element(msg)` |

- 65–85 行里，**每根 bar 的更新只有 9 行**（一次 `candle.update` + 14 次
  `series.update`，即 UC-56），其余是 15 条 series 的定义、图表选项、tooltip
  和接线；命令式控制流仅 6–10 行。没有算法、没有状态机、没有第二个引擎。
  **按上面的口径，这些是配置与映射，不是额外成本；`docs/REVIEW_ROUND5.md`
  §13.3 把「65–85」当成本列出来的读法已改正。**
- 你对这一点的判断（2026-11-07）：*"the chart only wants a bar from you to
  update the view, and other part are just definitions, mapping model to view.
  So there should not be coplex things to make by hand."* —— 已按行数验证成立。
- vendored `lightweight-charts.js` 是 197,922 字节 / 7 行的压缩 IIFE，结尾
  `window.LightweightCharts=jr`，**不是 ESM**，不能 `import`；要走生成 mjs
  路线得改用 npm 的 ESM 发行版（资产/依赖变化，不是手写 JS）。
- Hex 查过：`lightweight_charts` v0.1.1 是 **Phoenix LiveView / Elixir** 的
  TradingView 封装，另有 `contex` / `ggity` / `plotto` / `lantern_ui` 等服务端
  SVG 库，**没有 Gleam/Lustre 包着这个 JS 库的现成包**。用 Phoenix 那个等于
  保留本节开头那笔债务。纯 Gleam 路线现成的库是 Lustre 自带的
  `lustre/element/svg`。
- 原型刻意放在 `/tmp/glibe_chart_bridge/`，**没有进仓库**；未编译、未在浏览器
  跑过、未用真实数据验证。

**「生成 mjs」这条路（你的 2026-11-07 提法，已实测，见
`docs/REVIEW_ROUND5.md` §13.8 / §13.9）：**
> *"如果可以通过 gleam 源代码产生那个所需的mjs，不一样是不需要手写js吗？"*
> *"你说的探针证实我的第一点，希望你说的是，写gleam代码，编译形成应用JS库
> 绘图所需的那个mjs是可以做到的，而不是别的意思。"*

**是，正是这个意思，不是别的意思；R17 已把它定为优先做法。**「那个 mjs」=
浏览器加载的**应用模块**
（图表设置、15 条 series 定义、选项、`DataBar → bar` 映射、一根 settled bar
的更新）：它**由 Gleam 源码经 `gleam build` 编译生成**，路径是
`build/dev/javascript/<包名>/<模块>.mjs`，没有人手写这个文件。库本身来自
npm（§1.28 law 2：包作者的代码，不是我们的）。此前三种 `.mjs` 被混为一谈：
编译器生成的、包自带的、以及 `@external(..., "./xxx.mjs")` 指向的（才是我们
手写的 FFI）。上一条探针只证明了 `@external` 会生成一行 `import`；下面这个
完整探针证明了**整个应用模块本体**也是生成的。

**完整探针（`gleam 1.19.2`，2026-11-07）：** `/tmp/gleam_js_probe/probe`，
`target = "javascript"`，`gleam_json` v3.1.0，一个 `src/probe/chart.gleam`
写 15 条 `SeriesSpec`、`chart_options()`、`series_options()`、`bar_json()`、
`setup(container)`、`paint(series, bar)`，加三条
`@external(javascript, "lightweight-charts", …)`。`gleam build` 退出 0，
生成的 `chart.mjs` 共 **154 行**，含
`import { createChart as create_chart, … } from "lightweight-charts"` 以及
`export function specs() / chart_options() / setup() / paint()`；
`find src -name '*.mjs'` 为**空**。`gleam/json` 的 `object()` 就是
`Object.fromEntries(entries)`（`gleam_json_ffi.mjs`，包自带），所以图表选项
是从类型化 Gleam 值构造的原生 JS 对象，不需要我们写 FFI。§13.3 那 65–85 行
因此是**编译器输出**，不是需要维护的源码。

**「不是别的意思」的边界（实测，不假设）：**
- 库文件不是生成的：`lightweight-charts` ESM 来自 npm；`gleam_json_ffi.mjs`
  和 `lustre-server-component.min.mjs` 是包自带的。**不是零个 `.mjs` 文件，
  是零个我们手写的 `.mjs`。**
- 根项目不变：glibe 引擎仍是纯 `erlang`（R15，`.abstr` / `.beam`）。生成模块
  属于独立的 `client/` 包（`gleam.toml` 里 `target = "javascript"`）——**这
  正是 Lustre 的两个运行时分工**：Erlang/BEAM 一侧 Wisp + Mist + server
  components，JS-target 一侧 client SPA（`docs/REVIEW_ROUND5.md` §13.5）。
  你的读法（2026-11-07）：*"Lustre 文档我一段时间以前读过（现在可能更新了）
  它确实是有一部分是js target，其他部分是 BEAR/erlang target，这方面做的
  很好。"*（BEAR 即 BEAM，原话照录。）**这是设计得好的分工，不是与「pure
  erlang target is the future」有张力**；此前「有张力」的措辞撤回。是否要加
  这个 client 半边，仍随本条一起由你决定，不单独替你列新问题。
- glib 现在 vendored 的 `lightweight-charts.js` 是 197,922 字节 / 7 行的
  standalone IIFE（`window.LightweightCharts`），**不是 ESM**，不能 `import`；
  走这条路要换成 npm 的 ESM 发行版（依赖/资产变化，不是手写 JS）。
- **唯一可能需要手写的一小块：** `@external` 只绑**模块级函数导出**。v5 的
  `createChart` 是独立导出函数，但 `chart.addSeries(…)` 与 `series.update(…)`
  是 `IChartApi` / `ISeriesApi` 上的**实例方法**（glib `priv/index.html:372`
  与 `:691-705` 就是这么用的）；带点号的
  `@external(..., "chart.addSeries")` 编译期直接报
  `Invalid JavaScript function`。所以真正落地要么找函数式 API 的包装包，要么
  写一个 2–5 行转发模块。**后者已在 R16 允许范围内**，而且它不是「那个应用
  mjs」——应用模块仍然是生成的。探针里 `addSeries` / `updateSeries` 两个绑定
  是占位名，不是已核实的 npm 导出，此处不冒充可用。
- `@external` 在 1.19.2 只能绑**函数与类型**，不能绑模块常量（官方 Tour；
  `@external(..., "LineSeries") pub const ...` 探针解析失败 `expected "="`）。
  `CandlestickSeries` / `LineSeries` / `LineStyle` 之类同样落在上面那一小块
  转发里，已在 R16 范围内。
- **没有做：** 未建图表、未进浏览器、未跑真实数据；这是编译器事实，不是 UI
  能力结论。

**glib 除了那个库，还有别的成本吗？（你的问题，已量）**
- `priv/index.html:7` 是**唯一**一个 `<script src>`，指向 vendored
  `lightweight-charts.js`（197,922 字节 / 7 行 IIFE）。**没有 CDN、没有打包器、
  没有第二个 JS 库**。图表本身不带来别的运行时依赖。
- 其余是页面工作：`:8-203` 196 行 CSS；`:286-1045` 760 行内联 JS（703 非空、
  ~484 代码行），内容是 SSE/EventSource、tab 与 symbol 切换、15 条 series 设置、
  crosshair 七字段 tooltip、`lastPainted` 去重、日期转 epoch —— 在生成路线里
  变成 Gleam 工作，按你定的口径**不是额外成本**。
- **属于 javascript target、不属于图表库的成本**：glib `src/` 下 **14 个手写
  `.mjs`**，其中 `web/server_ffi.mjs` 434 行（Node `http`/`fs`/`path`/
  `child_process` 手写服务器）、`web/state_ffi.mjs` 74 行（共享可变状态）；
  `gleam.toml` 的 `tzif` + `zones` 因为 JS target 没有 `/usr/share/zoneinfo`；
  `package.json` 的 `@stoqey/ib` 是 TWS socket API，与图表无关（R15 已改走
  BEAM 上的 HTTPS REST）。**glibe 纯 erlang 引擎不付这些成本。**
- **净结论：** 图表库没有别的依赖成本；额外成本是 0 行手写外来源码。
  详见 `docs/REVIEW_ROUND5.md` §14。

**生成 mjs 路线的障碍（你要求「如果遇到障碍可以写出来」，全部实测）：**
- **你提醒的那条完全正确：** *"你在这里测试失败有可能是缺少那个chart库本身。"*
  `gleam build` 退出 0 时**不解析 npm 依赖**；探针没有
  `node_modules/lightweight-charts`，`node` 导入生成的 `chart.mjs` 报
  `ERR_MODULE_NOT_FOUND`。`npm install --no-save lightweight-charts@5.0.0`
  之后导入又报
  `The requested module 'lightweight-charts' does not provide an export named
  'addSeries'` —— 这证明探针里两个绑定是占位名。
- v5 真实导出（实测 `Object.keys`）：`createChart`、`createChartEx`、
  `createSeriesMarkers`、`LineSeries`、`CandlestickSeries`、`LineStyle`、
  `ColorType`、`CrosshairMode`、`version` 等；**没有 `addSeries` /
  `updateSeries`**，它们是实例方法。点号 external 编译期被拒
  （`Invalid JavaScript function`）。
- 所以落地唯一要手写的是 **2–5 行转发模块**（R16 范围内），应用 mjs 仍是
  生成的；另外要换 npm ESM 版（glib vendored 的是 IIFE），以及一个独立
  `client/` 包（根项目仍是纯 erlang，R15）。**构建绿 ≠ 能跑，以后要加运行时
  导入检查。** 完整表在 `docs/REVIEW_ROUND5.md` §13.10。

**WASM（你的设想，不是裁定）：** *"如果我们有时间去研究，那么想要完全不依赖
JS那只能走WASM路线了，这要看elixir有没有尝试这个，gleam那么小的community，
要做这事得自己动手，太麻烦了或许。"* 查证：Elixir **确实试过并且发布了**——
Software Mansion 的 Popcorn 1.0（2026-10-27）把完整 OTP/BEAM 编译成 WASM 跑在
浏览器里，未改动的 Elixir 代码、730 KB WASM + ~2.5 MB 标准库、~200 ms 启动、
Web Workers、`Popcorn.Fetch`、`JS.run/3`。但 Popcorn 自己说与 JS 通信「是
Popcorn 的重要部分」：DOM/canvas 和调用 JS 库仍走浏览器 JS API，而
LightweightCharts 本身就是 JS 库；Gleam 没有 WASM 后端。**不采用、不排期**；
有了 R17，图表这条路也用不上 WASM。详见 `docs/REVIEW_ROUND5.md` §15。

**psipi（你的记忆，未核实）：** 本机 `/Users/jk` 下按名字没找到 `psipi` 目录，
历史会话检索也没有记录。**只按 example-level 线索记录**：你记得以前的项目
试过用 Gleam 编译的 mjs 取代手写 JS、「大概是为了本地一个数据库」。它不是
本项目规范，也没拿来当任何决定的依据；找到目录后再补证据。
（`docs/REVIEW_ROUND5.md` §13.10）

**port 的具体形状（尚未采用，等你一句话）：** 退役 `apps/`，保留 UC-56/57/60
裁定的图表行为，用 **Mist**（HTTP/WS/SSE）+ **Wisp**（请求层）+ **Lustre**
（类型化 UI、OTP 监督的 server components）重建，加一个 `shared/` Gleam 类型包。
这三个链接在 `docs/DEVELOPER_GUIDE.md` 里只是**评估用参考，均未采用**；你也没
读过、没用过 Wisp。Lustre/Wisp **不是你的裁定**。

**相关文件：** `docs/REVIEW_ROUND5.md` §10 / §12 / §13 / §13.8 / §13.9 /
§13.10 / §14 / §15、`docs/RULINGS.md` R14 / R15 / R16 / R17、
`docs/DEVELOPER_GUIDE.md`、`docs/DESIGN.md` 的 dashboard 行、`apps/glibe_web/`。

---

## 已裁定（不需要再看，留在这里是因为它改变了上面的选项）

### 2. 手写 `.mjs` 的可接受范围 — R16 已生效

> *"如果仅限于页面设置和更新数据的这一个小范围，手写js的风险是严格掌控的，
> 可以接受。"* [user 2026-11-07]

- 覆盖的只有两件事：**(a)** 页面/图表设置（series 定义、pane、坐标与样式
  选项等声明性内容）；**(b)** 一根 settled bar 到达时的数据更新。
  不覆盖 SSE、tab / symbol 切换、业务计算、第二个引擎，也不覆盖其他用途。
- 这是对 §1.28 的**范围限定例外**，不是推翻：超出这两件事，§1.28 仍有效。
- R15 机制仍有效：根 `src/` 下禁止 `@external(javascript, ...)`、根
  `gleam.toml` 禁止 `target = "javascript"`。R16 谈的是手写 JS 文件，不是
  编译目标，两者不冲突。
- **因此撤销**：`docs/REVIEW_ROUND5.md` §13.4 曾写「采用 JS 图表库还需要你
  另给一次明确例外、否则只有 SVG 路线合规」。例外已经给出，§13.4 已改正。
- 原文落在 `docs/RULINGS.md` R16。

### 2a. 采用 JS 图表库、生成 mjs 优先 — R17 已生效

> *"我们是开发应用的，不是开发框架，所以能用js chart，成本不高的话，还是用。"*
> *"尽量用Gleam编译的mjs取代手写这件事，以前做其他项目时尝试过，是可行的。
> 如果遇到障碍可以写出来。"* [user 2026-11-07]

- **采用 JS 图表库**；SVG 自绘不再是默认路线（做图表引擎 = 开发框架）。
- **优先 Gleam 源码 → 编译器生成 `.mjs`**；手写 `.mjs` 只在 R16 的小范围里
  兜底（实例方法/常量转发）。`"尽量"` 是优先序，不是绝对禁令；§1.28 在范围外
  仍有效，R15 根项目仍是纯 erlang。
- **障碍必须写出来**：`docs/REVIEW_ROUND5.md` §13.10；已确认
  `gleam build` 不解析 npm 依赖，构建绿 ≠ 能跑。
- **仍未裁定**：web 层框架（Mist / Wisp / Lustre）。`apps/glibe_web` 去留与
  独立 `client/` 包两项已由 **R18** 裁定关闭。
  原文与执行结论在 `docs/RULINGS.md` R17。

---

## 已定，不需要裁决（列出来省得你去别处找）

### 3. SVG 图表真实数据试验 — 已定：推迟

**你的原话（2026-11-07）：** *"Does this means it will be as powerful as the
JS chart? Needs a try with actual data later, when other parts(other parts of
whole databar processing) is done."*

- **回答：不是。** 「不需要 JS 图表库」讲的是依赖，不是能力。LightweightCharts
  免费给的（canvas 渲染、15 条 series、双 pane、时间轴/价格轴 autoScale、
  crosshair、pan/zoom、fitContent、大数据量性能）SVG 版本都得自己写。
  SVG 真正更强的只有三处：类型化字段（引擎没算出的 series 编译器拒绝）、view
  是 model 的纯函数、`element.to_string` 可 SSR 并在测试里断言。
- **门控（做完才试）：** 完整 `sourcebar_gate → databar_processing → indicator
  / leaves / branches / strategy / runtime-test → accept`、真实 klines 的 replay
  CLI 产出真实 `databar_list`、UC-57 的 event 到 view 通路。
- **要测、不假设：** 15 条 series 的值对 `export/csv.gleam`；真实 bar 数下的
  DOM 节点数与每根 settled bar 的 patch 延迟；crosshair/tooltip 响应；是否
  必须做有界窗口（SVG 是每 bar O(n) 节点，canvas 是一张位图）。
- **本次没有做：** 未建 SVG 版本，故没有 Gleam 行数可比；原型未编译、未跑浏览器、
  未用真实数据。这条不是裁决项，只是时间与测量清单。
- **R17 之后的状态：** SVG 自绘不再是默认实现路线（我们是做应用，不是做
  图表框架）；但「与 JS 图表做真实数据能力比较」仍按你的时机推迟，测量结果
  仍有用（节点数、patch 延迟、是否要窗口化）。

---

## 设计待定（计划先行，暂不需要拍板）

### 4. config.gleam 类型化 identity keys — **方向已裁定（R20），迁移仍待计划**

`config.gleam` 现在用 `List(#(String, TimeframeSettings))`，键是
`"BTCUSDT_H1"` 这样的复合字符串。你的 phase-55 原则是：identity 是**类型化的
Dict key**，不是字段、也不是拼出来的字符串。改成 `Symbol` + `Interval` 作键是
架构变更。你的规则 *"计划和文档先行，任何时候都没有例外"*（2026-10-28）：
先有计划再动类型。

**2026-11-07 已裁定（你的原话）：** *"Type relations tell you those are Must
to have, otherwise your list of Timeframe for different intervals, and your
list of Instruments for Instrument will don't know where to live"*。
`docs/REVIEW_ROUND5.md` 里「不引入 `Desk` / `Broker` / `Account` 空壳」那一条
**就此撤销（仅限这一条）**：在 Gleam 里 `Dict(BrokerId, Broker)` 这样的字段
本身就是编译期消费者，类型关系就是 caller，空壳显得空是因为关系还没写出来。

**已落地：** `.planning/phases/04-domain-cleanup/04-01-PLAN.md` →
`src/glibe/desk.gleam` + `test/desk_test.gleam`。链条是
`Desk(Dict(BrokerId, Broker))` → `Broker(Dict(Symbol, Instrument),
Dict(AccountId, Account))` → `Instrument(Dict(Interval, TimeframeSettings),
Dict(Interval, Timeframe))`。名称定为 **`Desk`** 而非 `Deck`：trading desk 是
那张盯行情的台子，`Deck` 在金融语境里是 pitch deck / 演示稿；且 `Desk` 是
`glib/src/glib/desk.gleam` 里已经存在的确切名字（**example 级印证，不是依据**）。
另外查到一处实存拼写漂移：`glib/.planning/HANDOFF-2026-11-03.md:111` 的 owner
引文写 `Deck`，同文件 `:114` 的 AI 转述写成 `Desk`；**引文原样保留，没有替
owner 改写**，也没有拿它当改名依据。若你其实想要的是那个 UI 屏幕，它属于
`webclient/` 的 view，朴素的名字是 `Dashboard`，仍不是 `Deck`。
这是第一个完整的文档先行 / TDD 循环：骨架 `gleam build` 0 errors / 49 warnings，
`gleam test` RED `26 passed / 10 failures`，填体后 `36 passed, no failures`、
0 warnings、guards 全绿；`gleam docs build` 的 `package-interface.json` 里
`glibe/desk` 有 32 行模块文档且含计划路径。全文见 `docs/RULINGS.md` R20。

**仍未决、需要你拍板的只剩两件：**
1. **什么时候、以什么形状把 `config.gleam` 的 `symbols` 与
   `timeframe_settings` 两张表搬进这条链**（`:13-17`、`:518`、`:632`、`:647`）。
   本次**没有改 `config.gleam`**，表与 `list.find` 原样保留。
2. **命名冲突**：`src/glibe/api/symbol.gleam:1` 写着 "Symbol = Instrument"，
   而新增的 `Instrument` 是「被拥有的值」、`Symbol` 是「key」。两者是同义词
   还是两个概念，是命名裁决；按「不擅自改名」本次不动。是否再引入专门的
   `InstrumentId` 也随这句话一起决定。

**此外明确未做**：`src/glibe/timeframe.gleam` 的 `Timeframe` 仍自带
`symbol` / `interval` 字段，key 与 value 可能不一致；让它 keyless 是单独的
类型变更，已记为 design debt，本次未动。

### 5. Interval 闭集 7 → 9

`api/interval.gleam:19-34` 是 `MIN1 MIN15 MIN30 H1 D1 W1 MO1`（7 个）；glib 已
定的闭集是 `MIN1 MIN3 MIN15 MIN30 H1 H4 D1 W1 MO1`（9 个）。补 `MIN3` / `H4`
要加 codec 行和 bucket-end 规则。这是类型层的事，必须是类型变更，不能加字符串
分支。

---

## 待做工作（不需要你裁决）

### 6. BEAM Stage F

glibe 在 BEAM 上，这是唯一不以 glib 为参照、也无需等待的轴。未开始：
- 每个 `(symbol, interval)` 一个受监督的 `Timeframe` actor（`gleam_otp`）；
- 对已存 klines 的 replay CLI，让关于引擎的说法可检验；
- 退役 `apps/glibe_web/lib/glibe_web/data_generator.ex`（第二个引擎，UC-56 禁止）；
- `no_minute_trading.sh`，把裁定做成 guard。

---

## 已撤回项（不需要看，仅留指针）

2026-10-04 版问题清单里 5 个已撤回条目（KDJ 窗口、σ 窗口、下轨地板、K/D
单一 alpha、`window_kdj_size` 改名）和 1 个假前提（AI 策略层「等 glib 做完再
移植」），连同撤回理由，留在 `docs/QUESTIONS.md`。本文件不重复。
