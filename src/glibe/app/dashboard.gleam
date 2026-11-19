//// The view layer. Implements
//// `.planning/phases/06-app-architecture/06-01-PLAN.md`; the non-obvious
//// design is in `.planning/phases/06-app-architecture/06-02-CHALLENGES.md`
//// §D and §G (read those before changing any type here).
////
//// NAMING (owner 2026-11-19 08:28, R20): this layer is the **Dashboard** — the
//// view of the `Desk` model. It is NOT named `Desk` (that is the model root),
//// and we do not follow try_plushie's naming. Common usage and actual function
//// are both "Dashboard". One Dashboard is the projection of the one `Desk`.
////
//// THE CENTRAL DESIGN (challenge G, owner 08:35: "如何在 View 层绝不出现搬运
//// model 层各种 list"): the answer is a TYPE design, not a discipline.
////
////   1. Each (broker, symbol, interval) is ONE chart widget instance with a
////      STABLE node ID (identity lives in the key — R23/R37). Many brokers ×
////      many instruments × many timeframes = many stable-ID widget instances,
////      not a nested list walked by view.
////   2. Each widget's state owns an opaque incremental `bar_stream_chart.Chart`.
////      The ONLY input is `push(chart, bar)` — one bar. The chart library has NO
////      batch API, NO replay, NO load-list (README design rules): it stores
////      generated shapes + O(1) carried bounds, NEVER a copy of the caller's bar
////      list. So "carrying a list into view" is not representable here.
////   3. `view` consumes only `shapes(chart, viewport, mouse) -> ChartShapes`, a
////      framework-neutral SpecShape IR, and translates it to plushie Nodes.
////      It never maps over brokers / instruments / bar lists from the model.
////
//// VIEW-MODEL COMMUNICATION — HOW IT DIFFERS FROM THE FAMILIAR WAY (challenge G3):
//// The familiar (Web/React) shape is `view(state) = state.items.map(Row)`, i.e.
//// the whole collection is carried from model into view every render. The
//// official plushie tutorial's canvas demo does this too (`bar_shapes(model.series)`)
//// but that is a small demo, NOT the architecture for many timeframes. Here:
//// one bar arrives as a Msg (app/message.gleam) -> app routes it to the target
//// widget by its stable ID -> the widget pushes it into its own chart state ->
//// view reads only the derived IR. The model `Desk` remains the single source
//// of truth (R33); what view sees is DERIVED, INCREMENTAL shape data, not the
//// raw model collection. This is "keep the computation at the boundary", not
//// "move lists around".
////
//// DOMAIN vs PRESENTATION SPLIT (must stay explicit, challenges D3/G3):
//// - L1 domain core: leaf / branch / timeframe recompute is a pure `Desk -> Desk`
////   function (R33: one stream, no actor/scheduler/clock/poll).
//// - Here in the view layer: accumulating chart SHAPES is presentation-derived
////   state, held in widget state, NEVER written back into `Desk`. Confusing these
////   two is how one smuggles a scheduler into R33 or a model copy into the view.
////
//// MEMOISATION (composition-patterns): `ui.memo(key, dependency, fn)` skips
//// normalisation/diff when `dependency ==` is unchanged. In plushie_gleam 0.6.0
//// the `WidgetDef.cache_key` field exists but the normalizer does NOT use it yet
//// ("declaring it now lets widget authors opt in; the optimization will land in
//// a future release") — do not rely on it. Primary mechanism is widget state +
//// incremental push, not memo.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import bar_stream_chart.{type Bar, type Chart, type PriceScale, type Viewport}
import gleam/option.{type Option}
import glibe/desk.{type Desk}
import plushie/event.{type Event}
import plushie/node.{type Node}
import plushie/subscription.{type Subscription}
import plushie/widget.{type EventAction, type WidgetDef}

/// A chart widget instance's own state: an opaque incremental Chart plus the
/// viewport / pointer needed by `shapes`. Held BY THE RUNTIME per stable node ID
/// (official WidgetDef state is "arbitrary and opaque to the runtime... threads
/// state through renders"), NOT copied from the Desk model and NOT written back.
pub type ChartWidgetState {
  ChartWidgetState(
    chart: Chart,
    viewport: Viewport,
    mouse: Option(#(Float, Float)),
  )
}

/// The props a chart widget receives from outside: enough to build a Chart
/// (geometry + price scale) and a stable identity. Never a bar list.
pub type ChartWidgetProps {
  ChartWidgetProps(width: Float, height: Float, price_scale: PriceScale)
}

/// Build the WidgetDef for one (broker, symbol, interval) chart. Stable node ID
/// comes from the caller (encoded from R23/R37 identity keys). `handle_event`
/// consumes zoom/pan/crosshair locally; only domain-significant events Emit a
/// small payload. The `WidgetDef` constructor needs init/view/handle_event/
/// subscriptions/cache_key — wired when the chart adapter lands; type here only.
pub fn chart_widget_def() -> WidgetDef(ChartWidgetState, ChartWidgetProps) {
  todo as "WidgetDef(init/view/handle_event/subscriptions/cache_key); handle_event consumes zoom/pan locally, no bar-list prop"
}

/// Convert ONE arriving standard bar into the chart library's Bar, then
/// `push(chart, bar)`. One bar in, never a list. The field mapping is the
/// DataBar -> bar_stream_chart.Bar boundary (06-02 D4).
pub fn push_one(state: ChartWidgetState, bar: Bar) -> ChartWidgetState {
  todo as "bar_stream_chart.push(chart, bar) into state.chart; no load-list path exists by design"
}

/// Project a chart's derived IR into plushie Nodes. Reads only the opaque Chart
/// via `shapes`; does NOT walk any model list. This is what a widget's view calls.
pub fn chart_node(id: String, state: ChartWidgetState) -> Node {
  todo as "shapes(chart, viewport, mouse) -> ChartShapes IR -> translate SpecShape to Node; never map a model list"
}

/// Widget view callback: build the node subtree from id, props and its OWN state.
pub fn widget_view(
  id: String,
  props: ChartWidgetProps,
  state: ChartWidgetState,
) -> Node {
  todo as "compose canvas node(s) from chart_node(id, state); props carry geometry only"
}

/// Widget event handler: zoom/pan/crosshair are consumed locally (UpdateState);
/// domain-significant events Emit a small payload up to the app.
pub fn widget_handle_event(
  event: Event,
  state: ChartWidgetState,
) -> #(EventAction, ChartWidgetState) {
  todo as "consume cosmetic events locally; Emit only small typed payloads; never echo a bar list"
}

/// Widget subscriptions for this instance (namespaced by node ID by the runtime).
pub fn widget_subscriptions(
  props: ChartWidgetProps,
  state: ChartWidgetState,
) -> List(Subscription) {
  todo as "chart widget subscriptions if any; namespaced automatically by runtime"
}

/// The Dashboard view: a List(Node) of top-level windows (plushie `view` shape).
/// It composes stable-ID chart widgets; it does not read brokers/instruments
/// lists out of Desk. `[]` would close every window and shut down cleanly.
pub fn view(desk: Desk) -> List(Node) {
  todo as "one stable-ID chart widget per (broker,symbol,interval); compose from derived IR, never map model lists"
}
