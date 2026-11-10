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
`tzif` not yet a dependency. R31 BEAM 并发 = `process.spawn` + 类型化
`Subject`，不是待建的受监督 actor 机制（其「0/6 合并」段已作废）。**R32 结构是
花园**：加一个新事物 = 已有 Type 定义里的一个 field；位置靠倒推「现实中隶属于
谁」，谁也不隶属就放 `Desk`（`exchanges` 例）；集合用 Dict/List/其他按真实访问
方式对比研究决定；R26 仍成立。**一个 `Desk`，每个 `Timeframe` 叶子都活着**，
处理数据、进行交易；没有 N 份 Desk 要合并。

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
- **`gleam_erlang/process.spawn` + typed `Subject` is the whole parallel-task
  primitive** (official: no async/await, no futures, no locks). actor = thin
  long-lived-state wrapper; supervisor = fault tolerance, not parallelism.
  Wisp has 0 `process.` calls; glisten spawns one process per connection;
  Lustre's server runtime is exactly one actor.
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
- 04-05 Mist+Wisp web layer on 8610 (`/`, `/desk`, 404). 04-06 unix-time ingest
  boundary. 04-07 R30 module docs only (no implementation).
- 04-08 `src/glibe/monitor.gleam`: `TimeframeAddress(BrokerId, Symbol,
  Interval)` (interval in the ADDRESS, not a `Timeframe` field — R23),
  `IncomingBar(address, bar)`, `MonitorError` (address + typed lower reason),
  pure `advance(desk, incoming) -> Result(Desk, MonitorError)`. **One bar advances
  exactly ONE `Timeframe`** — no fan-out to all intervals; N×M monitoring = N×M
  addressed steps. `SourceBarRejection` replaces `Error(String)`; `fetch_klines`
  takes `Symbol`. 64 tests green.
- 04-09 `probes/parallel-bars/`：6 个带地址 bar → 6 个 BEAM Pid / 0 lock，
  R19 RED→GREEN 4 passed；R31 记官方 BEAM 证据与 `gleam_otp` 事实更正。
  **但它把一份 `Desk` 复制进 6 个进程，形状错误；「0/6 合并 / 所有权」是
  伪问题 → R32 作废**。probe 留作带作废注记的历史实验，不作设计实证。
- 04-10 R32 落地：撤回 R31 该段、DESIGN 04-09 节、README / STATE /
  ROADMAP / PENDING / 04-09 历史文档里的错误框架；官方 BEAM 证据保留。
  **glib 核实**：同一四类型链已在 `glib/src/glib/desk.gleam:11-13`、
  `broker.gleam:29-34`、`domain/instrument.gleam:76-82` 落地（55-02 done），
  但 glib 是 JS target、runtime single-stream，「每个 Timeframe 活着」未做到。
  本轮**未加生产类型、未改 `src/` 逻辑、未写新 probe**；0 待裁决项。
