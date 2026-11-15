# Rulings — glibe

The decisions that bind the code. Each is quoted where it came from, dated,
and given the place it landed. A ruling without a landing is a wish; this file
records only the ones that reached the code.

---

### R1 — *"a structure doesn't have an end_bar unless it is ended"* — user, 2026-10-03

A leaf or branch that has not ended carries **no** `end_bar`, and no `exit_bar`.
Both are `Option`. The alternative — a sentinel bar of zeros — lies, and its
`idx` of `0` collides with the first real bar's `idx`, which is also `0`.

**Landed in:** `leaf.gleam:26-27` (`end_bar: Option(DataBar)`), `branch.gleam:47-48`
(`end_bar` / `exit_bar: Option(DataBar)`), and `timeframe.gleam:34,43-57`
(`working_databar`, the four twins, and `manual_enter` / `manual_exit` all
`Option`). The per-bar rewrite of a sentinel and the false size it produced are
gone.

---

### R2 — *"branches are conceptually a group of leaves"* — user, 2026-10-03

A branch is not a move drawn separately from the leaves; a `YangBranch` rides
yin leaves and a `YinBranch` rides yang leaves. The interesting part is the
group, and a branch dies when the leaf it rides has lived too long.

**Landed in:** `branch.gleam` `next_yang_branch` / `next_yin_branch` — recognition
and death are expressed entirely in terms of the riding leaf.

---

### R3 — *"CMA 当然同样是选定均线的均值呀"* — user, 2026-09-15

