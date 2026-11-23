# 03-01 — the Desk-side publish path (SUMMARY)

Date: 2026-11-23. **This is the final record of 03-01: the mechanism, the
evidence, the RED→GREEN test names, the files changed and the gate counts.**
The earlier "carrier gap / owner decision" narrative in this file was my
invention and is RETRACTED — the queue is back to 0 items
(`docs/PENDING_DECISIONS.md`, `docs/STATE.md`).

## The mechanism, in one paragraph

A bar arrives as a **typed `CustomWidget` event** carrying a **pure-data**
`SourceBarArrived`; `message.from_event` maps OUR kind to `MsgSourceBarArrived`
and leaves every other event as `MsgEye`. `runtime.step` then reads down the
one Desk chain — `desk.get_broker` → `broker.get_instrument` →
`instrument.get_timeframe`, each level calling **its own** read/write pair
(R50) — runs `timeframe.sourcebar_gate` and, **only if the gate accepted**,
`timeframe.databar_processing` (whose last step is
`working_databar_archived`). The just-archived bar is read from the
`databar_list` head and becomes one `ChartPushRequest`; the new Desk is written
back up the chain, each level replacing **only its own key**. `runtime.update`
turns that request into a `Command` that sends it on the publish Subject; the
publisher process (the only holder of the plushie `Instance`) turns it into a
**targeted** `CustomWidget` event, which the chart widget's own `handle_event`
consumes, writing the bar into that widget's chart state.

## The two decisions that were open, and how they were settled

### 1. The carrier — R58: captured at WIRING time, never carried per bar

`03-00-ARCH-FINDINGS.md` open_question #1 asked: *"从 `update` 返回的命令如何携带
`Instance` 与归档 bar：专用发布进程 + 具名 `Subject`，还是在接线处闭包捕获？两案都需
编译探针，不靠 prose 选择。"* — settled from source + probe:

- `plushie.start(app, opts)` creates the `Instance` **after** the App is built
  (`plushie/plushie.gleam:191-279`: `Instance(supervisor:…, runtime: …)` is
  constructed only after `supervisor.start`), so **the Instance cannot be
  captured at wiring time**.
- A `Subject` created **before** the App **can** — so the Subject is the
  late-binding cell, and the `Instance` stays in the publisher process.
- The frozen glib design is the same shape: `ingest.feed(timeframe, bar,
  publish)` takes the publish **closure** as a parameter, baked by the owner at
  the composition root (`glib/src/glib/trading/ingest.gleam:57-71`; owner
  verbatim 2026-10-25: *"无论在model还是view model都不应该需要View呀"*).

**Consequence**: `wire.SourceBarArrived` carries **data only**
(`broker_id` / `symbol` / `interval` / `sourcebar`) — no `Subject` field. A
per-arrival capability would be a wrong-but-well-formed value (core §2.2): it
could name a dead channel and the type would not object. `runtime.app(publisher)`
and `runtime.update(desk, msg, publisher)` take the publisher as a **parameter**,
the same shape as `settings` in `databar_processing` (R40-A).

### 2. The `Dynamic` boundary — R58: BEAM-native identity, no codec

`03-01-PLAN.md` as written used `dynamic.from(payload)` and
`dynamic.unsafe_coerce(data)`. **Neither exists in gleam_stdlib 1.0.5**
(measured: the whole `gleam/dynamic` module is `classify`/`bool`/`string`/
`float`/`int`/`bit_array`/`list`/`array`/`properties`/`nil`). On the BEAM a
`Dynamic` IS the term — the stdlib's own private `cast` is
`@external(erlang, "gleam_stdlib", "identity")` (`gleam/dynamic.gleam:97-99`).
So `app/wire.gleam` casts with the same shape, and the probe round-tripped a
record holding an opaque `BrokerId`, an opaque `Symbol` and a closed-set
`Interval` with **every field equal**. The reader is **monomorphic** per payload
type (an unbound return type variable cannot be used for record access — the
compiler says *"I don't know what type this is"*). Zero hand-written codec, zero
string parsing; the kind is matched before the read, so there is no second
answer to disagree (R47).

## The trigger — the owner's ruling, enforced by construction

Owner, 2026-11-23: *"view的update 跟且仅跟 working_databar_archived() 有关"*.

