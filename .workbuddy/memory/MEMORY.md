# MEMORY — glibe (index only; verbatim rulings in `docs/RULINGS.md`, detail in daily logs)

## Authority & identity
**Owner's current statement > spec > legacy code > my inference.** I am
space-bunny; user is emptist. `glib/docs/` = hy4's AI prose (different model,
banned from glib): never adopt its first person or generic "gate"/"ladder"
vocabulary. Owner's words: `sourcebar_gate`, **price checker**, **risk
manager**. **glib docs are NOT evidence of glib code** (R38): compare docs
against code; take only implementations fitting current rulings. glib is not
authority. AI's own recorded ruling is not owner vocabulary either (R46).

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
anti-drift check (**a `////` block broken by `//` truncates it**). Retrofitting
docs/tests onto existing code is NOT this process — label it retrofit.
`docs/` = 「差生补课笔记」, not assets: never create prose docs to record
concepts. **Never write a ruling into `////`/`///` until the code matches**.

## Rulings R12–R47 (full text: `docs/RULINGS.md`)
R12 `1e-6·bb_m` floor · R13 closed sets are types · R14 `src/` Gleam only ·
R15 IB = historic stocks/ETFs · R16–R18 JS scope · R19 process above.
**R20** `Desk ▸ Broker ▸ Instrument ▸ Timeframe`, dashboard = VIEW.
**R21** full constructor names (`IntervalOneDay`); `H4`/`"1h"` only in
codec/adapter; R25 `TPlus1`/`CPU` are terms.
**R22** `Symbol` is a name, never `Instrument`. **R23** interval lives in the
KEY; no composite keys, second dict or `list.find`. ⚠ R23 §3's "keep
`TimeframeSettings` as a parameter block" is **struck by R46**.
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
**R38** **the stream has no rewind** (*"长江万里哪有倒退重来的道理"*): no
`replay`, no "replay CLI"; names must name real things. One arriving bar =
call the pair in order → **no third function**.
**R39** qualified `SourceBar` → `working_databar` → **all** computation/
processing/decisions happen **in that working databar** →
`working_databar_archived` → `databar_list`. One straight line, **no side
doors**; any step passing the bar as an argument has drifted.
`sourcebar.to_databar` (one bar born whole); `working_databar_archived(tf)`
takes no bar; `bars_listed` not `bars_accepted`.
**R40 / R40-A** `databar_processing` body = `timeframe |> f1 |> f2 ... |>
fN`, infinitely extensible; every step `fn(Timeframe, ...extra) -> Timeframe`
(ANY number of extra args, subject FIRST and returned); no step passes the bar.
Official tour "Pipelines": `rocket |> launch(1, 2)` = `launch(rocket, 1, 2)`;
bare name = one-arg call; `f(1, _)` capture moves the piped value later.
Measured green in `probes/timeframe-pipeline/` (11 tests, RED→GREEN twice).
Gleam refuses only a step RETURNING `#(Timeframe, a)`; parameter count is
never a restriction — a fact reaching a later step belongs in a FIELD.
**R41** `|>` is a SHAPE constraint, not formatting (owner: AI invents
parameter order / return types). Four throwaway packages
`/tmp/gleam_shape_negative`: control 0, wrong first arg 1, wrong return 1,
same invented signatures as ordinary calls 0.
**R42** glibe = 抄 glib 作业 + JS→Erlang 改编 + owner 裁定修正, **不另造设计**；
`timeframe.gleam` = `Timeframe` type + 全部相关 fn (glib `:32-35`)；
**`engine.gleam` 删除**；`no_timeframe_mixture.sh` 删除。**空架子即设计**：
`////`/`///` + type 关系 + 签名 in/out 对齐，`gleam build` 就照出缺口，
**一行干活代码都不用写**；倒推 upstream → 正推回 timeframe → 一路到
`Desk`；连最初 unit test 也是空的。`Desk` = top type / 根 / 中心控制室，
**上面不再有东西**。倒推查出的真缺口 = WRITE 半边 `put_timeframe_under`。
**R43** 空架子把 glib 只「如是我闻」的设计变成「信受奉行」。
**「反复推敲」= 反复对照 owner 设计核验空架子，判据：用词是否准确、
有无自己瞎编的东西**；**不是**测试之间互相推翻。理由：无实代码 → 系统
轻灵 → 一次载入 token 限量内；**前提**：*"我早已把整个系统设计成熟了"*。
实测：引用/用词漂移能活过全绿 build 与 test，只有回读设计才能发现。
**R44** `doc-tdd` 分支系统性重建：旧代码仅是历史遗迹
(`deprecated/2026-11-12-pre-doc-tdd/`, 79 files)，只读、不作依据、不参与
编译。**过去红绿数字无意义**；`gleam check`/`build` 是**设计探针报缺口**。
**项目层不再有 guard sh**（CI 那行也删）：只认编译器自身命令 +
`package-interface.json`；行为层（及时提交）靠纪律。实测 `gleam check`、
`gleam export package-interface --out`、`gleam docs build`、
`gleam format --check`。
**R45** *「你的旧实现搞他干嘛」* / *「你现在把types搞清楚，其他的东西从我的
用词当中去获取即可」*。清场后**不得翻 deprecated 当词库**；名字只从 owner
逐字用词 + 裁定取，没命名的按 R26/R32 留空。⚠ 本条曾把 R23
`TimeframeSettings` 列为「合法来源」，**已被 R46 推翻**。R43 判据含
**引用是否真逐字**，不得把 AI 转述标成 `owner, verbatim`。
**R46 (11-12 11:46)** `TimeframeSettings` 是 AI 造的，owner 不认识：
*「我不知道是什么玩意」*、*「问题是他做什么，谁用他，为什么存在」*。
⇒ 删除 `indicator_settings.gleam`、`Timeframe.settings` 字段、
`timeframe.new` 及其空 test；不留占位参数包、不改名。参数随真实消费方
按 R26/R32 一个一个落进真正拥有它的 type。**AI 记在 RULINGS 里的
裁定不是词源**：owner 在 R23 里是**质问**这个名字，不是命名它。
**R47 (11-12 12:03)** *「如果我不提出来，你能不能根据逻辑自己发现问题
呢？」* / *「这是什么玩意你自己看得懂不？」*。⇒ **看不懂**：那句 `///`
是 4 句否定 + 1 句作废断言 + 0 句事实；同模块 `////` 还写着「挂 `///`
即合法骨架」「无行为是设计如此」两句**自我豁免**。判据早齐，缺的是
**触发点**：前两轮只做词源审计、没做所指审计。写 `////`/`///` 后必须能
译成「谁读 / 写哪个具体值」，译不出即瞎编；禁止免检措辞。R43 的
「空架子轻灵」= 实现空、关系明确；空壳 = 关系本身为空，勿混。全绿
编译连空洞文档也放过。**本轮仍是 owner 点出后的开卷自检，无提示
自行发现尚未实测。**

