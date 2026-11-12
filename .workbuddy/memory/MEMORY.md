# MEMORY — glibe (index; verbatim rulings in `docs/RULINGS.md`, detail in daily logs)

## Authority & identity
**Owner's current statement > spec > legacy code > my inference.** I am
space-bunny; user is emptist. `glib/docs/` = hy4's AI prose (another model,
banned from glib): never adopt its first person or generic "gate"/"ladder"
vocabulary. Owner's words: `sourcebar_gate`, **price checker**, **risk
manager**. **glib docs are NOT evidence of glib code** (R38): compare docs
against code; take only implementations fitting current rulings. glib is not
authority.

## Direction
- *"glibe is the future, pure erlang target is the future"*, *"BEAM is great"*;
  no handwritten Erlang/JS sources → `src/` Gleam only; root target erlang,
  `webclient/` the only JS package (R16–R18). **Concurrency = Erlang/BEAM
  only**; never a JS-target/promise analogy. Web frontend for human eyes.
- **Root law: use a type whenever a type is needed in nature** — no universal
  `String` + parser + `panic` + sh/grep guard to repair it.
- glibe does not wait on glib: take owner rulings + glib's good code directly.

## Process (R19, mandatory)
Load `gleam-language` skill, read `references/gleam-core.md` **IN FULL** before
any Gleam judgement; `docs/gleam-thinking-core-to-memory.md` is its byte-equal
mirror (keep `cmp`-equal). **One module file, whole process**: ① `////` module
doc naming the `.planning` item + `///` on every item → ② empty skeleton
(types/functions only if needed, `todo as "…"`, no real body) → ③ unit tests
hold the design goal → ④ fill bodies step by step to green. `--warnings-as-errors`
is a GREEN gate only. `gleam docs build` → `package-interface.json` is the
anti-drift check (**a `////` block broken by `//` truncates it**; check both
packages). 11:05 retrofitting docs/tests onto existing code is NOT this
process — label it retrofit. 11:11 `docs/` = 「差生补课笔记」, not assets:
never create prose docs to record concepts. **Never write a ruling into
`////`/`///` until the code matches** (R39).

