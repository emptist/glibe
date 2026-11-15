# MEMORY — glibe (index only; verbatim rulings in `docs/RULINGS.md`, detail in daily logs)

## Authority & identity
**Owner's current statement > spec > legacy code > my inference.** I am
space-bunny; user is emptist. `glib/docs/` = hy4's AI prose (a different
model, banned from glib): never adopt its first person or "gate"/"ladder"
vocabulary. Owner's words: `sourcebar_gate`, **price checker**, **risk
manager**. glib docs are NOT evidence of glib code (R38). **AI's own recorded
ruling is not owner vocabulary** (R46 / R49).

## Direction
- *"glibe is the future, pure erlang target is the future"*, *"BEAM is great"*;
  `src/` Gleam only, root target erlang, `webclient/` the only JS package
  (R16–R18). **Concurrency = BEAM only.** Web frontend for human eyes.
- **Root law: use a type whenever a type is needed in nature** — no universal
  `String` + parser + `panic` + sh/grep guard to repair it.
- 「简单是正确的验证码」: complexity means definitions are wrong; fix them,
  add no mechanism.

## Process (R19, mandatory)
Load `gleam-language` skill + read `references/gleam-core.md` **IN FULL**
before any Gleam judgement; `docs/gleam-thinking-core-to-memory.md` is its
byte-equal mirror (keep `cmp`-equal). One module, whole process:
① `////` naming the `.planning` item + `///` on every item →
② empty skeleton (`todo as "…"`) → ③ unit tests hold the design goal →
④ fill bodies to green.
`gleam build --warnings-as-errors` is a **FIXED gate from the first
skeleton** (R48); never exempt a warning class. `gleam docs build` →
`package-interface.json` is the anti-drift check (a `////` block broken by
`//` truncates it). Retrofitting docs/tests ≠ this process.
`docs/` = 差生补课笔记, not assets; never write prose docs to record
concepts. **Never write a ruling into `////`/`///` until the code matches.**
R47: every `////`/`///` must translate to 「谁读/写哪个具体值」; no
self-exemption wording. **R50 extends this to the whole file: one file must
translate to ONE ownership relation.**

## Rulings index (full text: `docs/RULINGS.md`)
R12 `1e-6·bb_m` floor · R13 closed sets are types · R14 `src/` Gleam only ·
R15 IB = historic stocks/ETFs · R16–18 JS scope · R19 process above ·
**R20** `Desk ▸ Broker ▸ Instrument ▸ Timeframe`, dashboard = VIEW ·
**R21** full constructor names; wire codes only in codec ·
**R22** `Symbol` is a name, never `Instrument` ·
**R23** interval lives in the KEY; no composite keys / second dict /
`list.find` · R24 Mist+Wisp = AI demo · R25 `TPlus1`/`CPU` are terms ·
R26 Asset/Exchange/Market open, add types one at a time ·
**R27** `SourceBar.timestamp` = `gleam_time.Timestamp` ·
**R28** provider native shapes (`Kline`) + own `to_sourcebar`; standard
layer is the only union point · **R29** `sourcebar_closed` = UTC unix-second grid（11-15 前旧名 `bucket_ends`）·
**R30** web wall clock = OUTPUT-side projection; CSV stays UTC ·
R31 BEAM language facts ≠ this system · R32 add one field by real ownership ·
**R33** system IS ALREADY LIVE: one stream, pure value recompute, no actor /
scheduler / clock / poll; `Desk` is the ONE top-level Value ·
**R34** seib = CoffeeScript, owner's own design, structure RIGHT; ibOptions
= Python+pandas workaround, 五脏俱全但都不对劲 ·
**R35** SwiftUI similarity ONLY in View definition ·
**R36** Market/Broker not subordinate either way → no gap ·
**R37** a chain level needs TWO ownership relations; **identity lives in the
holder's Dict key**; *「你的左手不知道他是左还是右」* ·
**R38** the stream has NO rewind; one arriving bar = call the pair in
order, no third function · **R39** qualified `SourceBar` →
`working_databar` → ALL computation in it → archived → `databar_list`;
no side doors; `sourcebar.to_databar`, `bars_listed` not `bars_accepted` ·
**R40/R40-A/R41** `databar_processing` = `timeframe |> f1 |> … |> fN`,
each step `fn(Timeframe, ...extra) -> Timeframe`, subject FIRST and
returned; `|>` is a SHAPE constraint ·
**R42** glibe = 抄 glib 作业 + owner 裁定修正, 不另造设计;
`timeframe.gleam` = `Timeframe` + 全部相关 fn; no `engine.gleam`;
`Desk` = top/root, **上面不再有东西**; 空架子即设计, 连最初 unit test
也是空的 · **R43** 「反复推敲」= 反复对照 owner 设计核验空架子
（用词准确 / 有无瞎编）, 不是测试互相推翻; 全绿编译不检查名字出处 ·
**R44** `doc-tdd` 系统性重建; 旧代码是历史遗迹, 红绿数字无意义;
项目层无 guard sh, 只认编译器命令 + `package-interface.json` ·
**R45** 清场后不得翻 deprecated 当词库; 名字只从 owner 逐字 + 裁定取 ·
**R46** `TimeframeSettings` 是 AI 造的 → 删 module / field / `new` / test ·
**R47** `////`/`///` 必须能译成谁读写哪个具体值; 禁止免检措辞;
**无提示自行发现尚未实测** ·
**R48** `--warnings-as-errors` 只在 `gleam build`; 固定门禁, 不许按类别
豁免, 不许 `_` 批量静音; WAE 报的是逐条待实现清单 ·
**R49** `new`/`create`/`make` 先按 bug 查, 无 container 豁免; 值在拥有
它的地方构造; R33 逐字只命名 `Desk`, 没命名任何函数 ·
**R50** 一个模块只读写它自己那一层**持有的** Dict（`Broker` 有两个）;
**Desk 上面不再有 module** → 删 `config.gleam`; 恒为一个 Desk, 无
`DeskId`; id types 集中成零 import 叶子; `timeframe_under` /
`put_timeframe_under` / `LookupError` 删除; **R42「真缺口 = WRITE 半边」
作废**; core §5 反的是按设计模式切, 不是按业务域归属切.