## Measured facts
Gleam 1.19.2 / OTP 29: `import mod.{type T, Ctor}`; no `T(..)`; `@external`
may coexist with a Gleam body; `.abstr → .beam`. Mist 6.0.3 `mist.start`;
`wisp.Text`; `wisp/simulate.request`; `gleam run -m <mod>` needs no root
`main`. `package-interface.json`: `modules` is a **dict**, `documentation`
a **list of lines** — join with `"\n"`. Tests: bool `assert … as "msg"`,
`let assert`, never `panic`/`case Bool`.

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
  `gleam build --warnings-as-errors` 只属于填完 body 后的 GREEN 闸门。
  core mirror `cmp` 是 skill 与仓库镜像的字节一致性检查，不是门禁脚本。

## State (2026-11-12, doc-tdd)
分支 **`doc-tdd`**（就地新建，未 push）；04-13 及以前的实现整体封存为历史
遗迹。旧 README（464 行，教人跑已删的 guard sh）移入 `notes/`，根目录换成
15 行索引；CI 删 `sh scripts/guards.sh --all`。
**`src/` = 空架子、零行实代码**：`////` / `///` + type 关系 + 全标注签名，
函数体全 `todo`；`test/glibe_test.gleam` 空 unit test 只固定 in/out types。
`desk.gleam` 持整条链与 read/write 服务（不拆 broker/instrument 模块），
`timeframe.gleam` 持直线与管道全部 fn（不设 engine / indicator / strategy
模块），输出侧 view 边界写在 `desk.gleam` 的 `////`（不造 web/server）。
设计探针：`gleam check` / `build` / `format --check` / `docs build` /
`export package-interface --out` 均 exit 0，`////` 完整渲染。
**R43 空架子阶段核验本轮首次实测**（05-01 §5）：删 1 个自造占位构造子、
2 处假引用/假断言、5 个自造模块名，补 4 处出处；`Timeframe` 的 growing /
settled 字段回查 R1/R2/R4 后确认是 owner 设计，**保留**。但同轮漏掉了
`TimeframeSettings`（R46 补删）—— **全绿编译不检查名字的出处**。
**仍留白（R26/R32）**：`DataBar` 计算字段、leaf/branch 内部字段、`Kline`
线格式字段、`SourceBarRejection` 具体原因、`Account` 字段。
**未收敛**：`gleam.toml` 旧依赖表、`webclient/` 旧实现。
决策区 0；**未 push**；按逻辑原子提交，不 push。