`runtime.publish_request` produces a request **exactly when the pipeline ran to
the archive**, because **the gate's acceptance IS the archive's occurrence** — a
rejected bar never becomes a working databar, so it never archives. No head
comparison, no dedup (glib `SYSTEM_MODEL.md:1364` "one writer, one door, no
dedup"). The publish point is therefore a property of the pipeline, not a
heuristic bolted on afterwards.

## The model shape — R59

Owner, 2026-11-23, gave the shape: *(only one) Desk → (≥2) Broker → (≥1)
Account + (≥2) Instrument → (any compound of intervals) Timeframe*, each level
*"updated to their own paces"*, and *"the View layer will update with the
model"*. Measured against glibe's types: every field matches, **except** that
owner said `yin|yang leaf_list` where glibe has `yin_leaf_settled` /
`yang_leaf_settled` (a field PAIR). glib removed the four leaf lists on
2026-10-03 for want of a reader (`glib/docs/NAMING.md:451`) and replaced them
with that field pair on **2026-10-28** (owner verbatim,
`glib/docs/reference/timeframe-settled-leaf-2026-10-28.md:115`: *"A field
pair, not two lists"*). glibe's fields are that ruling's landing, so the
implementation follows 2026-10-28 and the difference is registered in R59 §2 for
the owner.

"Each level updates at its own pace" lands as the write-back rule: one arriving
bar replaces the Timeframe it belongs to, the Instrument holding it, the Broker
holding that and the Desk holding that — **and nothing else moves**, because
each `put_*` replaces only its own key.

## RED → GREEN

| Test file | Tests | What it pins |
|---|---|---|
| `test/wire_test.gleam` | 6 | the payload round-trips through its CustomWidget with every field equal; the two kinds do not cross; the stable ID is a function of the identity; an unknown kind decodes as neither |
| `test/publish_test.gleam` | 6 | our kind becomes `MsgSourceBarArrived`, an eye event stays `MsgEye`, an unknown CustomWidget stays `MsgEye`; `publish.request` delivers exactly one request; `publish.serve` forwards every request unchanged and keeps serving |
| `test/runtime_publish_test.gleam` | 6 | an eye / voice Msg publishes nothing; a missing key publishes nothing; a **gate-rejected** bar publishes nothing; an archived bar publishes exactly one request whose bar is the archived head; the new Desk holds the archived bar and `working_databar` is back to `None` |

RED was observed before every body was filled (the wire bodies crashed on
`todo src/glibe/app/wire.gleam:95/107/119/125`; the publish bodies on
`todo src/glibe/app/publish.gleam:44`; the message body on
`todo src/glibe/app/message.gleam:89`).

## One measured surprise worth keeping

**The publish Subject must be NAMED.** A `process.new_subject()` is OWNED by the
process that created it, and `process.receive` PANICS on a non-named subject
owned by another process (`gleam_erlang/process.gleam:226-238`) — while
`process.send` to a named subject resolves `whereis(Name)` and fails with
*"Sending to unregistered name"* when nothing is registered. So: the publisher
runs in its own process, the channel is a **named** subject, and main registers
the publisher's pid under that name **before any bar can arrive** — no race.
try_plushie says the same thing about its own named mailbox
(`try_plushie/src/window_switch.gleam:44-48`: *"必须在 main 里建一次、传给三个 App
和 serve——名字是全局唯一的 Erlang atom，不能在各进程里重复 new_name"*).

## Files changed

- `src/glibe/app/wire.gleam` — the two wire kinds, the pure-data payloads, the
  stable IDs, the four event builders/decoders, the BEAM-native cast.
- `src/glibe/app/message.gleam` — `from_event` is the closed-set gate.
- `src/glibe/app/publish.gleam` — the effect carrier and the receive loop.
- `src/glibe/app/runtime.gleam` — `app(publisher)`, `step`, `route`,
  `publish_request`, `update(desk, msg, publisher)`.
- `test/wire_test.gleam`, `test/publish_test.gleam`, `test/runtime_publish_test.gleam`
  — new.
- `test/app_shape_test.gleam` — the pinned shapes moved with the design (the
  publisher is now a parameter); **the pin's intent is unchanged** — the model
  is still the one `Desk`, never a `#(Desk, Charts)`.
- `docs/RULINGS.md` R58 (carrier + `Dynamic`), R59 (the model shape), R60 (view
  is view; try_plushie's correct parts; no Python), R61 (text-editing
  discipline: `ed`/`awk`, never line-number blind deletes).

## Gates

`gleam format --check` 0 · `gleam check` 0 · `gleam test` **121 passed, no
failures** · `gleam docs build` 0 · `gleam export package-interface` 0 ·
`gleam build --warnings-as-errors` 1 — **6 Todo + 13 unused**, down from
21 Todo + 57 unused. Every remaining `todo` is in `app/dashboard.gleam`, which
is 03-02's scope; every remaining unused warning is a dashboard skeleton
argument.
