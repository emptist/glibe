# 03-02 — dashboard widget/view bodies (SUMMARY — RETRACTED fake block; body is in-plan work)

> Correction (owner 2026-11-23): the "view blocked on same gap" finding below was
> built on my invented composite-widget/runtime-held-state design — RETRACTED. The
> design was already recorded (06-02 §G; `dashboard.gleam ////`): chart state lives
> in the model (MVU, proven by try_plushie `ChartModel`), one stable-ID chart per
> (broker,symbol,interval), glibe is one App (RULINGS.md:5408). `view(desk)` is
> in-plan work, not blocked. The measured rendering-chain facts below (SpecShape
> IR, shape→PropValue, canvas child Nodes) still stand. Retraction full text:
> `docs/PENDING_DECISIONS.md`, `docs/STATE.md`.

Date: 2026-11-23. Source audit of pinned plushie 0.6.0 + bar_stream_chart 1.2.1,
per owner's "疑点先读源码/自己的文档". No signature or body changed. Gate green
(86 passed). This records WHY the plan's bodies are not yet filled — so the
question is not re-raised as if new.

## What the source says (measured, not inferred)

Rendering chain in plushie 0.6.0 is REAL and usable:
- `SpecShape` has 6 variants (Rect/Path/Line/Text/Group/Interactive), `ChartShapes`
  6 layers — `bar_stream_chart/src/bar_stream_chart.gleam:99-172`.
- `shapes(chart, vp, mouse) -> ChartShapes` is public (`:807`).
- `plushie/canvas/shape.gleam` translates every SpecShape piece to `PropValue`:
  `rect/line/text/path/group/interactive_group/stroke` + `translate/scale`
  (`shape.gleam:123-398`); `ShapeOpt` carries Fill/Stroke/Opacity/Size/Transforms.
- `canvas.build` promotes shapes/layers into NODE CHILDREN
  (`plushie/widget/canvas.gleam:189-230`) — so the plan's phrase "SpecShape → Node"
  is really SpecShape → PropValue (via `shape`) → canvas layer props → child Nodes.
  The API exists; a `chart_node`/`widget_view` body is implementable.

## The block: `view(desk)` cannot enumerate the widgets (same root as 03-01 carrier)

- Plushie's widget state is HELD BY THE RUNTIME. `widget.build(def, id, props)`
  puts only the `WidgetDef` + props into the node's `meta` with `state: None`
  (`plushie/widget.gleam:206-215`); state is created/threaded by the runtime
  during normalize, and mutated only via `handle_event → EventAction.UpdateState`.
- So app-level `view(desk: Desk) -> List(Node)` must emit one widget placeholder per
  (broker, symbol, interval). To know WHICH triples exist it would have to walk
  `Desk → brokers → instruments → timeframes`. But `Desk` exposes only
  `get_broker` / `put_broker` (`src/glibe/desk.gleam:51-60`) — there is NO
  enumerate-all API, by design: R50 deleted `timeframe_under` and "no function
  here walks from Desk down to Timeframe" (`desk.gleam:25-29`). Each level calls
  its OWN keyed read/write pair; nothing lists the keys.
- Consequence: the set of dashboards to render has no source. glib's design never
  built this app-level view (it used a JS lightweight-charts series), so there is
  no frozen ruling to copy. This is the SAME architecture gap as 03-01's carrier:
  **the model has no downward-enumeration entry and widget state is isolated.**

## Decision needed (owner)
Registered in `docs/PENDING_DECISIONS.md` decision 1 (the 03-01 carrier item),
with this second facet appended: how does `view(Desk)` learn the widget set
without a R50-violating Desk-walk? Candidate directions are for owner to choose;
none assumed here. Per owner *"遇到不能决断的危险事件需要问我"* and create-plans
deviation rule 4, `view` stays `todo`.

## Independently implementable (NOT blocked — pending owner's go-ahead)
The following have real APIs, take `state`/`props` as parameters (no Desk-walk),
and can be filled by strict RED→GREEN without the decision:
- `chart_node` / `widget_view` — SpecShape→PropValue→canvas child Nodes.
- `widget_handle_event` (zoom/pan local `UpdateState`) / `widget_subscriptions`.
- `chart_widget_def` — wire init/view/handle_event/subscriptions/cache_key.
- `dashboard.push_one` + `data_bar_to_chart_bar` already filled & tested.
Owner's "按计划走" authorizes these; I held to report the `view` finding first
rather than leave a half-filled module without telling him. Await go-ahead or
the ruling that also unblocks `view`.

## Gate (real exit codes)
- `gleam format --check` → 0; `gleam check` → 0; `gleam test` → 0, **86 passed**.