The leaf CMA averages the **selected SMA** (`sma_tiny`), not the price. Feeding
it `close` is a prior error (mimo's). It is the forward recurrence
`(cma_old × N_old + raw) / (N_old + 1)` with `N_old = idx − start_idx`, one step
instead of a walk.

**Landed in:** `leaf.gleam:163` `leaf_cma`. A leaf born this bar returns its own
`sma_tiny`, never `0.0`.

---

### R4 — *"think of it again, you seem to only need a line of code"* — user, 2026-10-03

Recognition is one line: a `YangBranch` is recognised when `growing_yang_branch`
is `None` **and** `working_databar.idx == growing_yin_leaf.start_bar.idx`.

**Landed in:** `engine.gleam:158-159` (`yin_recognised` / `yang_recognised`). The
just-settled leaf (`previous`) is passed only to backtrack `start_bar` to the
dead leaf's corner; it gates nothing.

---

### R5 — *"since it has been dead for a while, it is not the death bar"* — user, 2026-10-03

`exit_bar` is `branch_exit_leaf_size` bars **after** the death, never the death
bar. A structure found dead after a long time is recognised as dead late.

**Landed in:** `branch.gleam` `next_*_branch` — `exit_bar = Some(databar)` on the
bar the branch is recognised as dead, `end_bar = Some(leaf.leaf_start_bar(riding))`
(the start of the leaf that killed it).

---

### R6 — closing is a length test, never a price test

A branch ends when the riding leaf has lived `branch_exit_leaf_size` bars — `>=`,
not `>` (the off-by-one in the original). Price never decides a close.

**Landed in:** `branch.gleam:196,238` (`leaf.data_leaf_size(riding, databar) >= exit_size`).

---

### R7 — *"a principle without a mechanism is decoration"* — design law

A rule that cannot be checked will be broken. The module-purity rule is a script,
not a paragraph.

**Landed in:** `scripts/no_timeframe_mixture.sh` — fails the build if `timeframe.gleam`
declares any function but `new`, or if any module but `timeframe.gleam` declares
`pub type Timeframe`.

---

### R8 — reject, never repair — glib's recorded decision, adopted 2026-10-04

A source bar whose own numbers disagree is rejected with the reason. It is not
repaired into agreement, because a repair puts a number in the engine no exchange
sent, and every indicator downstream is then measured on it.

**Landed in:** `api/sourcebar.gleam:62` `validate` (high ≥ low ≥ 0, volume ≥ 0,
high the highest of the four, low the lowest).

---

### R9 — convert epoch-ms at the boundary, not inside the bucket test

An exchange that counts milliseconds since the epoch is translated at the ingest
boundary, so every step downstream reads `"2024-01-15 09:00:00"` and not
`"1705309200000"`. Converting inside the bucket test would be the same bug twice.

**Landed in:** `api/sourcebar.gleam:90` `normalize_date` → `api/interval.gleam:82`
`bucket_ends` reads ISO only. This is the fix for the three-round H1 bug: an
hourly timeframe never closed a bar on Binance data.

---

### R10 — a verdict belongs to whoever decides

The `DataBar` carries measurements, nothing else. It used to hold six boolean
verdicts no module wrote; they are gone. A strategy derives its verdict from the
measurements and owns it.

**Landed in:** `databar.gleam` dropped the 15 unwritten fields; `trading/strategy.gleam:26`
`manual_signal` writes `"buy"` / `"sell"` / `""` on the bar.

---

### R11 — the manual strategy judges nothing of its own — user, UC-62

The branch `enter_bar` and `exit_bar` **are** the manual enter and exit. No other
manual strategy is needed for now; trading the opposite polarity too would be a
**second** strategy (shorting the down-leg), which UC-62 rules out.

**Landed in:** `engine.gleam:203` `strategy` — `manual_enter` on recognition,
`manual_exit` on the recognised-as-dead bar; the word written is the `YangBranch`'s.

---

### R12 — *"当下轨小于等于0时，给他一个人为的极小的正数"* / *"修正步骤应该在插值之前完成"* — user, 2026-10-14 (settled 2026-11-02)

**One** artificially tiny **positive** number, a fraction of `bb_m`
(`1e-6`), applied to the **lower edge before interpolation**. The reason is
arithmetic, not defence: downstream division must proceed. Flooring the three
lower lines *after* interpolation needs three floors, and three floors can
disagree — glib measured `bb_l3 = 0.00001 > bb_l2 = 0.0000047` on real data.
A `0.0` clamp is not a positive number and collapses the staff. Source: glib
`RULINGS.md` §1.13 `:496`, §1.14 `:525`, `DESIGN.md` §14.4c;
`src/glib/bollinger.gleam:199-225`.

**Landed in:** `src/glibe/bollinger.gleam` (`band_floor_ratio`, classic edges →
one floor → four convex-combination inner lines) and
`bollinger_one_tiny_positive_floor_before_interpolation_test`. This retires
the withdrawn *floor under the lower bands* item in `docs/QUESTIONS.md`,
which had misquoted the ruling as "no floor".

---

### R13 — *"Gleam is a typed language, don't you know?"* — user, 2026-10-12

A **closed set held as a `String` can only be described, and prose is what
nothing checks.** The signal is a custom type with exactly the cases that can
be produced; the String spelling exists only as the boundary codec. Source:
glib `RULINGS.md` §1.11 `:265`; also *"必须用type解决"* (2026-11-03) and
*"Use types everytime a type is needed in nature"* (2026-11-07).

**Landed in:** `src/glibe/trading/signal.gleam`
(`pub type Signal { Buy Sell NoSignal }` + `to_string`),
`databar.gleam` (`signal: Signal`), `trading/strategy.gleam`,
`export/csv.gleam`, `signal_is_a_closed_type_test`. One set, one home: the
dead 4-constructor `SmaSeries` duplicate in `indicator_settings.gleam` is gone.

---

### R14 — *"No handwritten erlangs or even worse JS source files"* — user, 2026-11-07

Also *"target erlang 无需手写任何erlang代码，无需ffi，ffi是JS专属的"* and
*"如果手写就说明你错了"* (2026-11-01, glib §1.28). Since **v1.19.0**
(2026-10-05) Gleam modules compile to **Erlang abstract forms** (`.abstr`),
then `.beam` — no `.erl` per module. The one `@@main.erl` inside `build/` is
the `gleam run` runner stub, still written by 1.19.2 (delete-and-rebuild
proved it, 2026-11-07), not compiled module code and not a stale artefact.
`@external` calls existing BEAM modules — it is not a licence to write a
foreign module (Gleam Language Tour, *Externals*).

**Landed in:** `scripts/no_foreign_source.sh` (registered in `guards.sh --all`
and CI), the retirement of the orphan `src/glibe/ib/ibkr.ex` (zero callers,
12 build warnings, undeclared `ibkr_api` dep), and the CI pin 1.19.2 / OTP 29.
**Scope:** `src/` — the engine. `apps/glibe_web` (Phoenix/Elixir + JS) is
**not** covered and is an open owner decision (open owner decision; `REVIEW_ROUND5.md` §7, and R16 below for the JS scope).

---

### R15 — IB is scoped to historic data for stocks/ETFs; no JS target dependence — user, 2026-11-07

> *"We will only use ib api to get historic data for stocks(ETFs), so if this
> will cause JS target dependence, I would rather give up ib entirely"*
> — emptist, 2026-11-07.

Two things are ruled here. **Scope:** IB is a **historical bar source for
stocks and ETFs only** — not live quotes, not orders, not accounts, not the
TWS socket API. **Priority:** the pure Erlang target outranks the broker. If
IB cannot be reached without `@external(javascript, ...)` or a
`target = "javascript"` build, **IB is dropped**, not the target.

**Measured 2026-11-07: the condition does not fire.** IB's Client Portal Web
API is plain HTTPS + JSON on localhost:
`GET https://localhost:5000/v1/api/iserver/marketdata/history?conid=&period=&bar=`
(returns `data: [{o,c,h,l,v,t}]`, epoch-ms timestamps). `gleam_httpc` is
already a dependency and already used by `binance/binance.gleam:23`; it is a
binding to Erlang's `httpc` and needs **no FFI, no `.mjs`, no JS target**.
`gleam_json` decodes the response. So historic IB data is reachable in pure
Gleam on BEAM. The JS-only IB path in glib is `ib_ffi.mjs` importing
`@stoqey/ib` — that is the **TWS socket API**, a different product chosen by
an AI, and it is outside this ruling's scope.

**Two honest frictions, neither a JS dependence:** the local gateway uses a
self-signed certificate (OTP 29 verifies TLS by default, so a CA or an
explicit verification decision is needed — `gleam_httpc.verify_tls(False)`
works but disables verification and must not be the default), and the gateway
requires an authenticated SSO session. Both are HTTP/session concerns.

**Landed in:** `scripts/no_foreign_source.sh` now also fails on any
`@external(javascript, ...)` under `src/` and on a `target = "javascript"`
declaration in `gleam.toml`. The priority is a mechanism, not a promise.
`src/` currently has **zero** `@external` in compiled code; the twelve
`@external(erlang, "Elixir.Glibe.Ibkr", ...)` in `ibkr.gleam.disabled` are a
retired design record, not source.

---

## R16 — 手写 JS 在「页面设置 + 数据更新」小范围内可以接受（2026-11-07）

> *"如果仅限于页面设置和更新数据的这一个小范围，手写js的风险是严格掌控的，
> 可以接受。"* [user 2026-11-07]

**这是 owner 的明确例外，范围按原话限定，不扩大。** 覆盖的只有两件事：
(a) 页面/图表的**设置**（series 定义、pane、坐标与样式选项等声明性内容）；
(b) 一根 settled bar 到达时的**数据更新**（UC-56 的一次 `series.update`）。
不覆盖 SSE、tab / symbol 切换、业务计算、第二个引擎，也不覆盖任何其他
手写 JS 的用途。

**与 §1.28 / R15 的关系。** glib `docs/RULINGS.md` §1.28 说 erlang target 上
手写 `.mjs` 是「走错了」的信号、law 4 是 *"Never write the file"*；R16 是
owner 本人对**这一小范围**给出的例外，不是推翻 §1.28：超出上述两件事，
§1.28 仍然有效。R15 的机制也仍然有效——根 `src/` 下禁止
`@external(javascript, ...)`、根 `gleam.toml` 禁止 `target = "javascript"`；
R16 谈的是**手写 JS 文件的可接受范围**，不是编译目标，两者不冲突。
`scripts/no_foreign_source.sh` 只守 `src/`，比这两条裁定都窄；过 guard
不等于合规，也不等于违规，最终以 owner 的范围为准。

**撤销的结论：** `docs/REVIEW_ROUND5.md` §13.4 曾写「采用 JS 图表库需要
owner 另给一次明确例外、否则只有 SVG 路线合规」。例外现在已给出，该句的
前提消失；§13.4 已改正为按 R16 的范围执行。

**引发的第二个事实（owner 2026-11-07 提法，已实测）：** 若所需 `.mjs` 是
**Gleam 源码编译生成**的，或 `@external` 绑定的是**已存在的** npm 包，则
根本不存在「手写 JS」。探针（`gleam 1.19.2`，`target = "javascript"`）生成
`probe.mjs`，其中 `import { createChart as create_chart } from
"lightweight-charts"`，`src/` 下零手写 `.mjs`；只有 external 指向
`./xxx.mjs` 时才需要手写文件。见 `docs/REVIEW_ROUND5.md` §13.8。

**成本口径与「生成 mjs」的准确含义（owner 2026-11-07 补充，属 R16 同一范围）：**

> *"因为可能是0成本（额外成本），因为不管你用什么语言，用绘图库都是要写一点
> 配置的。这部分不是额外成本。"*
> *"你说的探针证实我的第一点，希望你说的是，写gleam代码，编译形成应用JS库绘图
> 所需的那个mjs是可以做到的，而不是别的意思。"*

series 定义、图表选项、`DataBar → bar` 映射、一根 settled bar 的更新，是**用任何
语言、任何绘图库都要写的固有工作**，不是采用 JS 图表库带来的额外成本；额外成本
只有「手写外来源码」这一项，在这条路线是 **0**。「那个 mjs」= 浏览器加载的
**应用模块**，由 Gleam 源码经 `gleam build` 编译生成
（`build/dev/javascript/<pkg>/<module>.mjs`），不是人手写的；库本身来自 npm
（§1.28 law 2），根项目仍是纯 erlang（R15），带 `target = "javascript"` 的是
独立的 `client/` 包。owner 对 Lustre 的读法：*"它确实是有一部分是js target，
其他部分是 BEAR/erlang target，这方面做的很好"*（BEAR 即 BEAM，原话照录）——
这是两个运行时的分工，不是与「pure erlang target is the future」冲突。
完整探针与边界见 `docs/REVIEW_ROUND5.md` §13.9：`chart.addSeries` /
`series.update` 是对象方法而非模块级导出，点号 external 在编译期被拒
（`Invalid JavaScript function`），所以真正落地可能仍需 2–5 行转发模块——
**已在 R16 允许范围内**，且它不是「那个应用 mjs」。

---

## R17 — 应用不是框架：采用 JS 图表库，优先用编译器生成的 mjs（2026-11-07）

> *"我们是开发应用的，不是开发框架，所以能用js chart，成本不高的话，还是用。"*
> [user 2026-11-07]
>
> *"尽量用Gleam编译的mjs取代手写这件事，以前做其他项目时尝试过，是可行的。
> 如果遇到障碍可以写出来。"* [user 2026-11-07]

**这是 owner 的决定。两个限定词按原话保留，不扩大也不缩小：**

- **"成本不高的话"** 是条件。实测（`docs/REVIEW_ROUND5.md` §13.9 / §14）：
  series 定义、图表选项、`DataBar → bar` 映射、一根 settled bar 的更新，是
  任何语言用任何绘图库都固有的配置工作，**不是额外成本**；生成 mjs 路线的
  「手写外来源码」是 **0 行**。条件成立。
- **"尽量"** 是优先序，不是绝对禁令。生成 mjs 优先；R16 的小范围例外仍是
  实例方法/常量那一小块转发模块的兜底；§1.28 在范围外仍有效；R15 根项目
  仍是纯 erlang。

**由此得到的执行结论（以下不是 owner 原话，是按上面两句推出来的）：**

1. 图表组件**采用 JS 图表库**——glib 正在用的 TradingView LightweightCharts
   是唯一实测对象。Lustre SVG DSL 自己画 K 线不再是默认路线：那是做图表
   引擎，属于「开发框架」，不是「开发应用」。§12 的能力比较作为事实保留，
   不再作为默认方案。
2. 客户端代码优先写成 **Gleam 源码，经 `gleam build` 编译成 `.mjs`**；手写
   `.mjs` 只在 R16 范围内兜底。
3. **障碍必须写出来**（`docs/REVIEW_ROUND5.md` §13.10）。已实测的一条正是
   owner 提醒的：*"你在这里测试失败有可能是缺少那个chart库本身"* ——
   `gleam build` 不解析 npm 依赖，**构建绿 ≠ 能跑**；缺
   `lightweight-charts` 时 `node` 报 `ERR_MODULE_NOT_FOUND`，装上后探针里的
   占位绑定报 `does not provide an export named 'addSeries'`。
4. **仍未裁定**：web 层框架（是否用 Mist / Wisp / Lustre）、`apps/glibe_web`
   是否退役、是否引入独立 `client/` 包。本条只定图表库与代码生成方式，
   不替 owner 决定 web 层。
   **（2026-11-09 状态：后两项由 R18 关闭；第一项由 R24 关闭 —— 它不再是
   owner 裁决项，改由 AI 写 demo 对比决定。此处保留 R17 当时的原文。）**

**WASM 是 owner 的设想，不是裁定：** *"如果我们有时间去研究，那么想要完全
不依赖JS那只能走WASM路线了，这要看elixir有没有尝试这个，gleam那么小的
community，要做这事得自己动手，太麻烦了或许。"* 查证结果与他「有时间再研究」
的判断一致，记在 `docs/REVIEW_ROUND5.md` §15。**不采用、不排期、不替他决定。**

---

## R18 — web 前端的形状（2026-11-07 owner 裁定）

**owner 原话：** *"web前端是需要的，原因是要比写一个Gleam GUI容易（？）
web前端用来让人类通过肉眼观察发现程序输出结果的异常，发现逻辑错误，用来让
人类根据图掌握行情趋势，形成交易思路，用来观察非图形但是表格化的分形结构
重要数据，研究行情特征和新手工策略，还能看到交易指令发出点，交易指令成交
点等等。原来的Phoenix应用还是阵痛不用，但是不要一下子删除，要用来对照
方便你比较抉择一些技术决定。所以先移动到"过时"目录备考；另外web 客户端
确实应该放在一个单独的folder不要放在src里面，仿照Lustre的结构。这样可以
解决局部需要JS target问题（编译你用gleam写的源代码生成mjs而已，如果这样做
实在麻烦，就手写mjs，但是仅仅出现在那个webclient目录里面）"*

**裁定：**

1. **web 前端需要**，不是可选装饰：让人用肉眼发现输出异常与逻辑错误、从图
   读趋势形成交易思路、看表格化的分形结构重要数据、研究行情特征与新手工
   策略、看交易指令发出点与成交点。理由：比写一个 Gleam GUI 容易。
2. `apps/glibe_web`（Phoenix）**不删除、暂不使用**，移到
   `deprecated/glibe_web/` 备考，只在比较技术决定时作对照。
3. web 客户端放在**独立 folder** `webclient/`，**不进 `src/`**，仿照 Lustre
   的 client / server 分工：它有自己的 `gleam.toml`，
   `target = "javascript"`，是一个独立 package。根 `glibe` 仍是
   `target = "erlang"` 的纯 Gleam 引擎。
4. 局部 JS target 问题由**两个 package 各自的 target 声明**解决：边界由构建
   工具表达，不靠 sh 去 grep 文件扩展名。
5. 客户端优先写 Gleam 源码、由 `gleam build` 生成 `.mjs`（R17）；手写
   `.mjs` 只在生成确实麻烦时兜底，且**只允许出现在 `webclient/` 内**（R16）。

**已实测：** `webclient/gleam.toml` + `webclient/src/webclient.gleam` 经
`gleam build` 生成 `build/dev/javascript/webclient/webclient.mjs`，零手写
JS；根项目 `scripts/guards.sh --all` 全绿（26 tests、7 fixture cases）。

**R17 结尾"仍未裁定"的三项里，后两项由此关闭**：`apps/glibe_web` 去留、
是否引入独立 client 包。**web 层框架（Mist / Wisp / Lustre）仍未裁定**，
不替 owner 采用。历史评审文档中的 `apps/glibe_web` 路径记录的是当时的树，
不是当前路径；当前路径以本条为准。
**（2026-11-09 状态：这一项由 R24 关闭，不再是 owner 裁决项；改为 AI 写
demo 对比测试决定。此处保留 R18 当时的原文。）**

---

## R19 — 文档先行是代码里的文档；单元测试先于实现（2026-11-07 owner 裁定）

**owner 原话（节录，逐字）：** *"文档先行，目前不完全，仅仅是文本现行，其实
文档包含在代码中的文档"*、*"先定一个一个模块（就是一个gleam文件），一个
模块中先定义一个非常简单的 type 若干空的 fn 但是写完成文档，`////` for
module, and `///` for type or function, `//` for others, so gleam docs tools
will generate documents for you"*、*"fn empty_for_now(...) {todo as "I will
add code here according to function docs above"} builds with no error"*、
*"And this way you make unit tests first, and fill in functional code later,
cycling it over and over until all your intended works are all done and built
green"*、*"code files go without referencing to .planning plans, and documents
only live in docs folder while code modules may go the other way and without
anybody noticing it"*。

**裁定：**

1. **文档先行 ≠ 先写 `docs/` 文本。** 文档必须落在代码文件里：`////` 写模块，
   `///` 写紧随其后的 type / function，`//` 只是普通注释，`gleam docs` 看不见。
   `///` 就是该函数的规格；测试断言这个规格，函数体交付这个规格。
2. **一个模块的固定顺序**：`////` 模块文档（**点名它所实现的 `.planning`
   计划条目**）→ type → `///` + 带完整类型标注的签名 → `todo as "..."`
   空函数体 → **单元测试** → 每次填一个函数体并编译 → 循环到全绿。
3. **计划与代码必须有链接。** 只存在于 `.planning/` 或 `docs/`、代码文件里
   不引用它的计划是玩具；代码会往另一个方向走而没人发现。链接写在 `////`
   里，因此随编译产物一起存在。
4. **TDD 用 Gleam 自己的设施**：`assert` / `let assert` / `todo`，不用往源码
   里塞故意写坏的代码做负面测试（R16 之前的清理已如此）。

**实测（Gleam 1.19.2 / OTP 29，2026-11-07，独立探针包）：**

| 阶段 | 结果 |
|---|---|
| `////` + type + `///` + 签名 + 两个 `todo as` 体 | `gleam build` **0 errors**、**4 warnings**（2 个 `Todo found` + 2 个未使用参数）；`gleam build --warnings-as-errors` **exit 1** |
| 先写 `test/<pkg>_test.gleam`，`assert` 断言 `///` 承诺 | `gleam test` **RED**：`0 passed, 2 failures`，每个失败打印 `todo src/...:行号` 与 `info:` 里的消息 |
| 填完函数体 | `gleam build --warnings-as-errors` **0**、`gleam test` **0**（`2 passed`）、`gleam format --check` **0**、0 warnings |
| `gleam docs build` | `////` 段落与每个 `///` 渲染进 HTML；`build/dev/docs/<pkg>/package-interface.json` 以 `"documentation"` 字符串数组保存它们 |

**由此得到的两条机制，不是新 sh 守卫：**

- `--warnings-as-errors` 是**绿灯阶段**的门槛，红灯阶段必然失败；不要为了让
  它变绿而删掉骨架里的 `todo`。
- `gleam docs build` 生成的 `package-interface.json` 是**编译器的产物**，把
  `////` 里的计划引用变成机器可读数据。哪个模块没有 `////`，直接由这个文件
  看出来，不需要再写一个 grep 守卫去描述约定。

**当前差距（测量，不是猜测）：** glibe `src/` 下 23 个模块，
`package-interface.json` 显示 **23 个模块的 `documentation` 全为空数组**，
代码里对 `.planning` 的引用 **0 处**，`test/` 只有 1 个测试文件。对照
`glib`：`src/` 39 个模块里只有 1 个有 `////`，`///` 共 1507 行、
24 个测试文件，但代码里对 `.planning` 的引用同样是 **0 处**——文档与测试
都存在，却没有和计划连起来，也没有写在函数体之前。R19 正是补这两处。

**执行边界：** 这条裁定定的是工作方式，**不是改代码的许可**。`src/` 本次
**未改动**；`docs/RULINGS.md`、开发指南、`gleam-language` skill 的工作流与
浓缩核心已按此更新。第一个完整的文档先行 / TDD 循环落在下一件真正开工的
模块上。可运行的红→绿样例在
`~/.workbuddy/skills/gleam-language/docs-first-probe/`。
**该循环已在 R20 落到 `src/glibe/desk.gleam`，实测数字见下。**

---

## R20 — 所有权链是 must-have；`Desk` 定名；第一个文档先行 / TDD 循环落地（2026-11-07 owner 裁定）

**owner 原话（逐字节）：** *"注意你其他文档决定不引入 glib的几个types/modules
包括 Desk/Broker/Account 等等 （REVIEW_ROUND5.md)"*；*"1. Desk or Deck which
is better here meaning a dashboard"*；*"2. Type relations tell you those are
Must to have, otherwise your list of Timeframe for different intervals, and
your list of Instruments for Instrument will don't know where to live"*；
*"3. Documents first, means you can have almost empty shells but with full
documentation and the types are sufficient and will be built without error,
and you can write your tests before actual coding"*。

### 1. 推翻 `docs/REVIEW_ROUND5.md` 的排除项（仅限这一条）

该文 §1 表格（`:37`）写的是 *"`Desk`, `Broker` exist as keyless shells with
**zero production callers**"*，**Do NOT adopt** 一节（`:282`）据此排除了
*"`Desk` / `Broker` / `Account` empty shells"*。**这个理由不成立**：在 Gleam 里
`Desk(brokers: Dict(BrokerId, Broker))` 这样的字段本身就是**编译期消费者**——
type relation 就是 caller。空壳之所以显得空，是因为**关系还没被写出来**，
不是因为关系不该存在。所以：**`Desk` / `Broker` / `Account`（连同
`Instrument`）是 must-have，不是可选装饰。** 该节其余排除项
（`SignalBundle` / `evaluate_bar`、hy4 的类型名、`String` 化的
symbol/interval/action/check、14 个手写 `.mjs`）**继续有效，本条不推翻**。

**同一层关系，owner 在 2026-11-03 已经说过一次**
（`glib/.planning/HANDOFF-2026-11-03.md:111`，一条带时间戳的 owner 引文）：
*"在你没弄清楚你自己设计的 Deck then Broker then Instrument then Timeframe
的关系之前，你所设计出来的大堆复杂东西，不过是为了解决interval的窘境，
不可能有用。"* **来源与层级：** 这是**录在 glib 文档里的 owner 引文**，只作
印证、**不是规范、不是依据**；本条裁定的依据是上面本轮 owner 原话。它说明
「四类型所有权关系」本来就是先于 interval 问题的那一层，与本轮 point 2 是
同一件事——**不是新要求，是被排除项挡住的旧要求**。

**证据（glibe 当前代码，不是类比）：** `src/glibe/config.gleam:13-17` 是一组
平行的 `List(#(String, …))`；`:518` 的键是 `"BTCUSDT_H1"` 这种把
instrument 与 interval 两个事实压进一个 `String` 的复合键；`:632` 与
`:647` 各有一个 `list.find` 靠字符串相等查表。**这两张表没有 type 上的
owner**，正是 owner 说的 "will don't know where to live"。

### 2. 定名：`Desk`，不是 `Deck`

1. **域语义**：trading desk / dealing desk 正是「一个交易员盯着行情、管理
   broker、account、instrument」的那个单位，也就是 dashboard 所指的那张台子。
   `Deck` 在金融语境里是 **pitch deck / slide deck**（给投资人的演示稿），
   或一副牌、船的甲板；用它命名行情台会主动误导。
2. **精确名，以及一个实存的拼写漂移**：`glib/src/glib/desk.gleam` 已定义
   `pub type Desk`，`docs/REVIEW_ROUND5.md` 也一直写 `Desk`。**但 `Deck` 并非
   不存在**：`glib/.planning/HANDOFF-2026-11-03.md:111` 那条 owner 引文写的是
   *"Deck then Broker then Instrument then Timeframe"*，而同一文件 `:114` 的
   AI 转述紧接着改写成 `Desk → Broker → Instrument → Timeframe`。**在本次记录
   之前，两仓代码与文档里唯一的 `Deck` 就是这条引文**（此处是为说明该拼写才
   再次写下这个词）——是一次真实的拼写漂移，不是我编出来的对照。
   按「不擅自改名、用代码里的确切名字」，本次采用**代码里已存在的 `Desk`**；
   那条引文**原样保留，不替 owner 改写，也不拿它当改名依据**。
   **来源与层级**：`glib/src/glib/desk.gleam` 只是 **example**（一个已存在的
   实例，**不是规范、不是依据**）；本条裁定的依据是上面 owner 本轮原话。
   它的首行注释写着 `Desk ─▶ Broker ─▶ Instrument ─▶ Timeframe ─▶ DataBar`，
   仅作印证。owner 本轮同时写了 "Desk/Broker/Account" 与 "Desk or Deck"，
   说明他自己也在核对这一处拼写——上面的取舍是对他这句提问的回答，不是替他
   改掉旧引文。
3. **模型与视图分开**（这是 "meaning a dashboard" 的关键）：dashboard 是
   `webclient/` 里的 **view**，`Desk` 是引擎 `src/` 里 **model 的根节点**。
   引擎里的一个 type 不可能是屏幕；把这个 type 叫 `Deck` 来指屏幕会把两者
   混成一个东西。若只需给 UI 起名字，朴素的词是 `Dashboard`，也不是 `Deck`。

### 3. 第一个真正的文档先行 / TDD 循环（实测，非计划）

计划：`.planning/phases/04-domain-cleanup/04-01-PLAN.md`（先写，代码 `////`
里点名它）。新模块 `src/glibe/desk.gleam` 的顺序严格按 R19：
`////`（含计划路径）→ 7 个 type → 18 个带完整标注的签名 + `///` →
`todo as "…"` 体 → `test/desk_test.gleam`（10 个 `assert` / `let assert`）→
填体 → 绿灯。**没有改任何已有 `src/` 文件。**

| 阶段 | 实测（Gleam 1.19.2 / OTP 29） |
|---|---|
| 骨架 `gleam build` | **exit 0，0 errors，49 warnings** = 18 `Todo found` + 29 `Unused function argument` + 2 `Unused private constructor`（后两类是 type 还没被构造出来的连带结果，R19 小探针里没有） |
| 骨架 `--warnings-as-errors` | **exit 1**（红灯阶段的正常表现，是绿灯门槛） |
| 测试先于函数体 `gleam test` | **exit 1，26 passed / 10 failures**，10 个新测试全部被发现，每个打印 `todo src/glibe/desk.gleam:行号` 与该 `todo` 的 `info:` 消息 |
| 填完 18 个函数体 | `build --warnings-as-errors` **0 / 0 warnings**；`gleam test` **0，36 passed, no failures**；`gleam format --check` **0** |
| `gleam docs build` | `package-interface.json`：24 个模块中 **23 个 `documentation` 仍为空**（历史欠账照实留着）；`glibe/desk` 有 **32 行模块文档、25 个带文档的条目**，且计划路径在 JSON 里可检索 |
| `sh scripts/guards.sh --all` | **exit 0**（build、36 tests、format、7 个 fixture 用例） |

**类型关系落点：** `Desk(brokers: Dict(BrokerId, Broker))` →
`Broker(instruments: Dict(Symbol, Instrument), accounts: Dict(AccountId, Account))`
→ `Instrument(settings: Dict(Interval, TimeframeSettings),
timeframes: Dict(Interval, Timeframe))`。identity 是 key，不是字段；
`BrokerId` / `AccountId` 是 `opaque`；查找失败是 5 个变体的
`LookupError`，不是 `Error(String)`。于是 `config.gleam` 那两张表**现在有
了 typed 目的地**，虽然表本身尚未搬迁。

### 4. 明确未决、未做的事（不装作已完成）

- **`config.gleam` 未迁移**：两张 `List(#(String, …))` 及其 `list.find` 原样
  保留。搬迁是架构变更，另立计划，不在本条。
- **`Timeframe` 仍自带 `symbol` / `interval` 字段**，所以 key 与 value 可能
  不一致；让它 keyless 是单独的类型变更（`docs/REVIEW_ROUND5.md` 已记为
  design debt）。本条没有动 `src/glibe/timeframe.gleam`。
- **`src/glibe/api/symbol.gleam:1` 写着 "Symbol = Instrument"**，与新增的
  `Instrument` 值类型构成命名冲突。**不擅自改名、不擅自统一**，记为待裁决。
  当前用 `Symbol` 作 `Dict` 的 key；是否需要专门的 `InstrumentId` 也未决。
- `Interval` 闭集 7 → 9、web 层框架（Mist / Wisp / Lustre）仍未裁定。
- 没有新增任何 sh 守卫；防漂移靠编译器自己的 `package-interface.json`。

**2026-11-09 状态更新（R22 / R23 / R24 / R25，见下文）：本节上面四条
「未决、未做」已全部关闭。** `Symbol` 不再是 `Instrument`（R22）；两张
复合字符串表与第二本 settings 字典已删除，settings 成为 `Timeframe` 的
字段，`Timeframe` 不再自带 `symbol` / `interval` / `market_type`（R23）；
`Interval` 闭集已完成（R21）；web 层框架不再是 owner 裁决项，由 AI 写
demo 对比决定（R24）；`TPlus1` / `TPlus2` 保持原名（R25）。`Timeframe`
去掉自带 key 一事在 R23 里一并完成，不再是 design debt。落地实证见
`.planning/phases/04-domain-cleanup/04-03-PLAN.md` 与 `04-03-SUMMARY.md`。

---

## R21 — 类型构造子必须写全名，禁止「一个字母 + 数字」的线路码（2026-11-08 owner 裁定）

**owner 原话（逐字节）：** *"those one letter with a number things everywhere
are extremely stupid and we should avoid them. what is D1/H1/H4? All
meaningless stupid spams. As types they should have been at least
OneDay/OneHour/FourHour, or even better with a keyword, for example `Interval`,
such as IntervalOneDay, IntervalFourHour, and so on."*

### 1. 错在哪一层

`D1` / `H1` / `H4` / `MIN15` 是**交易所与配置文件的线路码**，属于边界词汇。
我把边界词汇抄进了 **model 的闭集构造子**，于是整个 codebase 都在用一组需要
额外记忆的暗号去推理。这不是拼写问题，是**分层问题**：线路码只能出现在
codec / adapter（`to_string`、`from_string`、Binance 拼写函数、配置文件格式），
**不能**成为类型本身的名字。

这条与官方 conventions 一致：`docs/gleam-thinking-core-to-memory.md` §5/§11
早已写明 **"No abbreviations"**、**"Anti-patterns: abbreviations"**；但同一份
核心的 §0 示例自己就用了短码。**武器自身违反了自己的规则**，本条一并修正。

### 2. 命名规则（对所有自定义类型生效，不只 `Interval`）

**构造子 = 类型名前缀 + 用英文写全的值，单位按 owner 给的形状取单数**
（`IntervalOneDay`、`IntervalFourHour`，不是 `IntervalOneDays` /
`IntervalFourHours`）。禁止一个/两个字母的单位缩写加数字。

| 旧（线路码） | 新（构造子） |
|---|---|
| `MIN1` | `IntervalOneMinute` |
| `MIN3` | `IntervalThreeMinute` |
| `MIN15` | `IntervalFifteenMinute` |
| `MIN30` | `IntervalThirtyMinute` |
| `H1` | `IntervalOneHour` |
| `H4` | `IntervalFourHour` |
| `D1` | `IntervalOneDay` |
| `W1` | `IntervalOneWeek` |
| `MO1` | `IntervalOneMonth` |

**保持不变：** `"1m"` / `"3m"` / `"4h"` / `"1M"` 这类线路拼写是**字符串边界
数据**，只活在 `to_string` / `from_string` / `binance/kline.gleam` 里。它们不是
构造子，不违反本条。

### 3. 机制与范围

- **机制是穷尽性检查，不是 sh 守卫。** 增加一个构造子，`case` 缺臂就是编译
  错误，编译器列出所有要改的地方。命名规则写进
  `docs/gleam-thinking-core-to-memory.md` §0 / §5 / §13，以及
  `gleam-language` skill 的工作流与可运行探针；两份核心用 `cmp` 保持一致。
- **已改名：** `src/`、`test/` 全部构造子引用；`webclient/` 无引用；当前计划
  `.planning/phases/04-domain-cleanup/04-02-PLAN.md`；「Interval 闭集」那一项
  的现行表述；`README.md`、`docs/DESIGN.md`、
  `.planning/ROADMAP.md` 中的现行表述。
- **历史文档不改写**：`REVIEW_*.md`、`session-ses_*.md`、`.workbuddy/memory/`
  日志、已完成的旧 phase 计划里保留当时的短码，它们是**当时的记录**，不是
  当前命名。与 R18 对 `apps/glibe_web` 路径的处理同一条规矩。旧代码形态在
  04-02 计划里以「被替换的记录」形式引用一次。
- **`TPlus1` / `TPlus2`（`api/rules.gleam`）未改名**：它们把行业标准术语
  T+1 / T+2 拼了出来，不是线路码。**R25（2026-11-09）已裁定保持原名，
  本项关闭。**
- **`config.gleam` 的 `"BTCUSDT_H1"` 复合字符串键**：R21 当时不动它，
  因为那是尚未拍板的数据迁移，不是构造子。**R23（2026-11-09）已删除
  该表及另一张 `symbols` 表**，此处保留的是 R21 当时的执行边界记录。

**执行边界：** 本条定的是**命名**，不是配置表迁移的许可。R20
「明确未决、未做的事」里的两项 owner 裁决（表的搬迁形状、
`Symbol` / `Instrument` 命名冲突）由 **R22 / R23（2026-11-09）关闭**。

---

## R22 — 名字不是实体：`Symbol` 永不是 `Instrument`（2026-11-09 owner 裁定）

**owner 原话（逐字）：**
> *"Symbol never is Instrument, people may call you with different titles and
> names they like, but you are you, how can a title and name be you? glib docs
> have full discussion. glibe搞错了的东西，就是搞错了，就要彻底干净地纠正，
> 没有绕圈子省事的办法，最终圈子越绕越大，还是要改正，不过是增加了改正的
> 难度"* [user 2026-11-09]

### 1. 错在哪一层

`src/glibe/api/symbol.gleam:1` 和 `:4` 写着
`Symbol = Instrument = Asset on specific Market (what you actually trade)`，
并把 9 个描述交易品种的字段塞进 `Symbol`。这个等号把**名字**当成了**实体**：
一个人可以被叫不同头衔，头衔不是这个人。这不是命名不精确，是分层错了。
该句出自 glibe 早期 AI prose：`glib/docs/reference/RELATED_PROJECTS.md:81`
引用过它；`glibe/session-ses_f35a.md:561` 的 AI 表格 "The instrument IS the
symbol" 已在同文件 `:528` 被 owner 以 *"Shame."* 纠正。

### 2. glib 中 owner 的原始论述（逐字，不是 AI 转述）

- `glib/docs/reference/domain-hierarchy-2026-10-22.md:18-22`：
  > *"有些经纪商提供contract类型例如ib，有些没有，但是Symbol必须都有，并且都
  > 不太一样，比如雅虎、币安、富途牛牛、盈透对应同一个上海股票600000，可能
  > 就有不同的 Symbol，比如有些600000，有些600000.sh, 有些600000.SH，这需要
  > 我们glib自己定义一个标准 Symbol然后在各 APIProvider/Broker中定义一个自己
  > 的格式，并各自定义一个到glib标准Symbol到切换函数"*
- `glib/docs/RULINGS.md:385`（UC-47）：
  > *"Market, Trading instruments(交易对象类型) then timeframe for each symbol
  > (or contract in the ib api terms), are what types I can see. Others are just
  > a list or a group of them but not neccessorilly being a type"*
- `glib/docs/RULINGS.md:1100-1105`（§1.17）：
  > *"symbol的方言标准化问题，其实是一个规则对照表 … glib标准 symbol 追随
  > 各自的命名即可。也就是说目前不存在问题。"*
- `glib/docs/reference/domain-hierarchy-2026-10-22.md:28-30`：
  > *"所以timeframe必须是隶属于某个Instrument，Instrument必须隶属于某个
  > Exchange … 又必须隶属于某个提供商"*

同一个品种在不同提供商有不同拼写 → `Symbol` 是**被给的称呼**，`Instrument`
是**实体本身**。glib 已落地的形状见 `glib/src/glib/domain/instrument.gleam:43-84`：
`Symbol` 是按 provider 区分的构造子集合、`Instrument(market, timeframes)` 不存
自己的 symbol；文件头那段 "BEING / given, not being" 是 **AI 代码注释**，不是
owner 原话，此处只作为已落地形状的证据。

### 3. 裁定

- `Symbol` = 某个 broker / provider 用来称呼一个 `Instrument` 的拼写，是
  `Broker.instruments` 的 **key**；它**不携带实体的任何内容**。`Instrument`
  是被拥有的**值**，**不存储自己的名字**。两者是不同概念，不统一命名、
  不设别名、不建 `InstrumentId` 中间层、不留兼容层。
- 那句 `= Instrument =` 整句删除，连 deprecated 注释都不留。9 个字段全仓
  检索确认**从未被任何模块读取**，一并删除，不迁移。
- **不许绕圈子**：搞错了就整条改正，不写适配层、不保留旧表再补解析器。
  「彻底」的验收标准见 R23 与 `.planning/phases/04-domain-cleanup/04-03-PLAN.md`。

---

## R23 — 彻底纠正：假类型、并行字典与向上指认的字段（2026-11-09 owner 裁定）

**owner 原话（逐字）：**
> *"你所举例，是不是glibe的？是不是在主要type缺位的情况下，AI自作聪明的省事
> 办法，就是绕圈子，然后圈子越绕越大越糊涂？唯一解决办法就是彻底纠正，至于
> Desk < Broker < Instrument < Timeframe 的隶属关系，非常清晰，glib文档中有我
> 给ai的具体解释； TimeframeSettings这是什么type？现实中存在这个type吗？跟
> Timeframe什么关系？又是在绕圈子？"* [user 2026-11-09]

### 1. 逐问回答（不绕）

**「你所举例是不是 glibe 的？」—— 是。** 我上一轮举的正是
`src/glibe/config.gleam` 的两张表：`symbols: List(#(String, symbol.Symbol))`
和 `timeframe_settings: List(#(String, indicator_settings.TimeframeSettings))`，
后者的键是 `"BTCUSDT_H1"` 这种**一个 String 装两个事实**的复合串，读取靠
`list.find`（`get_symbol` / `config_get_tfs`）。

**「是不是主要 type 缺位时 AI 自作聪明的省事办法？」—— 是。** 因为
`Desk ▸ Broker ▸ Instrument ▸ Timeframe` 这条链当时不存在，AI 用
「字符串拼键 + 第二本字典 + 查找函数」代替了本该由类型关系表达的归属。
`Instrument` 里除了 `timeframes: Dict(Interval, Timeframe)`，还平行地放着
`settings: Dict(Interval, TimeframeSettings)`；`Timeframe` 不自带 settings，
于是 `engine.databar_processing` 要外部再传一个 settings 参数。为了让
`sourcebar_gate` 知道 interval，又让 `Timeframe` 自带 `interval`; 为了知道
是谁，又自带 `symbol` 和 `market_type`。**每补一个绕行字段，就多一个需要
同步的事实** —— 正是 owner 说的「圈子越绕越大越糊涂」。

**「TimeframeSettings 是什么 type？现实中存在吗？」—— 不存在独立实体。**
它是 `src/glibe/indicator_settings.gleam:15-29` 一个 12 字段的数字包（5 个
SMA 窗口、KDJ 三个参数、`bb_multiplier`、`sma_for_bbm`、`branch_exit_leaf_size`）。
owner 从未命名过它；`glib/.planning/phases/32-system-design/32-01-PLAN.md:223-225`
里 AI 自己写着 *"Mine, awaiting his word: … a stand-in each"*。它不是领域里的
东西，只是**一组参数值**。按 `glib/docs/RULINGS.md:188`：
> *"除了我明确提到的那些 vars，不要瞎编瞎造不必要的变量"* [user 2026-09-20]

**「跟 Timeframe 什么关系？又是在绕圈子？」—— 是。** 这包数字是**某个
interval 的那台 Timeframe 跑起来用的参数**，一个 interval 一份，因此只能
是 `Timeframe` 的一个字段，不是与 `Timeframe` 平行、另起一本字典的实体。
glib 落地的正是这个形状：`glib/src/glib/timeframe.gleam:76-78`
`Timeframe(settings: IntervalSettings, working_databar, databar_list, …)`；
`glib/docs/DESIGN.md` §18.4 写明 *"the settings travel with the engine, the
interval does not"*。glibe 造出第二本字典 + 复合串表 + 两个查找函数，是在
绕圈子。

### 2. 隶属关系的 owner 具体解释（逐字）

- `glib/.planning/HANDOFF-2026-11-03.md:96`：
  > *"即然你的左手不知道他是左手你也活的好好的，为什么instrument的timeframe
  > 必须要知道他的interval？有这么愚蠢的设计吗？"* [user 2026-11-04]
- `glib/.planning/HANDOFF-2026-11-03.md:226-227`（同文见
  `glib/docs/DESIGN.md:3272-3276`）：
  > *"I used 'list' for easy of expression, in fact they could use dictionary
  > or any collections that are most fit to the requirements, for example,
  > instrument with a dictionary of timeframes using interval as key"* [user 2026-11-04]
- `glib/.planning/HANDOFF-2026-11-03.md:159`：
  > *"记住类型的事情不要偷懒，必须用type解决，其他所有替代方案迟早都会变成
  > 无用功，会被替换成type，别无选择。"* [user 2026-11-03]
- `glib/docs/RULINGS.md:2273`：
  > *"用type解决type问题，不是绕圈子费力不讨好"* [user 2026-10-26]

即：`interval` 只在 **key** 里，`Timeframe` 不自带；`symbol` 只在
`Broker.instruments` 的 **key** 里，`Timeframe` 不自带。
「被拥有者不指认拥有者」与「settings 随 engine 走」**都是 AI prose**（后者
出自 `glib/docs/DESIGN.md` §18.4，不是 owner 原话），此处只按 owner 上面的
原话执行；**「settings 随 engine 走」已由 R46 整条作废**。

### 3. 裁定（验收标准，不留兼容层）

- `Instrument` **只**持有 `timeframes: Dict(Interval, Timeframe)`。删除
  `settings` 字典、`put_settings` / `get_settings`、`NoSuchSettings`。
- ~~`Timeframe` 持有 `settings`，删除 `symbol` / `interval` / `market_type`
  三个向上指认的字段。~~ **2026-11-12 12:30 由 R48 整条作废**：「一个
  Timeframe 持有自己的 settings」讲不通，理由见 R48 §1；本条的依据是
  §1 末段 AI 散文（抄 glib `timeframe.gleam:76-78` 和
  `DESIGN.md §18.4`「settings travel with the engine」），不是 owner 原话。
  **本条仍然有效的部分**：删除 `symbol` / `interval` / `market_type` 三个
  向上指认的字段；`sourcebar_gate` 的 interval 由**选中这台 Timeframe 的
  调用方**传入（key 本来就在它手里）；`databar_processing` 不另收
  settings 参数。
- `config.gleam` 的 `symbols` 与 `timeframe_settings` 两张表删除；归属直接
  用类型值表达，不再有 `"BTCUSDT_H1"`、`list.find`、`get_symbol`、
  `config_get_tfs`。
- ~~`indicator_settings.TimeframeSettings` 保留为**值**（参数包），但明确写进
  模块文档：它不是实体、没有 id、没有自己的字典或配置表，唯一归宿是
  `Timeframe.settings`。不改名、不新造名字 —— owner 没说过的名字就是发明。~~
  **2026-11-12 11:46 由 R46 整条作废**：这一句自相矛盾 —— 一边说
  「owner 没说过的名字就是发明」，一边留下一个 owner 从没说过、并且本条
  开头正在**质问**的名字。owner 逐字：*"TimeframeSettings 是AI搞出来的
  东西，我不知道是什么玩意"*。R23 上面其余各条（identity 在 key、无复合
  串表、无第二本字典、无 `list.find`、删 `NoSuchSettings`）不受影响。
- 落地计划：`.planning/phases/04-domain-cleanup/04-03-PLAN.md`。

---

## R24 — web 层框架由 AI 写 demo 对比测试决定（2026-11-09 owner 裁定）

**owner 原话（逐字）：**
> *"web层架构当然是你通过写demo对比测试决定用哪一个呀，这个不可能由我决定
> 的，我不会去尝试一个又一个框架，这事你的优势，测试速度快。"* [user 2026-11-09]

- **这不是 owner 裁决项**，是我（AI）的工作：写最小可运行 demo、按可测指标
  对比、给出结论。owner 不会逐个试框架，也不会替我选。
- R17 / R18 留下的「web 层框架（Mist / Wisp / Lustre）仍未裁定」据此关闭，
  **不再列入待裁决文档**。候选与实测指标见
  `.planning/phases/04-domain-cleanup/04-03-PLAN.md` 的「后续工作」。
- 边界不变：根 `src/` 仍是纯 erlang（R15），`webclient/` 是唯一 JS-target
  package（R18），生成 `.mjs` 优先（R17）。demo 对比的结论**不等于**现在
  采用某个框架；是否引入仍按 `docs/DESIGN.md` 的稳定文档落地。
- **2026-11-09 已完成**：三个最小 demo 在 `probes/web-layer/` 真实起服务、发
  HTTP 请求、做 Node 导入检查；结论「推荐 A：Mist + Wisp 数据端点 + 生成的
  `.mjs` 视图，不采用 Lustre server components 作为默认」写进
  `docs/DESIGN.md`，全部实测数字在
  `.planning/phases/04-domain-cleanup/04-04-SUMMARY.md`。当时根 `gleam.toml`
  与根 `src/` 未改动，「结论不等于采用」的边界保持。
- **2026-11-09 后续（04-05）**：结论已被采用——这是我按本条自己该做的决定，
  不是新的 owner 裁决。根包加入 `mist` / `wisp`，
  `src/glibe/web/server.gleam` 用 `Route` 闭集服务真实 `Desk`（`/` HTML
  表格、`/desk` JSON）；Lustre server components 未被采用。R15 / R17 / R18
  的边界不变：根仍是 erlang target，`webclient/` 仍是唯一 JS-target 包，
  浏览器侧仍是生成的 `.mjs`。计划与实测见
  `.planning/phases/04-domain-cleanup/04-05-PLAN.md`、`docs/DESIGN.md`。

---

## R25 — 专业公认术语不是「字母 + 数字」线路码（2026-11-09 owner 裁定）

**owner 原话（逐字）：**
> *"比如说CPU这个是不是一个不可接受的缩略语？不是，因他是专业的公认的，
> 那么T+1这类的行业公认的表述，能不能接受呢？当然能呀，你非要说不能喝水，
> 喝氢二氧一，那不是没事找事么，这个跟什么狗屁H4 M1什么的是一个性质吗？"*
> [user 2026-11-09]

- **判据是「是否为领域内公认术语」，不是「是否含数字」。** CPU、T+1、T+2
  是专业公认表述，可以原样使用；`H4` / `M1` / `MIN15` 是交易所线路拼写，
  不是术语，只能活在 codec / adapter。两者不是同一性质。
- `api/rules.gleam` 的 `TPlus1` / `TPlus2` **保持原名**。R21 §3 里「已向
  owner 标出，等他一句话」由此关闭，不再列为待裁决项，也不再追问。
- R21 本身不因此放宽：构造子仍要写全名并带类型前缀；被禁的是**线路码当
  类型名**，不是行业术语。`docs/gleam-thinking-core-to-memory.md` §5/§13
  的 "No abbreviations" 按本条读。

---

## R26 — 关系未定就按需逐个加 type，不预先造一整套关系（2026-11-09 owner 裁定）

**owner 原话（逐字）：**
> *"exchanges/assets/markets 这里的assets具体指什么呢？与instrument 什么关系？
> exchange 和 market 什么关系，从数据源看，可以确定 Broker <- Instrument
> 这种关系是对的。其他type之间的关系，比较难确定，可以按需要逐步增加type，
> 届时关系可能就比较明晰了。"* [user 2026-11-09]

- **已确认的只有 `Broker ▸ Instrument`**，理由来自数据源本身。owner 原话
  （`glib/docs/reference/domain-hierarchy-2026-10-22.md` §1）：*"又必须隶属于
  某个提供商，因为提供商提供的数据格式不同，推送方式不同，推送申请不同，
  推送频率不同，等等"*；`glib/docs/RULINGS.md` §1.18：*"broker，同时也是api
  provider 他们是从不同角度命名的同样的东西"*。现行 `src/glibe/desk.gleam`
  的 `Broker(instruments: Dict(Symbol, Instrument))` 与此一致。
- **其余关系现在不定**：`Asset` / `Exchange` / `Market` 三者彼此、以及与
  `Instrument` 的关系，不在这里一次性定死，也不为「类型化」而把三张目录表
  硬塞进 `Desk` 链。按真实需要逐个增加 type，关系会在有消费方时变明晰。
  这不是允许 `String` 长期留在领域模型里：R13 / 根法则仍要求「该 type 出场
  时定义 type」；本条定的是**不预先发明没有消费方的关系**。
- 现有事实，逐条核对，不是推断（`src/glibe/config.gleam`）：
  - `assets` = 9 条标准化标的的**目录项** `Asset(id, name, class)`（BTC、SPY、
    USD…）；`class` 才是类别。owner 原话 *"Assets are standardized by laws"*
    （UC-47，`glib/docs/RULINGS.md:385`；`session-ses_f35a.md:568`）。glib 的
    `SYSTEM_MODEL.md` §10 把 `Asset` 列为 *"Deliberately unbuilt"*。
  - `markets` = 规则集 `Market(exchange: String, asset_class, rules)`；owner 原话
    *"different market have different settings so they should not be mixed
    together"*、*"a Binance BTC/USDT may have different trading rules comparing
    with the same asset in other markets"*（UC-47）。
  - `exchanges` = 连接参数 `Exchange(id, name, mic, base_url, ws_url,
    gateway_host, gateway_port)`。owner 原话 `glib/docs/RULINGS.md` §1.17：
    *"从ib的api观察，exchange放在contract里面，因为下单之后，同一个品种有可能
    是在不同的exchang中交易的"* —— exchange 是 contract 的字段（执行/路由场所），
    与「规则集」不是同一个概念，也不是 glib 里那个 `{ Binance | IB }` provider
    枚举（同名冲突，见 `domain-hierarchy-2026-10-22.md` §5）。
  - `get_asset` / `get_exchange` 在 `src/` 与 `test/` **没有任何调用者**；
    `get_market` 只在 `test/interval_test.gleam:99` 被调用一次。三张表与
    `Instrument` 之间当前**没有类型连接**，所以也没有可供「搬迁」的关系。
- **禁止重犯**：`Symbol = Instrument = Asset on specific Market` 那句已被
  R22 整句删除；`instrument = asset on market`、`Market = Exchange +
  AssetClass + MarketRules` 都是 glib 文档里的 **AI prose**，不是 owner 定的
  关系。不得借本条把它们重新写回来。
- 落地：`.planning/phases/04-domain-cleanup/04-03-PLAN.md` 与
  `src/glibe/config.gleam` 模块文档里「另立一个 identity-typing 计划」的
  措辞按本条改为「按需逐步增加」。`docs/DESIGN.md` 记录当前状态。

## R27 — 标准 `SourceBar` 的时间是 unix time（2026-11-09）

owner 原话：*"这里存在设计问题了，glib我已经批评过很多次，可能还是没有改，他的数据提供商方面sourcebar type，没有反应真实情况，定义错误。如果都不按照实际情况写，那么也不需要我们系统自定标准sourcebar 类型，而外部提供商模块也不用设置 to_sourcebar 函数来转换外部为我们内部标准的sourcebar了，所以，date在标准sourcebar中必须时timestamp，unix time"*

- **标准类型必须反映真实情况**：一根 bar 的时间是**绝对时刻**。内部标准
  `SourceBar` 的时间字段是 unix time（`gleam_time.Timestamp`，其内部即 unix
  seconds + nanoseconds），不是日期字符串、不是本地墙钟、不是「墙钟读数」。
- **转换责任在 provider adapter**：外部表示（Binance 的 epoch 毫秒、带或不带
  时区的标签、各市场的本地日历）由 provider 模块的 `to_sourcebar` 折成 unix
  time。这正是「自定义标准 `SourceBar`」存在的理由。标准层不拆字符串、不猜
  时区，也不把「没想明白」伪装成一个新类型。
- **作废的方向**：`.planning/phases/04-domain-cleanup/04-06-PLAN.md` 初稿曾
  按「墙钟读数」定义 `BarClock`，并用 R26 论证不直接用 `Timestamp`。该论证
  被本条否决：它是把没想明白的东西造了个类型，属于 R22 批评的绕圈子。
  `src/glibe/api/bar_clock.gleam` 与其测试整份删除，不留别名、不留兼容层、
  不留 deprecated 副本；历史留在提交记录里，不留在代码里。
- **桶网格跟着绝对时刻走**：`interval.bucket_ends` 对 unix 秒做网格取模
  （1h → `% 3600`、4h → `% 14400`、3m → `% 180`），不需要 calendar，也不
  需要 offset。若某市场的桶网格不与 UTC 对齐，那是**市场规则**，由有消费方
  时的 market 层表达（R26），不在这里预先发明。
- 边界不变：`String` 只活在线格式与 CSV/HTML 输出；`parse_rfc3339`、
  `to_rfc3339` 这类转换只出现在 adapter 与输出边。

## R28 — provider 原生 bar 各自保留、各自标准化（2026-11-09）

owner 原话：*"binance的kline包含很多特殊字段，其他提供商不提供，比如ib不提供那些字段，所以他们两家的sourcebar绝对不同，要保留原生态，并且各自标准化"*

- 标准 `SourceBar`（R27）是**内部标准**：不是任何 provider 的原生结构，
  也不是所有 provider 字段的并集。它只放系统真正按统一语义消费的东西。
- 每个 provider 定义自己的**原生 bar 类型**，线格式字段一个不丢：Binance
  kline 的 `closeTime` / `quoteAssetVolume` / `numberOfTrades` /
  `takerBuyBaseAssetVolume` / `takerBuyQuoteAssetVolume` / `ignore` 等，
  IB 有 IB 自己的一套。这两家的 sourcebar **绝对不同**。
- **各自标准化**：每个 provider 模块提供
  `to_sourcebar(native) -> Result(SourceBar, ...)`，把 provider 的时间表示折
  成 unix time（R27），并取出标准层需要的 OHLCV。转换只发生在这里。
- 禁止：adapter 直接构造标准 `SourceBar` 而丢掉原生字段；把 provider 特有
  字段塞进标准类型；用一种「通用 JSON bar」冒充所有 provider 的原生形状。
- 关系：provider 差异归属 adapter（R26「从数据源看」、`Broker ▸ Instrument`），
  标准层只有一份。`binance/kline.gleam` 的 `decode_klines` 返回原生
  `List(Kline)`，`to_sourcebar` 是唯一的出口。
- **原生命名也保留**（owner 2026-11-09 补充）：*"你看他原生的名字都不一样，binance称为kline，别人家可能成为bar，quote之类的形形色色"* ——
  Binance 的类型就叫 `Kline`，别家叫 `bar` / `quote` 是它自己的词。不得为
  了「统一」把 provider 原生类型改成通用名；统一只发生在标准层
  `SourceBar`，而且标准层不吸收这些名字。

## R29 — 夏令时与交易所时区：查 IANA 规则，不用固定 offset（2026-11-09）

owner 原话（两条，逐字）：*"注意美国股票市场涉及夏令时以及交易所时间好像是美国东部还是西部时间，这个需要用对应的库进行转化，ibOptions 项目中有这类转化的例子，也是很简单的，Gleam能用的相应的库我相信BEAM世界都有"*；
*"比如香港本地时间晚上22:30分，目前是美国时间早上9:30分，美国股市开盘，但是前一段时间，则是香港21:30分，对应美国9:30分"*

- **换算核对**：美东 09:30 开盘。冬令时 EST（UTC−5）与中国香港 HKT
  （UTC+8）差 13 小时 → 22:30；夏令时 EDT（UTC−4）差 12 小时 → 21:30。
  **同一个市场开盘时刻，绝对 unix time 一年里差一小时**，所以固定 offset
  必然错；反过来这正是 R27 要求标准层用 unix time 的理由。
- **查证到的库**（2026-11-09）：Gleam 原生 **`tzif` 2.0.0**
  （`hexdocs.pm/tzif/2.0.0`），配 `zones`（打包 IANA 数据，浏览器 / Docker /
  Windows）或 `tzif_loader`（读系统 `/usr/share/zoneinfo`）；
  `tzcalendar.to_time_and_zone(ts, "America/New_York", db)` 直接接受
  `gleam_time.Timestamp`。BEAM 侧另有 Elixir `Timex` + `:tzdata`，但那需要
  `@external`，不如 `tzif` 干净。**不自己写 DST 表，不加 sh 守卫。**
- **归属**：转换在 provider / market adapter 的 `to_sourcebar` 一侧
  （R27 / R28）；标准 `SourceBar` 与 `interval.bucket_ends` 不因此改变。
- **显式债务**：`bucket_ends` 现在是 unix 秒整点网格（1h `% 3600`、4h
  `% 14400`），只对 UTC 对齐的市场成立。美股 09:30 开盘，桶边界在美东
  10:30 / 11:30…，且冬、夏令时对应不同 UTC 时刻。这属于**市场日历规则**，
  按 R26 等真正有消费方时单独立计划并引入 `tzif`；不得用常数 offset 假装
  解决，也不在这里预先发明 `Market` 类型。
- **`~/gits/hub/ibOptions` 的实例**（owner 指路后逐条核对）：
  `tradingtime.py:24` 是 `eastern = pytz.timezone('US/Eastern')`；
  `USTradingTime` 用 `datetime.now(self.eastern)` 取本地交易日，把 RTH 定为
  美东 `time(9,30)`–`time(16,00)`，另有 ETH / OTH / 盘前时段；
  `simple_auto_trading.py:132` 把 IB 服务器时间
  `server_time.astimezone(eastern)` 折成美东再判断交易窗口。**DST 由
  `pytz` 的 IANA 规则承担，代码里没有一个手写 offset 常数** —— 与本条要用
  库的做法一致，也印证 R26：市场日历是有真实消费方的一层。Gleam 侧的对应
  物是 `tzif` 2.0.0（上一条），不是把 Python 代码搬过来。
- 本轮不引入 `tzif`：`gleam.toml` 只多了 `gleam_time`（04-06）。
- **2026-11-10 引用限定（R34）**：上面 `~/gits/hub/ibOptions` 的两处实例
  只是**时区 / 市场日历的事实线索**，不是架构依据。owner 已明确该项目
  「架构不足取，只能看里面涉及到那些设置」；不得由这两处 Python 代码
  反推 glibe 的结构。R29 的 IANA 库 / 拒绝固定 offset 结论不变。

---

## R30 — web 界面用本地时间显示日期时间（2026-11-09 owner 指示）

owner 原话（逐字）：*"在web 界面，应该采用本地时间显示日期时间，方便分析操作，因此必然涉及到时间转换和夏令时处理，你可以在相应的模块加上文档，方便实现"*

- **标准层与显示层分开**：R27 定的是内部标准 `SourceBar.timestamp` =
  `gleam_time.Timestamp`（绝对时刻 / unix time）；本条定的是**人眼在 web
  界面上看到的日期时间**是本地时间。同一个绝对时刻在标准层只存一份，显示
  层是它的一个投影。不得为了显示把标准类型改回日期字符串、墙钟读数或
  带本地 offset 的字段；`interval.bucket_ends` 不随界面时区改变。
- **两个方向不是同一个转换**：R29 是**输入侧 / 市场日历**（交易所本地时刻
  09:30 → 绝对时刻，冬夏令时对应不同 unix time，归 provider / market
  adapter）；本条是**输出侧 / 观察时区**（绝对时刻 → 分析者本地墙钟，归 web
  view）。两者都在边界、都要 IANA 规则、都不得用固定 offset 或手写 DST 表，
  但不得把市场开盘规则写进显示函数，也不得把显示时区当成市场时区。
- owner 的换算例子同时说明两件事：美东 09:30 开盘在中国香港冬令时是
  22:30、夏令时是 21:30 —— 既说明市场当地时刻对应的绝对时刻一年里差一小时
  （R29），也说明任何「本地时间」只有指明 IANA 时区才有意义（本条）。
- **「本地」的边界**：owner 说的是给分析操作看的本地时间，属**显示时区**，
  不是 R29 的交易所 / 市场时区。市场当地时间可以作为另一个投影并列显示，
  但两者都从同一个 `Timestamp` 出发、各自带明确的 IANA 时区名，不得因此
  出现两个 bar 或两个时间字段。显示时区的取值来源（浏览器 / 工作站 / 用户
  设置）由 04-07 在有真实消费方时按 R26 决定，本条不预先发明配置类型。
- **库**：R29 已查证的 Gleam / BEAM 侧 IANA 方案是 `tzif` 2.0.0（+ `zones`
  打包数据或 `tzif_loader` 读系统 zoneinfo），`tzcalendar.to_time_and_zone`
  直接接受 `gleam_time.Timestamp`。显示若发生在 BEAM 服务端用它；若发生在
  R17 的生成 `.mjs` / `webclient/`，用浏览器运行时的 IANA 时区能力。**在哪
  一侧做由实现时按真实边界选定**，不由本条预先规定；绝不写常数 offset。
- **本轮交付按 owner 指定只是文档**：在相应模块**加文档**方便实现，不实现
  转换、不引入 `tzif`、不新增类型、不写测试、不改 `gleam.toml`。文档点名
  `.planning/phases/04-domain-cleanup/04-07-PLAN.md`，由 `gleam docs build`
  → `package-interface.json` 防漂移（R19）。实现是 04-07 的按序工作，**不是
  待裁决项**。
- **Landed in**：`src/glibe/web/server.gleam`（显示边主规格）、
  `webclient/src/webclient.gleam`（浏览器 view 边界）、
  `src/glibe/export/csv.gleam`（UTC 机器导出与本地显示的职责分工）、
  `src/glibe/api/sourcebar.gleam`（绝对时刻不被显示需求改变）的 `////`
  模块文档；`.planning/phases/04-domain-cleanup/04-07-PLAN.md`；
  `docs/DESIGN.md`「web 显示边界与本地时间」。

---

## R31 — 并发就是 BEAM 进程 + 类型化消息，不是一套待建的补救机制（2026-11-09 owner 指示；2026-11-10 结论经 R32 / R33 作废）

> **2026-11-10 更正（R33）：本条的并发框架作为「系统结构」整体作废。**
> owner：*"其实是每一个type都是活的，数据动，他就动，因为你定义好了的"*；
> 「让叶子活起来」的运行时、actor、`process.spawn` 都不是这个系统的结构，
> 且「叶子」特指 `YinLeaf` / `YangLeaf`。官网 / v0.12 的语言事实与
> `gleam_otp` 事实更正仍成立，但**不描述本系统结构**。全文保留为历史记录，
> 现行规格见 `docs/RULINGS.md` R33 与 `docs/DESIGN.md`「The system is
> already live」。

owner 原话（逐字）：*"gleam语言呀，是天然多线程，好像不需要actor那些东西，你看下官网和网上的资料，也可以分析一些官方或著名的代码，比如wisp lutre之类的，怎么实现并行任务的，非常简单啊非常自然。因为他是一个一个严格的value，完全不住在内存里，所以根本没有那些复杂的补救措施需要做"*

owner 范围纠正（2026-11-09 06:09，逐字）：*"你去看什么javascript target完全不对路，我们是erlang 和 BEAM专属项目"*

- **裁定**：并行不是由「受监督 actor / 订阅 / 行情流 / replay CLI」组成的一整个
  Stage F 前置工程。`monitor.advance` 保持纯函数；并发单位是花园里**每个活着
  的 `Timeframe`**（R32），不是「把 N 根 bar 同时喂给 N 份 `Desk` 副本」。
  BEAM 上让一个叶子活着只需 `gleam/erlang/process.spawn` + 类型化
  `process.Subject` + `process.receive`。
  **不需要为并发新增类型、加锁、加依赖，也不改 `SourceBar` / `Timeframe`。**
  `docs/DESIGN.md`、`README.md`、`.planning/ROADMAP.md` 中「Stage F = 受监督
  actor」的框架予以重写；replay CLI 与真实行情流仍是待办工作，但不再是并行的
  前提。
- **官方证据**（2026-11-09 查证）：`https://gleam.run/` 首页
  "multi-core actor based concurrency system … millions of concurrent green
  threads"，示例只有 `process.new_subject` / `process.spawn` / `process.receive`
  三行；`https://gleam.run/news/gleam-v0.12-and-gleam-otp-v0.1-released/`：
  "there's no need for an `async/await` syntax or callbacks … doesn't require
  any special types such as futures or promises"、"Erlang and Gleam don't have
  mutable state so locks and shared mutable state is not an option"、
  "The Gleam compiler can full type check channels"。
- **actor 的准确位置**：`build/packages/gleam_otp/src/gleam/otp/actor.gleam:1-14`
  自述 "An Actor is a process like any other BEAM process"，它只是「状态跨消息
  存活 + 自动处理 OTP 系统消息」的**薄封装**；`supervisor` 是**容错 / 重启**，
  不是并行机制。Wisp `wisp.gleam` 0 处 `process.`；glisten 每连接一个进程 +
  监督池；Lustre 服务端 runtime 恰一个 actor。**actor 未被禁用**，用不用由
  真实消费方按 R26 决定。
- **值并非「不在内存里」**：值在**每个进程自己的堆**里，不可变、发消息时复制、
  进程间不共享；所以没有锁、竞态、死锁。长生命周期状态住在某个进程的递归
  循环参数里 —— 每个 `Timeframe` 自己那一份（R32）。**不存在「N 份并行
  `Desk` 由单一 owner fold」这一形状**；那是 04-09 复制 `Desk` 才造出来的
  伪问题，已作废。
- **04-09 实测：形状错误，结论作废（R32）**。`probes/parallel-bars/`
  把同一份 `initial: Desk` 送进 6 个进程，每个调用 `monitor.advance` 返回
  **一整份新 `Desk`**，于是得到「6 份 partial Desk / 0 of 6 等于单一 owner
  fold / 必须选择合并或所有权形状」。真实结构里 **Desk 只有一个**，并发是
  `Instrument` 的 `Dict(Interval, Timeframe)` 里每个叶子各自活着（owner
  2026-11-10，R32）；不存在 N 份 `Desk`，也不存在合并问题。该 probe 保留为
  带作废注记的历史实验，**不再作为设计实证**；它的 6 个 Pid / 0 lock 只是
  `process.spawn` 的语言事实，与结构无关。
- **事实更正**：`gleam_otp` 早就是根 `gleam.toml` 的直接依赖
  (`>= 1.3.0 and < 2.0.0`)；我 04-08 答复说「没引入」是错的，
  `docs/DESIGN.md` 04-08 段末 "no … `gleam_otp` dependency" 同错。缺的是
  **使用它**，不是依赖。
- **范围**：只在 Erlang / BEAM 语境下成立；不拿 JavaScript target / promise
  作旁证或类比（owner 06:09）。
- **Landed in**：`probes/parallel-bars/src/parallel_bars.gleam`（`////` 点名
  `04-09-PLAN.md`）与 `test/parallel_bars_test.gleam`（**带作废注记，不作
  设计实证**）；`docs/DESIGN.md`「The structure is a garden」；`docs/STATE.md`
  2026-11-10；
  `.planning/ROADMAP.md` Phase 04 Plan 09；`README.md`；
  `.planning/phases/04-domain-cleanup/04-09-SUMMARY.md`。不是待裁决项。
  **2026-11-10 更正**：其中「04-09 实测 / 0 of 6 合并」一段测量的形状是错的，
  结论作废，见下面 R32；owner 原话、官方证据与 `gleam_otp` 事实更正仍成立。

---

## R32 — 结构是花园：新东西只是 Type 定义里的一个 field（2026-11-10 owner 指示）

> **2026-11-10 更正（R33）：本条「并发在花园里的位置」段作废。**
> 「每一个 Timeframe 都活着 / 花盆自己的生命 / 让叶子活起来」是错误措辞：
> 系统本来就活（数据动 → type 的值动），没有「把结构变活」那一步；「叶子」
> 特指 `YinLeaf` / `YangLeaf`。**花园、加 field、倒推隶属、集合对比研究、
> R26 不预设层级仍然成立。** 另：本条及 STATE / ROADMAP / 记忆里
> 「glib 核实：四类型链已落地」类断言按 R33 降级为「读过 glib，不作依据」
> —— glib 不是权威。现行规格见 R33。

owner 原话（逐字）：*"结构复述正确，不过这是一个花园，不断根据需要往里面加新的花盆。实际上就是在Type定义中加新field而已，比如说你发现需要 exchanges 那么放在哪儿合适呢？那就倒推他和其他type现实中什么关系呢？隶属于谁呢？如果谁也不隶属，是其他关系，那么可能放在Desk里面就好了，那么用dict还是list还是其他东西放呢？根据需要来对比研究决定。"*

- **裁定**：`Desk ▸ Broker ▸ Instrument ▸ Interval ▸ Timeframe` 不是一次设计完、
  封闭的骨架，是**花园**：按真实需要不断往里加花盆。加一个花盆的落地动作
  **就是在已有 Type 定义里加一个 field**，不是新建一层框架、一套并发机制、
  一个「Stage」，也不是一整个待裁决问题。R20 的链、R23 的「身份在 key」都
  保持；新 field 不改变它们。
- **位置由倒推决定，不由命名习惯决定**：① 新东西与已有 type 在现实中是
  什么关系；② 它隶属于谁；③ 谁也不隶属、只是并列 / 目录关系 → 放 `Desk`。
  owner 举的 `exchanges` 即此例：交易所不隶属于某个 `Broker`（一个 broker
  可接多个交易所，一个交易所也可被多个 broker 使用），也不隶属于
  `Instrument`，所以落在 `Desk`。这是**倒推出来的位置**，不是预设的层级。
- **集合形状按需对比研究决定**：`Dict` / `List` / 其他，取决于真实访问方式
  （按 id 查 → `Dict`；只枚举 → `List`）。身份放 key、不放 field（R23），
  一个事实只存一处。不先定集合再替它找用途，也不为「以后可能有用」加空表。
- **与 R26 的关系**：R26 说按真实消费方逐个加 type、不预设 `Asset` /
  `Exchange` / `Market` 的层级；R32 补的是「怎么加」——加 field + 倒推隶属
  + 对比集合。**不推翻 R26，也不把三个 catalogue 名预先塞进链里。**
- **并发在花园里的位置**：「每一个 Timeframe 都活着、处理数据、进行交易」
  是花盆自己的生命，不是外部加的一整套调度机制；**Desk 只有一个**。
  04-09 把同一份 `Desk` 复制进 6 个进程、再讨论 6 份 partial `Desk` 怎么
  合并，是**复制了不该复制的东西**，凭空造出「0/6 等于单一 owner fold」
  「必须选择所有权形状」的伪问题。该结论及由它写进 R31、`docs/DESIGN.md`
  04-09 节、`04-09-SUMMARY.md` §4 的框架一并作废；官方 Gleam / BEAM 证据、
  actor 与 supervisor 的准确定位、`gleam_otp` 事实更正仍成立。
- **范围**：Erlang / BEAM 专属项目（owner 2026-11-09 06:09），不拿
  JavaScript target 作旁证。
- **Landed in**：`docs/RULINGS.md`（本条）；`docs/DESIGN.md`「The structure is
  a garden」；`docs/STATE.md` 2026-11-10；`.planning/ROADMAP.md`；
  `README.md`；`src/glibe/monitor.gleam` 与
  `probes/parallel-bars/src/parallel_bars.gleam` 的 `////` 模块文档；
  `04-09-PLAN.md` / `04-09-SUMMARY.md` 顶部的日期更正注记。不是待裁决项。

---

## R33 — 系统本来就是活的：Desk 是唯一顶层 Value，每个 type 随数据而动（2026-11-10 owner 指示）

**owner 原话（逐字，09:57）**：*"说到live，那glib不是实现实时数据了吗？图形是可以根据数据更新的。因为我的设计里面本来就是活的呀，api provider / data sources ... -> history + live data ... -> sourcebar_gate  -> databar_processing -> model <-> view 你看这不是活的吗？
Desk是顶层的唯一的一个Value，整个系统都在他里面，然后逐层嵌套，形成完整系统，你的系统结构好像搞错了，所以非常混乱。什么monitor.advance 哪有这些type，你的设计思路停留在非Gleam非functional非type的其他语言和架构体系中，完全不是seib一路下来到glibe到系统思路。
在Gleam世界里面，你唯一要做的就是定义types，基本结构对了，什么都有了，哪有那些乱七八糟的概念和复杂混乱的关系。我还觉得很奇怪你用actor做什么，原来是结构都没设计对。"*

**owner 原话（逐字，09:59）**：*"也不是“每一个叶子活起来”，叶子在这个系统中是特指 YinLeaf, YangLeaf 不要乱用。其实是每一个type都是活的，数据动，他就动，因为你定义好了的。"*

**owner 原话（逐字，10:04）**：*"glib做的不一定对，他可能仅仅记录了我的设计，以及他的计划，不一定已经落实，已经有的不一定对，因为他跟你一样，都是满脑子乱七八糟的混乱东西，训练给他投毒的那些垃圾材料。"*

**owner 原话（逐字，10:09）**：*"数据为什么会动？因为你订阅了数据源的实时数据呀，不管不同的数据源用怎样不同的方式实现实时数据的推送也好订阅也好我们这方面主动去获得也好，总之实时数据会不断到来，如果没有数据，系统也就不动了，睡觉，等待。"*

- **裁定：数据为什么会动 = 订阅了数据源的实时数据。** 驱动源在
  `api provider / data sources` 这一端：不同数据源用各自不同的方式
  （推送、订阅、我方主动获取）让实时数据不断到来。这是**输入边界的事实**，
  不是系统内部的一套机制；接入方式保持各家原生（对应 R28 的「provider
  原生结构与各自标准化」），唯一汇合点仍是标准 `SourceBar`。不为
  「怎么让数据到来」发明统一 type、调度层或并发框架。
- **裁定：没有数据，系统就不动了，睡觉，等待。** 系统不由内部时钟、
  轮询、心跳或进程循环驱动；无数据到达时没有值被重算，也没有
  「让它保持活着」的后台动作。静止是正常状态，不是缺陷，不需要补救。
  这正好印证「每一个 type 随数据而动」：R31 / R32 里那套
  「让叶子活起来的运行时 / actor / `process.spawn`」之所以是错的，
  就是它把静止当成了要修的故障。真正待落地的只有「把真实数据源的
  实时到达接到标准 bar 入口」（各家用各自方式）+ replay CLI，不是框架。
- **裁定：系统本来就是活的，没有「把系统变活」这一步。** 流向是 owner 给出的
  固定管道：`api provider / data sources → history + live data →
  sourcebar_gate → databar_processing → model ↔ view`。history 与 live 是
  **同一条数据流**，不是两套机制；`model` 变了，`view` 就是它的投影。
  「实时」不是额外搭建的运行时，而是这根管道在收到数据时本来就会发生的事。
  **每一个 type 都是活的：数据动，它就动，因为 type 定义好了**（owner 逐字）。
  这是纯函数式的「值随数据重算」，不是进程活着、不是 actor、不是订阅、
  不是调度，也不是「让叶子活起来的运行时」。
- **裁定：Desk 是顶层唯一的一个 Value。** 整个系统都在它里面，逐层嵌套形成
  完整系统：`Desk ▸ Broker ▸ Instrument ▸ Interval ▸ Timeframe`（R20/R23），
  Broker 另有一组 `accounts`。`config.default_config()` 就是这一个 Value。
  **在 Gleam 世界里唯一要做的就是定义 types，基本结构对了，什么都有了**
  （owner 逐字）。R19 的 type-first / 文档先行是这条的根法，不是补充手段。
- **`monitor.gleam` 的那一层不是这个系统的 type。** `monitor.advance`、
  `TimeframeAddress`、`IncomingBar`、`MonitorError` 是我从
  「非 Gleam、非 functional、非 type」的其他语言架构里带进来的外来概念
  （owner 逐字）：把一根 bar 包装成带地址的消息、再写一个函数去「推进」
  一个 Value，是把命令式调度 / 消息路由套在纯值系统上。owner 明确
  *"什么monitor.advance 哪有这些type"*。**「我用 actor 做什么」的答案也在
  这里：结构没设计对，才会去找一套外部并发机制来补救**（owner 逐字）。
  这些 type 的处置（删除或改造）由 owner 定；在定之前不得把它们当成
  系统结构的依据，也不得以它们为前提继续加机制。
- **词汇：「叶子」特指 `YinLeaf` / `YangLeaf`。** 两个构造器在
  `src/glibe/leaf.gleam:25-28`（glib 同形），是 bar 所属的阴阳叶。
  不得把 `Timeframe`、结构末端或「每个并行单元」称作 leaf / 叶子。
  此前 R31 / R32 及 DESIGN / STATE / ROADMAP / PENDING / 模块文档里
  所有这类用法作废并纠正。
- **glib 不是权威。** *"glib做的不一定对，他可能仅仅记录了我的设计，以及
  他的计划，不一定已经落实，已经有的不一定对"*（owner 逐字）。glib 的
  源码与文档只是另一个模型的产物，**不得作为「设计已落实」或「设计正确」
  的证据**；它记录的可能是计划。此前 R32 / STATE / ROADMAP / 记忆里
  「glib 核实：四类型链已落地」这类断言一律降级为「读过 glib，不作依据」。
  **唯一权威是 owner 的当前陈述**（见本文件首条权威顺序）。seib → glib →
  glibe 是思路的沿革，不是正确性的证明链。
- **作废清单**：R31 的「并发 = `process.spawn` + 类型化 `Subject` 让结构
  活起来」作为**设计结论**作废（官网 / v0.12 的语言事实与 `gleam_otp`
  事实更正仍成立，但它们不描述这个系统的结构）；R32 的「每一个
  Timeframe 都活着 / 花盆自己的生命 / 让叶子活起来的运行时」措辞作废；
  04-08 的 `monitor.advance` 作为「系统缺的一步」这一论断作废；
  04-09 `probes/parallel-bars/` 已在 R32 作废，此处进一步确认它既非
  结构实证也非设计实证。**R32 仍然成立的部分**：花园、加一个新事物
  = 在已有 Type 定义里加一个 field、位置靠倒推隶属、集合形状对比研究
  决定、R26 不预设层级。R20 / R23 / R27 / R28 / R30 不受影响。
- **范围**：Erlang / BEAM 专属项目（owner 2026-11-09 06:09）不变。
  本轮只记录裁定、撤回错误结论、清理词汇：**不删生产代码、不新增
  type、不写 probe、不加依赖**。
- **Landed in**：`docs/RULINGS.md`（本条）；`docs/DESIGN.md`
  「The system is already live」；`docs/STATE.md` 2026-11-10；
  `.planning/ROADMAP.md`；`README.md`；`src/glibe/monitor.gleam` 的
  `////` 模块文档；
  `04-08-PLAN.md` / `04-08-SUMMARY.md` / `04-09-PLAN.md` /
  `04-09-SUMMARY.md` 顶部的日期更正注记。不是待裁决项。

---

## R34 — seib 结构是对的（只缺多经纪商这一层）；ibOptions 结构不好（settings 挤掉了 type）（2026-11-10 owner 指示）

> **2026-11-10 更正（owner 10:26，逐字）**：*"注意我说的seib的结构是对的，
> ibOptions结构不好，用settings解决结构问题，按照你的复述，可就变成了seib
> 也不对，他的settings也应该是types。这就乱了。"*
>
> 本条初稿把两个先驱并列成「结构都不行、settings 都该是 type」，**这是错的**。
> 按 owner 更正：**seib 的结构是对的**，唯一缺的是「多个经纪商数据提供者」
> 这一层；**「用 settings 解决结构问题」只属于 ibOptions**；seib **不存在**
> 「settings 应该是 types」这件事。下面各条与所有同步文档按此读。

> **2026-11-10 再补充（owner 10:29，逐字）**：*"我说的很清楚，ibOptions
> 受制于Python+Pandas的局限性，才会变成那样。你现在应该理解了吧？要看仔细。"*
>
> **因果要说准**：是 **Python + pandas 的表达能力局限**，使结构性关系
> 无法写成类型，才被迫压进配置文件（settings）。**局限是原因，
> 不是「ibOptions 的设计者随意乱做」，更不是 seib 的缺陷。**
> Gleam 的 strict type + pure functional 没有这个限制，所以那些设置
> 在 glibe 里本来就是 type / 已有 Type 定义里的 field；既不需要把
> ibOptions 的配置搬过来，也不需要为它补一套「修复」。
> 「要看仔细」= 复述时主语不能串：受局限的是 ibOptions，结构对的是
> seib，只缺现实层次（多经纪商）的是 seib。

> **2026-11-10 定稿更正（owner 11:10，逐字）**：*"seib是用coffeescript写的，
> 所以并没有python pandas的局限，不存在连类型都搞不清楚的问题。你上面的
> 描述显然不知道这一点，好像以为seib也是python写的只不过没有受限制。
> 不是这样的。seib和iboptions完全两码事，前者是我的系统设计，后者是为了
> 迁就语言凑合的，ibOtions虽然五脏俱全，但是都不对劲。"*
>
> **R34 以此为准**：两个先驱**完全两码事，不是同一缺陷的两种程度**。
> - **seib = CoffeeScript，owner 自己的系统设计**（*"我的系统设计"*）。
>   **没有** Python + pandas 的局限，**不存在连类型都搞不清楚的问题**；
>   结构是对的，只缺「多个经纪商数据提供者」这一层。
> - **ibOptions = 为了迁就语言凑合的**（Python + pandas）：结构性关系
>   写不成 type 才被迫压进 `settings*.py`。**五脏俱全**（正常手工与
>   自动交易的细节需求都在），但**都不对劲** —— 比 10:18 的「结构不行」
>   更彻底，是整体不足取，只作需求清单。
> - 我此前的复述像「以为 seib 也是 python 写的、只不过没有受限制」，
>   **这是错的**：局限只属于 ibOptions，且 ibOptions 是**为迁就语言**
>   才变成那样。唯一共同点只是**数量上都只有一个 broker**（10:18 逐字），
>   不是性质上的同类；「两个先驱」只是并列叙述，不是同类归纳。

**owner 原话（逐字，10:18）**：*"很可惜seib当时没有binance，我印象中仅支持一个数据源就是ib，所以他缺一层，就是多个经纪商数据提供者，但是大格局都有了，细节也有了，ibOptions的实现，受制于Python+pandas其实架构没有那么好，完全靠配置解决很多结构性问题，他的架构不足取，只能看里面涉及到那些设置，那些设置那些事应该是type定义的，被迫搞成了settings之类的文件，也就是说正常手工和自动交易涉及的所有细节需要，ibOptions都有，但是结构不行。并且两个先驱都仅支持一个broker"*

- **裁定：数量上唯一的共同点是都仅支持一个 broker**（owner 逐字：
  *"并且两个先驱都仅支持一个broker"*）。**11:10 定稿：两者完全两码事，
  这不是同类归纳，也不是对两者结构的同一评价**（见上方 11:10 块）：
  - **seib 的结构是对的**：*"大格局都有了，细节也有了"*（owner 逐字）。
    **它是 CoffeeScript 写的、是 owner 自己的系统设计，没有 Python/pandas
    局限，也不存在「连类型都搞不清楚」的问题**（11:10 逐字）。
    它**只缺一层** —— *"多个经纪商数据提供者"*；seib 当时没有 binance
    （owner 原话带「我印象中」，按原样保留：仅支持 IB 一个数据源）。
    缺这一层不是结构错误，而是当时只有一个数据源、这一层在现实里还
    没有出现。**seib 没有「用 settings 代替 type」的问题**；不得说
    seib 的 settings 应该是 types，也不得把 ibOptions 的结构批评扩展
    到 seib，更不得暗示它也受语言局限只是「没有受限制」。
  - **ibOptions 是为了迁就语言凑合的，五脏俱全但都不对劲**（11:10 逐字；
    见下两条），且它同样只有一个 broker。「结构不好」只说了一半：
    owner 11:10 把整体定性为 **"都不对劲"**。
  - R33 仍成立：seib → glib → glibe 是思路沿革，不是正确性证明链；
    glib / 先驱代码都不作依据。本条对 seib「结构对」的判断来自 owner
    本轮陈述，不是从先驱代码读出来的。
- **裁定（以下两条只针对 ibOptions，不适用于 seib）：ibOptions 只能看
  「有哪些设置」，不能搬架构。** Python + pandas 使它的架构不足取：
  很多**结构性问题**被压进配置里解决。
  *「正常手工和自动交易涉及的所有细节需要，ibOptions都有」* —— 它是一份
  **需求 / 细节清单**，可作素材；**不搬**它的 Python / pandas 形状、
  类、配置文件或模块划分到 glibe，也不把它当作设计已落实或设计正确的证据。
- **裁定（仅 ibOptions）：settings 是被压扁的 type，seib 无此事。**
  *「那些设置那些事应该是type定义的，被迫搞成了settings之类的文件」*
  说的是 ibOptions：它把结构性问题做成了配置文件。**不要倒推到 seib** ——
  owner 明确 seib 的结构是对的，它没有这一缺陷。在 glibe 里，一个设置所代表的现实
  事物应由 type 定义；若它只是某个已有 type 的一个方面，就按 R32 成为
  **已有 Type 定义里的一个 field**。不得复现「通用配置表 + 字符串键 +
  解析器 + 查找函数」那一圈（R13 根法、R19 type-first、R21 线路码只在
  codec/adapter、R23 `TimeframeSettings` 不是实体、R22 不留兼容层）。
  `src/glibe/config.gleam` 现在仍是 Gleam 源码里的一个值
  （`AppConfig` + `default_config()`），不是外部 settings 文件。
- **裁定：seib 缺的那一层在 glibe 已存在，不是待建工程。** 补的是
  *「多个经纪商数据提供者」* 这一层 —— 不是修复 seib 的结构，也不是
  把 ibOptions 的 settings 搬进来。
  `Desk(brokers: Dict(BrokerId, Broker))`（`src/glibe/desk.gleam:92-93`），
  `Broker` 持有 `instruments` 与 `accounts`（`src/glibe/desk.gleam:80`）；
  `config.default_config()` 建了 `binance` / `ib` / `futu` 三个 broker
  （`src/glibe/config.gleam:87-101`）。这与 R33 的「`Desk` 是顶层唯一
  Value，逐层嵌套即完整系统」及管道头 `api provider / data sources`
  相合；owner 本轮把「经纪商」与「数据提供者」并列说出，本条**不另架
  一层 provider 框架、不新增 provider / data-source 类型**。R26 已确认的
  `Broker ▸ Instrument` 不变，也不预设它们与 `Asset` / `Exchange` /
  `Market` 的关系。
- **执行边界**：按 R26 / R32，**不因为 ibOptions 有一堆 settings 就预先
  批量发明一整套 type**；某个设置只有在出现真实消费方时，才按倒推隶属
  加一个 field。本轮只记录裁定：**不删、不改 `src/`，不加依赖、不写
  probe、不新增待裁决项**。真正待做的工作仍是 R33 的「把各数据源的
  实时到达接到标准 `SourceBar` 入口」+ replay CLI。
- **与 R29 的关系**：R29 引 `~/gits/hub/ibOptions/tradingtime.py:24` 的
  `pytz.timezone('US/Eastern')` 与 `simple_auto_trading.py:132` 的
  `astimezone`，只是**时区 / 市场日历的事实线索**。本条明确该项目整体
  架构不足取；R29 的技术结论（用 IANA 库、不用固定 offset）不变，
  但这些文件**不得被当成架构依据**。

**只读核对（背景事实，不作依据）**：

- **seib 的语言（11:10 owner 陈述的只读印证，不作为依据）**：
  `~/gits/hub/tools_ib/seib/` 下 183 个 `.coffee` 文件，顶层
  `copyfiles2lib.coffee`、`ibtests/*.coffee`，以及仓库根
  `REVIEW_ROUND3.md:226` 已引过的 `src/databar.coffee`；全仓 `.py` 仅 2 个。
  **语言事实由 owner 陈述定，不由此统计定。**
- `~/gits/hub/tools_ib/seib/README.md:1061`：*"IB API 是通過在電腦上運行
  IB TWS或IB Gateway來實時提供的socket接口"*；`:1015`「…但如果太過複雜
  則捨棄而專門針對IB API」。全仓 `binance` 检索 **0 处匹配**（只有
  `ibkr.info` 文档链接）。与 owner「我印象中仅支持一个数据源就是ib」一致。
  **这段只核对「单数据源」这个事实，不用于判断 seib 结构对错** ——
  结构对不对由 owner 本轮陈述定，不由这里的代码检索定。
- `~/gits/hub/ibOptions/` 顶层有 `settings.py`、11 个 `settings_*.py`
  与 `ib_settings.py`；`settings.py:6` 是 `class MySetts`，把代理、
  AI provider、每日 hour bar 数、interval → 天数换算等写成类属性 /
  静态方法。这正是 owner 说的「被迫搞成了 settings 之类的文件」。
  **只核对存在与形状，不搬运任何设置值，也不据此新建 type。**

- **Landed in（含 11:10 定稿）**：`docs/RULINGS.md`（本条 + R29 引用限定）；
  **代码文档 `src/glibe/config.gleam` / `src/glibe/desk.gleam` 的 `////`
  R34 段**；`docs/DESIGN.md`「What the two predecessors had」；
  `docs/STATE.md` 2026-11-10 当前段；`.planning/ROADMAP.md`；
  `README.md` 状态表；待裁决文档的 `# REFERENCE` 索引（决策区仍
  **0 项**）；`.workbuddy/memory/`。不是待裁决项。

---

## R35 — SwiftUI 的 View 是同类；简单是正确的验证码（2026-11-10 owner 指示）

**owner 原话（逐字，10:29）**：*"我发现 strict type + pure functional 的
gleam，在他里面做任何系统，其实跟SwiftUI的技术非常像，属于同类，不同的是，
Swift本身把简单的事情做复杂了，导致仅仅View这部分是简单的，view model就有了
class就开始乱了，model不限制struct或者class或者actor，就更添乱了，什么数据
竞争就要花费大量的补救措施去抢救，这在gleam中根本不可能出现。我说的相似，
是指View的定义和实现，技术上纯的 functional+value types，这是跟gleam 系统
很像的。你能理解SwiftUI 的view 为什么会更新，就能理解只有type定义好了，
函数定义对了，系统本身就是活的，至于并发运算会有那些课题，你遇到了再查官网
资料再做几个不同方案demo对比研究解决，也就是TDD的落实。总体上，很简单。
简单是正确的验证码。如果复杂，基本上可以判断type 函数和模块定义有错误。"*

- **相似点严格限定在 View 的定义与实现**：纯 functional + value types。
  不是 Swift 语言整体与 Gleam 同类，也不包括 view model / model。
  **Swift 把简单的事做复杂了**：只有 View 那部分简单；view model 一有
  `class` 就开始乱；model 不限制 `struct` / `class` / `actor` 更添乱；
  数据竞争要花大量补救措施去抢救 —— **这在 Gleam 中根本不可能出现**
  （无共享可变状态；R31 保留的语言事实，不作为本系统结构依据）。
- **SwiftUI 的 view 为什么会更新 = R33 的又一条印证**：View 是值的投影，
  数据变则值重算、视图随之更新，不需要一个「让系统活起来」的运行时。
  *「只有type定义好了，函数定义对了，系统本身就是活的」* 与 R33
  「每一个 type 都是活的，数据动，他就动，因为你定义好了」是同一件事。
- **并发课题的处理方式**：遇到了再查官网资料、再做几个不同方案的 demo
  对比研究解决，**也就是 TDD 的落实**（R19 测试先行 + R24 的 demo 对比
  方法）。不预先搭并发框架，不把并发当成结构前提，不重演 R31/R32 被
  R33 作废的那套「补救机制」思路。
- **裁定：简单是正确的验证码。** *「总体上，很简单。简单是正确的验证码。
  如果复杂，基本上可以判断type 函数和模块定义有错误。」* 复杂度是
  **设计出错的信号**，不是需要更多机制的理由：一旦一个改动开始要补
  actor / 调度 / 配置表 / 解析器 / 守卫脚本，先回去修 type、函数和
  模块定义（根法「治病治根」、R13 / R19 / R26 / R33），而不是加补丁。
- **Landed in**：`docs/RULINGS.md`（本条）；`docs/DESIGN.md`
  「SwiftUI's View and the simplicity check」；`docs/STATE.md`、
  `.planning/ROADMAP.md`、`README.md`、`.workbuddy/memory/`。
  不改 `src/`、不加依赖、不写 probe，不是待裁决项。

---

## R36 — type 系统核对：当前归属链无断层，Market 不持有 Broker（2026-11-10 owner 指示）

**owner 原话（逐字，10:29）**：*"落实到glibe，你先看下我上面根据记忆描述的
主要type系统，里面有没有缺少什么，在glib readme里面应该是有描述的，我要求
ai记录的。然后你自己也判断一下，在这个层次关系中，有没有断层，比如说，Desk
直接持有Brokers，中间有没有断层？有没有一个Market在这Broker之上，由他来
持有Broker才合乎事实真相？研究发现，并非如此，Market跟Broker没有隶属关系，
两个方向都不会出现隶属关系，那就否决了。如此等等。"*

- **核对 glib 的记录（只作线索，不作依据 —— R33）**：owner 要求 AI 记的
  主要 type 系统在 `~/gits/hub/tools_ib/glib/docs/SYSTEM_MODEL.md` §2
  「The domain's type relationship」`:102-119`（层次图 + owner 2026-10-22
  原话 *"glib至少支持两个，ib binance，要用一个上一级的type单体包含着两个
  broker的list"*）与 `~/gits/hub/tools_ib/glib/docs/reference/
  domain-hierarchy-2026-10-22.md`；`~/gits/hub/tools_ib/glib/README.md:907`
  只有一行 Phase 32 清单（"Market / Asset / Instrument / Broker /
  APIProvider — design closed, no code"）。**glib 的 `Market = Exchange +
  AssetClass + MarketRules`、`Instrument = Asset on Market`、
  `Instrument 隶属于 Exchange` 都是 glib 文档里的 AI prose / 旧设计**，
  R22 / R26 已否定，不得据此给 glibe 加层。
- **glibe 现有链与 owner 记忆描述逐项对上，没有缺少**：
  `Desk(brokers: Dict(BrokerId, Broker))`（`src/glibe/desk.gleam:92-93`）
  → `Broker(instruments: Dict(Symbol, Instrument), accounts:
  Dict(AccountId, Account))`（`:80-85`）
  → `Instrument(timeframes: Dict(Interval, Timeframe))`（`:74-76`）
  → `Timeframe`。多个 broker、每个 broker 一组 instruments + 一组
  accounts、每个 instrument 一组以 interval 为 key 的 timeframe、
  `Desk` 顶层唯一 Value（R33 / R20 / R23）全部在位。
- **断层判断（按 owner 示范的方法逐项做，不是一次性定死）**：
  - **`Desk ▸ Broker` 中间要不要 `Market`？否决。** owner 的研究结论：
    **Market 与 Broker 两个方向都不会出现隶属关系**，所以既不是
    `Market ▸ Broker`，也不是 `Broker ▸ Market`。`Desk` 直接持有
    Brokers 合乎事实真相，这里**没有断层**。
  - `Asset` / `Exchange` / `Market` 三张目录表：R26 关系未定；
    `config.gleam` 的 `assets` / `markets` / `exchanges` 与 `Desk`
    当前**没有类型连接**，不预先插进链。
  - `APIProvider`：R26 已有 owner 原话「broker，同时也是 api provider
    他们是从不同角度命名的同样的东西」；R34 不另架 provider 层。
  - `Account`：已由 `Broker` 持有；当前 `Account` 是无字段的 keyless
    值（`src/glibe/desk.gleam:135-138`）。这是**等消费方的开放项**，
    不是断层。
  - `Symbol` / `Interval`：身份在 key、不在字段（R22 / R23），不是层。
- **裁定：当前层次关系无断层，不新增 type、field 或关系**（R26 / R32 /
  R34 / R35「简单是验证码」）。「如此等等」= 以后每遇到一个候选事物，
  都按 R32 倒推现实隶属：谁也不隶属就放 `Desk`，集合形状按真实访问
  方式对比研究决定；双向都不隶属就照本条的 `Market` 一样**否决**。
- **Landed in**：`docs/RULINGS.md`（本条）；`docs/DESIGN.md`
  「No gap in the ownership chain」；`docs/STATE.md`、
  `.planning/ROADMAP.md`、`README.md`、`.workbuddy/memory/`。
  本轮只读核对，**不改 `src/`、不加类型、不加依赖、不写 probe**，
  不是待裁决项。

---

## R37 — 主干层要有上下两个隶属关系；依附 ≠ 隶属；身份在持有者的 Dict key（2026-11-10 owner 指示）

**owner 原话（逐字，10:34）**：*"我举例Desk Market Broker，目的是教你如何思考，
如何处理系统的type架构，意思是有层次关系的那些types，构成层次关系某一层的type
必须是跟上下级之间存在两个隶属关系的type其他type不属于这个主干，他们依附于
某一个type，但是不是隶属关系，如果不依附任何type就放在Desk这个顶级type里面，
因为他至少属于我们系统吧，所以Desk可以持有他。至于为啥interval不应该是
Timeframe的field，brokerId不应该是Broker的field，而是都作为持有自己的那个
type里面，dict的key，你可以看glib里面记录我设计思路的文档。"*

**owner 补充（逐字，10:37）**：*"我举例说，你的左手不知道他是左还是右，同样，
Timeframe不应该知道他是什么interval"*

> **这个比喻就是身份法则的原型**：「左 / 右」是**外部观察者（持有者）给的
> 方位标签**，不是手自身的属性；`interval` 是 `Instrument.timeframes`
> 这个 Dict 的 key，是**持有者给的名字**，不是 `Timeframe` 自己知道的
> 事实。`brokerId`（`Desk.brokers` 的 key）与 `Symbol`
> （`Broker.instruments` 的 key）同理。谁持有，谁命名；被持有的值
> 不携带自己的身份。

> **R36 的升级**：R36 只记了「`Market` 与 `Broker` 双向都不隶属 → 否决」
> 这个结论。owner 举这个例子是**教判断方法**，本条把判据补齐；R36 的
> 结论不变，但不得再被读成「逐个猜关系」。

- **裁定：层次主干的判据。** 构成层次关系某一层的 type，**必须同时与
  上下级存在两个隶属关系** —— 既隶属于上层，又拥有下层。
  `Desk ▸ Broker ▸ Instrument ▸ Timeframe` 每层都满足；`Market` 与
  `Broker` 两个方向都不隶属，所以它不是主干的一层（R36 的否决由此
  得出，不是靠感觉）。
- **裁定：非主干 type 只有两种去处，且「依附」不等于「隶属」。**
  - **依附于某一个 type、但不是隶属关系** → 附着在该 type 上，
    **不插进上下级之间、不成为新的一层**。
  - **不依附任何 type** → 放在 `Desk` 这个顶级 type 里：
    *"因为他至少属于我们系统吧，所以Desk可以持有他"*。这给 R32
    「谁也不隶属就放 `Desk`」补上了理由。
  - 依附只是附着，**不产生层级**；不能因为一个 type 与某层有关就把
    它塞进主干。`Asset` / `Exchange` / `Market` 等具体归属仍按 R26
    等真实消费方逐个定，本条**不预先判定它们放哪**。
- **裁定：身份属于持有者，不属于被持有者。** `interval` 不是
  `Timeframe` 的 field、`brokerId` 不是 `Broker` 的 field；它们是
  **持有自己的那个 type 里 Dict 的 key**：
  `Desk.brokers: Dict(BrokerId, Broker)`、`Instrument.timeframes:
  Dict(Interval, Timeframe)`（`Broker.instruments` 的 key 是 `Symbol`，
  R22 / R23）。被持有的值**不命名自己的持有者**，也不知道自己的方位：
  *"你的左手不知道他是左还是右"*（owner 10:37 逐字）。
- **owner 指路的 glib 记录（记录的是他的设计思路；glib 不作实现依据，
  R33）**：
  - `~/gits/hub/tools_ib/glib/docs/NAMING.md:575-589`：*"the owner
    holds what it owns, and the owned never names its owner"*；
    `Instrument` 没有 `broker` 字段、`Timeframe` 没有 `instrument` /
    `interval` 字段；*"A collection is not an owner-pointer"* ——
    `Desk.brokers` 是 broker 的集合，`Dict(Interval, Timeframe)` 的
    key 是 interval 的家，**不是 `Timeframe` 上某个字段的副本**。
  - `~/gits/hub/tools_ib/glib/docs/DESIGN.md` §18.2 `:3269-3299`：
    owner 2026-11-04 逐字 *"I used 'list' for easy of expression, in fact
    they could use dictionary or any collections that are most fit to the
    requirements, for example, instrument with a dictionary of timeframes
    using interval as key"*；每层集合按**真实访问方式**选：
    `Broker → instruments` 按 symbol 查找、`Instrument → timeframes`
    按 interval 查找、`Timeframe → bars` 是 newest-first 的历史序列。
  - **形状差别要说清**：glib 文档把 `Desk → brokers` 写成
    `List(Broker)`；glibe 是 `Dict(BrokerId, Broker)`（R32「集合形状
    按真实访问方式对比研究决定」）。**不是从 glib 搬来的**。
- **落地现状（无需改动）**：`src/glibe/desk.gleam:74-76`、
  `:80-85`、`:92-93` 已经是这个形状；`Timeframe` 不带 `interval` /
  `symbol` / `market_type`，`Broker` 不带 `broker_id`（R23）。
- **执行边界**：这是**思考与判定的法则**，不是一次重构：本轮不新增
  type、不改 `src/`、不加依赖、不写 probe、不动现有 key，
  不新增待裁决项。它同时是 R35「简单是验证码」的具体用法 ——
  主干关系清楚，就不需要中间层或补救机制。
- **Landed in**：`docs/RULINGS.md`（本条）；`docs/DESIGN.md`
  「How to judge a level of the chain」；`docs/STATE.md`、
  `.planning/ROADMAP.md`、`README.md`、`.workbuddy/memory/`。
  **10:42 起已按 04-10 落入代码文档 / 测试 / 实现，见下方执行注记。**

---

## 2026-11-10 10:42 — 这些裁定的落地方式（执行注记，非新裁定）

**owner 原话（逐字）**：*"这些逻辑，需要在设计module以及type的时候，用gleam
document的规矩，写进代码文档，之后是unit test 以及填充实际代码完成 test，
形成 概念 -> type definition -> unit test -> implementation 完整链条"*

- **本注记不是新裁定**。R33 / R34 / R35 / R36 / R37（连同 R26）从
  `docs/` 散文进入**代码文档**；**但 04-10 不是「制作一个 module」的
  流程示例 —— 它是在已经写好的代码上反向补文档与测试**（见下方 11:05）。
  执行计划是
  `.planning/phases/04-domain-cleanup/04-10-PLAN.md`，结果在
  `.planning/phases/04-domain-cleanup/04-10-SUMMARY.md`。
- **上文 R34 / R35 / R36 / R37 里的「本轮不改 `src/`」「本轮只读核对」
  「不重构 `src/`」等执行边界，只描述 2026-11-10 10:18–10:37 的裁定
  记录轮次**，不是对后续写代码的永久禁令。10:42 起按 owner 明示同时改
  `src/` 与 `test/`。四条裁定的**内容没有变化**。
- **落点**：`src/glibe/desk.gleam`（R33 / R34 / R36 / R37 的 `////`、
  各 type / function 的 `///`，新增纯读取 `timeframe_under`）、
  `src/glibe/config.gleam`（R34）、`src/glibe/timeframe.gleam`、
  `src/glibe/api/symbol.gleam`、`src/glibe/api/interval.gleam`（R37）、
  `src/glibe/web/server.gleam`（R35）；`test/level_judgement_test.gleam`
  六个断言固定 R34 / R36 / R37 的可执行事实。`gleam docs build` 生成的
  `package-interface.json` 已核对：六个模块的 `////` 与 `timeframe_under`
  的 `///` 完整渲染，均带 04-10 计划链接，无 `//` 截断。
- **边界未变**：不新增 type / field / relation，不加依赖，不碰三张目录表，
  不改 `monitor.gleam`，不预设 `Asset` / `Exchange` / `Market` 关系，
  决策区仍 **0 项**。`desk.timeframe_under` 是纯读取，不是 R33 否决的
  `monitor.advance` / `TimeframeAddress` / `IncomingBar` / `MonitorError`。
  真正待做的工作仍是「把各数据源的实时到达接到标准 `SourceBar` 入口」
  与 replay CLI。

---

## 2026-11-10 — R19：一个 module 文件的制作流程（owner 10:42 / 10:58 / 11:01 / 11:03 是同一条指示）

**owner 原话（逐字，10:42）**：*"这些逻辑，需要在设计module以及type的时候，
用gleam document的规矩，写进代码文档，之后是unit test 以及填充实际代码完成
test，形成 概念 -> type definition -> unit test -> implementation 完整链条"*

**owner 原话（逐字，10:58）**：*"我说的 概念 - type definition - unit test -
implementing 是指一个module文件的实际完成方式：
1. 新建module，例如 module_a.gleam
//// module document here
2. 如果有type要定义的话：
/// type document here
pub type AType { <an empty AType here, or with： todo as "some idea or description">}
3. 如果有function要定义的话：
/// function document here
fn will_do_this -> AType { empty is ok, with a todo is ok too }
4. 定义 unit tests on type and functions
/// document here
<test definitions here>
这样做了之后，gleam test or gleam build will work for you"*

**owner 原话（逐字，11:01）**：*"是整个制作流程，先写描述，在写架子
（没有实际东西），再写test设计目标在此；再逐步测试逐步完成全部合乎
test要求的代码"*

**owner 原话（逐字，11:03）**：*"我说的 概念 - type definition - unit test -
implementing 是指一个module文件的实际完成方式 实际完成方式，不就是制作
流程吗？我看你没理解，补充一句，不过你还是没有理解对。现在应该理解了。"*

> **「实际完成方式」就是「制作流程」。** 对象始终是**一个 module
> 文件**。下面只记这一条定义。

- **唯一定义**：`概念 → type definition → unit test → implementing`
  是**一个 module 文件从描述到完成的制作流程**，四步按顺序推进：
  1. **先写描述**：`////` 模块文档（命名 `.planning` 条目）+ `///`
     覆盖每个 type / function（以及测试）。概念与判据写在这里。
  2. **再写架子，没有实际东西**：按需定义 type（可空）、function
     签名（可空 / `todo as "…"`）。此时 `gleam build` / `gleam test`
     就能跑。**`gleam build --warnings-as-errors` 是固定门禁（R48）**：
     骨架阶段它必红，红的内容是逐条 `Todo` / 空用，必须读到具体行；
     不许把某一类 warning 预先归类为「expected skeleton shape」而整包
     豁免，也不许拿 warning 数量当工作量。
  3. **再写 test —— 设计目标在此**：测试把设计目标写成可执行的
     `assert` / `let assert`，每条测试也有 `///` 文档。此时 RED。
  4. **逐步测试、逐步完成全部合乎 test 要求的代码**：一次填一个
     body，compile，循环到 GREEN。
- **「如果有」是条件**：type / function 按需定义，不凭空造。但「没有
  实际东西」只指**架子阶段**，不是不实现；第 4 步必须把代码填到
  全部合乎 test 要求。
- **04-10 的如实定位（见下方 11:05）**：它**不是**这条流程的示例，而是
  对既有代码的反向补课。`Desk` 等 type 与逐层 `get_*` 早就实现，
  04-10 才补 `////` / `///` 与 6 个断言；只有 `timeframe_under` 这一小段
  是「`///` + `todo` → test → 实现」的顺序。R34–R37 的逐字内容与
  GREEN 结果不变，但不得再自称按流程制作了 module。
- **以后新建 module 从头照此流程走**：描述 → 空架子 → 测试定目标 →
  逐步实现；概念先进 `////` / `///`，不先进 `docs/` 散文。

---

## 2026-11-10 11:05 — 制作过程的根因批评（执行纪律，非新裁定）

**owner 原话（逐字）**：*"问题是，你制作一个module的过程，实际上完全不是
这样走的，所以错误百出。甚至是倒过来整，最后才填补文档说明设计意图，
补充test充门面。这是乱搞。"*

- **根因是制作顺序，不是某条内容写错**：代码先落地、文档与测试后补，
  等于让设计意图追着实现跑。测试如果只是给已有行为补断言，就是
  「充门面」，不能承载设计目标（11:01 逐字 *"test设计目标在此"*）。
- **纪律（约束每个 AI authored 文件）**：新建 / 重做一个 module 必须按
  上方四步顺序推进 —— ① 描述（`////` 命名 `.planning` 条目 + `///`
  覆盖每项）→ ② 空架子（可空 / `todo`，没有实际东西）→ ③ 写 test，
  **设计目标写在 test 里** → ④ 逐步测试、逐步实现到全部合乎 test
  要求。**禁止**先写实现再补文档说明设计意图、再补 test。
- **对既有代码的补课要标明是补课**：不得把 retrofit 包装成流程示例，
  也不得用一堆文档 / 断言制造「按流程做完」的印象。本条同时约束
  文档写法。
- **本轮处置**：代码与 GREEN 结果保留（真实有效），但所有把 04-10 写成
  「按流程制作」的叙述改为如实定位；不删代码、不删测试、不新增 type /
  依赖 / probe，决策区仍 **0 项**。

---

## 2026-11-10 11:11 — `docs/` 是什么：差生补课笔记（文档体系与制作习惯的裁定）

**owner 原话（逐字）**：*"如果不是反着做习惯了，怎么会理解不了我在说什么呢。
这误解本身就说明你的习惯是完全与"文档领先的TDD"不相干的。事实上，那么多
docs目录下的文档为什么存在，就是因为你没做到这种 gleam document领先于测试，
测试领先于实际代码的流程，如果"文档领先TDD流程"做好了，很多文档都不需要了，
那些文档都是我发现你错误之后给你上课留下的差生补课笔记。"*

- **误解不是孤立错误，是习惯的证据**：11:10 把 seib 读成「也是 Python、
  只不过没受限制」，根源就是**反着做**习惯了 —— 先有实现、再补说明，
  复述时便习惯性地把两者归成同一类。这与 11:05 的「倒过来整、补充
  test 充门面」是**同一个根因**，不是两条独立问题；owner 判定这种习惯
  **完全与「文档领先的 TDD」不相干**。
- **裁定：`docs/` 下的大量文档不是设计资产，是「差生补课笔记」**。它们
  存在的原因正是没做到 *"gleam document 领先于测试，测试领先于实际代码"*；
  是 owner 发现错误后上课留下的记录。**流程做对了，很多文档根本不需要。**
  因此 `docs/`（含本文件）不是权威、不是设计前置产物、不是知识库；
  **唯一权威始终是 owner 的当前陈述**（本文件首条权威顺序 / R33）。
- **正解位置**：概念与判据属于 `////` 模块文档与 `///` 项文档，设计目标
  属于 unit test，实现排在两者之后（上方 R19 制作流程）。散文文档只是
  补课与索引，**不得再用「多写几篇 docs」冒充落实了设计**。
- **纪律（立即生效）**：① 不再为记录概念新建散文文档；② 已有 `docs/`
  只在改错、记 owner 逐字裁定、记实测时更新，**不扩写、不铺陈**；
  ③ 文档数量应随流程做对而**下降**，不是上升；④ 新建 / 重做 module
  一律从 `////` 描述起手，test 先于实现（11:05 纪律不变）。
- **本轮处置（照此执行）**：**没有新建任何文档文件**；只在既有文档里
  把 11:10 的事实改准、把 11:11 的裁定记下，并把 R34 的区分落进
  `src/glibe/config.gleam` / `src/glibe/desk.gleam` 的 `////` 代码文档。
  不改 type / field / 关系、不加依赖、不写 probe，决策区仍 **0 项**。

## R38 — 单向流没有 replay；参考 glib 必须文档与实现对比（2026-11-12 owner 指示）

**owner 原话（逐字，五条，同一条指示）**：

1. *"glib中有代码，你可以看他是不是符合我的要求，符合就可以参考，不要自己瞎编一套，尤其是timeframe里面的各种函数"*
2. *"replay连名字都不对，glibe哪有什么需要re-play的东西。太荒唐了。"*
3. *"glib的问题跟所有AI写的东西的问题一样，所以文档跟实现不相干经常有，需要对比，文档写对了是因为我教的，代码写成什么样，AI自己都不清楚"*
4. *"stream不可能有倒回去重来一遍的道理，长江万里哪有倒退重来的道理"*
5. *"replay不知道你们两个谁抄谁，反正是错的。对的部分可能没有抄"*

- **裁定：glibe 是单向流，没有 replay / 倒带 / 重来一遍。** R33 的管道
  `api provider / data sources → history + live data → sourcebar_gate →
  databar_processing → model ↔ view` 只往前：history 与 live 是**同一条流的
  前后段**，不是一个可重放的序列。owner 2026-09-10 的逐字线索
  *"这就是 stream，只知道当下和过去，不知道后来"*（glib
  `docs/DESIGN.md:71`，仅作线索）。名字必须按现实事物命名；`replay` 把
  离线批处理词带进了单向流。**「replay CLI」这个长期待办词同错**：历史
  kline 不是重放，是同一条流的上游数据。
- **撤回**：`src/glibe/replay.gleam`、`test/replay_test.gleam`、
  `.planning/phases/04-domain-cleanup/04-11-PLAN.md` 全部删除（`17376a4`），
  `ReplayError` / `BarRejected` / `replay_from` 一并消失；前三笔 04-11
  提交判为错误方向，不保留为历史代码。**不改名重做、不补 `feed` 之类
  包装函数**：glibe 已有两个入口，一根 bar 到达就是依次调用它们
  （R35「简单是正确的验证码」）。
- **glib 文档与实现的对比实测（只作线索，不作依据；R33）**：
  - `glib/docs/DESIGN.md:61-63` 仍写 `trading/replay.gleam:45`，并自注
    *"the module's name is struck by law 18"*；`:1874` 仍写 "called from
    `replay.feed`"。**实现里该文件不存在**：实际是
    `src/glib/trading/ingest.gleam` 的 `feed` / `feed_all`。文档里的
    replay 是被划掉的旧名，实现早已改名 —— **文档不作实现证据**。
  - `glib/docs/DESIGN.md:1493-1529` §15（owner 2026-09-22 逐字）：只有
    两个顶层 data-treating 函数 `sourcebar_gate` / `databar_processing`；
    `:66` *"Batch is that pair run n times — not a second implementation"*。
    → 04-11 造的正是这句禁止的「第二套实现 + 批量入口」。
  - `glib/src/glib/trading/ingest.gleam:57-81`：`feed(tf, bar) -> Timeframe`
    **一根一喂**，`feed_all = list.fold(..., feed)`；`live.gleam:74` 最终
    也调同一个 `feed` → 符合 R33「history 和 live 同一条流」。
  - **不符合 glibe 裁定、不搬**：`publish: fn(Timeframe) -> Nil` 回调与
    `web.publish_*`（R33 view 是纯值投影）、`clock.now()` + `period_end`
    （R27 标准 `SourceBar` 是 unix time，不读系统时钟）、
    `sourcebar_buffer` / `sourcebar_export`（离线导出）、按 interval 查表的
    `IntervalSettings`（R23 settings 是 `Timeframe` 的 field）、
    `instrument.market.exchange`（R26 / R37）、`io.println` 与
    `is_product_version` 断言。
- **「对的部分」实测（glibe 现状 vs glib 实现；不擅自改，待 owner 定）**：
  - **已对上**：`engine.sourcebar_gate` / `engine.databar_processing` 两个
    名字与顺序（indicator → leaves → branches → strategy → 归档）与 §15
    一致；`Result` 闭集拒绝（R13）、interval 由 holder 传（R37）、unix
    网格（R27 / R29）是 glibe 后续裁定，比 glib 的 clock 更符合要求。
  - **命名差异**：glib `working_databar_archived` / `bars_listed` ↔ glibe
    `accept` / `bars_accepted`；glib `indicator.compute_bar` +
    `single_bar_test` ↔ glibe `indicator.run`（且无 UC-60 单 bar 检验）。
  - **glibe 多出来的字段**：`Timeframe` 仍带 `manual_enter` /
    `manual_exit`，而 `glib/src/glib/timeframe.gleam:720-731` 记录 owner
    2026-10-31 逐字否决（*"based on this to invent fields is not expected
    behaviour … keep things clean"*）。以上属结构 / 命名改动，本轮不动。
- **纪律**：① 名字按现实命名，单向流里不出现 replay / 重放 / 倒带；
  ② 参考 glib 必须**文档与实现对照**，只取符合 owner 当前裁定的实现；
  ③ 批次 = 那对顶层函数按序跑 n 次，不是第二套实现、不是 CLI、不是
  新模块；④ 不为凑流程造 type / function。
- **本轮处置**：删 3 文件、清理当前状态文档与代码文档里的 "replay CLI"
  旧词；历史 review / 旧日志 / 本文件旧条目保留原文（不篡改历史记录）。
  不新建文档、不新增 type / function / field / 依赖、不加测试，
  决策区仍 **0 项**。

## R39 — 整个系统就是这一条直线（2026-11-12 owner 指示）

**owner 原话（逐字）**：*"数据来到我们的系统，合格的sourcebar变成working
databar，从头到尾所有运算处理决策都在这个databar working中完成，之后他
就被working databar archieved，这就是整个的系统，没有任何旁门左道。
我把整个复杂的策略交易系统设计成如此简洁清晰的流程，完全杜绝了任何
瞎编的可能性，可惜AI还是瞎编"*

- **裁定：系统的完整定义，四步，一条直线，没有旁门左道。**
  ① 数据到达 → ② **合格的** `SourceBar` 变成 `working_databar` →
  ③ 从指标、叶子、分支到策略的**所有运算 / 处理 / 决策**都在
  **这个 working databar 中**完成 → ④ `working_databar_archived`
  （归档进 `databar_list`）。名字是 owner 的：`working_databar`、
  `working_databar_archived`。**这就是整个系统**；`replay`（R38）、
  `monitor.*`（R33）、actor / 调度 / 时钟 / 发布回调 / 第二套批量
  实现，全是旁门左道。这条直线本身就是「杜绝瞎编」的机制。
- **判据**：一处运算若不在 working databar 中完成，或需要把 bar
  **当参数在步骤间传递**，就已偏离这条直线（R35 简单验证码）。
- **glib 实现里符合这条的部分（对比文档后取实现；R38）**：
  - `src/glib/sourcebar.gleam:428 to_databar(bar, idx)`：**一根**合格的
    sourcebar 整根变成一根 `DataBar`；`timeframe.gleam:25` 记录
    2026-10-11 phase 42 删掉了 fold 半边 —— *"a bar is born whole on
    arrival, and a source bar that repeats the bar in hand is not a
    second half of anything"*。
  - `timeframe.gleam:351`：`databar_processing` 第一步把 bar 放进
    `working_databar: Some(databar)`；之后 indicator / leaves /
    branches / strategy **每步只接 `Timeframe`**，从 record 里的
    working_databar 读、写回 record（`:369-427`、`:732-765`）。
  - `:844-851 working_databar_archived(timeframe)`：**不带 bar 参数**，
    归档的就是 record 里那根，写 `databar_list` 并把 working 置 None
    （三态 `None → Some → None`）。
- **glibe 现状偏离清单（实测；本轮一律不改，等 owner 一句话）**：
  1. `working_databar` 被当成**未收盘桶累积器**：
     `src/glibe/databar.gleam:114 fold_sourcebar(working, bar)` 把多根
     sourcebar 折成一根（high / low / volume 累加）—— 正是 glib
     phase 42 已删的那半边，与「一根合格 sourcebar 整根出生」不符。
     （R27 / R29 的 `SourceBar.timestamp` 与 `bucket_ends` unix 网格
     裁定不变，本条不质疑它们。）
  2. `engine.databar_processing(tf, databar)` 把 bar **当参数**穿过
     `leaves(tf, databar)` → `strategy(tf, databar)` →
     `accept(tf, databar)`；各步不在 working databar 中读写。
  3. 归档叫 `accept(tf, databar)`，不是 `working_databar_archived(tf)`；
     `bars_accepted` 不是 `bars_listed`。
  4. `Timeframe` 仍带 `manual_enter` / `manual_exit`（owner 2026-10-31
     逐字否决，见 R38）。
- **纪律**：**结构按这条直线改对之前，不把这段话写进 `////` / `///`
  代码文档** —— 那会再造一次「文档与实现不相干」（owner 本轮第三条）。
  概念进代码文档必须与实现同一步落地。本轮只记裁定与实测，不改
  `src/`、不加 type / field / 依赖 / 测试，决策区仍 **0 项**。

---

## R40 — `databar_processing` 的主体就是 `timeframe` 的管道（2026-11-12 owner 指示）

**owner 原话（逐字）**：*"整个流程的在databar processing 内部的主体就是一个
简单的gleam经典：timeframe |> function1 |> function2 |> function3 ... |>
functionN 无限可伸展。为什么timeframe，timeframe里面有working databar，
gleam能不能这样写呢？要试试看，不能的话，则换成gleam能允许的写法"*；
补一句：*"glib可能已经这样做了，在我的要求下。"*

- **裁定**：`databar_processing` 内部是**一条管道**，主语是 `Timeframe`，
  因为 `working_databar` 是它的 field；每个 `functionN` 的**第一个参数**
  是 `Timeframe`、**返回值**是 `Timeframe`（参数个数不限，见 R40-A 的更正），
  从 record 里读 working databar、写回 record，**没有任何一步把 bar 当
  参数传**（R39 的判据在此落地）。末尾 `|> working_databar_archived`
  不带 bar。加一步就是加一个 `|> functionN`，不改任何早先步骤 ——
  这就是「无限可伸展」。
  - **2026-11-12 更正**：本条初稿写成「每个 `functionN` 都是
    `fn(Timeframe) -> Timeframe`」，把 owner 举例时省略的
    `function(...)` 误读成单参数限定。**这是错的**，全文以 R40-A 为准；
    初稿留在此处只为记录错误本身，不再作为判据。
- **语言问题用编译器回答，不用散文**（R35）。测量落在
  `probes/timeframe-pipeline/`，用**真实的**
  `glibe/timeframe.Timeframe`，不是仿造的迷你类型：
  - `gleam build --warnings-as-errors` = **0**，`gleam test` =
    **6 passed, no failures**，`gleam format --check` = 0，
    `gleam docs build` = 0。R19 全流程：描述 → 空架子 →
    RED（0 passed / 6 failures）→ 填实现 → GREEN。
  - **能写**：`tf |> step_one |> step_two |> step_three |>
    working_databar_archived`；`option.map` 处理
    `working_databar: Option(DataBar)`，无 `let assert`、无 `panic`、
    无 catch-all。带 label 的步骤 `tf |> scale(by: 2.0)` 也直接能接
    （R40-A 把这一点扩展到任意多个参数）。
  - **N 步**：`List(fn(Timeframe) -> Timeframe)` +
    `list.fold(steps, tf, fn(frame, step) { step(frame) })`，
    1000 步实测通过，record 是唯一的累加器。
  - **可失败步骤**：普通 `|>` 接不住；Gleam 允许的写法是
    `Ok(tf) |> result.try(checked_step) |> result.try(...)`，
    错误是闭集 `ProcessingError`，不是 `String`（R13）。
  - **Gleam 唯一不接受的形状**：某一步返回 record **旁边还带东西**
    （`#(Timeframe, a)`）。实测 `/tmp/gleam_pipe_negative`：
    `error: Type mismatch — "This function does not accept the piped type";
    The argument is #(Timeframe, Int), but function expects Timeframe`。
    允许写法 `let #(tf, fact) = step(tf)` 能编译（exit 0），但直线断了；
    **把 fact 放进 record 的 field** 才能保持管道，探针里
    `settle_leaf |> read_settled_leaf` 已实测。这不是语言限制，是
    **定义问题**（R35：定义错了才需要机制）。
  - **`opaque`**：跨模块 `Timeframe(..tf, …)` 实测失败
    （`error: Use of private value`），但
    `tf |> owner.step |> owner.step` 实测 exit 0。若把状态类型改成
    `opaque`，steps 必须与类型同模块；glibe 现在是 `pub type`，
    所以 `engine.gleam` 可以单独持有管道。
- **glib 对照（R38：文档与实现必须对比）**：owner 的要求**确实被记录
  过**，但**没有落进代码**。
  - 文档：`glib/docs/reference/timeframe-settled-leaf-2026-10-28.md:312-315`
    逐字引 owner：*"all functions called inside databar_process() will
    return the new timeframe value after their work, and finally it becomes
    pipeline of timeframe"*；`:292-310` 画出
    `Timeframe |> leaves |> branches |> strategy` 的图；
    `glib/docs/reference/timeframe-cleanup-audit-2026-10-28.md:671`
    把「改成 `tf |> leaves |> branches |> strategy`」列为第 6 步；
    `timeframe-cleanup-audit-review-2026-10-30.md:331` 记为 plan 52-03。
    `~/.workbuddy/skills/gleam-language/probe/src/q_settled_field.gleam`
    （2026-10-28）已在迷你类型上编译过 `seeded |> leaves |> branches`。
  - 实现：`glib/src/glib/timeframe.gleam`（2026-11-05）**全文没有一根
    `|>`**；`databar_processing`（`:338-490`）是五次
    `let timeframe = ...` 重绑定；`:421` 仍是
    `let #(timeframe, yin_leaf_settled, yang_leaf_settled) = leaves(timeframe)`，
    `:424` `branches(timeframe, yin_leaf_settled, yang_leaf_settled)`；
    `yin_leaf_settled` 是 `:632-633` 的**函数参数**，不是
    `Timeframe`（`:76-150`）的 field。**计划从未执行。**
  - 结论：glib 文档对、代码没做，again；**不移植**它的
    `publish_model` / at-home asserts / `io.println` / sourcebar_buffer
    （R38 的不移植清单）。
- **本轮处置**：只做探针与裁定，不动 `src/glibe/`。`engine.gleam`
  现在还不能一条管道到底：`leaves` 返回四元组、`strategy` 返回二元组、
  `accept(tf, databar)` 带 bar；把它们改成「首参与返回都是 `Timeframe`
  的步骤」是**定义改动**（R39 偏离清单；参数个数不限，R40-A），
  不是语言问题，另一步落地。探针 `////` 写的是**探针自己已实现并跑绿
  的直线**，不是 `engine.gleam` 的说明书 —— 不制造 R39 禁止的
  「文档与实现不相干」。决策区仍 **0 项**。

---

## R40-A — 管道步骤的参数个数不限（2026-11-12 owner 澄清）

**owner 原话（逐字）**：*"timeframe |> step_one |> step_two |> step_three
|> working_databar_archived 这个地方，我在举例时候方便起见，没有写
function(...),所以你如果以为这是限定，那么就很难做，因为只有单参数fn才能像
上面那样写，实际上你可有有无数参数，只要第一个是所谓 subject即可，具体的看
官方文件，搜索其中的标题包含 piplines 这部分"*

- **官方出处**（按 owner 指定搜标题）：Gleam Language Tour
  `https://tour.gleam.run/everything/#functions-pipelines`，章节标题
  **"Pipelines"**（单页 `https://tour.gleam.run/functions/pipelines/` 同文）。
  逐字引：
  - *"If the right-hand expression is a function call then then the left-hand
    value will be used as the first argument to the call. For example,
    `rocket |> launch(1, 2)` would become `launch(rocket, 1, 2)`."*
  - *"If the right-hand expression is not a function call then then it will
    become one, and the left-hand value will be the sole argument to the
    call. For example, `rocket |> launch` would become `launch(rocket)`."*
  - *"Gleam code is typically written with the "subject" of the function as
    the first argument, to make it easier to pipe. If you wish to pipe to a
    different position then a function capture can be used to insert the
    argument to the desired position."*
    （tour 的例子：`"1" |> string.append("2") |> string.append("3", _)
    |> io.println`）
- **裁定**：R40 里的 `function1` 只是**省略调用括号的简写**，不是单参数
  限定。每一步的形状是 `fn(Timeframe, ...extra) -> Timeframe`：第一个参数
  是 subject、返回值是 subject；`...extra` 可以有任意多个，位置参数、
  label、整个配置 type 都行，在管道调用点给出。R39 的判据不变：
  **没有任何一个参数是 bar**，bar 只在 `working_databar` field 里。
  subject 放第一个是官方与 owner 的约定；function capture 能把值送到
  非首位，语言允许，但 R40 的直线仍以 subject 首位为准。
  R40 的「Gleam 唯一不接受的形状」只针对**返回值**旁边多带东西，
  参数个数从来不是限制。
- **实测**（R19 全流程：描述 → 空架子 → RED `6 passed / 5 failures` →
  GREEN **11 passed, no failures**；`gleam build --warnings-as-errors` = 0，
  `gleam format --check` = 0，`gleam docs build` = 0）。全部落在
  `probes/timeframe-pipeline/` 的**真实** `Timeframe` 上：
  - `tf |> add_weighted(2.0, 1.0)`：
    `fn(Timeframe, Float, Float) -> Timeframe`，两个额外位置参数，
    close = `1.5 * 2 + 1 = 4.0`；
  - `tf |> with_labels(cap: 10.0, plus: 1.0, by: 2.0)` 与
    `|> with_labels(by: 2.0, cap: 3.0, plus: 1.0)`：三个 label 任意
    顺序，分别得 `4.0` 与 `3.0`（每个 label 都真的进了 body）；
  - `tf |> bounded(_, StepSettings(factor: 1.0, bias: 1.0,
    ceiling: 2000.0))`：额外参数是**一个 type**，capture 后成为
    `fn(Timeframe) -> Timeframe`，`list.repeat(step, 1000)` 折叠得
    `1001.5`；
  - `tf |> subject_second(2.0, _)`：tour 的 function capture 把
    `Timeframe` 送到非首位，close = `3.5`（语言允许，仅作测量）；
  - `mixed_line`：一根管道里同时有裸名、位置参数、label、capture，
    末尾仍是 `|> working_databar_archived`，归档 bar 的 close = `8.0`。
- **影响**：`engine.gleam` 的每一步不必被削成单参；需要设置、阈值或
  依赖值时，**在管道调用点传入**，而不是把 bar 当参数，也不是另造
  机制或全局状态。R40 的「无限可伸展」由此更直接：加一步就是加一个
  调用，  参数随这一步自带。本轮只改探针与裁定，**仍未改 `src/glibe/`**。

---

## R41 — `|>` 是形状约束，不是排版偏好（2026-11-12 owner 指示）

**owner 原话（逐字）**：*"使用piplines的写法，其实是对gleam能力提升有帮助，
也让代码更清晰整洁，很多时候参数是什么顺序，return什么，AI是随心所欲
瞎编的"*

- **裁定**：管道把「首参是 subject、返回是 subject」从**每个函数各自的
  自由决定**变成**编译器强制的一种形状**。这里说的「能力提升」是
  **写 Gleam 的人/AI 被结构约束住**，不是 Gleam 语言变强：静态类型检查
  一直在。没有管道时，同一流程里 N 个函数可以有 N 种签名，每个调用点
  手工对齐，编译器没有任何理由反对（下面 case D 实测 **exit 0**）——
  于是参数顺序、返回什么全凭当下瞎编。写进管道后，瞎编立刻是编译
  错误（case B / C 实测 **exit 1**）。
  - **判据**：`databar_processing` 的每一步必须是
    `fn(Timeframe, ...extra) -> Timeframe`（R40-A「参数个数不限」仍成立）。
    任何一步首参不是 `Timeframe`、或返回值不是 `Timeframe`，**不需要人
    review，编译器直接拒绝**。加一步只需知道这一个形状，不必读上一步
    的实现，也不必为它重新发明参数顺序与返回结构。
  - 与 R0 / R35 同源：让编译器记住形状，正是「type 到家」；
    「简单是正确的验证码」——管道把整个流程压成一行，复杂说明某一步的
    **定义**错了，不是需要更多机制。
  - 这也解释了 R39 偏离清单为什么必须修：不只是名字不好听，是每种
    自创形状都给下一次瞎编留了一个位置。
- **编译器测量**（`/tmp/gleam_shape_negative/`，四个独立 package，
  Gleam 1.19.2 / Erlang；负向 fixture 不进仓库，R19 规定）：
  | case | 写法 | exit | 编译器逐字 |
  |---|---|---|---|
  | A 对照 | `frame \|> step(by: 2) \|> last`，两步都是 `fn(Frame, ...)->Frame` | **0** | `Compiled in 0.55s` |
  | B 首参瞎编 | `step_wrong(k: Int, frame: Frame)` 写成 `frame \|> step_wrong(2)` | **1** | `error: Type mismatch` `Expected type: Int / Found type: Frame`（`:12:3`），以及 `Expected type: Frame / Found type: Int`（`:12:23`） |
  | C 返回值瞎编 | `step_returns_int(frame) -> Int` 后接 `\|> next` | **1** | `This function does not accept the piped type` / `The argument is: Int` / `But function expects: Frame`（`:16:32`） |
  | D 同样瞎编、不写管道 | `let a = step_wrong(2, frame)` → `let b = step_returns_int(a)` → `next(b, a)` | **0** | `Compiled in 0.38s` |
  - **D 是关键对照**：B / C 的签名原样搬过来，只因为改成手写调用链就
    全部通过。所以差别不在「Gleam 有没有类型检查」，而在**形状有没有
    被收敛**。R40 已测的 `#(Timeframe, a)` 返回（`/tmp/gleam_pipe_negative`，
    `Type mismatch`）是同一类拒绝：返回值旁边多带东西也是瞎编。
- **现状清点（`file:line` + 该行文本，R38 纪律）** ——
  `glibe/src/glibe/engine.gleam` 一条流程里 **8 个函数、8 种签名**：
  - `:68` `sourcebar_gate(` → `:72` 返回
    `Result(#(Option(DataBar), Timeframe), SourceBarRejection)`，3 参数；
  - `:91` `databar_processing(timeframe: Timeframe, databar: DataBar) -> Timeframe`；
  - `:119` `leaves(` → `:122` 返回
    `#(DataBar, Timeframe, Option(leaf.DataLeaf), Option(leaf.DataLeaf))`
    四元组；
  - `:160` `branches(` 收 **5 个**参数（`:161-165`，含 `yin_settled` /
    `yang_settled` / `exit_size`）→ `Timeframe`；
  - `:214` `strategy(timeframe: Timeframe, databar: DataBar) -> #(Timeframe, DataBar)`；
  - `:240` `accept(timeframe: Timeframe, databar: DataBar) -> Timeframe`；
  - `:255` `bars_accepted(databar_list: List(DataBar)) -> Int`（参数根本
    不是 `Timeframe`）；
  - `:268` `last_bar(timeframe: Timeframe) -> DataBar`（返回 bar 而非记录）。
  - `:94` `let #(databar, timeframe, yin_settled, yang_settled) = leaves(...)`,
    `:96` `let timeframe = branches(...)`,
    `:104` `let #(timeframe, databar) = strategy(...)`,
    `:105` `accept(timeframe, databar)` —— **四次手工解构/重绑定**，
    把上一步自创的返回结构人肉接到下一步自创的参数表上。
    这就是「参数是什么顺序、return 什么」被逐个决定的现场。
- **glib 对照（R38：文档与实现必须对比）**：
  `glib/src/glib/timeframe.gleam` 的 `:732`
  `strategy(timeframe: Timeframe) -> Timeframe` 与 `:844`
  `working_databar_archived(timeframe: Timeframe) -> Timeframe`
  **已经是正确形状**；但 `:511` `leaves(timeframe) ->
  #(Timeframe, Option(DataLeaf), Option(DataLeaf))` 仍返回三元组，
  `:630` `branches(timeframe, yin_leaf_settled, yang_leaf_settled)` 仍把
  中间结果当参数，`:338` `databar_processing` 还多带一个
  `publish_model` 回调（R38 不移植清单）。而 R40 已实测
  `databar_processing`（`:338-490`）**全文零 `|>`**、五次
  `let timeframe = …` 重绑定。**签名对了一半，没有管道，顺序照样靠手写。**
- **本轮处置**：只记录、测量与清点，**不改 `src/glibe/`**。把上述 8 个
  签名收敛成 `fn(Timeframe, ...extra) -> Timeframe`、把四次手工解构
  消掉、并把 `working_databar` 从桶累积器改回一根整 bar（R39），
  仍是等 owner 一句话的产品代码改动；R41 给出的理由是：那不是
  风格选择，是**让编译器替我们防住下一次瞎编**。决策区仍 **0 项**。

---

## R42 — 抄作业、模块归属、空架子即设计、Desk 为顶（2026-11-12 owner 连续指示）

**owner 原话（逐字，按时间）**：

1. 07:01 *"在 databar_processing 内部使用这样的写法，要求你先把设计搞对，
   然后把框架的document和框架本身搭好，这一步是思考要做什么，涉及少量
   如何做（参数和return），接下来写好unittests，接下来填充每一个function
   达到设计意图"*；*"你本来对于timeframe module的定义和制作根本是一塌
   糊涂，却想要一步登天套上正确的pipline写法去验证gleam语法是否正确，
   不仅毫无意义而且是荒唐颠倒… 并且给出的鬼例子什么Result作为subject
   完全瞎编"*
2. 07:04 *"首先 engine.gleam 是什么鬼"*；07:05 *"timeframe.gleam 定义
   Timeframe type以及相关的fn，你那个是什么鬼东西"*
3. 07:18 *"glibe本来就是抄作业，抄glib的，仅仅要求将JS target改编成
   erlang target，抄作业抄成这样也是没有谁了。好的没有抄，坏的都差不多
   囊括了。不能单独看代码，那边的AI记录的东西跟他编写的代码经常脱节。
   Gleam文档领先的TDD完全没有"*
4. 07:20 *"当你着手去做timeframe模块时，你先把文档写好，然后就能发现，
   你必须先定义好上游模块，这些空架子模块，gleam完全允许，所以这样
   倒推正推都能把缺口补齐，设计搞对"*；07:21 *"先做空架子，type关系
   定义好，然后就能发现缺少什么type的模块和函数了"* /
   *"gleam build会告诉你缺少什么"*
5. 07:25 *"等你倒追查出你需要Desk模块的时候就完全对了。也就是说你倒推出
   timeframe >> instrument >> broker >> desk 整个链条，以及各自需要提供
   的funtions服务"*
6. 07:29 *"Desk就是中心控制室，所有的声控app，web或者桌面端，以及分析
   决策等等type都会从这里直接或者逐层展开出来。但是你要一下子设计对
   很难，可是你写好空架子，就理顺了所有关系，连一行真正干活的代码都
   不用写，系统就完全设计对了。这才是 gleam document leading TDD"*
7. 07:32 *"Desk 从type上面来看，也可以说是 top type，也可以说是根，随便
   怎么理解，但是他上面不再有东西，这是设计要求，没有其他原因。你系统
   一定要有一个顶部的东西的"*
8. 07:35 *"这个skill慢慢随着开发完善，不要去一次写好，那是瞎编"*；
   07:39 *"最初的空架子，unit test 跟对应的 type fn 也都一样是空的，
   仅仅要求将 in out types 搞对；这一步gleam test or gleam build就已经
   能发现设计问题"*

- **裁定：glibe = 抄 glib 的作业 + 唯一改编 JS target → Erlang target
  + owner 裁定修正。不另造设计。** 抄之前必须**文档与实现对照**：glib
  文档是那边的 AI 记的，常与它写的代码脱节；抄的是 owner 的要求，不是
  抄没落实的代码（`timeframe-cleanup-audit-2026-10-28.md:665-671` 要求
  settled 进 field，`timeframe.gleam:630` 仍当参数传 —— 抄前者）。
  glib 完全没有 doc-first TDD，这一条不能一起抄。
- **模块归属**：`timeframe.gleam` = `Timeframe` type + 全部相关 fn，与
  `glib/src/glib/timeframe.gleam:32-35` 一致（行号回读 glib 源码后改正）。
  `engine.gleam` 是 AI 造的
  机制型模块（生产代码无人 import，其 `:19-21` 自己承认拆分的
  import-cycle 理由不成立），**删除**；
  `scripts/no_timeframe_mixture.sh` 是用 grep 把错误划分钉成门禁的
  守卫，**删除**（core §5 官方反模式 *"Do not fragment modules"*）。
- **空架子即设计**：写好 `////` / `///`、把 type 关系与签名的
  **in / out types** 对齐，`gleam build` / `gleam test` 就能照出缺口；
  此时**一行干活的代码都不用写**。倒推 upstream → 正推回 timeframe →
  一路到 `Desk`，每层补齐它该提供的 read / write 服务。连最初的
  unit test 也是空的，只要求 in/out types 对。
- **`Desk` 是 top type / 根 / 中心控制室，上面不再有东西**——设计要求
  本身，无其他原因；所有声控 app / web / 桌面端 / 分析决策 type 从它
  直接或逐层展开。倒推查出的真缺口是它的 **WRITE 半边**。
- 制作顺序（R19 严格执行）：文档 → 空架子 → build/test 暴露设计问题
  → 写断言 → 逐个填 body 到 GREEN。skill
  `gleam-document-led-tdd`（用户级）**随开发增量完善**，只写已实测
  的段落，不预写未发生的轮次。

- **本轮实测（file:line / exit code）**：
  - 架子阶段 `gleam build` **exit 1**：4 个 `Unknown record field`
    (`manual_enter` / `manual_exit`)，全在 `engine.gleam:222-228`；
    编译器同时列出新 `Timeframe` 的 11 个字段。架子本身只有 todo /
    unused-arg warning。
  - 写 `////` 倒推发现的上游缺口：`sourcebar.to_databar` 不存在（错放
    为 `databar.of_sourcebar`，旁边还有 `fold_sourcebar` 桶）；
    `indicator` / `leaf` / `branch` / `trading/strategy` /
    `trading/signal` 五个模块 `////` 数为 0；`desk.gleam` 只有只读
    `timeframe_under`，没有回写服务。
  - 归位后 `gleam build` **exit 0**，此时**零行新实现**（新函数仍全是
    `todo`）。
  - RED：`gleam test` = **64 passed / 19 failures**，每个失败都是带
    file:line 的 `todo`。GREEN：**83 passed, no failures**，
    `gleam build --warnings-as-errors` = 0。
  - 全门禁：format check 0；guards 0（`test_guards.sh` 7 → 4 case，
    删掉的是错误守卫的 case）；根包 / webclient / 两 probe 的 docs
    全 0；`parallel-bars` 4 passed、`timeframe-pipeline` 11 passed；
    核心镜像 `cmp` = 0；`package-interface.json` 9 个模块的 `////`
    完整渲染，`glibe/engine` 已不在接口里。

- **产品代码落地**（R39 / R40 / R41 不再是「等一句话」）：
  - `timeframe.gleam`：`sourcebar_gate(tf, interval_key, incoming) ->
    Result(Timeframe, SourceBarRejection)`；`databar_processing(tf)`
    主体 = `tf |> indicator |> leaves |> branches |> strategy |>
    working_databar_archived`，五步全是 `fn(Timeframe) -> Timeframe`；
    另有 `bars_listed`。删 `manual_enter` / `manual_exit`，加
    `yin_leaf_settled` / `yang_leaf_settled`。
  - `databar.gleam` 删 `of_sourcebar` / `fold_sourcebar`，只剩 type；
    `sourcebar.gleam` 拿回 `to_databar`（source 的法律），
    `sourcebar → databar` 单向 import，环消失。
  - `desk.gleam` 新增 `put_timeframe_under`（read 半边的对称 write）。
  - `monitor.gleam` 仅两行调用点适配（R33 历史代码、处置待 owner
    不变）；两个旧 monitor 测试按 R39 改断言：未闭合 bar 被忽略，
    不再开桶。
  - 决策区仍 **0 项**；**未 push**。

## R43 — 空架子让「如是我闻」成为「信受奉行」；反复推敲是核验架子，不是测试互相推翻（2026-11-12 07:51 owner 指示）

**owner 逐字（07:51，两条连发）**：

> *"等你用空架子去落实我的那些设计思路，也就是glib仅写如是我闻，
> 没有信受奉行的部分，你会发现不需要动脑筋去构造实际代码，就已经把
> 系统设计清晰完整的呈现出来，作为AI的智商，也能非常容易理解，
> 这时候所有的如是我闻就成了信受奉行了。所以反复推敲是指反复对照
> 我的设计结合你的思考去推敲现有的空架子搭建的是否正确，包括用词
> 是否准确，是否有自己瞎编的东西。这时候因为没有写实代码，整个系统
> 非常轻灵，你能一下子看完记住，并且容易思考，因为一下子都在你的
> token限量范围内载入完成了，不会挂一漏万。整体架构对了，再去逐个
> 落实代码，很快就都做对了。"*
>
> *"这样做的原因是，我早已把整个系统设计成熟了。否则你不容易这样做。"*

**裁定**：

- **空架子的作用对象是 glib 的「如是我闻」**：那边只把 owner 的设计
  记进文档（如是我闻），没有落实到代码（信受奉行）。用空架子去落实
  这些设计 —— 写 `////` / `///`、type 关系、in/out types、签名 ——
  **不需要构造任何实际代码**，系统就被清晰完整地呈现出来，AI 也容易
  理解；此刻「如是我闻」即成「信受奉行」。R42 的「抄要求，不抄没落实
  的代码」在此有了具体做法：抄的对象是设计要求，落实的方式是空架子。
- **「反复推敲」的准确含义（纠正 04-13 与 skill 里的写法）**：是
  **反复对照 owner 的设计、结合自己的思考，去核验现有空架子搭得对不对**，
  判据包括 **用词是否准确**、**有没有自己瞎编的东西**。它不是「写一个
  test 拉出若干部件、下一个 test 推翻前一个」那种流程描述 —— 后者是
  我在用户级 skill `gleam-document-led-tdd` 的待补条目里对 07:45 指示
  的**误读**，已按本条更正（删去预写的流程，只留 owner 定义与已实测
  事实）。07:45 说的「会推翻之前的东西」是可能的结果，不是推敲的定义。
- **为什么这样有效**：没有实代码，系统非常轻灵，可以一次看完、一次
  记住、容易思考；**整个架子一次性落在 token 限量内载入完成，不会
  挂一漏万**。整体架构对了，再逐个落实代码，很快就都做对。
- **前提（不可外推）**：*"我早已把整个系统设计成熟了。否则你不容易
  这样做。"* 这套做法成立是因为设计已经成熟、glibe 是抄作业；它**不是**
  从零发明设计的通用方法论。空架子的推敲是「对照一个已存在的正确
  设计」，不是「用架子试探出设计」。

**本轮实测（R43 判据的第一次应用，如实标注性质）**：

- 这是**写完实现之后**对 04-13 的 `////` / `///` 文档做的**追溯核验**，
  **不是**空架子阶段的推敲；后者尚未实测，仍留待下轮。
- 核验方式是逐条回 glib 源码/文档对照用词与行号，结论：
  - 有出处、**不是瞎编**：`bars_listed`（`glib/src/glib/timeframe.gleam:827`）、
    `sourcebar.to_databar`（`glib/src/glib/sourcebar.gleam:428`，且其
    `timeframe.gleam:25` 明写 "the **source's** law, not the bar's"）、
    `UC-62`（`glib/src/glib/timeframe.gleam:710/:767/:776`）、
    `:665-671`（`glib/docs/reference/timeframe-cleanup-audit-2026-10-28.md`
    §7.2.1 流程 1–6，含 "`tf |> leaves |> branches |> strategy`"）、
    `:312-315`（`glib/docs/reference/timeframe-settled-leaf-2026-10-28.md`
    "finally it becomes pipeline of timeframe"）、`:630` 处 `branches` 仍带
    两个 settled 参数（文档要求与代码实况的偏离属实）。
  - **用词/引用不准，已改正**：*"What stays is what names the record"*
    在 `glib/src/glib/timeframe.gleam:32-35`，04-13 的
    `src/glibe/timeframe.gleam`、`docs/RULINGS.md` R42、
    `.planning/phases/04-domain-cleanup/04-13-PLAN.md` §2/§5、
    `.workbuddy/memory/MEMORY.md` R42 原先都误标为 `:28-31`（那三行是
    表格里的 `branch_json` / `recognised_this_bar` / `export_accumulate`）。
    另 `:23-25` 过宽（含 `indicator` 行），收紧为 `:25`。
  - 核验时 `04-13-PLAN.md` §3 写的是 `databar.of_sourcebar(...)`，那是本轮
    **已删除**的旧名；已改为产品代码实际使用的 `sourcebar.to_databar`。
- 决策区仍 **0 项**；**未 push**。

---

## R44 — doc-tdd 系统性重建：旧代码是历史遗迹，项目层不设 guard sh，旧红绿无意义（2026-11-12 08:16 owner 连续指示）

**owner 逐字（按时间）**：

> *"继续做框架设计哦，你以前的代码仅能作为历史遗迹，什么都没弄对，丢了不可惜，
> 现在可就地checkout一个新分支了，doc-tdd，完成系统性的重建"*

> *"过时的什么门禁什么test发现多余的就删除或者让不要在添乱，放到过期目录去"*

> *"在你的新设计中，过去的东西绿不绿红不红一点用没有。不用去报告多少绿了多少
> 红了，没意义的。"*

> *"以后在项目层面都不需要什么guard sh，仅仅行为层面和非gleam compiler可控层面
> 需要，但是那个玩意也探测不到你行为的过错。比如git commit不及时等等。"*

> *"gleam command有很多工具你可能没用过，glibe的项目文档也没提过，你最好也
> 熟悉一下，gleam --help"*

**裁定**：

- **旧实现只是历史遗迹**：就地新建 `doc-tdd` 分支做**系统性重建**；旧
  `src/` / `test/` / `scripts/` / `probes/` / 根目录 review / session 笔记 /
  `docs/` 补课笔记整体移入 `deprecated/2026-11-12-pre-doc-tdd/`，可读但不
  参与新设计、不作为命名依据、不参与编译与门禁。本轮只做框架 / types /
  空架子，一行实代码不写。
- **过去的红 / 绿不再是证据**：旧代码、旧测试的 RED / GREEN 数量与通过率
  不衡量新设计的正确性，也不再作为结论汇报。新阶段的 `gleam build` /
  `gleam check` 是**设计探针**，它报的是**缺口**，不是分数。
- **项目层不再维护 `guard sh`**：`scripts/guards.sh` /
  `no_foreign_source.sh` / `test_guards.sh` 及其 CI 调用一并退场。项目层只认
  Gleam 编译器与类型系统自己能查的东西（`gleam build` / `check` / `test` /
  `format --check` / `docs build` / `export package-interface`）。
  `gleam docs build` → `package-interface.json` 是编译器自己的防漂移产物，
  保留；它不是门禁脚本。**行为层**（例如是否及时 `git commit`）靠纪律，
  owner 逐字：*"那个玩意也探测不到你行为的过错"*。
- **熟悉并使用 Gleam 自带命令**：本阶段实测 `gleam check`（只做类型检查、
  不生成代码）、`gleam export package-interface --out <path>`（直接输出
  模块 / type / fn 的 JSON 接口，不用去 `build/` 里捞）、`gleam docs build`、
  `gleam format --check`。`gleam --help` 与 `gleam help <subcommand>` 是
  入口；`--warnings-as-errors` 属于将来填完 body 之后的 GREEN 闸门，
  不是空架子阶段的要求。

**本轮实测（如实标注性质：空架子阶段的编译器设计探针）**：

- 79 个文件整体移入 `deprecated/2026-11-12-pre-doc-tdd/`；
  `.github/workflows/test.yml` 删掉 `sh scripts/guards.sh --all` 与旧注释。
- 12 个模块、函数体全为 `todo as "..."`，**零行实代码**。
  `gleam check` = **exit 0，无设计缺口**；输出只有空架子应有的
  `Todo found` / `Unused function argument` / `Unused private constructor`
  warning —— 后者正是 `opaque` 封印生效的编译器证据。
- 空 unit test 只做显式类型绑定（R42 07:39），不调用任何 `todo` body；
  `gleam build` / `gleam format --check src test` 均 exit 0。
- `gleam docs build` exit 0；`gleam export package-interface --out` exit 0，
  **12 个模块的 `////` 全部完整渲染**，没有一处被 `//` 截断。这是编译器
  自己的防漂移检查，没有新增任何 guard sh。
- 决策区仍 **0 项**；**未 push**。

---

## R45 — 名字只从 owner 用词取；types 是本轮唯一对象（2026-11-12 owner 纠正）

**owner 逐字（两条）**：

> *"你的旧实现搞他干嘛"*

> *"你现在把types搞清楚，其他的东西从我的用词当中去获取即可"*

**裁定**：

- 清场之后**不得再把 `deprecated/` 里的旧实现翻出来当词库**。字段名、
  函数名、构造子、模块名一律不从旧代码转录。上一轮把旧 type 定义、旧公开
  函数名、旧签名读出来提取词汇，是本末倒置；当时据此写进
  `indicator_settings.gleam`（`SmaForBbm` 与一堆 settings 字段）、
  `trading/signal.gleam`（`Buy` / `Sell` / `NoSignal`）、
  `api/interval.gleam`（`all()`）的转录已即时重写。
- 本轮唯一对象是 **types**：把 type 关系摆对 —— `Desk ▸ Broker ▸
  Instrument ▸ Timeframe`、身份在持有者 Dict key、闭集是 type、
  provider 原生形状与标准 `SourceBar` 分离、R39 直线与 R40 管道形状。
  其余东西（字段、函数、构造子）**只从 owner 逐字用词与
  `docs/RULINGS.md` 的裁定里取**；owner 没命名的按 R26 / R32 留空，
  等真实消费方出现再加一个 field，不猜名字。
- **不等于「删掉所有没逐字出现过的词」**：Gleam 语法必需的结构名（类型
  容器名、codec 名、runner 入口）是结构 necessity，不是领域概念；
  `docs/RULINGS.md` 里 **owner 原话**记录过的领域词（R1「four twins」、
  R2 `YinBranch` / `YangBranch`、R4 `growing_yang_branch` /
  `growing_yin_leaf`、R28 `Kline`）是合法来源，与旧实现无关。
  ~~R23 `TimeframeSettings`~~ **此项由 R46 删除**：R23 里 owner 是在
  **质问**这个名字，不是命名它；把「裁定档案中出现过的字符串」当成
  owner 用词，是本条最严重的误用。**合法词源只有 owner 逐字原话**，
  裁定正文里 AI 自己写的名字不算。
- **R43 判据在此落地**：核验「用词是否准确、有没有自己瞎编的东西」，
  包括**引用是否真的逐字** —— 不得把 AI 的转述标成 `owner, verbatim`。
  第一次空架子阶段核验的逐条记录见
  `.planning/phases/05-doc-tdd/05-01-PLAN.md` §5：删掉一个自造占位
  构造子、两处假引用 / 假断言、五个自造模块名，补四处出处；
  **没有删掉任何 owner 命名的领域概念**（`Timeframe` 的 growing /
  settled 字段一度想删，回查 R1 / R2 / R4 后确认是设计，保留）。
  **2026-11-12 11:46 更正（R46）**：这句只对当时查过的 8 项成立，
  不是对全系统的结论；第 9 项 `TimeframeSettings` 是自造概念且被漏掉。

**Landed in**：`src/glibe/` 12 个模块的 `////` / `///`；
`.planning/phases/05-doc-tdd/05-01-PLAN.md` §4 / §5；
`~/.workbuddy/skills/gleam-document-led-tdd/SKILL.md`。
决策区仍 **0 项**；**未 push**。

---

## R46 — 一个 type 存在的理由只能是「他做什么、谁用他、为什么存在」；`TimeframeSettings` 整条作废（2026-11-12 11:46 owner 裁定）

**owner 逐字（两条，同一轮）**：

> *"TimeframeSettings 是AI搞出来的东西，我不知道是什么玩意"*

> *"问题是他做什么，谁用他，为什么存在"*

### 1. 三问实测（`doc-tdd` 上，删除前）

- **他做什么**：`src/glibe/indicator_settings.gleam` 只有 1 个 type +
  1 个**零字段**构造子 + **0 个 fn**，无行为、无数据。旧实现里它是
  12 个数字（5 个 SMA 窗口、KDJ 3 参、`bb_multiplier`、
  `sma_for_bbm`、`branch_exit_leaf_size`），来源是从 ibOptions 的
  `settings*.py` 搬来的清单（R34），不是 glibe 领域里的东西。
- **谁用他**：全仓库仅 3 处引用，且全是空架子的**类型标注** ——
  `Timeframe.settings` 字段、`timeframe.new(settings)` 参数、
  `test/glibe_test.gleam` 的一条空 shape test。**零真实消费方**：
  `indicator` / `leaves` / `branches` / `strategy` 全为 `todo`，
  `config.default_config()` 不接收它，`desk` 不为它提供任何 lookup。
  R23 当年删掉的并行 settings 字典 + `config_get_tfs` 是它唯一真消费方。
- **为什么存在**：**AI 把自己的裁定当成了 owner 的词**。R23（11-09）
  owner 是**质问**：*"TimeframeSettings这是什么type？现实中存在这个type
  吗？跟Timeframe什么关系？又是在绕圈子？"*；本档案 R23 §3 却写下
  「保留为参数包，不改名」，且同一句紧接「owner 没说过的名字就是发明」
  —— 自相矛盾。R45 今早进一步把「R23 `TimeframeSettings`」列成
  「owner 原话记录过的领域词 / 合法来源」。**AI 散文 → 裁定档案 →
  词源**，三跳之后一个被质问的名字被洗白成设计。

### 2. 裁定

- **删除，不是改名、不是留空壳**：`indicator_settings.gleam` 整个 module、
  `Timeframe.settings` 字段、`timeframe.new`（其唯一存在理由就是收这个
  参数）、对应空 unit test，一并删除；`desk.gleam` / `config.gleam` /
  `test/glibe_test.gleam` 里相关说法同步改正。
- **「参数包」「settings 类型」在本系统中没有位置**。R34：ibOptions 用
  settings 文件解决结构问题是 Python+pandas 的局限，不是设计。某个计算
  真需要参数时，按 **R26 / R32** 随真实消费方一个一个落进**真正拥有它
  的 type 的 field**；现在填就是转录旧实现或瞎编。
- **词源的边界收紧**：`docs/RULINGS.md` 里**只有 owner 逐字原话**是词源；
  裁定正文中 AI 写下的名字、glib 的文档、AI 的转述、`.planning/` 下旧
  AI 笔记、deprecated 里的旧实现，**都不是**。特别是 owner 在问句里
  提到的名字，是**质问对象**，不是命名；AI 描述「旧代码里有个 X 要删」
  时出现的 X 同理（`NoSuchSettings` 即此类，`desk.gleam` 曾把它误标成
  owner 用词，同轮改正）。R45 那条「裁定记录过的领域词合法」按此读。
  已知残留：`.planning/` 下 12 份旧笔记仍写着 `TimeframeSettings`，
  因被本档案与 STATE 的历史段落引用而未移动，只作历史、不作词源。
- **判据扩充（R43 / R45 的补充）**：核验空架子时，对每个 type 与 fn
  逐条问 *「他做什么，谁用他，为什么存在」*，并且**出处必须能指到 owner
  逐字原话**，不能指到自己写过的裁定行。引用/名字漂移能活过全绿
  `gleam check` / `build` / `docs build`——编译器不检查名字的出处。
- **R23 其余各条不受影响**：identity 在持有者 key、无复合串表、
  无第二本字典、无 `list.find`、删 `NoSuchSettings` 依然有效；
  作废的只是 §2 的「settings 随 engine 走」（AI prose）与 §3 的
  「保留为参数包」。R45 中「第一次核验没有删掉任何 owner 命名的
  领域概念」一句只在其查过的 8 项内成立，已加更正。

**Landed in**：`src/glibe/timeframe.gleam`（`////` 写入本裁定、
删字段 / 删 `new`）、`src/glibe/desk.gleam`、`src/glibe/config.gleam`、
`test/glibe_test.gleam`、删除 `src/glibe/indicator_settings.gleam`、
`.planning/phases/05-doc-tdd/05-01-PLAN.md` §1 / §3 / §4 / §5.1、
`docs/STATE.md`、`docs/PENDING_DECISIONS.md`。
决策区仍 **0 项**；**未 push**。

## R47 — 自检必须自己触发；`///` 要能译成「谁读写哪个值」（2026-11-12 12:03 owner 质问）

**owner 逐字**：

> *"像这种情况，如果我不提出来，你能不能根据逻辑自己发现问题呢？你模块里面只有一个type，这个type说是 the numbers a timeframe run on 这是什么玩意你自己看得懂不？"*

### 1. 那句文档不是描述，是辩护

被删的 `indicator_settings.gleam` 的 `///` 原文：*"The numbers one
`Timeframe` runs on. Not an entity: no identity, no collection of its own,
no settings table. It travels WITH the engine (R23); the holder's Dict key
carries the interval."* —— 四句「它不是什么」+ 一句已由 R46 作废的断言
+ **零句可指认的事实**。哪个数、谁读、谁写、何时变，一个都答不出。
**看不懂**。更严重的是同一模块 `////` 里两句自我豁免：*"an empty type
with a `///` doc is a valid skeleton item"*、*"No function here on
purpose: a parameter block has no behaviour of its own"* —— 我亲手写下
「它没有行为」，再用「设计如此」把它合法化，正好绕过了「无行为 →
无消费方 → 不该存在」这个本该立刻触发的推理。

### 1.1 三个连带事实（12:14 owner 追问，实测）

- **名字与那句英文不同源**。deprecated 旧实现里 `TimeframeSettings` 是
  12 个具体数字（`sma_tiny_window_size` … `kdj_window_size`），名字从
  ibOptions 的 `settings*.py` 搬来（R34）；旧文档写的是 *"The numbers
  one **engine** runs on"*。R42 删掉 engine 后，我把 **"engine" 一词
  替换成 "Timeframe"** 就当新骨架的 `///` 交差 —— 一次字符串替换，
  不是重新描述。所以 `Settings`（配置）与 "numbers run on"（数字）
  从来没有共同所指，对不上是必然。
- **引用者 `Timeframe` 不需要它**。R46 的 diff 只删了字段一行、
  import 一行、`READS` 里一个名字、`new()` 一个函数；**其余 8 个函数
  签名与 10 个字段一字未动**。不是「Timeframe 需要 settings」，是为
  了让那个名字有落脚处才往 Timeframe 塞 field —— 与 R32「真实事物
  → 倒推隶属 → 加 field」方向相反，是循环论证。
- **`gleam check` 确实报告了空用**（12:19 owner 追问后实测更正：
  先前写的「过关不需要编造消费方」只说对一半，容易被读成「编译器
  什么都没报」）。`timeframe.gleam` 的引用共三处：`import
  glibe/indicator_settings.{type TimeframeSettings}`、`Timeframe.settings`
  字段、`new(settings: TimeframeSettings)` 参数（另加 `//// READS` 里
  一个名字，不参与编译）。把 R46 前三个文件临时恢复后实跑
  `gleam check`：exit 0、822 行、0 error，`Checking glibe` 之后
  第一条就是：

  ```text
  warning: Unused function argument
     ┌─ src/glibe/timeframe.gleam:81:12
  81 │ pub fn new(settings: TimeframeSettings) -> Timeframe {
     │            ^^^^^^^^ This argument is never used
  Hint: You can ignore it with an underscore: `_settings`.
  ```

  紧接 `:82:3` 一条 `Todo found`。全场 31 `Todo` + 53 `Unused
  function argument` + 3 `Unused private constructor`。**import 行
  没有 `Unused import`**（类型名确实出现在字段 / 参数标注里，算用上）；
  `indicator_settings.gleam` **在整份日志里零行** —— `pub` 构造子
  从未被构造也不报，那 3 条 private-constructor 来自 `Symbol` /
  `BrokerId` / `AccountId` 的 `opaque` 封印。
- **为什么报了却没发现**：骨架阶段所有 body 都是 `todo`，所以
  53 条 unused argument 全属「预期形状」—— core §14 与 R42 流程
  明写 *「todo / unused-argument warnings 是 expected skeleton
  shape, not failures」*。`settings` 那条被归进噪声直接过滤，
  连 `_settings` 这个 hint 都没照做。**不是编译器没报，是流程把
  信号定义成可忽略。** 反向判据：每个 `todo` 函数都喊了，唯独
  那个瞎编 type 一声不吭 —— **骨架里静默的模块比报警的模块更可疑**。
- 其余机制不变：`pub type` 字段零读者不产生诊断；当前骨架
  30 `Todo` + 52 `Unused function argument` + 3 `Unused private
  constructor`、0 error，`DataBar` 8 字段与 `Timeframe` 10 字段
  同样全无读者。core §1 保证 **inconsistencies** 不保证 **meaning**；
  core §2 第 2 问在此是 **0 消费者**；`do_not`「别把值停在 record
  里两步后取」连「两步后」都没有。2026-10-26 已因「为管道造一个
  无不变式的 record」被抓过（core 表首行），本次是同病复发。
- **推论（owner：*「无论采用什么手段都没办法让AI做一丁点有用的
  事情」*）**：在「AI 可现场发明概念」的前提下成立。R43 的前提与
  core *「让AI思考不现实 / Thinking is not my job」* 指向同一件事：
  设计由 owner 给定，AI 只做转录；一旦开始自己造 type、编 `///`、
  找落脚处，任何事后检查（compiler / guard / review）都只能查已写
  文本的性质，补不上生成那一刻的判断。**不是给 AI 装脑子，是取消
  它发明的自由度。**

### 2. 回答：判据早齐，缺的是触发点

**逻辑上完全能，且不需要 owner 提供任何新事实；但按当时的流程实际不会
触发。** R34（本档案、我自己记下的）明写 ibOptions 用 settings 解决结构
性问题是 Python+pandas 的局限、不是设计，一个设置应是**已有 type 的一个
field**，我却造了专门装 settings 的 type —— 当天记下、当天违反；R32
「新东西 = 已有 Type 里加一个 field」，零字段的 type 不是 field 是空壳；
R26 无真实消费方不预先发明；R13 根法反向读 = nature 里没有的东西不定义
type；R35「简单是正确的验证码」，1 type / 0 field / 0 fn 不是简单，是空。
**R43 的「空架子轻灵」= 实现为空、关系明确；那个 type = 关系本身为空**，
两者被我混为一谈。R43 核验当时只做了**词源审计**（名字出处、引用行号、
假 verbatim），没做**所指审计**；所有检查都向外（owner 用词 / 编译器 /
引用），没有一步向内指向这个东西本身。

**补的不是新判据、不是新机制**（R44 项目层不设 guard sh，也不写补课
散文），而是把 R43 核验扩一格：

- 每写完一个 `////` / `///`，必须能译成**「谁在什么场合读 / 写哪个具体
  值」**；译不出来的句子就是瞎编，当场删，不等 owner 点名。
- 对**每个** type / fn 主动跑三问，出处指向 owner 逐字原话；「只有 type、
  0 fn、0 真实消费方」是红旗，不是轻灵。
- **禁止自我豁免措辞**：「挂了 `///` 即合法骨架」「没有行为是设计如此」
  不得作为空壳的理由，理由必须写成具体的读者 / 写者。
- 全绿 `gleam check` / `build` / `docs build` 与完整渲染的 `////`，
  **连文档句子空洞也照样通过**；编译器检查类型一致性，不检查名字有无
  所指、文档有无内容（R46 已记，此处精确到文档文本）。

### 3. 当场自检（本轮，owner 提示之后）

按上述判据量剩余 11 个模块：`DataBar`（8 字段，被 `working_databar` /
`databar_list` 持有、`sourcebar.to_databar` 出生）、`YinLeaf` / `YangLeaf`、
`YinBranch` / `YangBranch`（owner 逐字命名，被 `Timeframe` 的 growing /
settled 字段持有）、`Signal`、`Kline`、`Interval`、`Symbol`、`SourceBar`
均有可指认的持有者或出生点，**无第二个纯空壳**。但 `databar.gleam:20-25`
仍留着同一句「`///` doc 即合法骨架 / No function on purpose」，本轮改掉，
换成具体的读者 / 写者。

**诚实标注**：这一轮仍是 **owner 点出之后**的开卷自检，不能算「无提示
自行发现」。后者**尚未实测**，不预写成功；留待下一轮由实际发生来填。

**Landed in**：`src/glibe/databar.gleam`、
`~/.workbuddy/skills/gleam-document-led-tdd/SKILL.md`、
05-01-PLAN §5.2、本文件。决策区仍 **0 项**；**未 push**。

---

## R48 — 「自己的 settings」讲不通；warning 不是奖励，WAE 是固定门禁（2026-11-12 12:27 owner 裁定）

**owner 原话（逐字）：**
> *"如果是当作一个字段放在timeframe里面，请问timeframe里面怎么可能有一个
> 自己的settings？怎么可以讲得通？至于说把warnings当作奖励，也是AI特有的
> 美德，所以你要用 gleam warnings-as-error 这个开关，具体你去看 gleam
> --help"* [user 2026-11-12]

### 1. 「Timeframe 持有自己的 settings」在关系上讲不通

R46 删掉了这个 type 和字段，但**只处理了名字出处，没处理关系**。R23 §1
末段（`:699-701`）保存着我当时的推理原文：

> *"这包数字是**某个 interval 的那台 Timeframe 跑起来用的参数**，一个
> interval 一份，因此只能是 `Timeframe` 的一个字段"*

这句话本身就是 R23 开头被 owner 质问的「绕圈子」，四层都站不住：

1. **和 R37 / R23 §2 直接矛盾**：`interval` **只在** `Instrument.timeframes`
   这个 Dict 的 **key** 里，`Timeframe` 不知道自己是哪个 interval（「左手
   不知道他是左还是右」）。一个按 interval 区分的参数，不可能属于一个
   不知道自己 interval 的值。「一个 interval 一份」恰恰证明它在 key 那一侧，
   不是塞回 value。我把「向上指认的字段」换了个名字又请回来了。
2. **和 R33 矛盾**：`Timeframe` 是纯值，一根 bar 到达就重算；它不「跑」
   任何东西。跑的是 `databar_processing` 里的步骤（indicator / leaves /
   branches / strategy）。参数属于**那些步骤** —— R40-A 明写步骤可以有任意
   额外参数、在 pipe 现场提供 —— 或在真是全局常量时属于 `Desk`（R42）。
   让值自带一份「关于自己怎么被算」的说明书，是把配置和状态混进同一个
   值里，且每个重算出的新值都要复制一遍。
3. **和 R34 / R32 矛盾**：ibOptions 把结构关系压进 `settings*.py` 是
   Python + pandas 的**局限**，不是设计；正确形状是一个设置 = **已有 type
   的一个 field**（R32 花园）。我造的却是「专门装设置的 type → 再塞进
   `Timeframe`」，等于把被否决的配置层重新发明一遍，还多一层自指。
4. **因果是反的**：R46 的 diff 只删了字段一行、import 一行、`READS` 里
   一个名字和 `new()`；其余 **8 个签名、10 个字段一字未动**。不是
   `Timeframe` 需要它，是**我为了让一个名字有落脚处，往 `Timeframe` 塞了
   一个 field** —— 关系由名字倒推出来，不是由现实倒推出来。

「怎么讲得通」的答案是**讲不通**；当时让它看上去讲得通的，只有 `///`
里四句「它不是什么」和 `////` 里「空 type 挂 `///` 即合法骨架」那张免检牌
（R47）。R23 §3 那句「`Timeframe` 持有 `settings`」已由本条整条划掉。

### 2. `--warnings-as-errors`：查过 help 之后的实测

`gleam --help`（1.19.2）全局只有 `-h` / `-V`。逐个查子命令，
**`--warnings-as-errors` 只存在于 `gleam build`**：

```
gleam build --help:
      --warnings-as-errors
          Consider the build failed if the package contains any warnings
```

`check` / `test` / `docs build` / `format` / `dev` / `compile-package` 的
help 里**都没有**这个开关。所以要让 warning 变成失败，唯一入口是
`gleam build --warnings-as-errors`；`gleam check` 再干净也替代不了它。
core §10 `:281`、§13 `:346`、§14 `:358` 三处早就写着这个命令 —— **卡片
写对了，CI 里没有，本地一次都没跑过**。

当前骨架实跑：`exit 1`，806 行，末尾
`error: 85 warnings generated. / Your project was compiled with the
--warnings-as-errors flag.` 85 条逐条印的是
`30 Todo found` + `52 Unused function argument` +
`3 Unused private constructor`。**这个数字不是成绩单**：它是 WAE 之后
编译器交出的、必须逐条读到行的清单；每填一个 body 少一条，全部填完才
归零。骨架阶段红是如实状态，不是失败判定，但**不许整包豁免**。

### 3. 作废「warning 合法」这张免检牌

以下都是我写下的、把 warning 归类为可忽略的文本，本条一并作废：
- 本文件 R19 第 2 步「warnings 合法，`--warnings-as-errors` 只是
  **GREEN gate**」（已改）；
- `gleam-language/references/gleam-core.md` §14 末句「therefore fails in
  the RED phase and is the GREEN gate」（已改）；
- skill `gleam-document-led-tdd` 第 3 步「Todo and unused-argument
  warnings are the expected skeleton shape, not failures」、第 6 步
  「GREEN gate, never a RED gate」（已改）。

R47 §1.1 实测过：`TimeframeSettings` 那个瞎编 type 唯一的报警就是
`timeframe.gleam:81:12 Unused function argument: settings`；我把 53 条同类
warning 整体归类为「expected shape」，信号就没了。**编译器报了，流程把它
定义成可忽略** —— 这就是 owner 说的「把 warnings 当作奖励」。WAE 之后
不再由我分类：任何 warning 都是构建失败，CI 里也挂这个开关（不是 guard
sh，是编译器自己的 flag，符合 R44）。

### 4. `_` 前缀是陷阱，不是解法（实测）

WAE 会给每条 unused argument 一个 hint：`_settings`。实测
`/tmp/underscore_probe`（Gleam 1.19.2）：把参数写成 `_a` 后，body 里引用
`_a` 报 `error: Syntax error / Found a discard name`；labelled 调用写成
`add(_a: 1)` 同样是语法错误。**`_name` 是 discard name，body 里永远不能
引用**，填实现时必须改回名字。所以按 hint 批量加 `_` 不是「消除问题」，
是**把一个空用信号永久静音** —— 若 R46 之前这么做了，那个瞎编 type 连
最后一条报警都不会有。禁止用 `_` 让一个还不知道「做什么 / 谁用 / 为什么
存在」的东西变干净；先跑 R47 三问，再决定是留参数还是删东西。

**Landed in**：`.github/workflows/test.yml`（加
`gleam build --warnings-as-errors`）、本文件 R19 / R23 §3 / R48、
`gleam-language/references/gleam-core.md` §14 及其仓库镜像、
skill `gleam-document-led-tdd`、05-01-PLAN §5.3 / §6、
`docs/STATE.md`、工作区记忆与当日日志。**`src/` 与 `test/` 未改一行**，
不用 `_` 洗信号。决策区仍 **0 项**；**未 push**。

---

## R49 — `new` 是 Python 式垃圾；见到即当 bug（2026-11-12 12:39 owner 裁定）

**owner 原话（逐字）：**
> *"为了这个毫无用处的field你确实编造了一个毫无用处的function叫做 new，而不
> 知道gleam里面很少需要这个所谓的new，python之类语言的垃圾，几乎见到new的
> 地方必定是bug存在的地方。"* [user 2026-11-12]

### 1. 实测：`new` 是为那个 field 编造出来的

R46 前 `timeframe.gleam:79-83`：

```gleam
/// A `Timeframe` born from its parameter block. There is no composite key,
/// no second settings dictionary and no `list.find` (R23).
pub fn new(settings: TimeframeSettings) -> Timeframe {
  todo as "05-01: one record, no key inside it"
}
```

它**唯一**的工作就是收一个不存在于设计里的参数；没有第二个调用方，`///`
里写的还是「它不是什么」。R46 删掉的清单是：字段一行、import 一行、
`READS` 里一个名字、**`new()` 一个函数**；其余 8 个函数签名、10 个字段
一字未动。**一个无用的 field 需要一个 `new` 来喂它，一个 `new` 又让这个
field 看起来有来处** —— 两者互相指认，正是 R46 / R48 说的循环论证，多出来
的第三个部件就是 `new` 这个 Python 式出生函数。

### 2. 裁定：见到 `new` 就当 bug，没有 container 豁免

- Gleam 里几乎没有 `new` 的位置：值是**构造**出来的，不是被某个
  `new()`「初始化」出来的；构造发生在**拥有它的地方**，不需要一个专门
  的、不说出「哪一次出生」的函数。
- `new` / `create` / `make` / `data` / `helper` / `manager` 命名的是机制，
  不是领域事实。出生函数若真有必要，**必须说出是哪一次出生**；说不出就
  不存在。
- **作废 core / SKILL.md 里那句「A container may be `new`」**：豁免一开，
  AI 就把它当许可证。今后**每一个 `new` 都先按 bug 查**，直到证明不是。
- 已改：`gleam-language/references/gleam-core.md` §3 示例
  `pub fn new(i: Int) -> PositiveInt` → `clamp_positive(...)`，§5 新增
  「No `new`」条目；`gleam-language/SKILL.md` 的 `<do_not>` 条目去掉豁免
  并写入本裁定；仓库镜像 `docs/gleam-thinking-core-to-memory.md` 同步
  （`cmp` 一致）。

### 3. 主动核验（本轮把尺子量到现行树）

- 现行 `src/` / `test/` 里 **`new` 零出现**（R46 已删净）；全部 38 个
  `pub fn` 逐个看过，没有第二个 `new` / `create` / `make` 出生函数。
- **但找到同类的第二处**：`src/glibe/config.gleam` 的 `////` 写着
  *"and R33 names `config.default_config()` as that one Value"*。回读
  R33（`:1090-1108`）的四段 **owner 逐字原话**，里面只命名了 `Desk`，
  **没有一个函数名**；`default_config()` 出自 R33 的**裁定正文（AI 散文）**。
  这与 R47 抓到的 `NoSuch*` / `idx` 是同一类假 verbatim，已改成如实标注
  词源；`default_config()` 本身保留（R33 裁定正文给出的系统起点值），
  但不再冒充 owner 逐字。
- 同文件还把 `default_config()` 称作 "this constructor"，并在 `///` 里
  写成 "A constructor literal, not a parsed config" —— 一个返回 `Desk`
  的函数不是 constructor literal。按 R47「`///` 能否译成谁读 / 写哪个
  具体值」改成：返回唯一顶层 `Desk`，body 是 Gleam 字面量，无 parser、
  无 `new` 式出生函数。**这是本轮 `new` 主题带出的 Python 式措辞残留。**

### 4. 落地与诚实标注

**Landed in**：`gleam-language` 的 `SKILL.md` 与
`references/gleam-core.md`、仓库镜像、`src/glibe/config.gleam`、
本文件 R49、05-01-PLAN §5.4、`docs/STATE.md`、工作区记忆、当日日志、
skill `gleam-document-led-tdd`。
**诚实标注**：本轮主动核验仍是在 owner 点出 `new` 之后启动的，查到的
`config.gleam` 假归属属于**同链条上的连带发现**，不算「无提示自行发现」；
后者**仍未实测**，不预写成功。决策区仍 **0 项**；**未 push**。

---

## R50 — 一个模块只读写它自己那一层；系统里永远只有一个 Desk（2026-11-12 深夜，owner 在 `src/glibe/desk.gleam` 留下的 12 条 `<**human: ...**>` review 评论）

### 1. owner 逐字（按文件顺序）

- 模块头：*"1) most of the code should not be here"*；
  *"2) there will always be only one desk in the system"*。
- `BrokerId` 上：*"try put all id types in one file/module, to avoid
  circular, and to make it easier to check"*。
- 九处 *"should be in its own file"*：`Account` / `Instrument` /
  `Broker` 三个 type，`broker_id` / `account_id`，
  `get_instrument` / `put_instrument` / `get_timeframe` / `put_timeframe`。
- `timeframe_under` 上：*"what is this for? no fn definition unless it is
  called somewhere; even if it is called, it should be defined in its
  belonging to module"*。
- `put_timeframe_under` 上：*"what? you ask a desk to do the things that
  should be done by the instrument? are you mad?"*。
- 追问：*"那些问题都很明显，我不说你自己看不出来混乱不堪的模块内容
  吗？"*

### 2. 裁定

1. **归属规则**：一个模块只读写**它自己那一层持有的 Dict**；函数跟着
   它读写的 Dict 的持有者走。`Broker` 按 R33 / R36 持有 `instruments`
   和 `accounts` **两个** Dict，两者都属于这一层，不因此拆模块。
   `get_account` / `put_account` owner 没有逐条点名，按同一条规则归
   `broker.gleam`（它们读写 `Broker.accounts`）——**这是把 owner 的
   规则再走一级，不是新造名字**。
2. **Desk 恒为一个**：无 `DeskId`、无第二个 Desk、无 Desk 集合、
   无 `AppConfig`；`config.default_config()` 是唯一出生点（R33 / R49）。
3. **删除 `timeframe_under` 与 `put_timeframe_under`**。前者零调用方，
   后者让根做叶子的活。**R42「倒推查出的真缺口 = WRITE 半边
   `put_timeframe_under`」整句作废**：那不是缺口。R38「一条到来的
   bar 按序调用 pair，没有第三个函数」本来就已经否掉它；每层调用
   **自己**的 read / write pair。
4. **所有 id 集中**到 `id.gleam`，且该模块**零 import**。
   **`LookupError` 删除**（见下方 §6 自查）：它是横跨四层的错误联合
   类型，`NoSuch*` 从来不是 owner 用词（R47），四个 `get_*` 改为
   `Result(value, Nil)`。

### 3. 两条编译器事实（`/tmp/glibe_split_probe`，Gleam 1.19.2 实测）

| 探针 | 编译器原文 | 结论 |
|---|---|---|
| `opaque` 构造子在别的模块被调用 | `error: Use of private value` … *"does define `BrokerId`, but it is private and cannot be accessed by other modules"* | `broker_id` / `account_id` 必须与 id type **同模块** |
| `a.gleam` ↔ `b.gleam` 互相 import | `error: Import cycle` … *"Gleam doesn't support dependency cycles like these, please break the cycle to continue."* | id 必须抽成**叶子**模块，否则 `desk ↔ broker` 成环 |

所以 owner 那句 *"to avoid circular"* 不是偏好，是编译期硬约束。

### 4. 为什么我没能自己看出来（诚实）

`desk.gleam` 的 `////` 里我自己写着 `WRITES: Desk, Broker,
Instrument, Account...`——**一个模块读写四个层级，这行字本身就是证据**，
我写了却没拿它去量这个文件。R47 的判据只用在「单条 `///` 能否译成
谁读写哪个具体值」，**没有用在「一个文件能否译成一条归属关系」**；
R42 我又给自己写过「链的各级服务集中在 `desk.gleam`」并援引
core §5 *"Do not fragment modules"* 当免检牌。该条官方反模式针对的是
**按设计模式切**（controllers / services / types / utilities），
不是按业务域归属切——属误读。
**本轮仍是 owner 点出之后的开卷自检；「无提示自行发现」仍未实测，
不预写成功。**

### 5. 落地与实测

`src/glibe/` 新增 `id.gleam`（2 type / 2 fn）、`account.gleam`（1 type）、
`instrument.gleam`（1 type / 2 fn）、`broker.gleam`（1 type / 4 fn）；
`desk.gleam` **233 行 → 56 行**（1 type / 2 fn），模块文档 62 → 35 行，
其余裁定的出处移回本文件。`test/glibe_test.gleam` 把钉着被删函数的
`desk_chain_shape_test` 换成 `chain_levels_shape_test` +
`identity_shape_test`。仍是零行实代码。

`gleam check` 0 · `gleam test` 0（9 passed）·
`gleam format --check src test` 0 · `gleam docs build` 0 ·
`gleam export package-interface --out` 0（14 模块 `////` 全渲染）·
`gleam build --warnings-as-errors` **exit 1 / 73 warnings**
（27 `Todo` + 43 `Unused function argument` + 3 `Unused private
constructor`）。R49 时是 85（30 / 52 / 3）：拆分层少 2 个 Todo +
9 个参数（删掉两个穿透函数），删 `config.gleam` 再少 1 个 Todo，
**没有一条 warning 被 `_` 静音**。

### 6. 二次自查（owner 追问：*"移出去的那些都放到那些模块了，
### 自己多检查思考哦，不要又是一锅粥"*）

**归属实测**（`package-interface.json` + import 图，单向无环）：

| 模块 | 自己持有 | 读写的 Dict | import |
|---|---|---|---|
| `id.gleam` | `BrokerId` / `AccountId` + 两个边界构造 | 无 | **零** |
| `account.gleam` | `Account` | 无 | **零** |
| `instrument.gleam` | `Instrument` + `get/put_timeframe` | `Instrument.timeframes` | `api/interval`, `timeframe` |
| `broker.gleam` | `Broker` + 四个 `get/put_*` | `instruments`, `accounts` | `account`, `api/symbol`, `id`, `instrument` |
| `desk.gleam` | `Desk` + `get/put_broker` | `Desk.brokers` | `broker`, `id` |

`config.gleam` 不在此表内 —— 见 §7，它已被删除。

**自己查出并修掉两处**（owner 未点名）：

1. **`LookupError` 不该存在**。第一遍拆分时把它塞进 `id.gleam`，
   那是又一小锅粥：它不是 id type，却横跨四层；更要紧的是
   `get_broker` 的返回类型允许返回 `NoSuchTimeframe(..)`——
   **格式正确、语义荒唐、无人反对**（core §2.2）。R37 说调用者
   本来就持有 key，错误里再带一次 key 是冗余；core §6「failure
   has nothing to say → `Nil`」；项目里 `api/interval.from_string`
   已是这个形状。⇒ 删除该 type，四个 `get_*` 改 `Result(v, Nil)`，
   `id.gleam` 变回「只有 id types、零 import」。
   **对照**：`SourceBarRejection` 是有具体原因的闭集错误，保留不动。
2. **规则措辞不准**。R50 §2 原写「一个模块只读写**一个** Dict」，
   但 `Broker` 按 R33 / R36 持有两个。改成「它自己那一层**持有的**
   Dict」。规则本身没变，是措辞曾经把设计说窄了。

复验：`check` 0 · `test` 9 passed（另删了 `config_shape_test`）·
`format --check` 0 · `docs build` 0 · `package-interface` 0 ·
**WAE 73（27 / 43 / 3）**。删掉一个 pub type 不改变 warning 数，
少的那 1 条来自 `default_config()` 的 Todo —— 说明 WAE 报的是
**还没写的函数体**，不是类型数量。

### 7. `config.gleam` 整体删除（owner 追问 *"desk -> config? ????"*，
### *"config 用来做什么的，你不知道？desk上面没有其他model你不知道？
### 瞎编什么鬼？"*）

**这是同一个错误换了个方向**。前六项我修的是「Desk 管了下面各层的
活」，这一项是「有个 module 管在 Desk **上面**」：`config.gleam`
`import glibe/desk`，`default_config() -> Desk`，自己没有 type、不读写
任何 Dict —— 它就是 R23 已经否掉的 `AppConfig` 那类东西，只是没叫
那个名字。R42 逐字 *"但是他上面不再有东西，这是设计要求"*；
R50 逐字 *"there will always be only one desk in the system"*。
只有一个 Value，就不需要一个「配置层」去生产它；R49 也说值在
**拥有它的地方**构造，不另设出生函数。

**我还编了一句关系**：`desk.gleam` 的 `////` 写着
`config.default_config() returns that one Value` —— 让根去指认谁
构造它，正是 R37「被持有者不指认持有者」的反面，也是 owner 那句
`"desk -> config?"` 抓到的东西。同一句在 `id.gleam` 里也有一份。

**处置**：`git rm src/glibe/config.gleam`；删
`test/glibe_test.gleam` 的 `import glibe/config` 与
`config_shape_test`（那是它唯一的「调用方」，还是一条空 shape
test，与 R50 删掉的 `timeframe_under` 同形）；两句文档关系删除，
改成「nothing sits above it to construct it」。**R49 里
「`default_config()` 本身保留」这句作废**：它当年是裁定了词源，
没有检查这个模块有没有存在理由。

**依赖方向**：`config → desk` 是 import 方向，不是 `desk → config`。
上一条回复我写「…→ `desk` → `config`，单向无环」时把**从叶子到根
的组装顺序**写成了箭头，读起来像根依赖上层 —— 表述错误，已更正。

决策区仍 **0 项**；**未 push**。

---

## 2026-11-13 — owner 逐字：工作方式（执行注记，非新裁定）

owner 2026-11-13 的 5 条逐字原话，原存于
`.codebuddy/CODEBUDDY.md`「工作方式（owner 逐字）」节。该文件是
「跨 WorkBuddy / CodeBuddy 会话入口」方案的产物，owner 逐字
*"里面什么乱七八糟的狗屁东西，什么都有"*、*"把我跟项目glibe有关的内容
放到合适的文档里面去，然后删掉这个垃圾文件"*，裁定删除。逐字按
`HANDOFF.md` §3「裁定全文与逐字原话在 `docs/RULINGS.md`」归位于此，
一字不改。**这不是新裁定**：不新增编号、不新增待裁决项、不据此改动
`src/` / `test/`。其余内容不归位，原因记在当日日志。

**owner 原话（逐字）**：

- *"我现在对AI的要求降低到听写这一层了。能智能化听写就不错"*（2026-11-13）
- *"不写实现，但是框架你搭建完整了吗？ / unit test这一步在框架初步建完，
  复查没问题之后。 / 下一步是填充具体实现。"*
- *"按照用户的指引，以及 business logic 去重新设计，框架搭建和测试不就是
  设计阶段吗"*
- *"继续做，直到做完。…你可以从任何一个点切入，跟着逻辑走，必然发现缺环，
  然后就去设计补上，等所有的通路都没有缺环，设计不就是完工了？"*
- *"关键是，你这次是把type搞对，也就是那一个type的对应模块做什么工作，
  这个分工搞清楚，不要搞得乱七八糟越俎代庖"*

第 4 条中间的 `…` 是原记录自带的省略，按 R43 不补全、不当完整逐字。
原文件另有两个不带引号的 AI 注记（「照逐字落，不自行推断…」、
「每次改动后回显…校对稿」），不是 owner 逐字，按 R43 / R47 不归位。

## 2026-11-14 — owner 逐字：push 不是破坏性动作（执行注记，非新裁定）

**owner 原话（逐字，2026-11-14）**：

- *"push本身又不是什么破坏性动作，哪有什么约定不能push，你不要push
  --force就行了。等你想用force的时候保管不回问我自己就上了，然后就灾难了"*

**查证**：owner 2026-11-09 的逐字只有 *"注意：.gitignore 及时更新，
及时做提交"*（`2026-11-09.md:110`），没有不 push 的要求；本文件此前
9 处「未 push」都是状态描述，不是裁定。`MEMORY.md` Conventions 里的
「do not push unless asked」是 AI 自己加在同一条后面的注记，被当成
owner 约定反复引用 —— 按 R46 / R49，AI 自己记录的裁定不是 owner
词汇，已删。owner 还点破了方向反了：真正破坏性的 `--force` 反倒
可能不问就上。

**执行边界**：普通 fast-forward `git push` 直接做、不逐次请示；任何
改写远端历史的操作（`--force`、`--force-with-lease`、rebase 后强推、
删除远端分支）必须先问 owner，不得自行上。**这不是新裁定**：不新增
编号、不新增待裁决项、不据此改动 `src/` / `test/`。

**实测**：`git merge-base --is-ancestor fb0082a HEAD` 为真 → 远端是本地
祖先；`git push --dry-run origin doc-tdd` 预演 `fb0082a..757cf63`；
普通 `git push origin doc-tdd` 后本地 HEAD、远端 `refs/heads/doc-tdd`、
`origin/doc-tdd` 三者同为 `757cf6367682299414a1d69ab7267089cfdcd2cd`。
全程无任何 force 参数。

---

## 2026-11-15 — owner 逐字：名词跟 Type 走、动词跟 function 走（执行注记，不新增编号）

**owner 原话（逐字，2026-11-15）**：

- *"1） 我仅仅评论了我恰好看到的几个文件中的一小部分内容，全面的类推需要你自己做
2） bucket这里，体现一个原则，就是不要用没有Type定义的名字去替换有Type的名字，这是bugs的隐形源头；所以这里最好用实际的type名，如果这个函数仅仅是用于 sourcebar 那么就用 sourcebar 不要用 bucket；对于一个kline或者sourcebar来说，完成了就是close了，这一点与 working databar 是否 archived 没有关系，注意你说是否关闭是另一个错误，动词游离于函数名之外，函数名是archived这是精心选择的，因为working_databar 早就closed了，这里working是我们系统让他承担的working还没有做完，做完了就不再working了，archived了。
3）你原来的命名掩盖了这个事实"*
- *"一根蜡烛线，他的open就是open的意思，他的close就是close的意思，没有其他意思，不要用started去替换open，也不要用ends去替换close，这些替换叫做无稽之谈，没有根据的术语替换。"*
- *"有些好的数据源，在一个蜡烛线没有close的时候，用的名字是 latest_price, or latest, they will only name a close price as close, but some will not have a close, just a latest price no matter it is ongoing or is closed, that is lazy but still not incorrect. since the close price is also latest."*
- *"latest_price is not found in binance and ib bars, so don't worry."*
- *"in a strict typed language, nouns and verbs should not be used without concerning, they should go after types and functions, so each of the terms you use will not cause trouble and misunderstanding. However, even in a language like Smalltalk, nouns and verbs are still be used very carefully, or even more carefully. for example, Dan Ingles chosed inject,reject,sellect,collect,detect for collection methods, how careful and beautiful. Ohter languages which are loosely designed never consider these."*

以上逐字含 owner 原有的拼写（`sellect` / `chosed` / `Ohter`），按 R43
不补全、不修饰。**不新增 R 编号、不新增待裁决项**：这是 R19 / R21 / R47
在命名上的一次收窄，落点是 `src/` / `test/` 已有的骨架与文档；本轮据此
改了名字与文档，**不改结构、不新增 type / field / 函数**。

### 查证与判据

- owner 在 `src/glibe/api/interval.gleam` 留下的 in-code review 建议
  `bar_close` / `bar_closes` / `bar_closed`，并要求查官方 naming
  conventions（该行 `<**human: …**>` 原文与 URL 留在代码里，此处不重抄）。
  官方 `conventions-patterns-and-anti-patterns/` 页（2026-11-15 WebFetch
  逐字，见 `.workbuddy/memory/2026-11-15.md`「官方命名惯例」）**没有**
  Bool / predicate 函数、动词时态或 labelled args 的规定；签名
  `(Interval, Timestamp) -> Bool` 里也没有 bar。按上面第 1 条，`bar` 同样
  没有 Type 支撑（glibe 里只有 `SourceBar` / `DataBar`），故取
  **`sourcebar_closed`**：名词取 Type 名，`close` 是蜡烛线本义且**留在
  函数名里**。过去分词与 owner 逐字 `working_databar_archived` 同形，两者
  是不同的值：`SourceBar` 在其周期完成时 closed，而 `working_databar`
  入场时早已 closed，`archived` 指系统指派给它的 working 做完。
- **`latest_price` 边界**：owner 明确 Binance 与 IB bars 里都没有这个词 →
  不引入、不拿它改名。源码里的 `latest close` 出现在 seib `joinNew` 的
  **设计证据**段（`api/sourcebar.gleam`、`ib/sourcebar.gleam`），是第 3 条
  说的合法蕴含词，保留。
- **保护不动**：`working_databar_archived`（owner 逐字，不是 `closed` 的
  同义词）、`open` / `close` 字段、`start_bar` / `end_bar` / `corner_bar` /
  `enter_bar` / `exit_bar` / `last_bar`（owner 逐字字段名）、provider 原生
  `open_time` / `wap` / `count`、`arriving`、`latest close`，以及散文中作
  「结束」讲的 `ends`（`That accumulation ends…`、`both ends included`）——
  第 2 条否的是拿 `ends` **替换 `close`**，不是这个英语动词本身。

### 落实（全面类推，不止 owner 恰好看到的几行）

| 原 | 现 | 依据 |
|---|---|---|
| `interval.bucket_ends` | `interval.sourcebar_closed` | `bucket` 无 Type；`SourceBar` 有 |
| 参数 `instant: Timestamp` | `timestamp: Timestamp` | 名词跟 Type 走 |
| 局部变量 `instant` | `open_time`（provider 字段名） | R28 provider 原生形状 |
| `finished` / `unclosed` / `finished_target_sourcebar` | `closed` / `has not closed` / `closed_sourcebar` | 第 1 条：完成就是 close |
| `bar` 参数（`validate` / `to_databar` / test helper / assert） | `sourcebar` | `bar` 无 Type |
| `THIS IS NOT THE BUCKET` / `No bucket accumulator` | `working_databar` / `SourceBar` accumulator | 同上 |
| `sourcebar.interval(of: bar)` 文档示例 | `of: sourcebar` | 同上 |

覆盖 `api/interval`、`api/sourcebar`、`databar`、`timeframe`、
`instrument`、`ib/sourcebar`、`binance/kline`、`test/glibe_test`。
新增 `sourcebar_closed_shape_test` 钉住 `fn(Interval, Timestamp) -> Bool`
（RED `Unknown module value: interval.sourcebar_closed` → GREEN
`15 passed, no failures`）。**编译器实测**：`let assert Ok(sourcebar)` 与
同作用域的 `sourcebar.SourceBarOneMinute(..)` 共存无遮蔽错误；
`open_time:` shorthand 合法。

门禁：`format --check src test` 0 · `check` 0 · `test` 0（15 passed）·
`docs build` 0 · `export package-interface` 0 · `build` 0；
`build --warnings-as-errors` **exit 1**，198 warnings =
77 `Todo found` + 118 `Unused function argument` + 1 `Unreachable pattern`
+ 2 `Unused private constructor`，与 11-15 日志的 198 / 77 逐条相同 →
本轮**零静音、零新增 TODO**（R48）。`package-interface.json`：
`modules: 15`；`glibe/api/interval` 的 `functions` =
`from_string` / `sourcebar_closed` / `to_string`，模块 `documentation`
41 行完整、无 `//` 截断。

### 历史文档不改写

`docs/RULINGS.md` R29 等历史节、`docs/STATE.md` 历史节、
`.planning/` 旧阶段计划、append-only 日志里的 `bucket_ends` 是**当时的
记录**，不改原文，只在 `05-01-PLAN.md` §8 与本文档加 dated 注记；
当前状态节单独更新。

---

## 2026-11-15 07:04–07:12 — owner 逐字：`bars_listed` 读头不数表、倒叙归档是针对 Gleam `List` 的刻意设计、`symbol.to_string`（执行注记，不新增编号、不新增待裁决项）

**owner 原话（逐字，2026-11-15）**：

- *"I have just seen your bars_listed, guess it be a function? I commented on
  that."*
- owner 在 `src/glibe/databar.gleam` 的 `DataBar.idx` 文档末尾留下的
  in-code review（逐字，含原有拼写 `funtion`）：
  *"here you should be careful: the bars_listed if is used anywhere, the
  funtion should be defined not to count but to calculate by the first one's
  idx in the databar_list, that is the idx + 1."*
- *"if you are to count the elements in a gleam list, gleam docs tell you
  that will be very ineffecient action. list is not an array, and is NOT a
  list you see in other languages."*
- *"你可直接将实现写出来，以免以后搞错了"*
- *"list倒叙归档是我特别设计的，针对gleam list的设计特点。所以凡遇到此类
  list相关的函数，以及成员的获取，一定要十分仔细，不要设计得好好的却不用，
  去用非常蠢笨的方法，导致极低效率。"*
- *"symbol.symbol_to_string will look odd, so the official docs treat it as
  bad, I haven't noticed the module file name, so that should have been
  to_string, so it reads symbol.to_string when called"*

以上逐字含 owner 原有拼写（`ineffecient` / `funtion` / `guess it be a
function`），按 R43 不补全、不修饰。**这不是新 R 编号**：R39 已定
`bars_listed` 的名字与出处，官方 conventions 早已是项目采用的规则；
本轮只是把「怎么实现」与「怎么取名」按已定设计落在 `src/` / `test/`，
决策区仍 **0 项**。

### 查证（代码，不是文档推断）

- **owner 问的 `bars_listed` 确实是函数**：`src/glibe/timeframe.gleam`
  的 `pub fn bars_listed(databar_list: List(DataBar)) -> Int`，本轮之前
  body 是 `todo as "05-01: count the settled bars"`，`test/glibe_test.gleam`
  只有 `bars_listed_shape_test` 绑定签名；`src/` 里**当时没有调用点**，
  三处文档却写成「counts」（`timeframe.gleam` 函数文档、
  `databar.gleam` 的 `idx` 文档、test 文档）。措辞与实现方向都错。
- **glib 代码**（R42 / R43，对照实现而非 AI 散文）：
  `glib/src/glib/timeframe.gleam:827-833` 的 `bars_listed` 是
  `case list.first(databar_list) { Ok(bar) -> bar.idx + 1  Error(_) -> 0 }`；
  `:99` 明写 head bar *"is* the count"*、*"O(1) on a cons list and cannot
  drift"*；`:848` 的 `working_databar_archived` 是
  `databar_list: [databar, ..timeframe.databar_list]`，**prepend**，
  databar_list newest-first；`:280` / `:602` 的「上一根」一律
  `list.first`。`branch.gleam:271` 的 `exited_branch` 也只读头；
  `leaf.gleam:113` / `:129` 的 CMA 递推明写 *"O(1) by `list.first`
  because the list is newest-first"*，替代「走每一根 bar」的旧算法；
  `leaf.gleam:45-49` / `branch.gleam:96-99` 的 size 是两个 `idx` 相减
  +1，不遍历。
- **官方命名惯例**：`x_to_y`；module 名与 type 名相同时**省略前缀**
  （`identifier.to_string` Good / `identifier_to_string` Bad）。
  `symbol.gleam` 的 module 就是 type 名，故 `symbol.symbol_to_string`
  是 Bad 形，应为 `symbol.to_string`。owner 明说自己先前那条 in-code
  review（*"use symbol_to_string to convert a symbol to a string"*）是
  *"I haven't noticed the module file name"* —— 按「owner 当前说法 >
  先前 comment」，本轮据此改名；**该 `<**human: …**>` 行逐字保留在代码
  里**（与 `interval.gleam` 那条未被采纳的 review 同一处置），不删 owner
  的字，也不把它当规格。`trading/signal.to_string` /
  `api/interval.to_string` 已是同一形状。

### 落实

| 落点 | 本轮之前 | 本轮 |
|---|---|---|
| `timeframe.bars_listed` | `todo as "count the settled bars"` | `case databar_list { [] -> 0  [newest, ..] -> newest.idx + 1 }`，直接取链表头 O(1)，不 import `gleam/list` |
| `timeframe.working_databar_archived` todo | "bar **appended** to databar_list" | "bar **prepended** to the HEAD … O(1), newest stays first" |
| `branch.exited_branch` todo | "read the first branch whose …" 像 `list.find` | "read the HEAD branch in O(1)"；函数文档补「Never `list.find`」 |
| `branch.branch_size` / `leaf.leaf_size` todo | "count from … idx" | "idx arithmetic … never walk" |
| `leaf.cma_recurrence` / `leaf_cma` | 文档只说读头 / todo 说 "average … over the leaf's own bars" | 明写 O(1) 头读取、never walk；todo 指向 `cma_recurrence` |
| `databar.gleam` `idx` 文档 / test 文档 | "counts the archived bars" | "reads this value off the HEAD bar and returns `idx + 1`" |
| `symbol.symbol_to_string` | `symbol.symbol_to_string` | **`symbol.to_string`**（`//// R19 status` 与 test 绑定同步） |
| `R19 status` 两处 | 自称「全是 todo」「一个断言」 | 改为「`bars_listed` 已填、其余 todo」「两个断言」 |

**RED → GREEN（R19）**：新增 `bars_listed_reads_head_idx_test`，用
`idx: 41` 的头 bar + 一根更旧的 bar，断言答案 **42 而不是 List 长度
2**，另断言空表 **0**；body 仍是 `todo` 时 RED（`15 passed, 1 failures`，
`todo src/glibe/timeframe.gleam:192`），填入实现后 GREEN
（`16 passed, no failures`）。这个断言特意让 `list.length` 的实现必红。

**门禁**：`format --check src test` 0 · `check` 0 · `test` 0（16 passed）·
`docs build` 0 · `export package-interface` 0 · `build` 0；
`build --warnings-as-errors` **exit 1**，196 warnings =
76 `Todo found` + 117 `Unused function argument` + 1 `Unreachable pattern`
+ 2 `Unused private constructor`。相对上一轮 198 / 77 / 118：
填掉 1 个 `Todo`、消掉 1 个 unused argument（该参数现在真被读取），
其余逐条相同 → **零静音、零新增 TODO**（R48）。
`package-interface.json`：`modules: 15`；`glibe/api/symbol` functions =
`string_to_symbol` / `to_string`；`glibe/timeframe` functions 含
`bars_listed`；`to_string` 与 `bars_listed` 的 `documentation` 完整渲染、
无 `//` 截断。

**不改写**：`docs/RULINGS.md` R29 / R39 / R43 历史节、`docs/STATE.md`
历史节、旧 `.planning` 阶段计划、append-only 日志里的 `bucket_ends` /
`bars_listed` 旧措辞保持原文；只在 `05-01-PLAN.md` §9、本文档与当前
状态节加 dated 注记。

---

## 2026-11-15 07:31 — owner 逐字：把 list 效率设计写进 README / DEVELOPER GUIDE、`idx` 的原因、所有此类 list 同理类推、文档先导 TDD 是根本措施（执行注记，不新增编号、不新增待裁决项）

**性质**：owner 要求把**既有设计**叙述到两份面向开发者的文档里，并说明
为什么这样设计。不是新裁定，不改 `src/` / `test/`，不新增 R 编号，
不新增待裁决项。决策区仍 0 项。owner 对参照实现的前提声明一并照录：
*"其中AI是否100%按照我设计去实现我也不知道，至少凡是我看到过的错误
都纠正过来了"*。

### owner 逐字（四条，原样）

1. *"你可以结合glib代码（其中AI是否100%按照我设计去实现我也不知道，
至少凡是我看到过的错误都纠正过来了）在README和 DEVELOPER GUIDE里面，
特别叙述一下本系统中若干list的效率设计，和高效率的用法。整体设计是
非常精巧的。不是粗心大意随便一看文件名瞎猜一下就能用好的。"*
2. *"为什么databar和sourcebar不一样，databar自带一个idx，原因也是如此。
这是效率最高的做法。"*
3. *"注意不仅是 databar_list, 所有的需要反复提取计算长度的list，同理
类推，都应该倒叙归档，如果glib AI没有100%这么做，那说明要么搞错了，
要么是一个非数据类的很小的不会无限增长的list，
或许都不应该用list的list。"*
4. *"与此弱相关，在你刚才处理大量代码文件却不曾写多少代码的过程中，
你应该感悟到了，文档先导的tdd模式会强迫你把gleam document做踏实，
因为不然你将来将没法知道怎么实现那些空架子。这是一个根本性的措施。
否则都是没有好好写文档的代码文件，逐渐的代码就乱掉了，因为与设计
思路完全脱节，天马行空放飞自我了。"*

### 查证（本轮实读，非推理）

**官方**：WebFetch `hexdocs.pm/gleam_stdlib/gleam/list.html`（v1.0.5，
与 `gleam-core.md` §8 的版本一致）。模块头逐字：*"New elements can be
added and removed from the front of a list in constant time, while adding
and removing from the end requires traversing and copying the whole list,
so keep this in mind when designing your programs."*；`length` 逐字
*"This function has to traverse the list to determine the number of
elements, so it runs in linear time. This function is natively
implemented by the virtual machine and is highly optimised."*；
`append` *"runs in linear time, and it traverses and copies the first
list"*；`last` / `reverse` 同为 linear time。**即便 VM 优化仍是 O(n)**，
放进每根 bar 的路径即 O(n²)。`gleam-core.md` §3：`List` 是 immutable
singly-linked list，`[x, ..rest]` prepend O(1)。

**glib 代码（file:line 均在 `glib/src/glib/` 下）**：

- `timeframe.gleam:97-105`：原 carried count 字段整个删掉，明写 head
  bar *"is* the count"*、`list.first(databar_list).idx + 1` 是
  *"O(1) on a cons list and cannot drift"*，实测 1001 根 bar 0 次
  disagreement；`:96` 字段、`:827` `bars_listed`、`:848` prepend、
  `:280` / `:601` 一切「上一根」只读头；`:295` 调用点就是
  `to_databar(sourcebar, bars_listed(timeframe.databar_list))`。
- `databar.gleam:29-34`：`idx` 定义逐字 *"a bar knows where it stands,
  so a structure can name a **bar** instead of a number and still measure
  a size or a span in O(1)"*；`sourcebar.gleam:115` 起九个变体逐字
  核对过，字段只有 `date` 与 OHLCV，**没有 `idx`**。
- 「同理类推」的其余数据 List：`timeframe.gleam:146-149`
  `sourcebar_buffer`（`sourcebar_export.gleam:45` prepend，
  `trading/export.gleam:24` 出口一次 reverse）、`:127-128`
  `signif_*_leaf_list`（`:549` / `:555` prepend）、`:144-145`
  `yin/yang_branch_list`（`:690` / `:694` prepend，`:746` 经
  `branch.exited_branch` 读头）。**全部倒叙归档**。
- `idx` 把数数换成相减：`leaf.gleam:45-49` `leaf_size`、
  `branch.gleam:96-99` `branch_size`、`leaf.gleam:119`
  `cma_recurrence` 的 `N_old`、`kdj.gleam:79-95` 用缓存
  `kdj_h_idx` / `kdj_l_idx` 判离场 bar 从而只在罕有路径重扫窗口、
  `branch.gleam:267-280` `exit_bar.idx == idx` 只读头。

**按 owner 第 3 条的三类例外分类（说明，不宣布 glib 全对）**：
(a) 有界窗口 `sma.gleam:69` `list.split(databar_list, size-1)`、
`:75` 的 `list.length(settled)`、`kdj.gleam:124`
`list.take(databar_list, w-1)` 只走常数窗口，不随历史增长；
(b) 输出侧**一次性** reverse：`trading/export.gleam:24`、
`trading/ingest.gleam:164`，`trading/live.gleam:129-131` 注释明写
逐行 `list.append` 是 O(n²) 故改 prepend + 一次 reverse；
(c) 非数据类小 list：`execution/risk_manager.gleam` 的
`RiskResult.results`（`:358` 一次 reverse）、`trades_today` /
`last_trade_times`（`:57-58`、`:146` 按日重置、`:377` `list.find`）、
`web/branch_view.gleam:142-147` 视图投影；这类也许本该是 type / Dict
而非 List，即 owner 说的「或许都不应该用 list」。
另有 `timeframe.gleam:461` / `:469` 的 `list.length` 在
`is_product_version || { … }` 的开发期 at-home test 里
（`config.gleam:86` 当前 `False`），不是生产路径，不构成许可。

### 落实

- 新建 **`DEVELOPER_GUIDE.md`**（根，10 节）：路径约定；「不能按名字猜」
  三个反例（`bars_listed` 不 count、`last_bar` 读头、`exited_branch`
  不 find）；官方逐字；倒叙归档不变量；`DataBar.idx` vs `SourceBar`
  专节；所有数据 List 一览；DO / DON'T；三类例外；**骨架 `todo`
  填写对照表**；文档先导 TDD 为何是根本措施；门禁；边界。
  文中每个 identifier 与 `file:line` 都实读核对（37 条路径引用全部
  解析成功，行号抽查内容吻合），Gleam 片段只取自已编译的
  `src/glibe/timeframe.gleam:191` 与对应 glib 实现。
- **`README.md`**：修正两处已成假话的措辞——"Every function body is
  `todo as \"...\"`" → "Most … `todo`"，以及把「设计不在 prose
  documents 里」改成「规格是代码内 `////` / `///`（编译产物核对），
  GUIDE 是导航不是第二份规格」；新增英文小节
  *The lists are newest-first on purpose* 与 GUIDE 链接。
- **`docs/HANDOFF.md`** 顶部导航区加一行指向 GUIDE（quote 块，不改
  任何历史节数字）。
- `docs/STATE.md` 新增 07:31 当前状态节；`.workbuddy/memory/2026-11-15.md`
  append；`.workbuddy/memory/MEMORY.md` State 同步。
- **`src/` / `test/` 一行未改**；`docs/PENDING_DECISIONS.md`、
  `.planning/` 阶段计划不动。

---

## 2026-11-15 07:42 — owner 逐字：倒叙 List 怎样给图表用、`reverse` 为什么不是低效（执行注记，不新增编号、不新增待裁决项）

**owner 原话（逐字）**：*"等你弄完了，问你一个问题，如果list的data都是按照
时间顺序倒过来放的，那么在系统中，是不是有时候要用revert来把他顺过来
才好用呢？那样不还是低效率吗？比如画图，你怎不能倒过来制作chart吧？
这里面涉及另一个系统效率设计的关键措施。"*

### 术语落点

owner 写的是 `revert`；官方 stdlib 的函数名是 `list.reverse`
（`gleam_stdlib` v1.0.5 `gleam/list`，逐字见 07:31 注记 /
`DEVELOPER_GUIDE.md` §2），本项目与 glib 里都没有名为 `revert` 的函数。
按「动词跟 function 走」，代码与本文只用 `reverse`。**这不是更正 owner
用词，是把术语落到真实函数上。**

### 查证（glib 代码，不是 glib 的 `docs/`）

owner 已声明 *"其中AI是否100%按照我设计去实现我也不知道"*，故下面是
代码事实，不是「glib 全对」的宣告。

1. `grep -rn "list.reverse" ../glib/src --include='*.gleam'` 实测 **7 处**：
   `census.gleam:172/213/363`、`execution/risk_manager.gleam:358`、
   `trading/live.gleam:130`、`trading/ingest.gleam:164`、
   `trading/export.gleam:24`。**没有一处在每根 bar 的
   `databar_processing` 路径上**：`:164` 是 replay 跑完后的页面初始绘制
   一次，`:24` 是退出写导出文件一次，其余是离线报告 / 有界窗口 /
   固定条数检查结果。
2. `glib/trading/ingest.gleam:151-154` 注释逐字：*"The bars go
   **newest-first inside the engine** (DESIGN §15) but are handed over
   oldest-first, because the chart extends forward in time. Reversing is
   not treatment — every value is exactly what `working_databar_archived`
   stored."*
3. **实时链路（每根 bar）**：`glib/timeframe.gleam:448`
   `publish_model(timeframe)` → `glib/web/server.gleam:57` / `:62`
   只取 `model.working_databar` 一根（`None -> Nil`，被拒的 bar 不占任何
   字段）→ `:110` `broadcast_chart` →
   `glib/web/server_ffi.mjs:429` SSE `chart_data` 发一根 →
   `glib/priv/index.html:768` `appendBar` → `:691-705` 每条 series 各一次
   `series.update`。`server_ffi.mjs:417-419` 逐字：*"send ONE finished
   DataBar over SSE `chart_data` (not an array) … history and live are
   indistinguishable because both flow through sourcebar_gate."*
4. **初始绘制走同一个函数**：`glib/priv/index.html:736-737`
   `paintDatabars(bars) { bars.forEach(appendBar) }`；`:644` 逐字
   *"No `setData` anywhere"*（bulk load 会 REPLACE 整条 series，抹掉已画的
   调试证据）；`glib/trading/ingest.gleam:1-8` 逐字 *"history is the same
   stream as live … no bulk seed, no `setData`, and no second pipeline"*。
5. **没有第二份顺序数据**：`glib/web/server_ffi.mjs:20` 逐字 *"What the
   ENGINE has archived, per symbol — not a second source of bars"*；
   `:32-38` 的 `gleam_list_to_array` 是那一次遍历；JS 数组尾部 `push`
   与 `series.update` 都是 O(1)。
6. 输出侧容器由用途决定：`glib/sourcebar_export.gleam:26-27` 逐字
   *"one positional JSON array, oldest-first … the file is read whole,
   sequentially, once, which is what an array is for."* 计算侧用链表
   （头部 O(1)），输出侧用数组（顺序读一次）。

### 判据与结论（不是新裁定）

- **是，要顺过来；但不是「每次画都 reverse」。** 问句里的「另一个关键
  措施」= **输出侧投影 + 单条增量流**：引擎只保存倒序那一份；顺序是它在
  输出边界的一次投影；之后每根 bar 只发一根、输出端只做 O(1) 追加。
- **效率算术**：若引擎按 oldest-first 存，每根 bar 写入 `list.append`
  O(n)、取「上一根」`list.last` O(n)、为保持图表顺序还得 reverse O(n)，
  N 根累计 **O(N²)**；现在是 prepend O(1) + 读头 O(1) + 广播一根 O(1)，
  N 根 **O(N)**，外加初始绘制 / 导出各一次 O(N)。reverse 本身确是 O(n)
  （官方逐字），但它挂在**「人打开一次页面 / 退出一次导出」**的频率上，
  不在**「数据到达 N 次」**的频率上。
- **与既有裁定的关系**：R30 正文定的是「标准层与显示层分开 … 同一个
  绝对时刻在标准层只存一份，显示层是它的一个投影 … 不得为了显示把标准
  类型改回日期字符串」。**顺序是同一条原则的同构应用**——不得为了画图
  把存储改回顺序。R20 `dashboard = VIEW`、R33（一条流、纯值重算、无
  actor / scheduler / clock / poll）、R38（流没有倒带）共同保证新 bar
  天然按时间先后到达，输出端只管追加。代码侧对应
  `src/glibe/desk.gleam:32-35` / `src/glibe/api/interval.gleam:30-31`。
- **本注记不是新裁定，不新增 R 编号、不新增待裁决项、不改 `src/` /
  `test/`。** 07:31 注记里把「输出侧一次性 reverse」列为「三类例外 (b)」
  是当时的分类；按 owner 本条，它升格为**第二个关键措施**。

### 落地

- `DEVELOPER_GUIDE.md`：路径约定补 `glib/priv/` 与 `glib/web/*.mjs`；
  新增 **§6**（边界一次 reverse / 单条增量流链路 / 效率算术 / 与 R30
  同构）；§3.1、§5、§8 的交叉引用更新；§7(b) 从「例外」改述为「§6
  措施在文件边界的形态」；原 §6–§10 顺延为 §7–§11。
- `README.md`：英文小节加一段 *The chart is not drawn backwards*，指向 §6。
- `docs/STATE.md` 新增 07:42 当前状态节；`.workbuddy/memory/2026-11-15.md`
  append；`.workbuddy/memory/MEMORY.md` State 同步。
- §6 新增的 20 条 `file:line` 按路径约定全部解析成功、抽查内容吻合；
  `src/` / `test/` 一行未改。历史节与 append-only 日志原文不改写。

---

## 2026-11-15 07:59 — owner 逐字：关键技术是 stream 模式、绘图软件的第一条判据、以及对每处 `reverse` 的追问（执行注记，不新增编号）

**owner 原话（逐字，2026-11-15 07:59）**：

> 我来回答我自己的问题：关键技术是stream模式，纵有万千条k线，系统里面其实只有一根在工作，那就是 working_databar, you almost always only need that one databar.
>
> 所以我们去找绘图软件或者自己做绘图软件 see project try_plushie 其中第一条看是否支持单根bar更新chart，如果不能，那么我们的系统不能用他。
>
> However, as you mentioned, glib has 7 positions where list.revers() is found, that smells. Was glib doing properly? You have to ask.
>
> For example, can it not use reverse when doing sourcebar_list exporting (for potential later offline tests only)? The same question should be asked if there are other ocassions reverse() is used on a list

（`list.revers()` / `ocassions` 两处拼写照抄，不作更正。）

### 本注记的性质

owner 是在**回答他自己 07:42 的问题**，并给出判据，然后要求我对每处
`reverse` **提出同一个问题**、不得自行宣布 glib 做对了。因此本注记是
**逐字归位 + 查证 + 提问**，不是新裁定、不是 R 编号、不替 glib 辩护，
也不改 `src/` / `test/`。07:42 注记里那句「没有一处挂在每根 bar 的
`databar_processing` 路径上」是对 **7 处 Gleam `list.reverse`** 的计数陈述；
它不能推广成「glib 整体做对了」——下面 §B 检出两处 JS FFI 的
`.reverse()` 正挂在高频路径上。

### A. 判据：系统里只有一根 bar 在工作

owner 这句与既有裁定同向，不是新机制：R33（一条流、纯值重算、无
actor / scheduler / clock / poll）、R38（流没有倒带，一根到达的 bar
按顺序调用那一对函数）、R39（全部计算在 `working_databar` 里，
做完才 archived 进 `databar_list`）。`src/glibe/timeframe.gleam:106-120`
的 `Timeframe` 里，`working_databar: Option(DataBar)` 是那**一根**，
`databar_list` 是归档历史。**任何「把整条历史翻一遍」的动作，都意味着
某个消费方在要整个历史，而不是要那一根**——这正是 owner 说的
*"that smells"* 的判据。

### B. 逐处查证（glib 代码与 try_plushie 源码，不是 glib `docs/`）

**B.1 `*.gleam` 内 7 处 `list.reverse`**（07:42 已记，此处补触发频率）：

| 位置 | 什么时候跑 | 翻的是整条历史吗 |
|---|---|---|
| `glib/trading/export.gleam:24` | 退出时 `export_flush` 写一次 | 是，`sourcebar_buffer` |
| `glib/trading/ingest.gleam:164` | `run_offline` / `run_online` 末尾各一次（`:109` / `:143`） | 是，`databar_list` |
| `glib/census.gleam:213` | 离线 branch 报告开头一次 | 是，`tf.databar_list` |
| `glib/census.gleam:172` | 每个 branch group 打印前 | 否，分组后的小表 |
| `glib/census.gleam:363` | `extreme_indices` 的 fold 末尾 | 否，fold 累积出的极值下标 |
| `glib/trading/live.gleam:130` | 一次 poll 窗口 decode 完 | 否，有界窗口 |
| `glib/execution/risk_manager.gleam:358` | 每次风控检查 | 否，7 项固定检查结果 |

**B.2 另有 2 处 JS FFI 的 `.reverse()`，07:42 注记漏记，且都挂在高频路径上**：

- `glib/binance_trading_ffi.mjs:36-38` `chart_bars()` =
  `timeframe.databar_list.toArray().slice().reverse()`；`:81` 在
  `set_symbol_state` 里调它。`apply_bar()`（`:49`，注释逐字 *"One place
  where an archived bar is turned into position, P&L and the shared state
  the dashboard reads — identical whether the bar arrived from the initial
  replay, a socket frame, or a poll"*）在 `:170`（seed）、`:227`（ws
  update）、`:282`（poll）三处被调用 ⇒ **每根 bar 都把整个
  `databar_list` 转成数组再翻一遍**，O(N²)。
- `glib/paper_trading_ffi.mjs:273`
  `chartBars = archived.slice().reverse()`，位于 `while (tradingState)`
  的 poll 循环（`:188`），**每次 poll 都翻一次**，即使
  `fresh.length == 0`（没有新 bar）。

这两处不在「7 处 Gleam `list.reverse`」里，但恰恰是 owner 的 stream
判据最该问的两处：它们要的是整个历史，不是那一根 bar。

**B.3 `sourcebar_list` 导出能不能不用 reverse（owner 点名的例子）**：

事实链（全部读过）：

1. `glib/timeframe.gleam:146-149` `sourcebar_buffer: List(SourceBar)`，
   注释逐字 *"Newest-first like `databar_list`, so capture is O(1);
   `export_flush` reverses it once, at the single write."*
2. 每根 closed bar 在 `glib/timeframe.gleam:235` 调
   `sourcebar_export.accumulate`（`:41-46` `[sourcebar, ..buffer]`）prepend。
3. `glib/sourcebar_export.gleam:26-27` 逐字 *"one positional JSON array,
   oldest-first … the file is read whole, sequentially, once, which is what
   an array is for"*；`:28-30` `to_json` → `encode_sourcebar_list`。
4. `glib/sourcebar.gleam:534-535`
   `json.array(sourcebar_list, of: encode_bar)` **保序**；
   `:515-518` `decode.list(of: decode_bar(interval))` 也**保序**。
   `glib/sourcebar_export.gleam:145` `json.parse(payload,
   decode_sourcebar_list(interval))` 读回来按文件顺序逐根喂同一条流。
5. `glib/sourcebar_export_ffi.mjs:44-48` 的 `flush()` 有
   `!wrote` 闸，逐字 *"Once per online session"*，调
   `engine.export_flush(latest)` 一次。

⇒ **答案（技术事实，不是裁定）**：直接删掉 `list.reverse` 会让文件变成
newest-first，读回来就是**倒着喂流**，不行；把 reverse 挪到读侧只是把
同一次 O(n) 换了个边，一帧没省。Gleam `List` 只能 O(1) 读头 / prepend
（官方逐字见 07:31 注记），从 newest-first 链表生成 oldest-first 数组
**必然要一次 O(n) 的反向遍历**，`list.reverse` 只是这次遍历的名字。

要真正不出现这次遍历，只有改变「攒一整份 buffer 再写」这件事本身：
① 每根 closed sourcebar 到达边界时顺手写一行（stream 写，无 buffer）；
② 干脆不要这条导出，离线测试从同一条流逐根读文件。
两者都回到 owner 那句「系统里其实只有一根在工作」。
`glibe` 的 `Timeframe`（`src/glibe/timeframe.gleam:106-120`）目前
**没有** `sourcebar_buffer` 字段，也没有 `export_flush`——这条路径在
glibe 尚未存在，是否引入需要 owner 逐字裁定。

**B.4 其余 6 处，按 owner 判据逐处提同一个问题**（不裁定）：

- `trading/ingest.gleam:164` → `web/server.gleam:152-161`
  `publish_databars` → `glib/web/server_ffi.mjs:42-44`
  `engineDatabars[key] = gleam_list_to_array(databar_list)`：这是一条
  **bulk 初始绘制**通道，交出去的是整个历史数组。按 stream 判据要问：
  历史既然「是同一条流的前段」（R38），初始绘制能不能也一根一根发，
  从而这处 reverse 与这份数组都不需要？
- `census.gleam:213` / `:172` / `:363`：离线报告。`:363` 是
  fold-prepend 后的一次 reverse，属「prepend O(1) 累积 + 一次 O(n)」的
  正确形状，改写法仍是同一次遍历；但 `:369-373` `in_span` 用
  `list.filter` + `list.length`、`:381-384` `age_of_last` 用 `list.last`
  且依赖 oldest-first 顺序，所以 `:213` 那次整表 reverse 是否可以
  换成读头 / `idx` 相减，值得问。
- `trading/live.gleam:130`：poll 窗口 decode 的 prepend + reverse，
  注释（`:125-129`）自己解释了「逐行 `list.append` 是 O(n²)」。
  但按 R33，这条 live 路径本身就是「poll」，与「无 poll」相冲。
- `execution/risk_manager.gleam:358`：`list.append` 累积 7 项
  （`:300`–`:355`）**之后**再 `list.reverse`。append 本已保序，
  reverse 把结果倒过来；这处最值得问「为什么」，且 `list.append`
  与 `gleam-core.md` §5 的禁令同形（虽 n=7 恒定）。

**B.5 `try_plushie` 的第一条判据（owner 点名）**：

- **框架机制够**：`plushie_gleam` 有 `Snapshot`/`Patch`、`tree.diff`
  ID-keyed（`try_plushie/plushie-architecture.md` §4.2–4.3）。
  `try_plushie/test/try_plushie_test.gleam:394-423`
  `stable_geometry_gives_single_bar_patch_test` 断言稳定几何 + 稳定 id
  时 `insert=1 / remove=1 / update_props=0 / replace_node=0`；
  `:425-462` `tree_diff_patch_size_test` 断言 `insert=2 / remove=2 /
  update_props ∈ [1,14)`。
- **当前实现没做到「一根 bar 进绘图」**：
  `try_plushie/src/try_plushie.gleam:401-403` `subscribe()` 返回 `[]`
  （无归档事件源）；`try_plushie/src/fusion_view.gleam:231-237`
  `window()` 每次 `view` 都 `list.length` + `drop` + `take` +
  `list.reverse` 一个 160 根窗口，**绘图输入仍是整窗 list，不是 head
  那一根**。`src/fusion_view.gleam:25-36` 的模块头说三处几何已改，
  与 `plushie-architecture.md` §17.5/§17.6「三处几何未改」的记录
  不一致——按「代码是事实、文档是散文」，以源码为准。
- **本次实测的边界**：在 `try_plushie` 跑
  `gleam test` **exit 1**，`src/explore.gleam:158` 用了
  `gleam_stdlib` v1.0.5 不存在的 `list.range`（编译器逐字
  *"The module `gleam/list` does not have a `range` value"*）。所以上面
  两组断言数字是**测试源码里的断言**，不是本次跑出来的实测；本注记
  不宣称「try_plushie 测试通过」。
- **按 owner 判据的结论**：机制支持，但当前 app 既无归档事件源、
  绘图又吃整窗 list ⇒ **按「如果不能，那么我们的系统不能用他」，
  plushie / try_plushie 当前不满足第一条门槛**。是否就此记为
  「当前不可用」、还是先补事件源与单根输入再评，需 owner 一句话。
- 对照：`plushie-architecture.md:458` 记 glib 用的是 TradingView
  **Lightweight Charts v5** + SSE `series.update` 单 bar 增量；
  `:513` 记 BEAM 侧 Plotto「有 K 线但无对数轴/交互/缩放，
  **无单 bar 增量**」——同一条判据在那个项目里已经用来否掉过一个库。

### C. 本注记不做什么

- 不宣布 glib 全对，也不宣布它错；owner 已声明 *"其中AI是否100%按照
  我设计去实现我也不知道"*（07:31 逐字），权威始终是 owner 逐字与
  代码内文档。
- 不改 glib / try_plushie 任何源码（参照项目只读），不改 `src/` /
  `test/`，不新增 R 编号。
- **B.3 与 B.5 两处需要 owner 一句话的，记入待裁决区**；07:42 注记里
  「不新增待裁决项」只对那一轮成立，本轮 owner 明确要求 *"You have
  to ask"*。

---

## 2026-11-15 08:13 — owner 对 07:59 两问的答复（执行注记，不新增编号）

把 07:59 的两个问题原样交给 owner 后，答复逐字：

- 问 `sourcebar_buffer` 导出要不要存在 → **「一会儿讨论这个问题」**。
- 问 plushie / `try_plushie` 是否记为「当前不可用」 →
  **「那个里面的绘图是手搓的，AI声称可以单bar更新，确实最初版本是做到的，如果你发现目前不是，那是他后来搞错了，不是不可以改正」**。

### 对 07:59 B.5 结论的修正（owner 当前陈述 > 我的推断）

我 07:59 写的是「机制够、当前实现不满足第一条门槛 ⇒ 按 owner 判据
**当前不满足**」，并把它列成待裁决项。**这个判断的落点错了，现予修正**：

1. **绘图是手搓的**，不是库提供的成品控件。所以「是否支持单根 bar
   更新」问的**不是库的能力上限**，而是我们自己的绘图实现有没有守住
   「只吃 head 那一根」这条纪律。判据的对象从「选哪个库」变成
   「任何绘图实现都不许把整窗 list 交给 view」。
2. **能力已经被验证过**：owner 逐字 *"AI声称可以单bar更新，确实最初
   版本是做到的"*。`try_plushie/plushie-architecture.md:1463` 的 owner
   逐字同向：*"单bar更新做不到才会去整list，本来绘图根list无关，因为
   每次都仅需第一个bar"*。
3. ⇒ 我在 §B.5 检出的 `src/try_plushie.gleam:401-403` `subscribe()`
   返回 `[]`、`src/fusion_view.gleam:231-237` `window()` 每次 `view`
   都 `list.length` + `drop` + `take` + `list.reverse` 整窗，是
   **后来 AI 改错的实现回归，可以改正，不是「不能用他」的证据**。
   **不判为「当前不可用」，不排除 plushie，不转向别的库。**
4. **07:59 记的实测边界仍然成立**：本次 `gleam test` 在 `try_plushie`
   **exit 1**（`src/explore.gleam:158` 用了 `gleam_stdlib` v1.0.5 不存在
   的 `list.range`），所以 `test/try_plushie_test.gleam:394-423` 的
   `insert=1 / remove=1 / update_props=0` 是**测试源码断言，不是本次
   实测**。本轮未改该项目任何源码。
5. **「最初版本做到」这一条无法从版本历史复核**：在 `try_plushie`
   跑 `git log --oneline` 返回 *"fatal: your current branch 'master'
   does not have any commits yet"*，该仓库当前无提交。按权威顺序
   （owner 当前陈述 > 旧代码 > 我的推断），这条以 **owner 逐字为准**，
   不拿代码去验证、也不拿代码去否认；**不写成我实测过**。

### 待裁决区的变化

- `sourcebar_buffer` 导出：**保持待裁决**（owner「一会儿讨论」），
  07:59 B.3 的技术事实与四个选项原样保留，不预设结论、不催。
- plushie 选型：**不再是待裁决项**，结论按本节第 3 条写进本注记；
  待裁决区该条整条删除。决策区 **2 项 → 1 项**。

### 本注记不做什么

不改 glib / `try_plushie` 任何源码，不改 `src/` / `test/`，不新增
R 编号，不改写 07:59 及更早的注记原文（append-only）。

---

## 2026-11-15 08:16 — owner 逐字：为什么 glibe 拒绝 JS target、以及「禁止手写 erl」（执行注记，不新增编号）

owner 逐字（原样）：

> *"注意经过对比和实证，我已经转向了glibe这个拒绝JS target的项目，mjs也是祸根之一，AI不会自我约束，所以要换成erlang target，并且禁止手写erl"*

### 本注记的性质

这是 owner 对 07:59 审计（glib 两处 JS FFI `.mjs` 挂在每根 bar / 每次
poll 路径上）给出的**理由与铁律**，不是新的待裁决项，也不改写
R14 / R15 / R16 / R17 / R18 的历史原文。「经过对比和实证」是 owner
自己的判断；本注记只把它与本轮可复核的代码事实对齐，不替他宣布
`webclient/` 的旧裁定作废。

### 实证：编译器替 owner 守住了哪一半，守不住哪一半

本轮在 `/tmp/glibe_target_probe`（Gleam 1.19.2，独立包，
`target = "erlang"`）跑了三个探针，逐条报真实退出码：

1. **JS-only external 被编译器拒绝。** `src/target_probe.gleam` 写
   `@external(javascript, "./foreign.mjs", "now")` 加
   `pub fn now() -> Int`：`gleam build` **exit 1**，编译器逐字：
   ```
   error: Unsupported target
   The `now` function is public but doesn't have an implementation for the
   Erlang target. All public functions of a package must be able to compile
   for a module to be valid.
   ```
   ⇒ `target = "erlang"` 不是一句承诺：JS 外来实现在这个包里根本没有
   可编译的入口。这正是「拒绝 JS target」由**构建工具**表达、不靠 AI
   自我约束的意思。
2. **手写 `.erl` 不会被拒绝，反而被编译。** 把
   `src/hand_written.erl`（`-module(hand_written).` / `go() -> 42.`）
   放进同一个 `src/`，配 `@external(erlang, "hand_written", "go")`：
   `gleam build` **exit 0**，产物
   `build/dev/erlang/target_probe/ebin/hand_written.beam` 与
   `_gleam_artefacts/hand_written.erl` 都出现。`gleam-core.md` §9 逐字：
   *"the compiler checks Gleam-side uses but cannot verify the foreign
   implementation exists or returns that type"*。
   ⇒ **「禁止手写 erl」是必需的第二半**：换成 erlang target 之后，
   AI 只要把 `.mjs` 换成 `.erl`，同一条绕过类型检查的路依旧畅通，
   而且编译全绿。这一半编译器**守不住**。
3. **孤立的 `.mjs` 在 erlang target 下无活性。** `src/foreign.mjs` 被
   复制进 `_gleam_artefacts/foreign.mjs`，`gleam build` **exit 0**，
   没有任何 JS 运行时产物。它既不编译也不报错 —— 所以「不许出现
   `.mjs`」同样不是构建工具能给的保证。

### 本轮实读的 glibe 结构事实（不是意图）

- `gleam.toml:3` 逐字 `target = "erlang"`；全文件没有 `[javascript]`
  节、没有 `runtime`、没有 `gleam_javascript` 依赖。
- `src/` = **15 个 `.gleam`、零个非 `.gleam` 文件**；
  `grep -rn "@external" src webclient/src test` 返回空。
- 根包 `build/dev/erlang/glibe/` 下唯一的 `.erl` 是
  `_gleam_artefacts/glibe@@main.erl`（`gleam run` 的 runner stub），
  其余是 **44 个 `.abstr` / 46 个 `.beam`**；`find build -name '*.erl'`
  共 **196 个**（`80 dev` + `116 packages`），除这 1 个 runner stub 外
  全在 `build/packages/` 与依赖的 dev 产物下，属于
  `simplifile` / `houdini` / `gramps` / `hpack_erl` / `gleeunit` 等
  **hex 包自带的源码**。**没有一行 `.erl` 是我们写进 `src/` 的。**
- `webclient/gleam.toml:3` 是 `target = "javascript"`（R18 裁定的
  独立包），`webclient/src/` 只有 1 个 `.gleam`，零手写 JS；
  `build/dev/javascript/webclient/webclient.mjs` 由 Gleam 编译生成。

### 判据（按 owner 逐字推出来的执行边界，不是新裁定）

- 引擎的 BEAM 能力只有两个来源：**OTP 模块**经
  `@external(erlang, …)`，或 **`gleam add` 的 hex 包**的纯 Gleam API。
  与 `~/.workbuddy/skills/gleam-language/references/externals.md` §5
  「绝不手寫 `.erl` / `.ex`」（owner 2026-11-13）是同一条。
- 不新增项目级 guard sh（R44 / `gleam-core.md` §12：能用包边界表达的，
  不写 shell 去 grep 扩展名）。根包用 `gleam.toml` 的 target 表达；
  `src/` 只放 `.gleam` 是**包边界**，不是靠注释求 AI 自觉。
  探针 2 说明这一半编译器不检查，所以它是**审阅时看文件清单**的
  事实，**不是「编译绿就等于合规」的证明** —— 这一点如实写，不粉饰。
- 07:59 检出的 glib 两处 `.mjs` 高频 `reverse` 归到「祸根」：
  `glib/binance_trading_ffi.mjs:37/81`、
  `glib/paper_trading_ffi.mjs:273`。它们是**手写在引擎 `src/` 里的
  外来源码**，与 R18 允许的「独立包里由 Gleam 生成的 `.mjs`」
  不是同一件东西。

### 与 R16 / R17 / R18 的张力（不替 owner 撤销）

`webclient/gleam.toml:8` 逐字 *"a hand-written .mjs is permitted HERE
AND ONLY HERE"*，以及 `webclient/src/webclient.gleam:20` 的 `////`，
还留着 owner 2026-11-07 逐字给出的**手写 `.mjs` 兜底许可**
（R16 小范围例外 / R18 第 5 条：*"如果这样做实在麻烦，就手写mjs，
但是仅仅出现在那个webclient目录里面"*）。它正是「AI 自我约束」
形状的规则：靠一句「HERE AND ONLY HERE」限制，而不是靠目标声明。
**本轮原样保留，不删、不改写、不宣布作废** —— owner 当前陈述优先，
但这一句没有点名 `webclient/`；撤销他自己的旧逐字需要他一句话。
这一处记为待裁决区的一项，不预设结论。

### 本注记不做什么

不新增 R 编号，不改写 R14–R18 与 07:59 / 08:13 历史原文
（append-only），不改 `src/` / `test/` / `webclient/` 任何一行，
不改 glib / `try_plushie`，不新增项目级 guard sh。

---

## 2026-11-15 08:27 — owner 逐字：决策问题写进单独文档，不再用对话式提问（执行注记，不新增编号）

owner 逐字（原样）：

> *"你不可再使用这种提问方式，有决策问题写入 单独文档，我会去看。"*

### 本注记的性质与我的错误

08:16 我把「拒绝 JS target 是否一并收紧 `webclient/`」用对话里的
选项卡片问了一次。**错的是提问方式，不是问题内容**：卡片不会留在
仓库里，也不让 owner 按自己的时间去看；他要的是决策问题落在
**单独文档**里。该问题在 08:16 已经写进
`docs/PENDING_DECISIONS.md`「需要你决定」第 2 项，所以本轮
**不重问、不重列、不催答复**。

### 执行约定（按逐字，不扩大）

- 决策问题**只**写进单独文档 `docs/PENDING_DECISIONS.md`
  「需要你决定」节；对话里不再弹选择卡片、不再要求即时答复。
- 文档里**不预设结论**：08:16 第 2 项 A 选项原有的「推荐理解」
  标注删除，三个选项一律平列；owner 自己去看、自己定。
- *"我会去看"* = 不催、不设时限、不把未答项当成已否决。
  08:13 的 `sourcebar_buffer` 一项继续原样保留。
- 本注记**不是**对 08:16 那个技术问题的裁定，决策区**仍为 2 项**。

### 本注记不做什么

不改 08:16 及更早的注记原文（append-only），不改 `src/` /
`test/` / `webclient/`，不新增 R 编号，不新增 guard sh。

---

## 2026-11-15 08:28 — owner 逐字：`external` ≠ FFI、≠ 手写 erl；external 是正常设计（执行注记，不新增编号）

owner 逐字（原样，含原拼写）：

> *"0 external 并不一定是好事，但是external不等于手写erl，这一点AI总是弄混，
> 要好好阅读gleam官方文档。我说过很多遍, 你在 ~gits/gleam-language 去找相关的
> 话吧，我不知道ai有没有记下来。总之 exteranl is not equal to FFI, and is not
> based on handwritten erlang or elixir, while handwritten erlang and elixir
> by you are prohibited, external 是必须的正常的合理的gleam设计"*

### 查证一：`~gits/gleam-language` 里到底记了什么

owner 指的路是 `/Users/jk/gits/gleam-language/`。**找到的是边界，
没找到这句正面逐字**：

- `knowledge/externals.md` §2（逐字）：*"BEAM 目标下，Gleam 调用 Erlang /
  Elixir / LFE = `external`（外部），但绝不是 `foreign`（外来）… JS =
  `foreign`（外来）… 不要把 `@external(erlang, …)` 叫做 "FFI""*，
  标注为 owner ruling 2026-11-13；§5 逐字 *"铁律：绝不手寫 `.erl` /
  `.ex`"*，并列出两条合法来源（OTP 模块、`gleam add` 的包）。
- `knowledge/SKILL.md:202-205` 是同一条的索引；
  `gleam-thinking-core.md` §9 写 *"Externals sparingly — prefer Gleam;
  most projects use none"*。
- **全库检索没有「0 external 并不一定是好事」「external 是必须的正常的
  合理的 Gleam 设计」这两句**。owner 那句「我不知道ai有没有记下来」
  属实：AI 记下了「不许手写 erl」和「external≠foreign」，**没记下
  external 本身是必须且正常的设计**，于是把它滑成了「零 external
  才干净」。本轮不擅自改这个仓库（owner 只让去读）。

### 查证二：官方文档（本轮实读 `https://gleam.run/documentation/externals`）

页面标题是 **Externals guide**，取回的正文里没有出现 "FFI" 一词；
官方用词是 external function / external type。逐字摘录：

> *"Gleam on Erlang can use Erlang, Elixir, LFE, and other BEAM languages."*
>
> *"There is no additional performance cost to calling functions written in
> other languages and those written in Gleam."*
>
> *"Externals are useful, but they have several disadvantages."*
>
> *"We recommend minimising use of externals, most projects won't use any at
> all. Externals could be a good choice in these situations: — You need to use
> an API provided by the runtime you are using. … — There is code written in
> another language on the runtime …"*
>
> *"The Gleam compiler will ensure that all uses of the function will be
> correct for the annotated types, but it cannot verify that the function
> implemented in the other language returns the specified types, or even
> that it exists."*

⇒ 「sparingly / most projects won't use any at all」是**用度建议与现状
统计**，不是「零 external 是优点」的判据；需要运行时 API 时，
external 正是官方给的答案。官方文档也确实展示了一段
`-module(pokemon).` 的 Erlang 源码与 `src/my_app/pokemon.mjs` 的 JS
源码 —— 那是**语言机制的一般示例**，不是给 AI 在本项目手写目标语言
源文件的许可；owner 禁的是 *"handwritten erlang and elixir by you"*。

### 我 08:16 错在哪里（不改写历史原文，在此更正）

1. `docs/STATE.md` 08:16 节把「零 `@external`」列在小标题
   **「glibe 当前合规事实」**下，`README.md` 也把 `zero @external`
   写成 erlang-target 的一项成绩。⇒ 把「目前恰好没有」误当成
   「应该追求零」。owner 逐字：**0 external 并不一定是好事**。
2. 08:16 探针 2 为证明手写源码会被编译，写了
   `@external(erlang, "hand_written", "go")`。那条的**问题是我手写
   的 `src/hand_written.erl` 文件**，不是 `@external` 属性本身。
   把二者捆在一起讲，就是 owner 说的「AI 总是弄混」。
3. 我引用 `gleam-core.md` §9 的官方措辞 *"cannot verify the foreign
   implementation exists"* 时没区分术语：按 owner 的边界，BEAM 侧是
   **external**，只有跨运行时的 JS 才是 foreign / FFI。
   **不要把 `@external(erlang, …)` 叫 FFI。**

### 执行边界（按逐字，不扩大）

- `@external(erlang, "lists" / "os" / "httpc" / "inets" / "ssl", …)`
  调 OTP，或 `gleam add` 一个包再调它的纯 Gleam API，是**必须的、
  正常的、合理的 Gleam 设计**；真有需要就写，不因「想保持零」而绕开。
- 被禁止的只有一件事：**AI 自己手写 `.erl` / `.ex`（以及往 `src/`
  手写 `.mjs`）**。这条与「正常使用 external」并存，不矛盾。
- `src/` 当下零 external 是**现状**，不是目标、不是成绩、不是门禁；
  不把 external 数量做成指标或 sh 守卫（R44 / core §12）。
- R14 / R15 里「根包禁 `@external(javascript, …)`」的历史裁定
  **不变**：那禁的是 JS target 依赖，不是禁 external。

### 落地与本注记不做什么

`README.md` 去掉「zero @external」的成绩写法并写明 external 是正常
设计；`docs/STATE.md` 在最新状态节更正 08:16 的「合规事实」措辞
（**历史节原文不改写**）；`docs/HANDOFF.md` §5、待裁决区第 2 项的
事实描述、项目 memory 同步。**08:16、08:27 及更早注记原文不改写**
（append-only，更正写在这里）；不改
`/Users/jk/gits/gleam-language/` 任何文件，不改 `src/` / `test/` /
`webclient/`，不新增 R 编号，不新增 guard sh。

---

## 2026-11-15 08:30 — owner 逐字：语言知识的家是 `~gits/gleam-language`，不是 WorkBuddy 全局 Memory（执行注记，不新增编号）

owner 逐字（原样）：

> *"如果没有找到关于FFI仅限于JS的原因，那么AI没记下来，他可能记录到
> workbuddy的全局Memory里面去了。很愚蠢的做法。"*

### 查证结果（逐条，不替 owner 猜）

1. **「FFI 仅限于 JS」的理由找到了，就在知识中心**：
   `/Users/jk/gits/gleam-language/knowledge/externals.md:14-20` §2 逐字
   *"它们同跑在一个 BEAM VM 上，运行时表示一致，是同一个世界的兄弟
   语言"* / *"JS 是完全不同的运行时；跨运行时才叫 Foreign Function
   Interface（FFI）。JS 目标的外部源文件（`.mjs` / `.js`）才是 FFI"*，
   并标注 owner ruling 2026-11-13。
   `~/.workbuddy/skills/gleam-language/references/externals.md` 与它
   **byte-identical**（`cmp` exit 0）。⇒ 08:28 注记说的「没找到」
   只针对**「external 是必须/正常/合理的设计」「0 external 并不一定
   是好事」那两句正面逐字**，不针对 FFI 理由；两者不是同一句。
2. **但 owner 的怀疑在版本记录层面成立**：知识中心仓库
   `git status --short` 是 ` M knowledge/SKILL.md` 与
   `?? knowledge/externals.md` —— 装着 FFI 理由的那个文件**从未被
   提交**，仓库 `git remote -v` 为空、分支 `master` 只到
   `5f1a798`。也就是说理由只躺在磁盘上的松散文件和
   WorkBuddy 用户级 skill 目录里，**没进知识中心的版本历史**；
   这与 owner 说的「记到 workbuddy 的全局里去了」是同一类落点错误。
3. **WorkBuddy 全局 Memory 里并没有这个理由**：用户级
   `MEMORY.md:569-572` 只有 R14/R15 的一句摘要
   （*"No handwritten Erlang or JS in `src/` … `@external` binds
   existing BEAM modules, it is NOT a licence to write a foreign
   module"*），既没有「同跑在一个 BEAM VM」的理由，也没有
   08:28 的正面裁定；`/Users/jk/.workbuddy/MEMORY.md` 与
   `/Users/jk/.workbuddy/memory/96be…_memory.md` 检索
   `FFI|foreign|external` 均无命中。⇒ **没有把语言知识塞进全局
   Memory**，但也没把它提交到该去的仓库。

### 执行边界（按逐字，不扩大）

- Gleam 语言事实与 owner 逐字的家是 **`~gits/gleam-language`**，
  不是 WorkBuddy 全局 Memory。本轮**不往任何全局 Memory 写语言
  知识**（08:28 / 08:30 两条逐字只归位到本文件与项目 memory）。
- 08:28 与 08:30 的正面裁定补记在 glibe 的 `docs/RULINGS.md`
  （本项目 owner 逐字的家）与项目 memory；**不擅自提交或改写
  `gleam-language` 仓库** —— 它已有不属于本轮的未提交改动
  （`SKILL.md` 被改、`externals.md` 未跟踪），替别人提交正是
  owner 说的「AI 不会自我约束」。该仓库的状态如实报给他，不代他决定。
- 「不许手写 `.erl`/`.ex`」与「`@external(erlang, …)` 是正常设计」
  是两条并存的规则，见 08:28 注记；不因本条改动。

### 本注记不做什么

不新增 R 编号，不改写 08:16 / 08:27 / 08:28 及更早注记原文，
不改 `src/` / `test/` / `webclient/`，不改
`/Users/jk/gits/gleam-language/` 任何文件、不提交那个仓库，
不新增 guard sh。

---

## 2026-11-15 08:38 — owner 逐字：导出前为什么要 `reverse`？答案是「没有理由」；要看消费方怎么用（执行注记，不新增编号）

owner 逐字（原样，含原拼写）：

> *"关于 sourcebar_list exporting:
> why should it be reversed before exporting? to answer this you have to answer no reason, since whether the data in disk is newest first or oldest first, it will never prevent a comsumer to use it. The key is how the comsumer will use it. Right? So how the comsumer is using the exported data today in glib? that is where to inspect."*

### 先认错：07:59 / 08:13 答的是另一个问题

待裁决区第 1 项与 `DEVELOPER_GUIDE.md` §7(e) 第 1 处，
我写的是「直接删 `list.reverse` 会倒着喂流」「挪到读侧只是把同一次
O(n) 换边」，并据此把 oldest-first 当成**文件格式的必要条件**。那是把
「某一个消费方的便利」写成了「数据的性质」，正是 owner 这句要纠正的：
**「为什么要 reverse」的答案是「没有理由」**。磁盘上是 newest-first
还是 oldest-first，都不妨碍消费方使用；同一份数组从哪头读、要不要
遍历一次，是消费方的事。历史注记原文不改写，更正写在这里。

### 逐字要求的查证：glib 今天的消费方到底怎么用

**写侧三处，只有一处 `reverse`：**

| # | 位置 | 是否 reverse | 为什么 |
|---|---|---|---|
| A | `glib/src/glib/trading/export.gleam:21-25` `export_flush` | **是**：`to_json(list.reverse(sourcebar_buffer(timeframe)))` | 它的 buffer 是 newest-first |
| B | `glib/src/glib/census_import.gleam:119-127` `store_fetch` | 否：`to_json(sourcebar_list)` | `binance.fetch_bars` 返回 oldest-first |
| C | `glib/src/glib/census_import.gleam:171-184` `import_daily` | 否：`to_json(sourcebar_list)` | IB 下载本身 oldest-first |

buffer 的 newest-first 逐字：`glib/src/glib/timeframe.gleam:146-149`
*"Newest-first like `databar_list`, so capture is O(1); `export_flush`
reverses it once, at the single write."*；累积是
`glib/src/glib/sourcebar_export.gleam:41-46` 的 `[sourcebar, ..buffer]`。
`glib/src/glib/sourcebar_export_ffi.mjs` 的 `write_session` 逐字
*"The payload arrived already encoded and already ordered — this does
no reshaping of the data."* —— JS 侧不翻。⇒ **三个写方都产出
oldest-first，A 的 reverse 只是让它追上 B / C 已经是的形状**；它连
「写方统一规则」都不是，更不是数据的性质。

**读侧与消费链（这才是要查的地方）：**

1. `glib/src/glib/trading/ingest.gleam:124-147` `run_offline` →
   `sourcebar_export.read`（`:130`）→ `feed_all`（`:142`）。
2. `glib/src/glib/sourcebar_export.gleam:139-149` `read_payload` →
   `json.parse(payload, decode_sourcebar_list(interval))`；
   `glib/src/glib/sourcebar.gleam:515-518` 的 `decode.list` 与
   `:534-535` 的 `json.array` 都保序，`:145` 把解码结果**原样**交回。
3. `glib/src/glib/trading/ingest.gleam:75-81` `feed_all` 是
   `list.fold(sourcebar_list, timeframe, fn(t, b) { feed(t, b, publish) })`
   —— **从头部开始，一根一根喂**；`:57-70` `feed` →
   `sourcebar_gate` → `databar_processing` → `working_databar_archived`。
4. 顺序为何重要：`glib/src/glib/timeframe.gleam:280-283`
   `dealt_with_last` 读 `list.first(timeframe.databar_list)`（头 = 最新
   归档的一根）与到达 bar 的 `Timestamp` 比较；`:294-296` 给准入的
   bar 一个 `idx = bars_listed(...)`，而 `bars_listed` 读头。**这条流
   是有状态的、默认时间向前**；倒着喂时 `idx` 递增而 `date` 递减，
   值是合法的、历史是错的。它**不校验**顺序，只是假定顺序。
   （`glib/test/sourcebar_export_test.gleam:131-133` 的注释写成
   「gate 会答 this bar was dealt with last」；按 `:280-283` 的等式，
   该分支只在日期重复时才命中，更准确的说法是「顺序被假定、未被
   检查」。）
5. 同一批文件的其余消费方：`glib/src/glib/binance.gleam:168-205`
   `fetch_bars` 在 `GLIB_SEED_FROM_FILE` 时用 `decode_sourcebar_list`
   读同一个文件（`:198`）、原样返回 →
   `glib/src/glib/trading/ingest.gleam:101-108` `run` → 同一个
   `feed_all`；`glib/src/glib/census.gleam:212-213` 调 `run_offline`
   后再 `list.reverse(tf.databar_list)` 出报告；CLI 入口
   `glib/src/glib/glib.gleam:300`。
6. 顺序被**写成契约**：`glib/test/sourcebar_export_test.gleam:122-150`
   `the_vault_reads_back_oldest_first_test` 断言读回按 oldest-first；
   `glib/src/glib/sourcebar_export.gleam:26-27` 逐字
   *"one positional JSON array, oldest-first … the file is read whole,
   sequentially, once, which is what an array is for."* —— 「整份顺序
   读一次」本身就是**为这个消费方选的格式**，不是数据的性质。

**磁盘实测**（本轮读 `data/*.json` 首尾 `date`）：`ADAUSDT_1d` /
`ATOMUSDT_1d` / `AVAXUSDT_1d` / `BNBUSDT_1d` / `DOGEUSDT_1d` /
`DOTUSDT_1d` 各 1000 根、`BTCUSDT_1h` 4800 根、`BTCUSDT_1m` 4801
根、`BTCUSDT_1d` 27 根、`DRAM_daily` 110 根，**全部首尾递增**
（`BTCUSDT_1d` 1791331200000 → 1793577600000）；两个以字符串存
`date` 的 `_daily.json` 不计入。⇒ 现状确实是 oldest-first。

### 结论（按 owner 的问法，不换回我原来的问法）

- **「导出前为什么要 reverse」＝ 没有理由。** 磁盘顺序不约束消费方；
  数组从哪头读、要不要一次 O(n) 遍历，都是消费方的事。
- glib 里这次 reverse 存在的**唯一**原因是消费方：`feed_all` 从链表
  头部 fold 进一条有状态的流，而流假定时间向前。所以它是**为一个
  消费方做的边界投影**，可以等价地放在读侧，也可以随消费方形状
  改变而整个消失（逐行 stream 写、或从尾部读），不必挂在写侧。
- 按 07:59 的 stream 判据，真正要问的是**这个消费方本身**：
  `run_offline` 把整份历史逐根重放过引擎，要的是「整个历史」而不是
  「那一根 `working_databar`」。这才是 *"that smells"* 的落点，
  reverse 只是它的症状。
- glibe 的 `src/glibe/timeframe.gleam:106-120` 仍**没有**
  `sourcebar_buffer` / `export_flush`；待裁决第 1 项因此收窄为
  「这条消费方路径要不要存在」，`reverse` 不再是决定性因素。

### 本注记不做什么

不新增 R 编号，不改写 07:59 / 08:13 / 08:16 / 08:27 / 08:28 / 08:30
及更早注记原文；不改 glib / `try_plushie` 任何源码，不改 glibe 的
`src/` / `test/` / `webclient/`；不新增 guard sh；决策问题仍只写进
08:27 指定的那一份单独文档，不在对话里提问。

---

## 2026-11-15 08:44–08:58（导出格式与读取方法：探讨、实证，以及 owner 对「顺序」的裁定）

### owner 逐字（四段，按到达时间）

1. **08:44（主问）**：*"首先对export出去的文件的格式，需要探讨，将来glibe
   用什么格式，用json？csv？更有效率的二进制方式？然后对读取方法进行探讨，
   需要这个导出的文件必须按照时间顺序存储sourcebar信息吗？"*
2. **08:49**：*"你没有加载 gleam-thinking-core? 不知道 gleam add 所有BEAM
   也就是hex.pm package 并且直接通过 `@external` 使用？不知道Gleam世界
   如此简单？"*
3. **08:55**：*"输出json是一种最懒的做法，因为不需要花精力去找最佳方案了。
   但是或许hex有合适gleam的原生数据库都不一定的。"*
4. **08:58**：*"倒序资料肯定不影响消费呀，我不知道glib怎么做的，如果你
   读取的使用也用list来存，那么很简单的事情，你想怎么放？旧数据放前面？
   那不是prepend是什么"*

### 先认三处错

- **08:49 批评成立，但要如实说清边界**：本轮开头确实按 R19 加载了
  `gleam-language` skill 并**全文**读了 `references/gleam-core.md`
  （379 行），08:50 又 `cmp` 过 `docs/gleam-thinking-core-to-memory.md`
  → **exit 0，字节一致**。所以不是「没加载」，是**加载了却没照着做**：
  第一版探针里手写了 `int_to_string` / `digits` / `one_digit` /
  `join_with` / `bool_to_string`，还手写了一段定长位数组 codec，而
  `gleam_stdlib` 早在 `gleam.toml:6` 里，`int.to_string`（`int.gleam:149`）、
  `string.join`（`string.gleam:457`）、`bool.to_string`（`bool.gleam:189`）、
  `bit_array.byte_size`（`bit_array.gleam:26`）全是现成的。这违反
  `gleam-core.md` §8 *"Do not re-implement a library's job"*、§12
  *"`pip install` mindset → `gleam add`"*，也重犯了 owner 先前那句
  *"gleam add 去加上你却少的东西，不要绕圈子替换"*。**探针已重写**，
  下面所有数字来自重写后的编译产物。
- **08:55 批评成立**：我默认把 JSON 当成唯一在讨论的格式，没去 hex 查
  「有没有更合适的方案」。*"最懒的做法"* 指的是**不花精力找方案**
  这个行为，不是 owner 对 JSON 下了禁用裁定 —— 不擅自扩大成禁令。
- 07:59 / 08:13 的旧错（把消费方便利写成数据性质）已在 08:38 认过，
  此处不重复、不改历史原文。

### A. glibe 现状（读过的 file:line，不是推测）

- `src/glibe/api/sourcebar.gleam:105-178`：`SourceBar` 是**九个变体**，
  每个带同样六个字段 `timestamp: Timestamp` / `open` `high` `low`
  `close: Float` / `volume: Int`；`:43` 逐字 *"So there is NO `interval`
  `field: a number could disagree with the bar around it, a variant
  cannot."* —— **grade 在变体里，不在字段里**。
- `build/packages/gleam_time/src/gleam/time/timestamp.gleam:100`：
  `pub opaque type Timestamp { Timestamp(seconds: Int, nanoseconds: Int) }`，
  是**纳秒精度的 opaque 值**；`:1178` `to_unix_seconds` 返回 `Float`
  （有精度损失），`:1187` `to_unix_seconds_and_nanoseconds` 才无损。
- `src/glibe/timeframe.gleam:106-120`：`Timeframe` 仍**没有**
  `sourcebar_buffer`、没有 `export_flush`；`src/` 全库检索
  `json|csv|binary|bit_array|term_to_binary|file.|write|read|export|
  encode|decode` 命中的全是 `////` 文档里的英文单词，**零序列化、
  零文件 IO 代码**。所以「将来 glibe 用什么格式」目前是**悬空**的：
  这条消费方路径本身还是待裁决第 1 项。
- `gleam.toml:3` `target = "erlang"`；`manifest.toml` 里
  `source = "hex"` 的包 **23** 个（含 `gleam_json`、`gleam_erlang`、
  `simplifile`、`mist`、`wisp`）。

### B. glib 的格式与 codec（format 是长期契约的实证）

- `glib/src/glib/sourcebar_export.gleam:26-27` 逐字
  *"one positional JSON array, oldest-first … the file is read whole,
  sequentially, once, which is what an array is for."*
- `glib/src/glib/sourcebar.gleam:524-535` `encode_bar` 逐字
  **"The variant is not spelled — the reader is told the interval, and
  the bar's numbers are the fields."**；`:510-518` 的
  `decode_sourcebar_list(interval)` 靠**读方带外传入** grade，
  `:534-535` `json.array` 保序。
- `glib/src/glib/sourcebar_export.gleam:139-149` `read_payload` 用
  `json.parse(payload, decode_sourcebar_list(interval))` **整份 parse**；
  `:151-176` `read_provider_generation` 是**三代格式兼容兜底**
  （当前 vault / Binance / IB 三种 decoder 逐个试）。这就是「把
  closed set 降级成 String + parser」之后要付的账：`test/sourcebar_export_test.gleam:122-150`
  把 oldest-first 钉成了契约。
- `glib/src/glib/trading/export.gleam:21-25` 退出时
  `list.reverse(sourcebar_buffer(..))` 一次，写整份 array。
- ⇒ positional JSON array **不能 append 一根**：它是「整份 parse /
  整份写」的形状，与 07:59 stream 判据（系统里只有一根
  `working_databar` 在工作）相冲。这句是格式性质，不是对 glib 的
  全对/全错宣判。

### C. 真的去 hex 与 OTP 查了（不预设「没有」）

`https://hex.pm/packages?search=...` 08:56–08:57 实读，**存在的包名**：

| 方向 | 包（版本 / 页面逐字） |
|---|---|
| Gleam 原生 SQLite | `sqlight` 1.2.0 *"Use SQLite from Gleam!"*；`marmot` 1.9.1 *"Type-safe SQL for SQLite in Gleam"*；`parrot` 2.3.0 *"type-safe SQL in gleam for sqlite, postgresql & mysql"*；`cake` 4.1.0 / `cake_sqlight` 1.5.0 / `gloo` 1.0.2 |
| Gleam 原生 CSV | `gsv` 5.1.0 *"A simple csv parser and generator written in Gleam"*；`tysv` 1.0.0 *"Stream typed values in Gleam from CSV"* |
| BEAM 侧数据库 | `khepri` 0.19.3 *"Tree-like replicated on-disk database library"*；`esqlite` 0.10.1（sqlite NIF）；`concord` 3.1.17 *"embedded distributed key-value store"* |
| 时序 / 列式 | `oban_met` 1.3.3 *"distributed, compacting, multidimensional … time series datastore"*；`explorer` 0.13.0 *"Series … and dataframes"* |
| Elixir/Erlang CSV | `csv` 3.2.2 / `nimble_csv` 1.3.0 / `erl_csv` 0.6.0 |

**比 hex 更近的一层**：OTP 内置，连 `gleam add` 都不用。
`erl -noshell -eval 'code:ensure_loaded(..)'` 实测（OTP 29）：
`mnesia={module,mnesia}`、`dets={module,dets}`、`ets={module,ets}`、
`kernel={module,kernel}`；`stdlib` 返回 `{error,nofile}` 只因它是
application 名而非模块名，不是加载失败（如实记，不写成失败）。
`erlang:term_to_binary` / `binary_to_term` 是 `erlang` 模块的 BIF
（官方 `erlang.html` 页首 *"The Erlang BIFs and predefined types."*
与 `ext_binary()` 定义 *"structured according to the Erlang external
term format"*）。**注意**：`term_to_binary/2` 选项与
`binary_to_term/2` 的 `safe` 安全警告，官方页三次 WebFetch 均 60s
超时、只返回页首 —— **未取得逐字，本轮不引用、不编造**。
⇒ owner 08:55 *"或许hex有合适gleam的原生数据库都不一定的"* **成立**，
08:49 *"gleam add 所有BEAM 也就是hex.pm package 并且直接通过
`@external` 使用"* 也成立；两者合起来就是 08:28 已裁定的
*"`external` 是必须的正常的合理的gleam设计"* 的正面例子。

### D. 编译探针（Gleam 1.19.2 / OTP 29，`/tmp/glibe_format_probe`，真实 exit code）

探针**只用 stdlib 现成函数 + 一行 `@external`**，零手写 codec、
零手写 `.erl`、零新增源码文件进仓库。第一次 `gleam run` 因
`repo.hex.pm` 不可达 exit 1，复用 glibe 的 `manifest.toml` 走本地
缓存后 **exit 0**。

- **二进制不需要手写 codec**：`@external(erlang, "erlang",
  "term_to_binary")` 与 `"binary_to_term"` 两行，把「grade 在变体里」
  的六字段值往返 → `ETF round-trip keeps grade + all six fields:
  True`；两个**不同变体**分别验过都是 `True`。这是 R13 / R21 /
  R27 与 `gleam-core.md` §2 的直接后果：JSON/CSV 得把 closed set
  和 opaque `Timestamp` 降级成文本再 parser 回来，ETF 直接存 term，
  变体 tag、纳秒 `Timestamp`、`Float` 精度全部原样保真。
- **实测字节**：单根 JSON object **98** / ETF **73**；10 根
  positional JSON array **991** / JSON lines **989** / ETF 整表
  **727** / ETF 逐记录 **73×10**。
- **`gleam add` 实证**：探针里 `gleam add simplifile` → 输出
  `Added filepath v1.1.2` / `Added simplifile v2.7.0`，编译 **exit 0**。
  `simplifile.gleam:381/391/404` 的 `read_bits` / `write_bits` /
  `append_bits` 本身就是 `@external(erlang, "simplifile_erl", ...)`。
  逐根 `write_bits` 一根 + `append_bits` 一根 → 文件 **145 bytes**、
  单根 **73 bytes**，两个不同变体 grade 往返都 `True`。
  ⇒ **每根 O(1) 落盘，无 buffer、无 `list.reverse`**。
  在 glibe 里要用需先 `gleam add simplifile`（现为 `wisp` 的传递
  依赖，在 `manifest.toml:31`）；本轮**没有**改 `gleam.toml`。
- **OTP 层实验，非 Gleam 编译验证（如实区分）**：
  `erl -noshell -eval` 下 DETS 故意**乱序**插入 3 根
  `[B3, B1, B2]`，按 `timestamp` 作 key 查找全部命中，且
  `variant tag survived storage: true`。⇒ 按 key 存取的存储里
  **根本没有「文件顺序」这个概念**，顺序是查询时的一次投影
  （与 R30 / 07:42 输出侧投影同构）。

### E. 读取方法：owner 08:58 的答案，编译验证

`/tmp/glibe_format_probe/src/read_order.gleam`，**exit 0**：

```
file NEWEST-first, read + prepend -> 10, 20, 30
file OLDEST-first, read + prepend -> 30, 20, 10
head of the List from a NEWEST-first file = 10 (the OLDEST bar)
```

整个 reader 只有 `[record, ..acc]` 一个操作 —— **零 `reverse`、
零 `append`、零 `length`**。文件 newest-first（引擎内
`databar_list` 的天然形状），逐根读进来 prepend，得到的正好是
oldest-first，`list.first` 就是最旧那根，可直接喂 `feed_all`。
owner 08:58 *"旧数据放前面？那不是prepend是什么"* 说的就是这一步：
**要顺过来，靠的是读侧的 prepend（O(1) 累积），不是 reverse（O(n)
重排）**。这是 08:38「磁盘顺序不约束消费方」的具体读法。

### 结论（严格区分「探讨」与「裁定」）

1. **「导出的文件必须按时间顺序存储 sourcebar 吗」＝ 不必须**，
   这是 owner 08:38 + 08:58 的**裁定**，不是待裁决项：
   - 08:38：磁盘 newest-first / oldest-first 都不阻止消费方使用；
   - 08:58：读进来用 List 存，想要旧数据放前面就是 prepend；
   - 实证：newest-first 文件 + 逐根 prepend → oldest-first；
   - 更彻底：DETS / Mnesia / `sqlight` 按 key 存取，顺序只是
     查询时的投影，文件里没有这个属性。
   ⇒ 「按时间顺序存储」是**一个消费方的读法**，既不是数据的性质，
   也不是格式的必要条件。glib 把它钉成契约，是它选了
   「positional JSON array + 整份 `decode.list` + 从头 fold」
   这个组合的结果。
2. **格式＝探讨中，需要 owner 一句话，本轮不裁定**。事实底座是
   A–E：JSON 是最省力但不是唯一；hex 上有 Gleam 原生 SQLite / CSV
   与 BEAM 数据库；OTP 还有连 `gleam add` 都不用的 `dets` /
   `mnesia` / `term_to_binary`；`SourceBar` 的变体与 opaque
   `Timestamp` 让「存 term」比「降级成文本再 parse」少一整层
   codec，而代价是 BEAM 专有、不可跨生态读、不可移植。
   **选项平列、不预设推荐、不催**，按 08:27 约定只写进那一份
   单独文档（第 3 项，且依赖第 1 项：若第 1 项选「不引入」，
   本项自动消失）。
3. 与 07:59 stream 判据的关系（说明，不是裁定）：positional
   JSON array 必须整份 parse / 整份写；JSON lines、ETF 逐记录、
   或按 key 的数据库都能每根 O(1) 落盘、每根 O(1) 读，与
   「系统里只有一根 `working_databar` 在工作」同形。

### 本注记不做什么

不新增 R 编号，不改写 07:59–08:38 及更早注记原文（append-only）；
不改 glibe 的 `src/` / `test/` / `webclient/` / `gleam.toml` /
`manifest.toml`（探针全在 `/tmp`），不改 glib / `try_plushie`；
不新增 guard sh；不在对话里弹决策卡片、不催、不预设推荐；
不替 owner 选格式，也不把 *"最懒的做法"* 扩大成 JSON 禁令。

---

## 2026-11-15 09:09

**owner 逐字**：

> "BEAM里面有的东西好像都不用另外做什么，直接可用，gleam语言和erlang
> elixir都是BEAM的门，归元无二路，方便有多门，gleam是最方便的那扇门。"

**这条说的是「为什么前面那串事实成立」，不是新增机制。** 08:16
（转 erlang target、禁手写 erl）、08:28（external ≠ FFI、≠ 手写 erl、
零 external 不是成绩）、08:30（语言知识的家在 `~gits/gleam-language`）、
08:49（`gleam add` + `@external` 直接用）、08:55（OTP 自带数据库、
JSON 是懒做法）都指向同一件事：能力已经在 VM 里，取用不需要另造
桥接层、codec 或手写目标源码；差别只是从哪扇门进去。

### 查证（Gleam 1.19.2 / OTP 29，探针全在 `/tmp`，真实退出码）

**A. 零依赖、零手写 erl，OTP 模块直接可用。**
`/tmp/glibe_beam_door_probe/gleam.toml` 只有 `name` / `version` /
`target = "erlang"`，`manifest.toml` 里包数 **0**，`src/` 下 `.erl`
文件数 **0**；`src/beam_door_probe.gleam` 四行 `@external` 指向
`erlang:term_to_binary` / `binary_to_term` / `monotonic_time` 与
`lists:reverse`。`gleam run -m beam_door_probe` **exit 0**：
两个不同变体的 ETF 往返各 `True`、`otp_reverse([1,2,3])` → `[3,2,1]`。
产物是 `beam_door_probe.beam` + `beam_door_probe@@main.beam`，
唯一的 `.erl` 是生成的 `@@main` runner stub；glibe 自身
`build/dev/erlang/glibe` 同理是 **46 个 `.beam`** 加一个
`_gleam_artefacts/glibe@@main.erl`，没有逐模块 `.erl`（core §9）。
探针第一版写了 `echo monotonic_time() > 0`，实测 `False`；改成
打印原始值得 **`-576460751688905208`** —— 「应为正」是我未经
验证的假设，本注记只记这次测量值，不写成官方规则（该页未取逐字）。

**B. Elixir 是同一台 VM 上的另一扇门。**
`elixir --version` → **Elixir 1.20.4 (compiled with Erlang/OTP 29)**；
`elixir -e ':code.which(String)'` →
`/opt/homebrew/Cellar/elixir/1.20.4/lib/elixir/bin/../lib/elixir/ebin/Elixir.String.beam`。
同一个 `erl -noshell -pa <ebin>` 会话里 `lists` 与 `'Elixir.String'`
都返回 `{module, …}`，`'Elixir.String':upcase(<<"beam">>)` →
`<<"BEAM">>`。传 Erlang 字符串字面量 `"beam"`（是 list）会
`function_clause`，传 binary 才对 —— 这是**值的形状**，不是桥接层。

**C. 从 Gleam 那扇门直接调 Elixir 模块，编译目标仍是 `erlang`。**
`/tmp/glibe_beam_door_probe/src/elixir_door.gleam` 只有一行
`@external(erlang, "Elixir.String", "upcase")`；
`ERL_LIBS=<elixir lib> gleam run -m elixir_door` **exit 0**，打印
`"BEAM"`。零 `.ex` / 零 `.erl` / 零 wrapper / 零 codec。
**区分要说清**：OTP 内置 BIF 连这一步都不用；Elixir 标准库需要把它的
`ebin` 放进 code path（一个 `ERL_LIBS`），那是部署路径，不是额外写
代码。本条不扩大成「任何库都无需配置」。

### 与既有裁定、知识中心的关系

- `/Users/jk/gits/gleam-language/knowledge/externals.md:14-24` §2
  逐字：*"BEAM 目标下，Gleam 调用 Erlang / Elixir / LFE = external
  （外部），但绝不是 foreign（外来）。它们同跑在一个 BEAM VM 上，
  运行时表示一致，是同一个世界的兄弟语言"*；官方逐字
  *"Gleam on Erlang can use Erlang, Elixir, LFE, and other BEAM
  languages."* 同文件 `:42-50` §4：Elixir 模块名带 `Elixir.` 前缀、
  **目标仍是 `erlang`**；`:52-64` §5：只有 OTP 模块与 `gleam add`
  包两条路，手写 `.erl` / `.ex` 违规。
  `docs/gleam-thinking-core-to-memory.md` §9（core 的 byte-equal
  镜像）同条：*"target is the COMPILATION target, not the source
  language (Elixir still uses `erlang`)"*。
- **不推翻 R31 / R33**：这句说的是「取用运行时能力的门」，不是把
  BEAM 的 actor / scheduler / clock / poll 搬进 glibe 的系统设计；
  系统仍是一条流、纯值重算、一个 `Desk`。**也不改 08:16 的
  「禁止手写 erl」**：08:16 探针 2 已实测手写 `.erl` 会编译绿且产出
  `.beam`，编译器不拦，所以那半条禁令仍然必需。
- 对 §6.6 格式探讨只是一条**说明，不是裁定**：既然 `term_to_binary` /
  `dets` / `mnesia` / `ets` 与 hex 包都已在，格式探讨不必去造 codec
  或手写目标源码；格式仍是 owner 08:44 的探讨项，不因此替他选。
  **不往 WorkBuddy 全局 Memory 写语言知识**（08:30）。

### 本注记不做什么

不新增 R 编号，不改写 08:44–08:58 及更早注记原文（append-only）；
不改 glibe 的 `src/` / `test/` / `webclient/` / `gleam.toml` /
`manifest.toml`；探针全在 `/tmp`；不改
`/Users/jk/gits/gleam-language/` 任何文件、不提交那个仓库；
不新增 guard sh；不在对话里弹决策卡片、不催、不预设推荐；
不把这句扩大成「任何库都无需配置」或「可以手写 erl」；
不替 owner 选导出格式，决策区不增不减。

---

## 2026-11-15 09:22

**owner 逐字**（同一轮三条）：

1. *"你对于gleam语言经过实测验证的感悟，应该写入 ~/gits/gleam-language,
   或者用硬ln连接过去，注意我说的是硬，不是symbol link，this is unix
   family OS filesystem"*
2. *"你担心依赖BEAM的问题，不用担心，我就是打算靠BEAM吃饭的。
   你没看到我最近的项目都是gleam"*
3. 09:22 追加 *"你可把exteranl.md ln 过来方便查阅"*（`exteranl` 是原话
   拼写，实际文件名 `externals.md`）。

### A. 语言知识的家：知识中心，单文件硬 `ln`

- 此前注记里「不改 `/Users/jk/gits/gleam-language/` 任何文件、不提交
  那个仓库」**是我自己设的边界，不是 owner 的裁定**；owner 当前陈述
  优先（Authority 第一条）。本轮按逐字把实测感悟写进知识中心；
  历史注记原文不改写（append-only），更正写在这里。
- 知识中心本来的设计（`README.md` §1 / §2 / §5，2026-11-13 owner
  逐字）：*"不要链接目录结构，仅去硬link gleam-thinking-core 那个
  文件，因为各自的项目中有几个版本，造成混乱必须设计这个单一数据源"*；
  *"skill等等文档也一样处理，放在哪里，谁用谁链接就行了，单一文件
  链接，说link的时候，在unix世界就是指单独文件的"*；
  *"file link (ln without -s or anything else) should not be broken in
  a unix/linux filesystem"*。⇒ 单个文件、单个 `ln`、无 `-s`；
  `stat -f '%i %l'` 是检查，`cmp` 只是字节级 sanity check。
  这与更早那次「手工 link 顶替软件设计差错」不是一回事：那次是
  **目录级**链接/复制来做同步，这里是 owner 明确要求的**单文件**
  链接，且知识中心本就按这个模型建成。
- 本轮实测（`stat -f 'dev=%d inode=%i links=%l'`，同一设备
  `dev=16777231`）：
  · 核心卡四个名字同一 inode `337552766`（links 4），含 glibe 的
    `docs/gleam-thinking-core-to-memory.md`；
  · `knowledge/gleam-measured.md` ↔ skill
    `references/gleam-measured.md` 同 inode `333921129`（links 2）；
  · `knowledge/externals.md` 与 skill 副本**原先是两个 inode**
    （`339942506` / `339942149`，`cmp` 0 但不是链接）—— 这正是
    08:30 我说的「停在磁盘松散文件」；
  · `ln -f` 之后 `externals.md` 三个名字同 inode `339942506`、
    links **3**（知识中心 / skill `references` /
    `glibe/docs/externals.md`，按 09:22 逐字链过来方便查阅）；
    新增 `knowledge/beam-doors-measured.md` ↔
    `skill/references/beam-doors-measured.md` 同 inode `340468671`、
    links **2**；`find … -type l` 全空（零 symlink）。
- **落地内容**：`knowledge/beam-doors-measured.md` 收录这一轮**全部编译
  实证的语言事实**（零依赖 OTP BIF / Elixir 门 / external≠FFI≠手写 erl /
  `term_to_binary` 零 codec / `gleam add simplifile` / List 读侧 prepend /
  未取得逐字的边界），不写 glibe 项目状态；`SKILL.md` 的
  `<reference_index>` 用 `open(..., "r+")` **就地**加一条（inode
  `324709842`、links 2 保持不变）；知识中心 `README.md` §2 的 shelf
  计数与「`cmp` 分不出副本与链接」同步。
- `glibe/docs/externals.md` 是**硬 `ln` 过来的查阅入口，不是新写的
  规格**：它讲语言机制（含「JS 目标的 `.mjs` 才是 FFI」），glibe
  08:16「禁止 AI 手写 `.erl` / `.ex` / `.mjs` 进 `src/`」仍是本项目
  裁定；该文件 §8 记的是 try_plushie / glib 的历史，不是 glibe 的
  设计证据（同 R38 边界）。
- 知识中心仓库**无 remote**，且带有别人未提交的
  ` M knowledge/SKILL.md` 与 `?? knowledge/externals.md`；本轮只写文件
  与链接，**未提交、未 push、未改写他人未提交内容**。

### B. 依赖 BEAM 不是顾虑，是方向

- 我在三处把 *"BEAM 专有、不可跨生态读 / 不可跨语言读、不可移植"*
  写成格式选项的**「代价」**：08:44–08:58 注记（历史原文不改写）、
  `docs/PENDING_DECISIONS.md` 第 3 项 A / C、`DEVELOPER_GUIDE.md`
  §6.6 的「取舍」段。owner 当前逐字说明「靠 BEAM 吃饭、最近项目
  都是 Gleam」⇒ **跨生态可读不是本项目的需求，BEAM 原生不是
  减分项**。
- 本轮把后两处改成**性质陈述**（不是代价、不加推荐）：BEAM 原生格式
  直接存 term、零 codec；JSON / CSV 人可读是它的性质，但「跨生态」
  不再作为优势计入。**格式仍是探讨项**，不因此选 ETF、不因此禁
  JSON、不因此替 owner 裁定；选项仍平列（08:27），决策区不增不减
  （仍 3 项）。
- 与 09:09「一 BEAM 多门」同向，不推翻 R31 / R33（那两条说的是
  系统设计，不是取用运行时能力的门），不改 08:16 禁手写目标源码。

### 本注记不做什么

不新增 R 编号；不改写 07:59–09:09 及更早注记原文；不改 glibe 的
`src/` / `test/` / `webclient/` / `gleam.toml` / `manifest.toml`；
不新增 guard sh；不在对话里弹决策卡片、不催、不预设推荐；
不把「靠 BEAM 吃饭」扩大成「任何库都无需配置」；不往全局 Memory
写语言知识；不替 owner 选导出格式。

## 2026-11-15 09:32（BEAM 跨平台 / Gleam 治 AI 先天性疾病：owner 观点 + speak_engl 实证）

owner 逐字：

> *"BEAM非常坚固可靠并且小巧，跨一切平台，简直是不可多得的好东西，
> 只不过群众永远追逐热点而不知道用好东西而已。加上Gleam语言，简直是AI的救星，
> AI整天忙忙碌碌，但是最终碌碌无为，很难把一个中等复杂的项目做成落地无隐患，
> 因为语言有问题，不能对治AI的先天性疾病。Gleam就是可以拿来治AI的好药。
> 关于BEAM跨平台，我的项目 speak_engl 已经证实了。"*

### 落点（与既定裁定同向，不新增 R 编号）

- **观点部分（BEAM 好、群众追热点、Gleam 是 AI 的救星/好药）是 owner 的
  看法**，逐字归位，不当作语言事实断言；记入知识中心
  `~/gits/gleam-language/knowledge/beam-cross-platform-measured.md`，
  硬 `ln` 进 skill `references/`（inode `340471733` / links 2），`SKILL.md`
  索引就地加一条（inode `324709842` / links 2 不变）。与 09:09「一 BEAM
  多门」同向。
- **跨平台部分是实测证实**，非仅观点：查 `speak_engl`
  (`/Users/jk/gits/hub/prog_langs/swift/two_way_com_training/speak_engl`)：
  - README 逐字 *"built in Gleam on the BEAM. Runs on-device via mob
    (iOS/Android) and plushie (desktop) — one Gleam core for all platforms,
    no server needed"*；*"The engine runs entirely on the phone."*
  - `GLEAM_APP_TECH_STACK.md:214-215` 平台表：mob 覆盖 Android+iOS
    （BEAM embedded，*"production apps on App Store + Play Store"*），
    plushie 覆盖 Desktop (macOS/Linux/Windows)；`:222-223` 最低
    iOS 13+ / Android 9(API 28)；`:533` plushie 还产出 Linux/Windows
    交叉编译二进制；`:117-118` *".beam from all three languages fully
    interchangeable in the same BEAM process"*。
  - CI 矩阵实测在五大平台编译/运行 BEAM：`.github/workflows/test.yml`
    (ubuntu core + mobile, macos desktop 语音)、`mob-ios.yml`
    (macos, 下载 `otp-ios-sim-d199a49a` ERTS 17.1.1 + 启动 iPhone 17
    Pro 模拟器)、`mob-android.yml` (ubuntu, NDK 27.2.12479018 + Zig
    0.17.0 交叉编译出 `.apk`)、`mob-build.yml` (ubuntu, `gleam build`
    → BEAM)。OTP 29 / Gleam 1.19.2 / Elixir 1 全程。
- **范围**：这条**不改动 glibe 的工程状态、不增不减决策区（仍 3 项）、
  不改 `src/`/`test/`/`webclient/`/`gleam.toml`/`manifest.toml`**；
  是 owner 的战略观点被本人项目实证，归位即完成。
- **知识中心仓库无 remote、且带他人未提交改动**（前几轮已确认）：本次
  只写文件 + 硬 `ln` + 索引，**未提交、未 push**；`glibe` 侧已普通
  push 到 `origin/doc-tdd`。

### 本注记不做什么

不改写 07:59–09:22 及更早注记原文；不把「Gleam 治 AI」写成可量化的
工程结论；不凭记忆扩张 BEAM 平台清单（只列 speak_engl 实测覆盖的
macOS/Linux/Windows/iOS/Android）；不替知识中心仓库做提交。
