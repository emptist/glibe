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
`Broker.instruments` 的 **key** 里，`Timeframe` 不自带；settings 随 engine 走。
「被拥有者不指认拥有者」这句是 AI prose，此处只按 owner 上面的原话执行。

### 3. 裁定（验收标准，不留兼容层）

- `Instrument` **只**持有 `timeframes: Dict(Interval, Timeframe)`。删除
  `settings` 字典、`put_settings` / `get_settings`、`NoSuchSettings`。
- `Timeframe` 持有 `settings`，删除 `symbol` / `interval` / `market_type`
  三个向上指认的字段。`sourcebar_gate` 的 interval 由**选中这台 Timeframe
  的调用方**传入（key 本来就在它手里）；`databar_processing` 不再另收
  settings 参数。
- `config.gleam` 的 `symbols` 与 `timeframe_settings` 两张表删除；归属直接
  用类型值表达，不再有 `"BTCUSDT_H1"`、`list.find`、`get_symbol`、
  `config_get_tfs`。
- `indicator_settings.TimeframeSettings` 保留为**值**（参数包），但明确写进
  模块文档：它不是实体、没有 id、没有自己的字典或配置表，唯一归宿是
  `Timeframe.settings`。不改名、不新造名字 —— owner 没说过的名字就是发明。
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
