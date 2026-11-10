# MEMORY — glibe (curated; full text in `docs/RULINGS.md`, daily logs)

## Authority & identity
**Owner's current statement > Idris spec > legacy code > my inference.**
`glib/docs/` is hy4's AI prose, not owner's record; never inherit its first
person or vocabulary (generic "gate", "ladder"/"Rung"). hy4 is a different
model, banned from glib. Owner's words: `sourcebar_gate` (the only gate),
**price checker**, **risk manager**. I am space-bunny; user is emptist.

## Direction
- *"glibe is the future, pure erlang target is the future"*, *"BEAM is great"*,
  *"No handwritten erlangs or even worse JS source files"* → `src/` Gleam only.
  **Root law: use a type whenever a type is needed in nature** — no universal
  `String` + parser + sh/grep guard to repair it.
- **glibe does not wait on glib**: take owner rulings + glib's good code directly.
- Root erlang; `webclient/` the only JS-target package (R16–R18: generated `.mjs`
  preferred, small hand-written JS allowed only there, Phoenix → `deprecated/`).
  Web frontend is for human eyes (anomalies, trend charts, fractal tables,
  order/fill points).
- **Concurrency is Erlang/BEAM only** (owner 2026-11-09 06:09: *"你去看什么
  javascript target完全不对路，我们是erlang 和 BEAM专属项目"*). Never use the JS
  target or promises as a concurrency analogy.

## Before any Gleam judgement
Load `gleam-language` skill, read `~/.workbuddy/skills/gleam-language/references/gleam-core.md`
**IN FULL**; `docs/gleam-thinking-core-to-memory.md` is its byte-equal git mirror
(keep `cmp`-equal). Workflow (R19, binds EVERY AI-authored file in EVERY project):
`////` module doc **naming the `.planning` item** → types → `///` on every
type/function → `todo as "…"` → tests → bodies → green. `gleam docs build` →
`package-interface.json` is the anti-drift check, **no new sh guard**.
`--warnings-as-errors` is a GREEN gate only; RED skeletons legitimately fail it.
**A `////` block broken by a `//` line truncates the interface docs** — always
check both packages' `package-interface.json`.

## Rulings (one-line index; full text + verbatim quotes in `docs/RULINGS.md`)
R12 `1e-6·bb_m` floor before interpolation. R13 closed sets are types.
R14 `src/` Gleam only. R15 IB = historic stocks/ETFs; guard fails on
`@external(javascript,…)` / `target = "javascript"`. R16–R18 JS scope above.
R19 docs-first/TDD. R20 **`Desk ▸ Broker ▸ Instrument ▸ Timeframe`** must-have
(owner's "Deck" = spelling drift, not a rename); dashboard = VIEW.
R21 constructors **named in full, prefixed by the type name** (`IntervalOneDay`);
letter+digit wire codes (`H4`/`M1`/`"1h"`) only in codec/adapter. R25 a
professional term (CPU, T+1/T+2 → `TPlus1`/`TPlus2`) is NOT an abbreviation.
R22 **`Symbol` is a name, never the `Instrument`** — correct wrong things
cleanly, no alias/compat layer. R23 **`TimeframeSettings` is not an entity**:
it is `Timeframe.settings`; interval lives in the KEY, never a field; no composite
`"BTCUSDT_H1"` key, no second dict, no `list.find`. R24 web framework choice
(Mist+Wisp, 04-05) is **AI demo work, not an owner ruling**. R26 **only
`Broker ▸ Instrument` is settled**; `Asset`/`Exchange`/`Market` relations stay
open — add types one at a time when a consumer needs one, no speculative level.
R27 `SourceBar.timestamp` = `gleam_time.Timestamp` (unix time), never a date
`String`/wall clock (no "BarClock", no compat). R28 provider native types stay
native with their own names (`Kline` for Binance) and all wire fields; each has
`to_sourcebar`; the standard layer is the only union point. R29 `bucket_ends` =
UTC-aligned unix-second remainder grid (1h 3600, 4h 14400, 3m 180); US 09:30
open + DST is a market-calendar debt → `tzif` 2.0.0 when a US-equity consumer
exists, never a fixed offset (`~/gits/hub/ibOptions/tradingtime.py:24`,
`simple_auto_trading.py:132`). R30 web display time = **output-side** projection
of the same `Timestamp` to the analyst's local wall clock (IANA/DST), R29 is the
**input-side** market calendar — never merge them; CSV stays UTC RFC3339;
`tzif` not yet a dependency.
**R33（2026-11-10，范式纠正，覆盖 R31/R32 的并发框架）**：
- 系统**本来就活**：`api provider / data sources → history + live data →
  sourcebar_gate → databar_processing → model ↔ view`；history 与 live 同一条
  流。**每一个 type 都是活的：数据动它就动，因为定义好了**（纯值重算），
  不是进程 / actor / 调度 /「让叶子活起来的运行时」。
- 数据会动是因**订阅了数据源的实时数据**（推送 / 订阅 / 主动获取，各家
  自己的方式，属输入边界，汇合点只有标准 `SourceBar`）；**没有数据系统就
  不动了，睡觉等待** —— 静止正常，无需时钟 / 轮询 / 心跳补救。
- **`Desk` 是顶层唯一的 Value**，逐层嵌套即完整系统；*"在Gleam世界里面，
  你唯一要做的就是定义types，基本结构对了，什么都有了"*。定义 types 就是全部。
- `monitor.advance` / `TimeframeAddress` / `IncomingBar` / `MonitorError`
  **不是本系统 type**（*"哪有这些type"*），是从非 Gleam / 非 functional /
  非 type 架构带来的命令式调度；用 actor 的根源正是结构没设计对。代码保留
  为历史，处置由 owner 定，不得作为结构依据。
- **「叶子」特指 `YinLeaf` / `YangLeaf`**，绝不能指 Timeframe 或结构末端。
- **glib 不是权威**：可能只记录设计与计划、未必落实，已落实也未必对；
  唯一权威是 owner 当前陈述。glib 代码只读作背景，不作设计正确/已落实的证据。
  seib → glib → glibe 是思路沿革，不是正确性证明链。
- **R32 仍成立**：花园 = 在已有 Type 定义里加一个 field；位置靠倒推隶属，
  谁也不隶属放 `Desk`；集合 Dict/List 按真实访问对比研究；R26 不预设层级。
  R31 官网/v0.12 语言事实与 `gleam_otp` 事实更正仍成立，但不描述本系统。

## Measured facts
- Gleam 1.19.2 / OTP 29: `import mod.{type T, Ctor}`; **no `T(..)` form**;
  `@external` may coexist with a Gleam fallback body; v1.19.0 emits
  `.abstr → .beam` (no per-module `.erl`, only the `@@main.erl` runner stub).
- `float.parse("100")` is `Error(Nil)` — `parse_number` widens Int.
- `gleam build` does not resolve npm deps (green build ≠ runnable app);
  dotted `@external` names fail to compile. Mist 6.0.3 = `mist.start` (Wisp
  doc's `start_http` stale); `wisp/simulate.request(method, path)` builds a real
  Request; `wisp.Text(body)` is the response body; `gleam run -m <module>`
  needs no root `main`. Web demos (04-04): Mist+Wisp 72/22 Hex vs +Lustre
  124/23 vs bare Mist 82/14. *"Needs no JS library"* is a **dependency** claim.
- `gleam_otp` **is already a direct root dependency** (`gleam.toml`); saying
  "not introduced" was wrong — what was missing was its use.
- BEAM language facts (R33: **they do NOT describe this system's structure**):
  `gleam_erlang/process.spawn` + typed `Subject` = parallel-task primitive
  (no async/await, no futures, no locks); actor = thin long-lived-state
  wrapper; supervisor = fault tolerance. Wisp 0 `process.` calls; glisten
  one process per connection; Lustre server runtime exactly one actor.
- Tests: bool `assert … as "msg"`, `let assert` (never `panic`/`case Bool`);
  negative guard tests use `/tmp` fixtures, never broken real `src/`.

## Conventions
- **No bare `Qn` labels** — cite full path + section title.
- Pending decisions live **only** in `docs/PENDING_DECISIONS.md`: self-contained,
  **decisions FIRST**, everything else under `# REFERENCE`; never repeat decided
  items in the decision section. One-way: **no other document may reference it**
  (verify repo-wide after any edit). `docs/QUESTIONS.md` = withdrawn items.
- **Owner 2026-11-09: "注意：.gitignore 及时更新，及时做提交"** — update ignore
  rules BEFORE generating artifacts; commit each logical step as it lands, never
  one batch at the end. `.gitignore` has one `build/` rule (any package/depth).
- Toolchain: `export PATH="/opt/homebrew/bin:$PATH"`; BSD `grep` unreliable —
  use the Grep tool / Python; capture exit codes with `> log 2>&1; echo "EXIT=$?"`.
- Green = `gleam build --warnings-as-errors` (0/0) + `gleam test` + `gleam format
  --check src test` + `sh scripts/guards.sh --all` + `gleam docs build` +
  core mirror `cmp`. Build/test before committing; one logical concern per
  commit; **do not push unless asked**; never `rm -rf build`.
- Owner 2026-11-09: *"尽量发挥gleam的特长…一下手就把想明白的逻辑写明白"* — put
  understanding in types; leave the un-thought-out in `todo`, never in `String`.

## Phase 04 status
- **R33（2026-11-10，当前规格）**：系统本来就活，见上面 Rulings 段。
  04-08 的 `monitor.*` 与 04-09 的 `probes/parallel-bars/` **全部标为历史、
  非 owner 设计**（`////` / `///` 文档已更正；`src/` 生产代码未删，处置待
  owner 定）。「glib 核实：已落地」类断言降级为「读过 glib，不作依据」。
  本轮记裁定 + 撤回 + 清理词汇，**未新增 type / 未写 probe / 未加依赖**；
  0 待裁决项。64 tests（根）+ 4（probe）green。
- 04-05 Mist+Wisp web layer on 8610 (`/`, `/desk`, 404). 04-06 unix-time
  ingest boundary. 04-07 R30 module docs only (no implementation).
- 历史：04-08 曾造 `monitor.advance` / `TimeframeAddress` / `IncomingBar` /
  `MonitorError`（`SourceBarRejection` 取代 `Error(String)`、`fetch_klines`
  收 `Symbol` 仍有效）；04-09 曾做 6 Pid / 0 lock probe。两者的并发框架与
  「0/6 合并」结论经 R32 / R33 作废，仅留作带日期更正注记的历史记录。