## Measured facts
Gleam 1.19.2 / OTP 29: `import mod.{type T, Ctor}`; no `T(..)`; `@external`
may coexist with a Gleam body; `.abstr → .beam`. **`pub opaque`
constructor used from another module → `error: Use of private value`;
mutual imports → `error: Import cycle`** (R50 probe). Mist 6.0.3
`mist.start`; `wisp.Text`; `gleam run -m <mod>` needs no root `main`.
`package-interface.json`: `modules` is a dict, `documentation` a list of
lines. Tests: `assert … as "msg"`, `let assert`, never `panic`/`case Bool`.
**2026-11-15**: `fn(of: T) -> R` is `Syntax error` — labelled arguments
are NOT part of a function type, so a type binding cannot pin a label;
pin it at an uncalled call site instead. A function name may not start
with `_` ("expecting a lowercase name here").

## Conventions
- **No bare `Qn` labels** — cite full path + section title.
- Pending decisions **only** in `docs/PENDING_DECISIONS.md`: decisions
  FIRST, rest under `# REFERENCE`; no other document may reference it.
- **Owner 2026-11-09: ".gitignore 及时更新，及时做提交"** — ignore rules
  BEFORE artifacts; one logical concern per commit; never `rm -rf build`.
- **Owner 2026-11-14: "push本身又不是什么破坏性动作，哪有什么约定不能push，
  你不要push --force就行了"** — 普通 fast-forward `git push` 直接做、
  不请示；`--force` / `--force-with-lease` / 任何改写远端历史的操作
  **必须先问**。原先的「do not push unless asked」是 AI 注记冒充 owner
  约定，已删（逐字与查证见 `docs/RULINGS.md` 2026-11-14 执行注记）。
- Toolchain: `export PATH="/opt/homebrew/bin:$PATH"`; capture exit codes.
- R44 起项目层没有 guard sh。设计探针: `gleam check` / `build` /
  `format --check src test` / `docs build` / `export package-interface`.
  `gleam build --warnings-as-errors` 从空架子起就是固定门禁（CI 已挂）:
  骨架阶段必红, 逐条读到行, 不许整包豁免或 `_` 洗信号。
  core mirror `cmp` 不是门禁脚本。

