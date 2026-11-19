# Brief: glibe

**One-liner**: glibe is the pure-BEAM successor to the frozen `glib` — one `Desk` value carried by one pure `Desk → Desk` stream, with a Dashboard view driven by `working_databar_archived`.

**Re-baselined 2026-11-20.** The previous tree is at `.planning-archived-2026-11-20/` (45 files, moved with `git mv` — history intact). It described an abandoned Elixir/Finch + JS-web architecture. This tree describes the current design only.

## Design authority (where the owner's words live)

The owner's design statements are recorded in **glib's frozen `.planning/` files** (R42: glib is frozen, safe to cite). Full-path citations, taken 2026-11-20:

| Law | Owner's literal words | Source |
|---|---|---|
| View is part of the stream system, not a separate app | *"the web view app should be a part of the system using MVC or MVVM, don't do stupid things outside the streaming system"* | `~/gits/hub/tools_ib/glib/.planning/phases/39-web-front-mvvm/39-00-FINDINGS.md:7-9` |
| View follows the model's single publish point | *"model变(working_databar_archived())view跟着变而已"* | `…/39-web-front-mvvm/39-03-PLAN.md:25` |
| Working bar is the kernel of processing | *"the working_databar is the kernel of the databar_processing"*; *"you will never need the working_databar outside without a function call inside databar_processing"* | `…/47-present-carried/47-01-PLAN.md:13,15-16` |
| History vs present | *"the list is the history, and the working_databar, and growing_things are the present"* | `…/47-present-carried/47-01-PLAN.md:18-19` |
| Completion decided by timestamp, not by data fullness | *"我说只能根据时间戳来判断当前bar是否结束，你一个hour bar怎么可能在每一分钟都完成一次？？"* | `…/48-live-poll/48-01-PLAN.md:25` |
| Frequent fetch, limited acceptance | *"从服务器取得数据的频率要比我们采信数据的频率频繁 … 频繁读取，有限采信"* | `…/48-live-poll/48-01-PLAN.md:194-195` |
| No batch ⇒ speed is not a concern | *"if you code is not using batch computing, everything is in the main stream, then you should not worry about the speed"* | `…/AI_STRATEGY_PLAN-2026-10-03.md:269-270` |
| Identity lives in the holder's Dict key; child never knows parent | *"instrument with a dictionary of timeframes using interval as key"*; *"why should timeframe know instrument? Can it be more stupid?"* | `…/HANDOFF-2026-11-03.md:226,799` |
| Each provider keeps its own native shape and its own converter | *"外来的sourcebar如果不按照同样的interval变体定义方式定义，请问你理由是什么？… 他如何把自己标准化为sourcebar？"* | `…/HANDOFF-2026-11-03.md:92-94` |
| erlang target, no hand-written `.mjs` | *"target erlang 无需手写任何erlang代码，无需ffi，ffi是JS专属的"* | `…/HANDOFF-2026-11-03.md:209-210` |
| Plans are made with the planning skill; study its structure | *"那些已有的plan是系统化的…是运用planning skill制作的，你应该去研究它的结构要求"* | `…/PLAN_FORMAT.md:25-26` |

Items without a literal owner quote are labelled as AI synthesis, never promoted to owner words. Notably Welford / add-subtract-leaving / amortised KDJ appear in `.planning/` as implementation narration, not as owner quotations (source: `docs/STATE.md` 2026-11-20 II, `06-06-STREAM-INDICATORS.md` archived).

Current rulings and measured state: `docs/RULINGS.md`, `docs/STATE.md`. Open work register: `docs/PENDING_DECISIONS.md` (decision queue 0).

## Current state (measured 2026-11-20)

- `target = "erlang"`. Dependencies: `plushie_gleam` 0.6.0; `bar_stream_chart` 1.2.1 via local path `../bar_stream_chart` (owner will re-publish, then `gleam add`). No JS target, no `webclient/`, no hand-written `.erl`/`.mjs`.
- Domain core: `Desk ▸ Broker ▸ Instrument ▸ Timeframe` typed ownership (R20/R37); identity in holder's Dict key; one pure `Desk → Desk` stream, no actor/scheduler/clock/poll (R33).
- `config.gleam` landed: `Settings`/`IndicatorSettings`/`StructureSettings`/`IntervalSettings` + `default_settings`/`for_interval`/`validate`; parameters passed to indicators, never stuffed into `Timeframe` (R46 correction).
- `DataBar` carries the eight chart measurement fields; `dashboard.data_bar_to_chart_bar` maps them; `bar_stream_chart.push` is the proven single-bar update mechanism.
- App MVU skeleton: `app/message` (`from_event` filled), `app/runtime` (init filled; `update` todo), `app/dashboard` (`push_one` filled; view/widget bodies todo).
- Gates at last measurement: format/check/test(64)/docs/export = 0; `--warnings-as-errors` = 1 with 19 `todo` + 40 unused-skeleton-argument warnings (fixed skeleton baseline, R48).

## Success criteria

- [ ] Every active code module's `////` names a plan file that exists in this tree (no dangling plan references after the archive).
- [ ] `timeframe` four steps (`indicator`/`leaves`/`branches`/`strategy`) filled with O(1) stream bodies — no O(n²) batch variance.
- [ ] App view publishes only on `working_databar_archived`; bars drawn from `databar_list` head; no second model, no shadow.
- [ ] All gates green: `gleam format --check`, `gleam check`, `gleam test`, `gleam docs build`, `gleam build --warnings-as-errors` (warnings zero once skeleton bodies are filled).

## Constraints

- Every code file: `////` naming its plan item + `///` on every item → empty skeleton → tests RED → fill bodies GREEN (R19). Loading `gl-center` skill + `references/gleam-core.md` in full precedes any Gleam judgement.
- WAE is a fixed gate from the first skeleton (R48): no class exemptions, no bulk `_`.
- One module = one ownership relation (R50). Add fields by ownership (R32). New/create/make = bug (R49).
- Plans follow the `create-plans` skill format: YAML frontmatter + 7 XML blocks; per-task `<verify>` and `<done>`.
- One topic, one home: design concepts live in `docs/`, not in plan prose; plans reference docs and the glib frozen sources.

## Out of scope

- JS target, web front, `webclient/`, hand-written `.erl`/`.mjs`.
- Actor / scheduler / clock / poll / rewind / buffer / replay — the system is already live (R33/R38).
- Rewriting glib's `.planning/` — frozen design source, read-only.
