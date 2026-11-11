# MEMORY — glibe (curated; verbatim rulings in `docs/RULINGS.md`, daily logs)

## Authority & identity
**Owner's current statement > Idris spec > legacy code > my inference.**
`glib/docs/` is hy4's AI prose (hy4 = another model, banned from glib); never
inherit its first person or generic "gate"/"ladder" vocabulary. Owner's words:
`sourcebar_gate`, **price checker**, **risk manager**. I am space-bunny; user
is emptist. **glib docs are NOT evidence of glib code** — docs were owner-
taught, code was AI-written; always compare the two (R38).

## Direction
- *"glibe is the future, pure erlang target is the future"*, *"BEAM is great"*,
  *"No handwritten erlangs or even worse JS source files"* → `src/` Gleam only.
  **Root law: use a type whenever a type is needed in nature** — no universal
  `String` + parser + sh/grep guard to repair it.
- **glibe does not wait on glib**: take owner rulings + glib's good code directly.
- Root erlang; `webclient/` the only JS-target package (R16–R18, generated
  `.mjs` preferred). Web frontend is for human eyes.
- **Concurrency is Erlang/BEAM only** (owner 2026-11-09: *"我们是erlang 和
  BEAM专属项目"*). Never use JS target/promises as a concurrency analogy.

## Before any Gleam judgement
Load `gleam-language` skill, read `references/gleam-core.md` **IN FULL**;
`docs/gleam-thinking-core-to-memory.md` is its byte-equal mirror (keep
`cmp`-equal). **R19 making process** (one module file, whole process):
① `////` module doc naming the `.planning` item + `///` on every item →
② empty skeleton (types/functions only if needed, `todo as "…"` ok, no real
body) → ③ tests hold the design goal → ④ fill bodies step by step to green.
`gleam build`/`gleam test` work at skeleton stage; `--warnings-as-errors` is a
GREEN gate only. `gleam docs build` → `package-interface.json` is the
anti-drift check; **a `////` block broken by `//` truncates it**; check both
packages. **11:05**: retrofitting docs/tests onto existing code is NOT this
process; label it retrofit. **11:11**: `docs/` are "差生补课笔记", not assets —
never create prose docs to record concepts; doc count should fall.

## Rulings (index; verbatim in `docs/RULINGS.md`)
R12 `1e-6·bb_m` floor. R13 closed sets are types. R14 `src/` Gleam only.
R15 IB = historic stocks/ETFs; guard fails `@external(javascript,…)`.
R16–R18 JS scope above. R19 docs-first/TDD (full text above).
R20 **`Desk ▸ Broker ▸ Instrument ▸ Timeframe`**; dashboard = VIEW.
R21 constructors named in full, prefixed by type name (`IntervalOneDay`);
`H4`/`M1`/`"1h"` only in codec/adapter. R25 CPU/T+1 → `TPlus1` is a term,
not an abbreviation. R22 **`Symbol` is a name, never `Instrument`**; no compat
layer. R23 **`TimeframeSettings` is not an entity**: it is
`Timeframe.settings`; interval lives in the KEY; no composite keys, no second
dict, no `list.find`. R24 Mist+Wisp (04-05) = AI demo, not owner ruling.
R26 **only `Broker ▸ Instrument` settled**; Asset/Exchange/Market stay open,
add types one at a time. R27 `SourceBar.timestamp` = `gleam_time.Timestamp`
(unix), never a date String/wall clock. R28 provider native shapes stay
native (`Kline`) with all wire fields; each has `to_sourcebar`; standard layer
is the only union point. R29 `bucket_ends` = UTC-aligned unix-second grid
(1h 3600, 4h 14400, 3m 180); US 09:30 + DST is market-calendar debt →
`tzif` when a US-equity consumer exists. R30 web display time =
**output-side** projection to local wall clock (IANA/DST); R29 =
**input-side** calendar; never merge; CSV stays UTC RFC3339.
**R31** BEAM language facts (spawn/Subject, actor, supervisor) — do NOT
describe this system. **R32** garden = add one field in an existing type,
placed by real ownership; Dict/List by real access pattern.
**R33 (paradigm)**: system **is already live**: `api provider / data sources →
history + live data → sourcebar_gate → databar_processing → model ↔ view`.
History and live are ONE stream; every type moves because data moves (pure
value recompute) — no actor/scheduler/clock/poll/heartbeat. `Desk` is the ONE
top-level Value. Data moves because a source is subscribed; **no data →
system sleeps and waits**. `monitor.advance`/`TimeframeAddress`/`IncomingBar`/
`MonitorError` are NOT this system's types (historical code only). 「叶子」
means `YinLeaf`/`YangLeaf` only. **glib is not authority**.
**R34**: predecessors are **completely different things**; only shared fact =
one broker each. **seib = CoffeeScript, owner's own system design**, structure
RIGHT, no Python/pandas limits, no "types unclear" problem, no settings defect
— only missing the multiple-brokers/providers layer (already here:
`Desk(brokers: Dict(BrokerId, Broker))` + 3 brokers; no provider layer).
**ibOptions = a workaround for Python+pandas**, 五脏俱全但都不对劲: structural
relations could not be types → flattened into settings; requirements list
only. R29's ibOptions citation is a time-zone fact clue only.
**R35 SwiftUI**: similarity ONLY in View definition/implementation (pure
functional + value types); view updates = R33. Concurrency questions: check
official docs + demo comparison = TDD. **「简单是正确的验证码」** — complexity
means type/function/module definitions are wrong; fix definitions, add no
mechanism. **R36 no gap**: `Market` and `Broker` are not subordinate in
either direction → rejected; `Desk ▸ Broker` stands. **R37 level test**: a
main-chain level needs TWO ownership relations (up and down); others attach
but are not subordinate (no inserted level), or belong to nothing → `Desk`.
**Identity lives in the holder's Dict key**: `interval` is not a `Timeframe`
field, `brokerId` is not a `Broker` field — *"你的左手不知道他是左还是右"*.
**R38 (2026-11-12)**: **the stream has no rewind** (*"长江万里哪有倒退重来
的道理"*). No `replay`, no 重来一遍, no "replay CLI": history and live are
earlier/later segments of ONE stream. Names must name real things. When
referencing glib, **compare its docs against its code**; take only
implementations fitting current rulings. Measured: `glib/docs/DESIGN.md:61`
still cites `trading/replay.gleam` ("name struck by law 18"), `:1874` says
`replay.feed`, but the **code is `trading/ingest.gleam`'s `feed`/`feed_all`**.
§15 `:1493-1529` = only two top-level data-treating functions
`sourcebar_gate`/`databar_processing`; `:66` "Batch is that pair run n times
— not a second implementation". `ingest.feed(tf, bar)` = one bar at a time;
`live.feed_raw` calls the same `feed`. **Do not port**: publish callbacks,
`clock.now()`/`period_end`, `sourcebar_buffer`/export, interval→settings
lookup, `market.exchange`, `io.println`/at-home asserts. glibe already has
both functions; one arriving bar = call them in order (R35), so **no third
function/module**. Open (owner decides): glib `working_databar_archived`/
`bars_listed` vs glibe `accept`/`bars_accepted`; glibe `Timeframe` still has
`manual_enter`/`manual_exit`, which owner struck 2026-10-31
(`glib/src/glib/timeframe.gleam:720-731`).
**R39 (2026-11-12, the whole system)**: ① data arrives → ② a qualified
`SourceBar` becomes `working_databar` → ③ **all** computation/processing/
decisions happen **in that working databar** → ④ `working_databar_archived`
→ `databar_list`. One straight line, **no side doors**; this simplicity is
what makes invention impossible. Test: any step passing the bar as an
argument between functions has drifted. glib code that matches:
`sourcebar.to_databar` (one bar born whole; phase 42 deleted the `fold`
half), `databar_processing` puts it in `working_databar` and every later step
takes only `Timeframe`, `working_databar_archived(tf)` takes no bar.
glibe drift (measured, NOT changed — owner decides): `working_databar` is a
bucket accumulator (`databar.fold_sourcebar` folds many bars into one);
`engine.databar_processing(tf, databar)` passes the bar through
`leaves`/`strategy`/`accept`; names `accept`/`bars_accepted` vs
`working_databar_archived`/`bars_listed`; `manual_enter`/`manual_exit` still
present. **Do NOT write R39 into `////`/`///` until the code matches** —
that would recreate docs unrelated to implementation.

## Measured facts
- Gleam 1.19.2 / OTP 29: `import mod.{type T, Ctor}`; no `T(..)` form;
  `@external` may coexist with a Gleam body; `.abstr → .beam`, no per-module
  `.erl`. `float.parse("100")` = `Error(Nil)` — `parse_number` widens Int.
- `gleam build` ≠ runnable app (npm deps unresolved); dotted `@external`
  names fail. Mist 6.0.3 = `mist.start` (Wisp docs' `start_http` stale);
  `wisp/simulate.request`; `wisp.Text`; `gleam run -m <mod>` needs no root
  `main`. `gleam_otp` **is already a root dependency**.
- `package-interface.json`: `modules` is a **dict**; `documentation` is a
  **list of lines** — join with `"\n"` before searching.
- Tests: bool `assert … as "msg"`, `let assert`, never `panic`/`case Bool`;
  negative guard tests use `/tmp` fixtures.

## Conventions
- **No bare `Qn` labels** — cite full path + section title.
- Pending decisions **only** in `docs/PENDING_DECISIONS.md`: decisions FIRST,
  rest under `# REFERENCE`; **no other document may reference it**; verify
  repo-wide after edits. `docs/QUESTIONS.md` = withdrawn.
- **Owner 2026-11-09: ".gitignore 及时更新，及时做提交"** — update ignore
  rules BEFORE artifacts; commit each logical step as it lands.
- Toolchain: `export PATH="/opt/homebrew/bin:$PATH"`; BSD grep unreliable —
  use Grep tool/Python; capture exit codes `> log 2>&1; echo "EXIT=$?"`.
- Green = `gleam build --warnings-as-errors` + `gleam test` + `gleam format
  --check src test` + `sh scripts/guards.sh --all` + `gleam docs build` +
  core mirror `cmp`; one logical concern per commit; **do not push unless
  asked**; never `rm -rf build`.

## Current state (2026-11-12)
- **70 tests** root + 4 probe green; full gate green; decisions 0; clean tree;
  **not pushed**.
- 04-10 = **retrofit** (docs/tests added after code, per 11:05): `////`/`///`
  in six modules, 6 tests RED 68/2 → `desk.timeframe_under` GREEN 70/0; no
  new type/field/relation/dependency.
- **04-11 withdrawn (R38)**: `replay.gleam`/`replay_test.gleam`/`04-11-PLAN.md`
  deleted (`17376a4`); R38 in `5537127`; vocabulary purge in `9b3e6ed`.
- Historical, not owner design: `monitor.gleam` (04-08),
  `probes/parallel-bars/` (04-09). Disposition awaits owner.
- Remaining real work: connect each provider's **real-time arrival** to the
  standard `SourceBar` input boundary (a history batch is the same stream,
  the pair run n times; no second implementation, no CLI).
