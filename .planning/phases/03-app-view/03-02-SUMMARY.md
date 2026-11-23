# 03-02 — the Dashboard view layer (SUMMARY)

Date: 2026-11-23. **Final record of 03-02: the mechanism, the evidence, the
RED→GREEN test names, the files changed and the gate counts.** The earlier
"view blocked on the same gap" narrative was built on my invented
composite-widget / runtime-held-state design and is RETRACTED (`docs/RULINGS.md`
R60 §1).

## The mechanism

The Dashboard is the **projection of the one `Desk`** (R20). It holds no model
list and computes no aggregate: the bars live in the chart package's own state
(which holds generated shapes and O(1) carried bounds, never the caller's bar
list), and the count comes from that state's carried number.

```
Desk ▸ Broker ▸ Instrument ▸ Timeframe
  └─ one chart widget per (broker, symbol, interval), stable node id
       └─ plushie's widget registry holds its state across renders
            └─ the archived bar arrives as a targeted CustomWidget event
                 └─ the widget's own handle_event pushes it into ITS chart
```

## The one design point that decided everything: translate at PUSH time

Owner, 2026-11-23 (R60 §2): *"view就是单纯的view，不要把任何model中的list拿过去，
更不要再view里面反复遍历计算，概算的东西都在model里面了。"*

Measured, the difference is not stylistic:

| | what the view does | cost |
|---|---|---|
| `bar_stream_chart.push` (the old `push_one`) | discards the generated shapes, so the view must call `shapes/3` — which **re-wraps the whole accumulated list** (`src/bar_stream_chart.gleam:807`) | **O(n) per frame** |
| `bar_stream_chart.push_generating` (**what is used now**) | the package returns THIS bar's shapes; we translate **only those** and prepend them to the layer | **O(1) per frame** |

The package says this is the intended split — `src/bar_stream_chart.gleam:181-185`:
*"A framework adapter keeps the already-translated shapes for each data layer in
its Model, wraps them in one affine group per layer using these values, and
never re-translates the accumulated list on every frame. This is the package
side of the Elm `lazy` boundary."*

try_plushie does exactly this and is the blueprint (R60 §1): `fusion_view.gleam:139-157`
(*"No accumulated list is traversed"*) and `:159-172` (*"O(1) assembly of the six
canvas layers … No `list.map` over accumulated shapes happens here — that work
moved to `push`"*). Its `Chart` type holds the four translated layers beside the
package's chart; glibe's `ChartWidgetState` does the same.

## What the state now holds

```gleam
pub type ChartWidgetState {
  ChartWidgetState(
    spec: Chart,               // the package's opaque chart (bounds + count)
    candle_pv: List(PropValue), // ALREADY TRANSLATED, prepended at push
    overlay_pv: List(PropValue),
    volume_pv: List(PropValue),
    kdj_pv: List(PropValue),
    viewport: Viewport,
    mouse: Option(#(Float, Float)),
  )
}
```

The view reads the package's `frame` — the O(1) part: constant-size axes and
crosshair plus **one affine per data layer** — and wraps each already
translated layer in that one group. Nothing in the view walks the accumulated
shapes, and the package's `shapes/3` is not used on the hot path.

## RED → GREEN

`test/dashboard_test.gleam` (new, 5 tests):

| Test | What it pins |
|---|---|
| `push_one_adds_one_bar_test` | one push adds exactly one candle shape; the count is the package's carried number |
| `push_one_prepends_without_retranslating_test` | `list.drop(s2.candle_pv, 1) == s1.candle_pv` — the new state is the new shape prepended to the old layer, so the old bar was **not** re-translated |
| `the_chart_push_event_lands_in_this_widget_test` | our `CustomWidget` push event is consumed by the widget and lands in **its own** chart state |
| `a_pointer_event_moves_only_the_viewport_test` | a pointer event adds no bar — the model is not touched |
| `the_dashboard_is_one_window_with_one_chart_per_identity_test` | the Dashboard is ONE window |

The second test's form is deliberate: an earlier version used `list.last` to
fetch the oldest shape, which **traverses** the list — exactly what R60 forbids.
The newest-first convention makes `list.drop(xs, 1)` the O(1) way to say "and
the old layer is unchanged" (R62).

## Files changed

- `src/glibe/app/dashboard.gleam` — the state now holds the translated layers;
  `chart_widget_def`, `push_one` (`push_generating`), `chart_node` (O(1)
  assembly), `widget_view`, `widget_handle_event` (the chart push lands in this
  widget; other events are cosmetic), `widget_subscriptions` (none — no timer,
  R33), `view` (one window, one chart widget per identity), plus the
  `SpecShape → PropValue` translator and the affine group.
- `test/dashboard_test.gleam` — new.
- `test/app_shape_test.gleam` — the fixture follows the new state shape; the
  pinned **intent** (the model is the one `Desk`, never a `#(Desk, Charts)`) is
  unchanged.

## Gates

`gleam format --check` 0 · `gleam check` 0 · `gleam test` **126 passed, no
failures** · `gleam docs build` 0 · `gleam export package-interface` 0 ·
`gleam build --warnings-as-errors` **0** — **0 Todo, 0 unused**. The whole
repository is now warning-free.
