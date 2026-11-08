# MEMORY — glibe (curated, compact)

## Authority
**Owner's current statement > Idris spec > legacy code > my inference.**
`glib/docs/` is mostly hy4's AI prose, not the owner's record; owner words appear
as dated `[user …]`, `{<UC: …>}` and verbatim Chinese quotes in
`glib/docs/RULINGS.md`. hy4 is a different model banned from glib; never inherit
its first person, its vocabulary (generic "gate", "price gate", "risk gate",
"ladder"/"Rung") or rewrite owner quotes. Owner words: `sourcebar_gate` (the only
gate), **price checker**, **risk manager**.

## Direction
- *"glibe is the future, pure erlang target is the future"*; *"BEAM is great"*;
  *"No handwritten erlangs or even worse JS source files"* → `src/` Gleam only.
  **Use a type whenever a type is needed in nature** (root law): no universal
  `String` + parser + sh/grep guard to repair it.
- **glibe does not wait on glib**: take owner rulings + glib's good code directly;
  never cite an unbuilt glib roadmap as a dependency.
- Root stays erlang. `webclient/` is the only JS-target package (R18); generated
  `.mjs` preferred (R17); small hand-written JS allowed only there (R16).
- Web frontend exists for human eyes: spot output anomalies, read trend charts,
  inspect tabular fractal structures, see order issue/fill points.

## Load before any Gleam judgement
`docs/gleam-thinking-core-to-memory.md` **IN FULL** (git mirror of
`~/.workbuddy/skills/gleam-language/references/gleam-core.md`; keep `cmp`-equal).
Workflow (R19): `////` module doc **naming the `.planning` item** → types →
`///` on every type/function → `todo as "…"` bodies → tests → bodies → green.
`gleam docs build` → `package-interface.json` makes the plan link machine-
readable; that is the anti-drift check, **no new sh guard**.
`--warnings-as-errors` is a GREEN gate only; RED skeletons legitimately fail it.
Every AI-authored file in every project follows this docs-first order.

## Rulings — full text in `docs/RULINGS.md`
R12 one `1e-6·bb_m` lower-band floor before interpolation. R13 closed sets are
types. R14 `src/` Gleam only. R15 IB = historic stocks/ETFs only; guard fails on
`@external(javascript,…)` and `target = "javascript"`. R16 small-scope hand-
written JS already permitted. R17 JS chart lib adopted. R18 Phoenix app →
`deprecated/`, separate `webclient/`. R19 docs-first/TDD in code. R20
`Desk ▸ Broker ▸ Instrument ▸ Timeframe` is **must-have**; name **`Desk`**
(owner's 2026-11-03 "Deck" quote = recorded spelling drift, not a renaming
order); dashboard = VIEW in `webclient/`. R21 **constructors named in full,
prefixed by the type name** (`IntervalOneDay`); letter+digit wire codes as type
constructors banned, wire spellings (`"1h"`) only in codec/adapter. Historical
review/session docs keep old codes as records.
R22 **`Symbol` is a name, never the `Instrument`**: a title cannot be the
entity; wrong things are corrected cleanly — no alias, no compat layer, no
workaround that makes the next correction harder. R23 **`TimeframeSettings` is not an entity**: it is the parameter
block of one `Timeframe` (`Timeframe.settings`); no second dict, no composite
`"BTCUSDT_H1"` key, no `list.find`; `Timeframe` never carries `symbol` /
`interval` / `market_type` — interval is in the key. R24 web-layer framework
choice is **the AI's demo comparison work, not an owner ruling**; adopted as
Mist+Wisp in 04-05. R25 a
recognised professional term (CPU, T+1/T+2) is **not** an abbreviation; keep
`TPlus1`/`TPlus2`. Wire codes like `H4`/`M1` are still banned.
R26 **only `Broker ▸ Instrument` is settled** (data-source argument); relations
among `Asset` / `Exchange` / `Market` and to `Instrument` are deliberately
open — add types **one at a time when a consumer needs one**, no advance
identity-typing plan, no speculative `Market` level. `assets`/`exchanges`
have 0 consumers; `Instrument = Asset on Market` is AI prose, do not revive.

## Measured facts
- Gleam 1.19.2: `import mod.{type T, Ctor}`; **no `T(..)` form**. A function may
  have an `@external` **and** a Gleam body (fallback). v1.19.0 emits
  `.abstr → .beam`, no per-module `.erl`; only the `@@main.erl` runner stub.
