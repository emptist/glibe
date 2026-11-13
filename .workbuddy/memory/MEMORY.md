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
layer is the only union point · **R29** `bucket_ends` = UTC unix-second grid ·
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

## Conventions
- **No bare `Qn` labels** — cite full path + section title.
- Pending decisions **only** in `docs/PENDING_DECISIONS.md`: decisions
  FIRST, rest under `# REFERENCE`; no other document may reference it.
- **Owner 2026-11-09: ".gitignore 及时更新，及时做提交"** — ignore rules
  BEFORE artifacts; one logical concern per commit; **do not push unless
  asked**; never `rm -rf build`.
- Toolchain: `export PATH="/opt/homebrew/bin:$PATH"`; capture exit codes.
- R44 起项目层没有 guard sh。设计探针: `gleam check` / `build` /
  `format --check src test` / `docs build` / `export package-interface`.
  `gleam build --warnings-as-errors` 从空架子起就是固定门禁（CI 已挂）:
  骨架阶段必红, 逐条读到行, 不许整包豁免或 `_` 洗信号。
  core mirror `cmp` 不是门禁脚本。

## State (2026-11-14, doc-tdd, 未 push)
`src/` = **15 个模块**（`package-interface` 实测 `modules: 15`），函数体
仍多为 `todo`; `test/` 9 个空 shape test + **1 个真断言**。
链按 R50 分层: `id`/`account`（零 import）→ `instrument` → `broker` →
`desk`; `config.gleam` 已删。WAE 仍红（69 `Todo`，R48 逐条清单）。
**R19 第一个 body 已填**: `kline.to_sourcebar`（RED 11/1 → GREEN
12 passed）。构造子作一等函数不接受 labelled argument，9 arm 各自构造。
**「仍留白」清单（11-12 §5.1）已失效**: 5 项里 4 项早落进骨架
（`DataBar` / leaf / branch 字段、`BinanceKline` 12 字段、
`SourceBarRejectionUnqualified`）；仅 `Account` 仍是零字段占位
（`account.gleam:27-29`，R26/R32 刻意等消费方）。**Kline 线格式不是
设计留白** —— Binance 官方 12 字段照抄即可（R28），别拿它向 owner
要逐字；provider 的数据问题查 provider 手册，不靠推理。
**未收敛**: `gleam.toml` 旧依赖表、`webclient/` 旧实现。
决策区 **0 项**。
