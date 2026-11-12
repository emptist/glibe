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
- `Timeframe` 持有 `settings`，删除 `symbol` / `interval` / `market_type`
  三个向上指认的字段。`sourcebar_gate` 的 interval 由**选中这台 Timeframe
  的调用方**传入（key 本来就在它手里）；`databar_processing` 不再另收
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
     就能跑；warnings 合法，`--warnings-as-errors` 只是 **GREEN gate**。
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