- `gleam build` does **not** resolve npm deps: green build ≠ runnable app
  (`ERR_MODULE_NOT_FOUND`). LightweightCharts v5 exports `createChart`,
  `LineSeries`…; `addSeries`/`updateSeries` are **instance methods**; dotted
  `@external` names fail to compile. Add a runtime import check.
- `lpil` = Louis Pilfold (Gleam + Wisp); Mist = `rawhat`; Lustre = Hayleigh
  Thompson. Popcorn/WASM research only, **not adopted**. psipi unverified.
- Tests: bool `assert … as "msg"`, `let assert`; never `panic` or `case Bool`.
  Negative guard tests use `/tmp` fixtures (`scripts/test_guards.sh`), **never**
  plant broken code in real `src/`.
- Web demos (04-04, R24): Mist+Wisp 72 lines/22 Hex vs +Lustre server
  component 124/23 vs bare Mist 82/14; all 0 hand-written JS, 0 npm, same
  generated `webclient.mjs`. **A adopted (04-05)**: root `gleam.toml` has
  `mist`+`wisp`; `src/glibe/web/server.gleam` serves the real `Desk` at `/`
  (HTML table) and `/desk` (JSON), `gleam run -m glibe/web/server` on 8610;
  54 tests green. Mist 6.0.3 = `mist.start` (Wisp doc example's
  `start_http` is stale); Lustre 5.7.1 `html.title(attrs, String)`.
  `wisp/simulate.request(method, path)` builds a real Wisp Request for
  handler tests; `wisp.Text(body)` is the response body constructor.
  `gleam run -m <module>` runs a module's `main` without a root `main` slot.
- *"Needs no JS library"* is a **dependency** claim, not a capability claim.
  Series/option definitions and per-bar mapping are inherent work, **not** extra
  cost. Real-data chart trial deferred until databar processing is complete.

## Conventions
- **No bare `Qn` labels** — cite full path + section title.
- Pending decisions live **only** in `docs/PENDING_DECISIONS.md`: self-contained,
  **decisions FIRST at the very top**, everything else under a clearly labelled
  `# REFERENCE` block the owner does not read (owner 2026-11-08: too long and
  messy, decided items mixed in). Never repeat decided items in the decision
  section. One-way: it may copy from other docs, but **no other document may
  reference it** — verify repo-wide after any edit. `docs/QUESTIONS.md` =
  withdrawn items only.
- **Owner 2026-11-09: "注意：.gitignore 及时更新，及时做提交".** Update ignore
  rules BEFORE generating artifacts, and commit each logical step as it lands,
  never in one batch at the end. `.gitignore` now uses a single `build/` rule
  (any package, any depth) so a new probe needs no remembered edit.
- Toolchain: `export PATH="/opt/homebrew/bin:$PATH"`. BSD `grep` unreliable —
  use the Grep tool or Python. Capture exit codes with `> log 2>&1; echo
  "EXIT=$?"`, never `cmd | tail`.
- Green = `gleam build` (0 errors/0 warnings) + `gleam test` + `gleam format
  --check src test` + `sh scripts/guards.sh --all`. **Build/test before
  committing**; one logical concern per commit; **do not push unless asked**;
  never `rm -rf build`.

## R27–R29 (2026-11-09) — time and provider boundaries
- Standard `SourceBar.timestamp` = `gleam_time.Timestamp` (unix time). Never a
  date `String`, a wall clock, or an invented "BarClock" (that draft was voided
  and deleted, no compat layer). `DataBar.timestamp` likewise.
- Provider native types stay native **with their own names** (`Kline` for
  Binance; `bar`/`quote` elsewhere), all wire fields kept; each provider has
  `to_sourcebar`. The standard layer is the only union point (R28).
- `bucket_ends` = unix-second remainder grid (1h 3600, 4h 14400, 3m 180).
  UTC-aligned only. US 09:30 open + DST is an explicit market-calendar debt
  (R29): use `tzif` 2.0.0 (+ `zones`/`tzif_loader`) when a US-equity consumer
  exists, never a fixed offset. `ibOptions/tradingtime.py:24` and
  `simple_auto_trading.py:132` are the reference examples.
- Wire gotcha: `float.parse("100")` is `Error(Nil)`; `parse_number` widens Int.
- Owner 2026-11-09: *"尽量发挥gleam的特长，有效减少先乱写后翻工补救的巨大消耗和浪费，一下手就把想明白的逻辑写明白。"* Put understanding in types; leave the un-thought-out in `todo`, never in `String`.

## R30 (2026-11-09) — web display time is local
- Owner: web 界面日期时间用本地时间显示以方便分析，必然涉及时间转换 + 夏令时；
  要求先在相应模块写文档方便实现（本轮只交付文档，不是待裁决项）。
