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

## Rulings R12–R40-A (full text: `docs/RULINGS.md`)
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
70 tests root + 4 `parallel-bars` + 11 `timeframe-pipeline` green; full gate
green (guards / docs / core mirror cmp); decisions 0; **not pushed**.
04-10 = **retrofit** (`timeframe_under`, 68/2 → 70/0). 04-11 `replay`
withdrawn (`17376a4`, R38 `5537127`, purge `9b3e6ed`). 04-12 = pipeline
shape probe + R40. Historical, not owner design: `monitor.gleam`,
`probes/parallel-bars/`; disposition awaits owner. Remaining real work:
connect each provider's **real-time arrival** to the standard `SourceBar`
input boundary (history batch = same stream, the pair run n times; no second
implementation, no CLI), and rebuild `engine.gleam`'s steps so the FIRST
arg and the return are `Timeframe` (extra params are fine, R40-A) and
R39/R40's straight line is the product code — a definition change, not a
language question.