## State (2026-11-15, doc-tdd, 已 push 到 origin/doc-tdd)
`src/` = **15 个模块**（`package-interface` 实测 `modules: 15`），函数体
已填 2 个 body（`kline.to_sourcebar`、`timeframe.bars_listed`）;
`test/` 14 个 shape test + **2 个真断言**（16 passed）。
链按 R50 分层: `id`/`account`（零 import）→ `instrument` → `broker` →
`desk`; `config.gleam` 已删。WAE 仍红（**76 `Todo`** / 196 warnings，R48 逐条清单；
owner review 基线 70，instrument 九 arm +8、symbol 填一 arm −1）。
**owner 2026-11-14 in-code review 已逐条落实**（原样基线 `2c54535`）：
`id` 的 `string_to_*` 改名、`sourcebar.interval(of sourcebar:)` 加 label、
`symbol.string_to_symbol` 与一个 arm 的 body、`instrument` 九 arm case
骨架。**2026-11-15 命名原则已全面类推**：`bucket_ends` →
`sourcebar_closed`；`bucket` / `bar` / `instant` / `finished` /
`unclosed` → 有 Type 或有真实出处的词；`working_databar_archived` /
`open` / `close` / owner 逐字字段名 / provider 原生字段保护不动；
`latest_price` 在 Binance 与 IB bars 里不存在，不引入。逐字全文见
`docs/RULINGS.md` 2026-11-15 执行注记。**owner 07:12 追加裁定**：
`bars_listed` **不是计数**——`databar_list` 倒叙归档是针对 Gleam
`List`（单向链表）的刻意设计，凡 list 相关函数与成员获取一律读头部
O(1)，禁 `list.length` / `list.find` / `list.append`；
`symbol.symbol_to_string` → **`symbol.to_string`**（module 与 type
同名时省前缀，调用读作 `symbol.to_string`），owner 先前那条
`<**human**>` review 逐字留在代码里但不作为规格。逐字与 glib
代码出处见 `docs/RULINGS.md`「2026-11-15 07:04–07:12」。
**未定**：只剩 `Symbol` 变体归属（Shape A / B 编译比较见
`2026-11-15.md`）。`trading/signal.from_string` /
`api/interval.from_string` owner 未点名、不属本次「无 Type 支撑的名词」
问题，不动、不列待裁决项。
**R19 第一个 body 已填**: `kline.to_sourcebar`（RED 11/1 → GREEN
12 passed）。构造子作一等函数不接受 labelled argument，9 arm 各自构造。
**「仍留白」清单（11-12 §5.1）已失效**: 5 项里 4 项早落进骨架
（`DataBar` / leaf / branch 字段、`BinanceKline` 12 字段、
`SourceBarRejectionUnqualified`）；仅 `Account` 仍是零字段占位
（`account.gleam:27-29`，R26/R32 刻意等消费方）。**Kline 线格式不是
设计留白** —— Binance 官方 12 字段照抄即可（R28），别拿它向 owner
要逐字；provider 的数据问题查 provider 手册，不靠推理。
**owner 07:31（只写文档，`src/`/`test/` 未改）**：新建根
`DEVELOPER_GUIDE.md`（10 节：倒叙归档 / `DataBar.idx` vs
`SourceBar` / 数据 List 一览 / 三类例外 / 骨架 todo 对照表 /
doc-first TDD 是根本措施），`README.md` 修两处假话并加 list 小节，
`HANDOFF.md` 加导航。官方 `gleam_stdlib` v1.0.5 `gleam/list` 逐字：
prepend/读头 O(1)（即便 VM 优化仍是 O(n)）；`idx` 让长度/跨度/
窗口边界变成相减；glib 里 `databar_list` / `sourcebar_buffer` /
`signif_*_leaf_list` / `yin/yang_branch_list` 全部 prepend + 读头；
三类例外按 owner 判据分类，不宣布 glib 全对。逐字全文与
file:line 查证见 `docs/RULINGS.md`「2026-11-15 07:31」。
**owner 07:42（只写文档，`src/`/`test/` 未改）**：问「倒叙 List 怎样画图、
`reverse` 是否低效」→ **第二个关键措施 = 输出侧投影 + 单条增量流**：
引擎只存倒序那一份，顺序是边界的一次投影；实时每根 bar 只发一根 SSE
`chart_data`，前端 `appendBar` + `series.update` O(1) 追加，初始绘制也走
同一个函数（`No setData` / `not a second source of bars`）。`list.reverse`
全库 7 处全在边界，无一处挂每根 bar 路径；oldest-first 存会 N 根
**O(N²)**，现在 **O(N)** + 边界各一次 O(N)——成本挂在「人看一次」而非
「数据到达 N 次」的频率上。与 **R30**「标准层 / 显示层分开、显示层是
投影」同构，R20 / R33 / R38 支撑。`DEVELOPER_GUIDE.md` 新增 §6
（原 §6–§10 顺延 §7–§11），§7(b) 从「例外」升格为「§6 措施在文件
边界的形态」；`README.md` 加 *The chart is not drawn backwards*。owner
写 `revert`，官方函数是 `list.reverse`，文档按 function 走只用 `reverse`。
逐字与 6 步链路查证见 `docs/RULINGS.md`「2026-11-15 07:42」。
**owner 07:59（只写文档，`src/`/`test/` 未改）**：回答自己 07:42 的问题
→ 关键技术是 **stream 模式**，*"纵有万千条k线，系统里面其实只有一根
在工作，那就是 working_databar, you almost always only need that one
databar"*；绘图软件第一条判据 = **能否单根 bar 更新 chart**，不能则
「我们的系统不能用他」；并要求对每处 reverse 追问 *"Was glib doing
properly? You have to ask."* **07:42 那句「7 处全在边界、无一处挂每根
bar」被限定**：那只是 `*.gleam` 计数；另检出 2 处 JS FFI
`.reverse()` 挂在每根 bar（`binance_trading_ffi.mjs:37/81`，
`apply_bar` 在 `:170/:227/:282`）与每次 poll
（`paper_trading_ffi.mjs:273`）。`sourcebar_list` 导出不能直接删
reverse —— `json.array` / `decode.list` 保序、读回逐根喂流要求
oldest-first，删了会倒着喂；挪到读侧只换边；要省掉只能不攒 buffer
或不要这条导出（glibe `Timeframe:106-120` 目前没有该字段）。
`try_plushie`：框架机制支持单根（`test:394-423` 断言 1 insert /
0 update_props），但 `subscribe()` 返回 `[]`、`fusion_view.window()`
每次 view 都 `length`+`drop`+`take`+`reverse` 整窗 ⇒ ~~当前不满足
第一条门槛~~ **（08:13 已由 owner 修正，见下：改错的实现回归，
不是选型否决）**；本次 `gleam test` 在该项目 exit 1
（`explore.gleam:158` `list.range` 不存在），数字是源码断言非实测。`DEVELOPER_GUIDE.md`
新增 §6.5 / §7(e)（9 处逐处提问表）、§6.1 加订正块；README /
STATE / HANDOFF（修掉「不要 push」假约定）同步；RULINGS 追加 07:59
逐字与查证。**本轮不宣布 glib 全对，也不宣布它错。** 逐字全文见
`docs/RULINGS.md`「2026-11-15 07:59」。
**owner 08:13（只写文档，`src/`/`test/` 未改）**：对 07:59 两问的
答复逐字 —— `sourcebar_buffer` 导出 **「一会儿讨论这个问题」**
（保持待裁决、不预设不催）；plushie **「那个里面的绘图是手搓的，
AI声称可以单bar更新，确实最初版本是做到的，如果你发现目前不是，
那是他后来搞错了，不是不可以改正」**。⇒ **07:59 的落点错了**：
绘图是手搓的，判据问的不是库的能力上限，而是我们自己的实现有没有
守住「只吃 head 那一根」；能力最初版本做到过，当前的整窗重画是
**后来 AI 改错的实现回归、可改正**，不是「不能用他」的证据。
**不判当前不可用、不排除 plushie、不转向别的库。**
查证边界：`try_plushie` 仓库 `git log` 无提交（*"does not have any
commits yet"*），「最初版本做到」无法从版本历史复核，以 owner 逐字
为准、不写成实测；本次 `gleam test` 在该项目仍 exit 1。
RULINGS 追加 08:13 注记；DEVELOPER_GUIDE §6.5/§11、README、
PENDING_DECISIONS（删第 2 项）、STATE 08:13 节同步；决策区 2 → 1。
逐字全文见 `docs/RULINGS.md`「2026-11-15 08:13」。
**owner 08:16（只写文档）**：*"注意经过对比和实证，我已经转向了glibe
这个拒绝JS target的项目，mjs也是祸根之一，AI不会自我约束，所以要换成
erlang target，并且禁止手写erl"*。**三个探针实测**（`/tmp/glibe_target_probe`，
target=erlang）：JS-only `@external(javascript,…)` → **exit 1**
`Unsupported target`；手写 `src/hand_written.erl` + `@external(erlang,…)`
→ **exit 0**、`hand_written.beam` 被编译 ⇒ **编译器不拦手写 erl**，
「禁止手写erl」是必需第二半且编译绿≠合规；孤立 `.mjs` → exit 0、
只复制到 `_gleam_artefacts/`。glibe 现状：`gleam.toml:3 target="erlang"`，
`src/` 15 `.gleam` / 零 `@external`（现状非目标，见 08:28）/ 零 `.erl`，build 里 196 个 `.erl`
全属 hex 依赖或 runner stub；`webclient/` 仍是 R18 独立 JS-target 包、
生成 `.mjs`、零手写 JS。BEAM 能力只走 OTP `@external(erlang,…)` 或
`gleam add` 包（externals.md §5 同条）。**未擅动** `webclient/gleam.toml:8`
/ `src/webclient.gleam:20` 的 R16/R18 手写 `.mjs` 兜底（owner 没点名）。
逐字与实证见 `docs/RULINGS.md`「2026-11-15 08:16」。
**未收敛**: `gleam.toml` 旧依赖表、`webclient/` 旧实现。
决策区 **2 项**：① `sourcebar_buffer` 导出要不要存在（A 不引入 /
B stream 写 / C 照 glib 抄 / D 先不定），owner「一会儿讨论」；
② 08:16「拒绝 JS target」是否一并收紧 `webclient/`（A 只约束引擎、
取消手写兜底 / B 全项目无 JS target / C R16/R18 原样不动）。
**owner 08:27（工作方法，强制）**：*"你不可再使用这种提问方式，
有决策问题写入 单独文档，我会去看。"* ⇒ 决策只写进
`docs/PENDING_DECISIONS.md`「需要你决定」；对话里不弹选项卡片、
不催、选项不预设推荐，未答项不等于否决。
**owner 08:28（术语，必须记住）**：*"0 external 并不一定是好事 …
exteranl is not equal to FFI, and is not based on handwritten
erlang or elixir, while handwritten erlang and elixir by you are
prohibited, external 是必须的正常的合理的gleam设计"*。
⇒ **零 `@external` 只是骨架现状，不是目标/成绩**；需要 runtime
API 就正常写 `@external(erlang, "lists"/"os"/"httpc"/…)` 或
`gleam add` 包。`@external(erlang,…)` ≠ FFI ≠ 手写 erl；禁的只有
AI 手写 `.erl`/`.ex`/`.mjs` 进 `src/`。官方 Externals guide
（本轮实读）：*"Gleam on Erlang can use Erlang, Elixir, LFE, and
other BEAM languages"*；*"most projects won't use any at all"*
是用度建议与统计，不是「零才好」。AI 常把「禁手写 erl」滑成
「零 external 才干净」——别再犯。
**owner 08:30**：*"如果没有找到关于FFI仅限于JS的原因，那么AI没
记下来，他可能记录到workbuddy的全局Memory里面去了。很愚蠢的做法。"*
⇒ **Gleam 语言知识的家是 `~gits/gleam-language`，不是 WorkBuddy
全局 Memory**。理由在 `knowledge/externals.md` §2（BEAM 同 VM ⇒
external；JS 跨运行时 ⇒ FFI），但该文件在知识中心仓库是 `??`
未跟踪、`SKILL.md` 是 `M`、无 remote ⇒ 没进版本历史；全局 Memory
只有 R14/R15 摘要。本轮不写全局 Memory、不擅自提交那个仓库。
逐字与查证见 `docs/RULINGS.md`「2026-11-15 08:27 / 08:28 / 08:30」。