## Rulings R12–R45 (full text: `docs/RULINGS.md`)
R12 `1e-6·bb_m` floor · R13 closed sets are types · R14 `src/` Gleam only ·
R15 IB = historic stocks/ETFs · R16–R18 JS scope · R19 process above.
**R20** `Desk ▸ Broker ▸ Instrument ▸ Timeframe`, dashboard = VIEW.
**R21** full constructor names (`IntervalOneDay`); `H4`/`"1h"` only in
codec/adapter; R25 `TPlus1`/`CPU` are terms.
**R22** `Symbol` is a name, never `Instrument`. **R23** `Timeframe.settings`;
interval lives in the KEY; no composite keys, second dict or `list.find`.
R24 Mist+Wisp = AI demo · R26 Asset/Exchange/Market open, add types one at
a time. **R27** `SourceBar.timestamp` = `gleam_time.Timestamp` (unix).
**R28** provider native shapes (`Kline`, all wire fields) + own
`to_sourcebar`; standard layer is the only union point. **R29** `bucket_ends`
= UTC unix-second grid; US 09:30 + DST = market-calendar debt → `tzif` when
a US-equity consumer exists. **R30** web local wall clock = **output-side**
projection; R29 = **input-side** calendar; never merge; CSV stays UTC RFC3339.
R31 BEAM language facts ≠ this system · R32 garden = add one field by real
ownership.
**R33 (paradigm)** system **is already live**: `api provider / data sources →
history + live data → sourcebar_gate → databar_processing → model ↔ view`;
history+live = ONE stream; pure value recompute — no actor/scheduler/clock/
poll/heartbeat; `Desk` is the ONE top-level Value; no data → sleeps and waits.
`monitor.advance`/`TimeframeAddress`/`IncomingBar`/`MonitorError` are
historical only; 「叶子」 = `YinLeaf`/`YangLeaf`.
**R34** seib = **CoffeeScript, owner's own design**, structure RIGHT, only
missing the multi-provider layer (already here). ibOptions = Python+pandas
workaround, 五脏俱全但都不对劲: structural relations flattened into settings;
requirements list only. **R35** SwiftUI similarity ONLY in View
definition/implementation; concurrency → official docs + demo = TDD.
**「简单是正确的验证码」** — complexity means definitions are wrong; fix them,
add no mechanism. **R36** Market/Broker not subordinate either way → no gap.
**R37** a main-chain level needs TWO ownership relations (up+down); others
attach or → `Desk`. **Identity lives in the holder's Dict key**:
`interval` is not a `Timeframe` field, `brokerId` not a `Broker` field —
*"你的左手不知道他是左还是右"*.
**R38 (11-12)** **the stream has no rewind** (*"长江万里哪有倒退重来的
道理"*): no `replay`, no 重来一遍, no "replay CLI"; names must name real
things. Measured doc/code mismatch: `glib/docs/DESIGN.md:61` cites
`trading/replay.gleam`, `:1874` `replay.feed`, but the code is
`trading/ingest.gleam`'s `feed`/`feed_all`; `:66` "Batch is that pair run n
times — not a second implementation". `ingest.feed(tf, bar)` one bar at a
time; `live.feed_raw` calls the same `feed`. **Do not port**: publish
callbacks, `clock.now()`/`period_end`, `sourcebar_buffer`/export,
interval→settings lookup, `market.exchange`, `io.println`/at-home asserts.
One arriving bar = call the pair in order → **no third function**.
**R39 (11-12, the whole system)**: qualified `SourceBar` →
`working_databar` → **all** computation/processing/decisions happen **in
that working databar** → `working_databar_archived` → `databar_list`. One
straight line, **no side doors**; any step passing the bar as an argument
has drifted. Matching glib code: `sourcebar.to_databar` (one bar born
whole), `databar_processing` puts it in `working_databar`, every later step
takes only `Timeframe` as subject (extra params allowed, R40-A),
`working_databar_archived(tf)` takes no bar.
**glibe drift (measured, NOT changed — owner decides)**: `fold_sourcebar`
bucket accumulator, `engine.databar_processing(tf, databar)` passes the bar
through `leaves`/`strategy`/`accept`, names `accept`/`bars_accepted`, and
`manual_enter`/`manual_exit` (owner struck 2026-10-31).
**R40 (11-12)** `databar_processing` body = `timeframe |> f1 |> f2 ...
|> fN`, infinitely extensible; every step's FIRST arg and return are
`Timeframe` because `working_databar` is a field; no step passes the bar as
an argument. **R40-A (11-12, owner clarification)**: a step may have ANY
number of extra parameters — positional, labelled, a whole settings type —
supplied at the pipe site; `function1` was shorthand, not an arity limit.
Official tour section **"Pipelines"**
(`tour.gleam.run/everything/#functions-pipelines`): `rocket |> launch(1, 2)`
= `launch(rocket, 1, 2)`; bare name = one-arg call; `f(1, _)` capture moves
the piped value to a later arg (language allows; R40 keeps subject first).
Measured green in `probes/timeframe-pipeline/` on the real `Timeframe`
(11 tests, R19 RED→GREEN twice): plain pipe, labelled-arg capture, 1000-step
`list.fold`, `Ok(tf) |> result.try(step)` for fallible steps, field-carried
fact, `|> working_databar_archived(tf)`, 2 positional args, 3 labelled args
in any order, a captured `StepSettings` step folded 1000 times, capture into
a later arg, and `mixed_line` with all four shapes in one pipe. **Gleam
refuses only a step RETURNING `#(Timeframe, a)`** (type mismatch); parameter
count is never a restriction; `let #(tf, fact) = …` compiles but breaks the
line — put the fact in a field ⇒ definition problem, not a language limit.
`opaque` blocks cross-module record update but not the pipe of public steps.
glib recorded the owner's requirement
(`docs/reference/timeframe-settled-leaf-2026-10-28.md:312-315`,
`timeframe-cleanup-audit-2026-10-28.md:671`) but its
`timeframe.gleam` has **zero `|>`** and still returns a 4-tuple at `:421`
— docs ≠ code again. `src/glibe/` unchanged this round.
**R41 (11-12)** `|>` is a SHAPE constraint, not formatting (owner: AI
invents parameter order / return types). Every step fixed to
`fn(Timeframe, ...extra) -> Timeframe`; static types always existed, what a
pipe adds is ONE shared shape, so a wrong first arg or return is a compile
error. Four throwaway packages `/tmp/gleam_shape_negative`: control 0,
wrong first arg 1 (`Expected Int / Found Frame`), wrong return 1
(`does not accept the piped type`), SAME invented signatures with ordinary
calls 0. `engine.gleam` measured: 8 functions / 8 signatures
(`:68/:91/:119/:160/:214/:240/:255/:268`), 4 hand-written destructurings
(`:94/:96/:104/:105`). glib `:732/:844` already have the right shape but
`databar_processing` has zero `|>`. `src/glibe/` still unchanged.

**R42 (11-12, ownership + the skeleton IS the design)**: glibe = 抄 glib
作业 + JS→Erlang target 改编 + owner 裁定修正，**不另造设计**；glib 文档是
那边的 AI 记的，常与代码脱节 → 抄 owner 要求，不抄没落实的代码；那边无
doc-first TDD，不能一起抄。`timeframe.gleam` = `Timeframe` type + 全部相关 fn
(glib `timeframe.gleam:32-35`，R43 核验后改正)；**`engine.gleam` 删除**（AI 造的机制模块，
生产代码无人 import，`:19-21` 自认 import-cycle 理由不成立）；
`scripts/no_timeframe_mixture.sh` 删除（grep 钉死错误划分）。
**空架子即设计**：先 `////`/`///` + type 关系 + 签名 in/out types 对齐，
`gleam build`/`gleam test` 就照出缺口，**一行干活代码都不用写**；倒推
upstream → 正推回 timeframe → 一路到 `Desk`；连最初 unit test 也是空的。
`Desk` = top type / 根 / 中心控制室，**上面不再有东西**（设计要求，无其他
原因）；所有声控 app / web / 桌面 / 分析决策 type 从它展开。倒推查出的真
缺口 = WRITE 半边 `put_timeframe_under`（与只读 `timeframe_under` 对称）。
实测：架子 build exit 1（4 个 `Unknown record field` manual_enter/exit 全在
`engine.gleam:222-228`）→ 归位后 build exit 0 且零行新实现 → RED
64 passed/19 failures → **GREEN 83 passed, no failures**，WAE=0，全门禁绿；
`package-interface.json` 9 模块 doc 完整、`engine` 已消失。skill
`gleam-document-led-tdd`（用户级）随开发增量完善，只写已实测段落。

**R43 (11-12 07:51, 空架子与反复推敲的准确含义)**：空架子的对象是 glib
只记下（如是我闻）没落实（信受奉行）的 owner 设计；只写 `////`/`///` +
type 关系 + in/out types 就把系统完整呈现，**无需一行实代码**，如是我闻
即成信受奉行。**「反复推敲」= 反复对照 owner 设计 + 自己的思考，核验
空架子搭得对不对，判据：用词是否准确、有无自己瞎编的东西**；**不是**
测试之间互相推翻的流程 —— 我 skill 里那条预写是误读，已删。理由：无实
代码 → 系统轻灵 → 一次载入 token 限量内、不挂一漏万；架构对了再逐个
落实代码，很快都做对。**前提不可外推**：*"我早已把整个系统设计成熟了。
否则你不容易这样做"* —— 这是抄成熟设计，不是从零发明设计的通用方法。
本轮首次应用是**写完实现后的追溯核验**（非空架子阶段推敲，后者仍未
实测）：`bars_listed`/`to_databar`/`UC-62`/两处 doc 区间都有出处；查出
glib "What stays…" 在 `timeframe.gleam:32-35` 而非 `:28-31`（5 处文档
误标）、`:23-25` 过宽应收紧 `:25`（3 处）、PLAN §3 残留已删的
`databar.of_sourcebar`；全部改正。**实测：引用/用词漂移能活过全绿 build
与 test，只有回读设计才能发现。**

**R44 (11-12 08:16)** `doc-tdd` 分支系统性重建：*「你以前的代码仅能作为
历史遗迹，什么都没弄对，丢了不可惜」*。旧 `src/`/`test/`/`scripts/`/
`probes/`/review/session/补课笔记 → `deprecated/2026-11-12-pre-doc-tdd/`
（79 files），只读、不作依据、不参与编译。**过去的东西绿不绿红不红一点
用没有**，不再报告旧红绿数字；新阶段 `gleam check`/`build` 是**设计探针
报缺口**，不是分数。**项目层不再有 guard sh**（CI 那行也删）：只认编译器
自身命令 + `package-interface.json` 防漂移产物；行为层（及时提交）靠纪律，
脚本探测不到。熟悉 `gleam --help`；本轮实测 `gleam check`（只类型检查）、
`gleam export package-interface --out <path>`（直接出接口 JSON）、
`gleam docs build`、`gleam format --check`。
**R45 (11-12)** *「你的旧实现搞他干嘛」* / *「你现在把types搞清楚，其他的
东西从我的用词当中去获取即可」*。清场后**不得翻 deprecated 当词库**；本轮
唯一对象是 types 关系，其余名字只从 owner 逐字用词 + `RULINGS.md` 裁定取，
没命名的按 R26/R32 留空。不等于删掉所有未逐字出现的词：语法必需的结构名
与裁定里记录过的领域词（R1 four twins、R2 `YinBranch`/`YangBranch`、R4
`growing_yang_branch`、R23 `TimeframeSettings`、R28 `Kline`）合法。
R43 判据含**引用是否真逐字**，不得把 AI 转述标成 `owner, verbatim`。

## Measured facts
Gleam 1.19.2 / OTP 29: `import mod.{type T, Ctor}`; no `T(..)`; `@external`
may coexist with a Gleam body; `.abstr → .beam`; `float.parse("100")` =
`Error(Nil)` → `parse_number` widens Int. `gleam build` ≠ runnable app;
dotted `@external` names fail. Mist 6.0.3 `mist.start`; `wisp.Text`;
`wisp/simulate.request`; `gleam run -m <mod>` needs no root `main`;
`gleam_otp` already a root dep. `package-interface.json`: `modules` is a
**dict**, `documentation` a **list of lines** — join with `"\n"`. Tests:
bool `assert … as "msg"`, `let assert`, never `panic`/`case Bool`.

## Conventions
- **No bare `Qn` labels** — cite full path + section title.
- Pending decisions **only** in `docs/PENDING_DECISIONS.md`: decisions FIRST,
  rest under `# REFERENCE`; **no other document may reference it**.
- **Owner 2026-11-09: ".gitignore 及时更新，及时做提交"** — ignore rules
  BEFORE artifacts; one logical concern per commit; **do not push unless
  asked**; never `rm -rf build`.
- Toolchain: `export PATH="/opt/homebrew/bin:$PATH"`; BSD grep unreliable →
  Grep tool/Python; capture exit codes.
- **R44 起项目层没有 guard sh**。空架子阶段用 `gleam check` / `build` /
  `format --check src test` / `docs build` /
  `export package-interface --out` 当**设计探针**（报缺口不报分数）；
  `gleam build --warnings-as-errors` 只属于将来填完 body 后的 GREEN 闸门。
  core mirror `cmp` 仍是 skill 与仓库镜像的字节一致性检查，不是门禁脚本。

## State (2026-11-12, doc-tdd)
分支 **`doc-tdd`**（就地新建，未 push）；04-13 及以前的实现整体封存为历史
遗迹，状态以本节为准。79 files → `deprecated/2026-11-12-pre-doc-tdd/`；
旧 README（464 行，教人跑已删的 guard sh）也移入 `notes/`，根目录换成
15 行索引；CI 删 `sh scripts/guards.sh --all`。
**`src/` = 12 个模块、零行实代码**：`////` / `///` + type 关系 + 全标注签名，
函数体全 `todo`；`test/glibe_test.gleam` 空 unit test 只固定 in/out types。
`desk.gleam` 持整条链与 read/write 服务（不拆 broker/instrument 模块），
`timeframe.gleam` 持直线与管道全部 fn（不设 engine / indicator / strategy
模块），输出侧 view 边界写在 `desk.gleam` 的 `////`（不造 web/server）。
设计探针：`gleam check` exit 0 无缺口（只 Todo/unused warning）、
`build` / `format --check` / `docs build` /
`export package-interface --out` exit 0，12 个模块 `////` 完整渲染。
**R43 空架子阶段核验本轮首次实测**（05-01 §5）：删 1 个自造占位构造子、
2 处假引用/假断言、5 个自造模块名，补 4 处出处；`Timeframe` 的 growing /
settled 字段回查 R1/R2/R4 后确认是 owner 设计，**保留**。skill 两条留白
（空 test 架子、写实现前核验）已按实测补写。R44/R45 已入 `RULINGS.md`，
`STATE.md` 顶部新段与作废的 "What green means" 已更新。
**仍留白（R26/R32）**：`TimeframeSettings` 字段、`DataBar` 计算字段、
leaf/branch 内部字段、`Kline` 线格式字段、`SourceBarRejection` 具体原因、
`Account` 字段。**未收敛**：`gleam.toml` 旧依赖表、`webclient/` 旧实现。
决策区 0；**未 push**；按逻辑原子提交，不 push。
