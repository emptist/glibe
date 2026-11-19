# MEMORY — glibe (INDEX only; verbatim in `docs/RULINGS.md`, dated detail in `.workbuddy/memory/YYYY-MM-DD.md`)

## Authority
Owner's current words > spec > legacy code > my inference. User=emptist; I=space-bunny. `glib/docs/`=hy4's prose (banned from glib; never adopt its "gate"/"ladder" voice); glib docs ≠ glib code (R38). Owner's words: `sourcebar_gate`, price checker, risk manager. Every assertion: cite a source line / owner quote / label it 推断.

## Direction
- BEAM-native is a property, not a portability cost ("我就是打算靠BEAM吃饭"). Gleam/Erlang/Elixir = doors to one BEAM. `target = "erlang"`; no JS target; web front OUT; `webclient/` deleted; no hand-written `.erl`/`.mjs`. `@external(erlang, …)` is normal Gleam design, not FFI; zero-external is a skeleton fact, NOT a goal.
- Root law: use a type whenever a type is needed in nature — no universal String + parser + panic + guard sh. 「简单是正确的验证码」: complexity = wrong definitions; fix them, add no mechanism.
- Gleam language knowledge lives in `~/gits/gleam-language`, NOT WorkBuddy global memory; hard-`ln` single files only (verify `stat -f '%i %l'`), never symlink / dir link. core mirror `docs/gleam-thinking-core-to-memory.md` byte-equal (`cmp` 0).
- Visual layer closed: `bar_stream_chart` (own Gleam chart pkg, 1.2.0) + plushie renderer (0.6.0), both erlang target; web not needed (RULINGS 11-19 00:03/00:07/00:10). Voice half: seek existing BEAM/hex lib, don't rebuild; capability proven by glib docs + speak_engl; lab `voice.gleam` is a stub.
- App: gdltdd. View layer = **Dashboard** (= projection of `Desk`), never named Desk; `try_plushie` only proves plushie works — its types/flow were copied+invented, do NOT copy. glib = implementation reference where it doesn't violate owner design; owner design is authoritative.

## Process (R19, mandatory)
Load `gleam-language` skill + `references/gleam-core.md` IN FULL before any Gleam judgement. Per module: ① `////` naming the `.planning` item + `///` on every item → ② empty skeleton → ③ unit tests → ④ fill bodies to green. **Skeleton todo granularity is a spectrum (owner 11-19 08:40/08:46/08:51): leaf `todo as "…"` under case/use arms is CAN, not MUST. Two can-criteria: (a) arms DIFFER and each pins a concrete design choice (9-interval `case` in `instrument.gleam`); (b) imports become structure consumed by the frame with no working code, and WAE becomes a finer per-line Todo list (probe-confirmed: no unused-import warning). Identical arms (`from_event`'s 12 → `MsgEye`) stay one todo.** WAE (`gleam build --warnings-as-errors`) is a FIXED gate from the first skeleton (R48): no class exemptions, no bulk `_`; output is a per-line Todo list. `gleam docs build` → `package-interface.json` = anti-drift. `docs/` = 差生补课笔记; never store concepts in prose docs; never write a ruling into `////`/`///` until code matches. R47: every doc says who reads/writes which concrete value. R50: one file = ONE ownership relation.

## Rulings index (full text: `docs/RULINGS.md`)
R12 floor · R13 closed sets=types · R14 src Gleam only · R15 IB=stocks/ETFs · R16–18 JS scope · R19 process · R20 Desk▸Broker▸Instrument▸Timeframe, dashboard=VIEW · R21 full ctor names, wire codes only in codec · R22 Symbol=name · R23 interval in KEY · R24 Mist+Wisp=AI demo · R25 TPlus1/CPU terms · R26 Asset/Exchange/Market open · R27 timestamp=Timestamp · R28 provider shapes+to_sourcebar · R29 sourcebar_closed=UTC grid · R30 web clock=output projection · R31 BEAM facts≠system · R32 add field by ownership · R33 system IS LIVE: one pure `Desk→Desk` stream, no actor/scheduler/clock/poll · R34 seib=CoffeeScript · R35 SwiftUI only in View · R36 Market/Broker not subordinate · R37 two ownership relations · R38 no rewind · R39 SourceBar→working_databar→databar_list · R40/41 pipe=shape constraint, subject first+returned · R42 glibe=抄glib+owner修正 · R43 反复推敲=核验空架子 · R44 doc-tdd · R45 no deprecated vocab · R46 TimeframeSettings deleted · R47 docs name readers/writers · R48 WAE fixed gate · R49 new/create/make=bug · R50 one module=one Dict.

## Measured facts
Gleam 1.19.2 / OTP 29. `import mod.{type T, Ctor}`; no `T(..)`; qualified ctor patterns are a syntax error (import unqualified: `Widget(_)` not `Event.Widget(_)`). `@external` may coexist with a Gleam body; `.abstr`→`.beam`, no per-module `.erl`. opaque ctor cross-module = private error; mutual imports = cycle; `fn(of: T)` syntax error; fn names can't start `_`. Tests: `assert … as "msg"`, `let assert`; never panic/case Bool. OTP built-ins need no dep / hand-written erl.

## Conventions
- No bare `Qn` labels — cite full path + section title.
- Pending decisions ONLY in `docs/PENDING_DECISIONS.md` (decisions first, rest under `# REFERENCE`); no other doc references it; queue = 0. No choice cards; flat options, no preset recommendation.
- `.gitignore` before artifacts; one concern per commit; never `rm -rf build`. FF push just do it; `--force` / force-with-lease / any remote-history rewrite MUST ask.
- Toolchain: `export PATH="/opt/homebrew/bin:$PATH"`; capture real exit codes.

## State (2026-11-19 08:46, origin/doc-tdd, tree clean)
App gdltdd: 2 doc-first skeletons (`app/message.gleam`, `app/dashboard.gleam`) + `test/app_shape_test.gleam` 4 shape tests; bodies all todo; no body filled. Deps: plushie_gleam 0.6.0, bar_stream_chart 1.2.0. Gates at 08:35: format/check/test(50)/docs/export all 0; WAE 1 = 20 todo + 41 unused arg (skeleton). Next: RED→GREEN fill bodies. Full dated detail in `docs/RULINGS.md` + daily logs.