- **R30 = 输出侧**（同一个 unix-time `Timestamp` → 分析者本地墙钟）；**R29 =
  输入侧**（市场当地时刻 → 绝对时刻）。两者都靠 IANA 规则（`tzif` 2.0.0 /
  浏览器运行时），禁止固定 offset 或手写 DST 表；不得合并成一个转换，显示时区
  ≠ 交易所时区。市场当地时间若并列显示，只是同一 Timestamp 的另一个带 IANA
  名的投影，不是第二个 bar / 字段。
- 标准层不变：R27 unix time、`bucket_ends` UTC 网格、CSV UTC RFC3339。
  规格在 `src/glibe/web/server.gleam` 的 `////`（主），另三个模块各写职责并
  指向 `.planning/phases/04-domain-cleanup/04-07-PLAN.md`；实现属 04-07，
  `tzif` 仍非依赖（R26）。
- **`////` 模块文档块被 `//` 行打断会截断 `package-interface.json` 里的文档**
  （04-06 曾输出半句话）。写完模块文档必须 `gleam docs build` 并查产物；
  两个包各自有 `package-interface.json`，都要查。

## 04-08 (2026-11-09) — monitor address, not interval fan-out
- 静态链早已支持 N 品种 × M 周期（`config.gleam` 里 6 个独立 Timeframe）。
  真正缺的是**一根 bar 到达时没有地址**，以及 gate 路径用 `Error(String)`。
- `monitor.gleam`：`TimeframeAddress(BrokerId, Symbol, Interval)`（interval 在
  **地址**里，永不是 `Timeframe` 字段 — R23）、`IncomingBar(address, bar)`、
  `MonitorError`（带地址 + 类型化下层原因）、纯函数
  `advance(desk, incoming) -> Result(Desk, MonitorError)`。
- **一根 bar 只推进一个 Timeframe，不向该品种所有周期扇出**：kline 流是按
  interval 请求的。N×M 监控 = N×M 个带地址的 step；Stage F 的 actor 调它。
  把一根 bar 扇出到所有周期是个诱人但错误的设计。
- `SourceBarRejection` 闭集取代 validate/gate 的 `Error(String)`；
  `fetch_klines` 收 `Symbol` 而非 `String`。不发明 provider↔broker 关系（R26）。
- 64 tests green。**真实并发 / 订阅 / replay CLI 仍是 Stage F，未启动**；
  这次只补类型结构，不是运行时。不是新 owner 裁定。
  ⚠️ 这句「Stage F = 受监督 actor」的框架已被 owner 2026-11-09 06:01 质疑，待
  04-09 重写；且「gleam_otp 没引入」是错的（根 gleam.toml 早有直接依赖）。

## 并发认知（2026-11-09，本日只记录，明天做）
- Owner：Gleam 天然多线程，并行任务「非常简单啊非常自然」，不需要 actor 那些
  复杂补救措施，因为值是严格 value、不共享内存。**06:09 纠正：*"你去看什么
  javascript target完全不对路，我们是erlang 和 BEAM专属项目"*** —— 谈并发只在
  Erlang / BEAM 语境，别拿 JS target / promise 当旁证或类比。
- 官方证据：`gleam.run` 首页 "multi-core actor based concurrency system …
  millions of concurrent green threads" + 三行 `new_subject` / `spawn` /
  `receive`；v0.12 发布文「no need for an `async/await` syntax or callbacks」
  「no special types such as futures or promises」「don't have mutable state so
  locks and shared mutable state is not an option」「compiler can full type
  check channels」。actor = 长生命周期状态 + 自动处理 OTP 系统消息的**薄封装**；
  supervisor = 容错，不是并行机制。一次性并行任务只需 `process.spawn` +
  类型化 `Subject`。
- 本机实测：Wisp `wisp.gleam` 0 处 `process.`；glisten 每连接一进程 + 监督池
  (`:274/397/435/446`)；Lustre 服务端 runtime 恰一个 actor
  (`runtime/server/runtime.gleam:81-122`)。
- **`gleam_otp` 早就是根 `gleam.toml` 的直接依赖**；我上一轮说「没引入」是错的，
  `docs/DESIGN.md` 04-08 段末 "no … gleam_otp dependency" 同错。缺的是使用它。
- owner 06:07：今天浅尝即止，明天免费 token 到手继续，今天只记录。接手点：
  `.planning/phases/04-domain-cleanup/04-09-PLAN.md`（含明天 5 步）。本日 0 代码
  改动、0 probe、0 依赖、0 R31。
