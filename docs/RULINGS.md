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
  T+1 / T+2 拼了出来，不是线路码；已向 owner 标出，等他一句话。
- **`config.gleam` 的 `"BTCUSDT_H1"` 复合字符串键仍在**：那是 R20
  「明确未决、未做的事」里记为尚未拍板的数据迁移，不是构造子；本条不动。

**执行边界：** 本条定的是**命名**，不是配置表迁移的许可。R20
「明确未决、未做的事」里的两项 owner 裁决（表的搬迁形状、
`Symbol` / `Instrument` 命名冲突）仍然开着。
