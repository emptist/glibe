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

## Rulings R12–R43 (full text: `docs/RULINGS.md`)
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
- Green = `gleam build --warnings-as-errors` + `gleam test` + `gleam format
  --check src test` + `sh scripts/guards.sh --all` + `gleam docs build` +
  core mirror `cmp`.

## State (2026-11-12)
**83 tests root** + 4 `parallel-bars` + 11 `timeframe-pipeline` green; full
gate green (WAE / format / guards 4 case / docs root+webclient+2 probes /
core mirror cmp); decisions 0; **not pushed**. 04-13 = R39/R40/R41 落地：
`engine.gleam` + `no_timeframe_mixture.sh` 删除，函数归位 `timeframe.gleam`
（直线管道，五步 `fn(Timeframe) -> Timeframe`），`sourcebar.to_databar`
归位、`fold_sourcebar` 删除，`desk.put_timeframe_under` 新增，
`manual_enter/exit` 删除、`*_leaf_settled` 新增；两个旧 monitor 测试按 R39
改断言。04-10 = retrofit；04-11 replay 撤回；04-12 形状探针 + R40/R41。
Historical, not owner design: `monitor.gleam`, `probes/parallel-bars/`;
disposition awaits owner. Remaining real work: connect each provider's
**real-time arrival** to `timeframe.sourcebar_gate` (history batch = same
pair n times; no second implementation, no CLI); R42 的「空 test 架子」与
R43 的「**空架子阶段**对照设计核验并因此改名/删瞎编」尚未实测，留待下轮
（「测试互相推翻」是已被 R43 纠正的误读，不再作为待办）。
