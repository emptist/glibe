# 03-03 — the composition root (SUMMARY)

Date: 2026-11-23. **Final record of 03-03: the wiring, the evidence, the
files changed and the gate counts.**

## The wiring, in the order it happens

```
1. publish_name()          — the channel's NAME, created ONCE
2. publish_channel(name)   — the named Subject for that name
3. runtime.app(channel)    — the App, which CAPTURES the channel (R58)
4. plushie.start(app, …)   — ONE App; only NOW does the Instance exist
5. process.spawn(publisher) — the publisher process, holding the Instance
6. process.register(pid, name) — the name now resolves to that publisher
```

Steps 1–3 happen **before** the app starts, because the `Instance` does not
exist yet (`plushie/plushie.gleam:191-279` builds it inside `start`, after the
App). Step 6 happens **before** any bar can arrive, because
`process.send` to a named subject resolves `whereis(Name)` and fails with
*"Sending to unregistered name"* otherwise. That ordering is the whole reason
there is no race.

## Why the channel is a NAME and not a subject

Measured: `process.new_subject()` is OWNED by the process that created it, and
`process.receive` **PANICS** on a non-named subject owned by another process
(`gleam_erlang/process.gleam:226-238`). The publisher must be a separate
process (it is the only holder of the `Instance`), so the channel must be named.
try_plushie says the same of its own mailbox
(`try_plushie/src/window_switch.gleam:44-48`: *"必须在 main 里建一次、传给三个 App
和 serve——名字是全局唯一的 Erlang atom，不能在各进程里重复 new_name（会耗尽 atom
表）"*).

## The one App (not one App per chart)

try_plushie's three `plushie.start` calls really are three Apps — three
supervisors, three runtimes, three renderers. That shape solved ITS problem
(two independent streams + a large Desk model); the official multi-window shape
is ONE `start` whose `view` returns several windows (`plushie/app.gleam:70-76`).
glibe: **one App**, many charts as stable-ID widgets in its one window.

**Measured on the tree:** `grep -rn 'plushie.start(' src/` → **one real call**
(`src/glibe.gleam:77`); every other hit is documentation.

## What is NOT here

No clock, no poll, no timer, no second `Desk`, no per-chart App, no global atom
table, no chart state in the model (`grep -n 'chart' src/glibe/{desk,broker,
instrument,timeframe}.gleam` → only a comment). The data arrives from the
providers by their own native means (R33), and the model is the one Desk.

## Files changed

- `src/glibe.gleam` — **new**: the composition root. `publish_name`,
  `publish_channel`, `start`.
- `src/glibe/app/runtime.gleam` — `app(publisher)` captures the channel.
- `docs/RULINGS.md` R58 (carrier + `Dynamic`), R59 (model shape), R60 (view is
  view; try_plushie's correct parts; no Python), R61 (text-editing discipline),
  R62 (newest-first; `list.drop`, not `list.last`).

## Gates

`gleam format --check` 0 · `gleam check` 0 · `gleam test` **126 passed, no
failures** · `gleam docs build` 0 · `gleam export package-interface` 0 ·
`gleam build --warnings-as-errors` **0** — **0 Todo, 0 unused** (from 21 Todo +
57 unused at the start of Phase 03).

## What Phase 03 did NOT do, and why

- **No provider wiring.** The bars' arrival path is the providers' own business
  (R33: *"接入方式保持各家原生"*); 03-03 wires the app side of that seam, and
  the injection helper is the one thing left to add when a provider lands.
- **No structure table.** C4 (*"结构不画、只列表"*) puts leaves and branches in
  the view's lower table — that is a later phase, and it needs the leaf-list
  question R59 §2 registers.
- **No zoom/pan handling.** `widget_handle_event` consumes cosmetic events
  locally and moves the viewport's inputs; the interactive groups the chart
  package emits are wired, but the pointer maths (which lives in the chart
  package's `zoom_at` / `pan_by_pixels`) is not yet driven by the events.
