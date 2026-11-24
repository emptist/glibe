//// The view layer — the **Dashboard**, the projection of the one `Desk`
//// (R20 / owner 2026-11-19 08:28). Implements
//// `.planning/phases/03-app-view/03-02-PLAN.md`.
////
//// NAMING (owner 2026-11-19 08:28, R20): this layer is the **Dashboard** — the
//// view of the `Desk` model. It is NOT named `Desk` (that is the model root),
//// and we do not follow try_plushie's naming. One Dashboard is the projection of
//// the one `Desk`.
////
//// THE VIEW IS PURELY A VIEW (owner 2026-11-23, R60 §2):
////   *"view就是单纯的view，不要把任何model中的list拿过去，更不要再view里面反复
//// 遍历计算，概算的东西都在model里面了。"*
////
//// So, in this module:
////   - **No model list is carried into the view.** The bars live in the chart
////     package's own state, which holds GENERATED SHAPES and O(1) carried
////     bounds — never the caller's bar list (`bar_stream_chart`'s own design
////     rule, and `src/bar_stream_chart.gleam:200` *"No bars list"*).
////   - **No repeated traversal in the view.** The shapes are generated AND
////     translated ONCE, at push time; the view only reads the package's
////     `frame` — the O(1) part — and wraps each already-translated layer in
////     one affine group. The package says this is the intended split
////     (`src/bar_stream_chart.gleam:181-185`): *"A framework adapter keeps
////     the already-translated shapes for each data layer in its Model, wraps
////     them in one affine group per layer using these values, and never
////     re-translates the accumulated list on every frame. This is the package
////     side of the Elm `lazy` boundary."*). The shape package's own
////     `shapes/3` re-wraps the WHOLE accumulated list (`src:807`) and is
////     therefore **not** used here.
////   - **No aggregate is computed in the view.** The count comes from the
////     chart's own carried count (`bar_stream_chart.len/1`), O(1).
////
//// THE SAME SHAPE IS IN FROZEN glib's page (R20): glib `web/branch_view.gleam`
//// renders from the model's own fields and never re-derives them.
////
//// try_plushie's parts that are RIGHT and are adopted here (R60 §1): the push
//// translates only THIS bar's shapes and prepends them
//// (`try_plushie/src/fusion_view.gleam:139-157`: *"No accumulated list is
//// traversed"*), and the view assembles in O(1) with one affine group per
//// layer (`fusion_view.gleam:159-172`: *"No `list.map` over accumulated shapes
//// happens here — that work moved to `push`"*).
////
//// try_plushie's part that is WRONG and is NOT adopted: one App per chart
//// (three `plushie.start` calls, three renderers). glibe has ONE App; many
//// charts are stable-ID widgets in one window (R60 §1).

import bar_stream_chart.{
  type Bar, type Chart, type PriceScale, type SpecShape, type Viewport,
}
import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import glibe/app/wire
import glibe/broker.{Broker}
import glibe/databar.{type DataBar}
import glibe/desk.{type Desk, Desk}
import glibe/instrument.{Instrument}
import glibe/trading/signal.{SignalBuy, SignalNoSignal, SignalSell}
import plushie/canvas/shape
import plushie/event.{
  type Event, Key, KeyEvent, KeyPressed, Move, Press, Release, Scroll, Widget,
}
import plushie/node.{type Node, type PropValue, DictVal, StringVal}
import plushie/prop/length
import plushie/subscription.{type Subscription}
import plushie/ui
import plushie/widget.{type EventAction, type WidgetDef}

import plushie/widget/canvas

/// A chart widget instance's own state: the chart package's opaque chart plus
/// the FOUR ALREADY-TRANSLATED data layers, the O(1) viewport and the pointer.
///
/// **The translated layers are the whole point** (R60 §2): they are produced at
/// push time — one bar's shapes only — and the view never re-translates the
/// accumulated list. Held BY THE RUNTIME per stable node ID (official WidgetDef
/// state is *"arbitrary and opaque to the runtime … threads state through
/// renders"*), NOT copied from the Desk model and NOT written back.
pub type ChartWidgetState {
  ChartWidgetState(
    spec: Chart,
    candle_pv: List(PropValue),
    overlay_pv: List(PropValue),
    volume_pv: List(PropValue),
    kdj_pv: List(PropValue),
    viewport: Viewport,
    mouse: Option(#(Float, Float)),
    drag: DragState,
  )
}

/// Whether a pointer drag is in progress, and where it last was. A custom type
/// (not a bare Bool + a loose Float) so "dragging with no last x" is
/// unrepresentable — the compiler forces both fields to be written together
/// (R13, core §2). `DragIdle` carries no stale coordinate.
pub type DragState {
  DragIdle
  DragActive(last_x: Float)
}

/// The props a chart widget receives from outside: enough to build a Chart
/// (geometry + price scale) and a stable identity. Never a bar list.
pub type ChartWidgetProps {
  ChartWidgetProps(width: Float, height: Float, price_scale: PriceScale)
}

/// Build the WidgetDef for one (broker, symbol, interval) chart. Stable node ID
/// comes from the caller (encoded from R23/R37 identity keys).
pub fn chart_widget_def() -> WidgetDef(ChartWidgetState, ChartWidgetProps) {
  widget.WidgetDef(
    init: fn() {
      ChartWidgetState(
        spec: bar_stream_chart.empty(
          bar_stream_chart.Geometry(width: 800.0, height: 400.0),
          bar_stream_chart.PriceScaleLinear,
        ),
        candle_pv: [],
        overlay_pv: [],
        volume_pv: [],
        kdj_pv: [],
        viewport: bar_stream_chart.default_viewport(0),
        mouse: None,
        drag: DragIdle,
      )
    },
    view: fn(id, props, state) { widget_view(id, props, state) },
    handle_event: fn(event, state) { widget_handle_event(event, state) },
    subscriptions: fn(props, state) { widget_subscriptions(props, state) },
    cache_key: None,
  )
}

/// Map the ONE archived domain bar onto our own `bar_stream_chart.Bar` — the
/// DataBar -> chart.Bar boundary (06-02 D4). Every measured field is a direct
/// one-for-one copy (the chart Bar was designed from glib's original DataBar);
/// the only translation is the decision: glibe's closed `Signal` has three
/// values, the chart's has six, and `SignalNoSignal` maps to `SignalHold`
/// (the chart's no-marker value, exactly glib's `SignalType` shape).
///
/// This is the real consumer that makes the eight chart-measurement fields on
/// `DataBar` exist (R26 / R32). It copies SCALARS off one archived bar — it
/// never walks `databar_list` and never re-computes an indicator. Indicator
/// values were already written onto the bar upstream by `databar_processing`;
/// their writer must use the O(1) stream recurrences in `glib/{sma,bollinger,
/// kdj}` — NEVER the O(n²) batch full-window recompute (DESIGN.md:1427,
/// 06-06-STREAM-INDICATORS.md).
pub fn data_bar_to_chart_bar(bar: DataBar) -> Bar {
  let signal = case bar.signal {
    SignalBuy -> bar_stream_chart.SignalBuy
    SignalSell -> bar_stream_chart.SignalSell
    SignalNoSignal -> bar_stream_chart.SignalHold
  }
  bar_stream_chart.Bar(
    idx: bar.idx,
    open: bar.open,
    high: bar.high,
    low: bar.low,
    close: bar.close,
    volume: bar.volume,
    sma_medium: bar.sma_medium,
    yin_leaf_cma: bar.yin_leaf_cma,
    yang_leaf_cma: bar.yang_leaf_cma,
    k: bar.k,
    d: bar.d,
    j: bar.j,
    bb_u3: bar.bb_u3,
    bb_l3: bar.bb_l3,
    signal: signal,
  )
}

/// Convert ONE arriving standard bar into the chart library's Bar, then
/// `push_generating(chart, bar)` and translate ONLY this bar's shapes.
///
/// **The translation happens HERE, at push time** (R60 §2; try_plushie
/// `fusion_view.gleam:139-157`): the four layers are prepended with this bar's
/// own shapes, so the view never walks the accumulated list. One bar in, never a
/// list. The field mapping is the DataBar -> chart.Bar boundary (06-02 D4).
pub fn push_one(state: ChartWidgetState, bar: Bar) -> ChartWidgetState {
  // The package generates THIS bar's shapes and returns them; we translate
  // ONLY those and prepend them to the layer. The accumulated list is never
  // walked (R60 §2; try_plushie `fusion_view.gleam:139-157`).
  let #(spec, generated) = bar_stream_chart.push_generating(state.spec, bar)
  ChartWidgetState(
    ..state,
    spec: spec,
    candle_pv: [translate(generated.candle), ..state.candle_pv],
    overlay_pv: list.append(
      list.map(generated.overlays, translate),
      state.overlay_pv,
    ),
    volume_pv: [translate(generated.volume), ..state.volume_pv],
    kdj_pv: list.append(list.map(generated.kdj, translate), state.kdj_pv),
  )
}

/// Project a chart's derived IR into plushie Nodes. **O(1)**: the four data
/// layers are the already-translated lists from the state, each wrapped in ONE
/// affine group from the package's `frame`; the axes and the crosshair are the
/// frame's own constant-size shapes. No model list is read and no accumulated
/// shape list is traversed (R60 §2).
pub fn chart_node(
  id: String,
  props: ChartWidgetProps,
  state: ChartWidgetState,
) -> Node {
  // O(1): the four data layers are the ALREADY-TRANSLATED lists in the state;
  // the package's `frame` gives the constant-size axes and crosshair plus ONE
  // affine per data layer. Nothing here walks the accumulated shapes (R60 §2).
  let frame =
    bar_stream_chart.frame(
      state.spec,
      bar_stream_chart.Viewport(
        first_visible: state.viewport.first_visible,
        visible_count: state.viewport.visible_count,
      ),
      state.mouse,
    )
  let layers =
    dict.from_list([
      #("axes", translate_list(frame.axes)),
      #("candles", affine_group(state.candle_pv, frame.candles, "candles")),
      #("overlays", affine_group(state.overlay_pv, frame.overlays, "overlays")),
      #("volume", affine_group(state.volume_pv, frame.volume, "volume")),
      #("kdj", affine_group(state.kdj_pv, frame.kdj, "kdj")),
      #("crosshair", translate_list(frame.crosshair)),
    ])
  canvas.build(
    canvas.new(id, length.Fixed(props.width), length.Fixed(props.height))
    |> canvas.with_opts([canvas.Layers(layers)]),
  )
}

/// Widget view callback: build the node subtree from id, props and its OWN state.
pub fn widget_view(
  id: String,
  props: ChartWidgetProps,
  state: ChartWidgetState,
) -> Node {
  chart_node(id, props, state)
}

/// canvas width in pixels — the `zoom_at`/`pan_by_pixels` coordinate basis.
/// Derived from the fixed widget geometry (`:294-297`), not a user setting.
const canvas_width: Float = 800.0

/// Widget event handler. The chart push is the ONE domain-significant event;
/// pointer/wheel/key events are cosmetic and change ONLY this widget's O(1)
/// viewport, mouse and drag state — never the Desk model, never the translated
/// shape lists (R60 §2). The old version returned `state` unchanged for every
/// cosmetic event, so zoom/pan/crosshair were dead (audit B1, 2026-11-25).
pub fn widget_handle_event(
  event: Event,
  state: ChartWidgetState,
) -> #(EventAction, ChartWidgetState) {
  case wire.chart_push_from_event(event) {
    Some(#(_stable_id, bar)) ->
      // The runtime routed this event to THIS widget by its stable id, so the
      // bar belongs to this chart (03-00 FINDINGS D).
      #(widget.UpdateState, push_one(state, data_bar_to_chart_bar(bar)))
    None -> #(widget.UpdateState, handle_cosmetic_event(event, state))
  }
}

/// Route a non-domain event to the interaction that owns it. Each helper is
/// PURE and O(1): it reads/writes only viewport, mouse and drag — never the
/// accumulated shape lists and never the model. Unknown events leave state
/// untouched.
fn handle_cosmetic_event(
  event: Event,
  state: ChartWidgetState,
) -> ChartWidgetState {
  case event {
    Widget(Scroll(x:, delta_y:, ..)) -> scroll_zoom(state, x, delta_y)
    Widget(Press(x:, ..)) ->
      ChartWidgetState(..state, drag: DragActive(last_x: x))
    Widget(Move(x:, y:, ..)) -> pointer_move(state, x, y)
    Widget(Release(..)) -> ChartWidgetState(..state, drag: DragIdle)
    Key(KeyEvent(event_type: KeyPressed, key:, ..)) -> key_navigate(state, key)
    _ -> state
  }
}

/// Mouse wheel: zoom around the cursor x. delta_y < 0 zooms in (bar_stream_chart
/// contract). The total is the chart's O(1) carried count.
fn scroll_zoom(
  state: ChartWidgetState,
  cursor_x: Float,
  delta_y: Float,
) -> ChartWidgetState {
  let total = bar_stream_chart.len(state.spec)
  let viewport =
    bar_stream_chart.zoom_at(
      state.viewport,
      total,
      canvas_width,
      delta_y,
      cursor_x,
    )
  ChartWidgetState(..state, viewport: viewport)
}

/// Pointer move: a drag pans by the pixel delta; regardless of drag state the
/// cursor position is stored so `frame` draws a crosshair (previously always
/// None — the empty crosshair layer). `mouse` never feeds the model.
fn pointer_move(
  state: ChartWidgetState,
  x: Float,
  y: Float,
) -> ChartWidgetState {
  let total = bar_stream_chart.len(state.spec)
  let #(viewport, drag) = case state.drag {
    DragActive(last_x:) -> #(
      bar_stream_chart.pan_by_pixels(
        state.viewport,
        total,
        canvas_width,
        x -. last_x,
      ),
      DragActive(last_x: x),
    )
    DragIdle -> #(state.viewport, DragIdle)
  }
  ChartWidgetState(
    ..state,
    viewport: viewport,
    mouse: Some(#(x, y)),
    drag: drag,
  )
}

/// Keyboard navigation mirrors try_plushie: up/down zoom, left/right pan.
fn key_navigate(state: ChartWidgetState, key: String) -> ChartWidgetState {
  let total = bar_stream_chart.len(state.spec)
  let viewport = case key {
    "ArrowUp" ->
      bar_stream_chart.zoom_step(state.viewport, total, bar_stream_chart.ZoomIn)
    "ArrowDown" ->
      bar_stream_chart.zoom_step(
        state.viewport,
        total,
        bar_stream_chart.ZoomOut,
      )
    "ArrowLeft" ->
      bar_stream_chart.pan_step(state.viewport, total, bar_stream_chart.PanLeft)
    "ArrowRight" ->
      bar_stream_chart.pan_step(
        state.viewport,
        total,
        bar_stream_chart.PanRight,
      )
    _ -> state.viewport
  }
  ChartWidgetState(..state, viewport: viewport)
}

/// Widget subscriptions for this instance. **None**: the chart is driven by the
/// archived bar arriving, not by a timer (R33 — no poll; the system is alive
/// because data arrives).
pub fn widget_subscriptions(
  _props: ChartWidgetProps,
  _state: ChartWidgetState,
) -> List(Subscription) {
  []
}

/// The Dashboard view: a List(Node) of top-level windows (plushie `view` shape).
/// It composes stable-ID chart widgets; it does not read brokers/instruments
/// lists out of Desk. `[]` would close every window and shut down cleanly.
pub fn view(desk: Desk) -> List(Node) {
  [ui.window(wire.dashboard_window_id(), [], chart_nodes(desk))]
}

// --- the chart's own nodes ---------------------------------------------------

/// One chart widget per (broker, symbol, interval) — the stable ID comes from
/// the three identity keys, and the props carry geometry only (never a bar).
fn chart_nodes(desk: Desk) -> List(Node) {
  let Desk(brokers) = desk
  dict.fold(brokers, [], fn(acc, broker_id, broker) {
    let Broker(instruments, _) = broker
    dict.fold(instruments, acc, fn(inner, symbol, instrument) {
      let Instrument(timeframes) = instrument
      dict.fold(timeframes, inner, fn(innermost, interval, _timeframe) {
        let identity =
          wire.ChartIdentity(
            broker_id: broker_id,
            symbol: symbol,
            interval: interval,
          )
        [
          widget.build(
            chart_widget_def(),
            wire.chart_widget_id(identity),
            ChartWidgetProps(
              width: 800.0,
              height: 400.0,
              price_scale: bar_stream_chart.PriceScaleLinear,
            ),
          ),
          ..innermost
        ]
      })
    })
  })
}

// --- IR -> PropValue translation ---------------------------------------------

/// Translate one shape of the package's framework-neutral IR into the
/// renderer's shape value. This runs ONCE per shape, at push time.
fn translate(shape_spec: SpecShape) -> PropValue {
  case shape_spec {
    bar_stream_chart.SpecRect(id:, x:, y:, width:, height:, fill:, opacity:) -> {
      let opts = case opacity {
        None -> [shape.Fill(fill)]
        Some(o) -> [shape.Fill(fill), shape.Opacity(o)]
      }
      shape.rect(x, y, width, height, opts)
      |> with_id(id_string(id))
    }
    bar_stream_chart.SpecPath(id:, commands:, stroke:) -> {
      let cmds =
        list.map(commands, fn(command) {
          case command {
            bar_stream_chart.SpecMoveTo(x:, y:) -> shape.MoveTo(x: x, y: y)
            bar_stream_chart.SpecLineTo(x:, y:) -> shape.LineTo(x: x, y: y)
          }
        })
      shape.path(cmds, [shape.Stroke(stroke_of(stroke))])
      |> with_id(id_string(id))
    }
    bar_stream_chart.SpecLine(id:, x1:, y1:, x2:, y2:, stroke:) ->
      shape.line(x1, y1, x2, y2, [shape.Stroke(stroke_of(stroke))])
      |> with_id(id_string(id))
    bar_stream_chart.SpecText(id:, x:, y:, content:, fill:, size:) ->
      shape.text(x, y, content, [shape.Fill(fill), shape.Size(size)])
      |> with_id(id_string(id))
    bar_stream_chart.SpecGroup(id:, children:, transforms:) ->
      shape.group(translate_list(children), [
        shape.Transforms(list.map(transforms, translate_transform)),
      ])
      |> with_id(id_string(id))
    bar_stream_chart.SpecInteractive(id:, children:, tooltip:) ->
      shape.interactive(
        shape.group(translate_list(children), []),
        id_string(id),
        [shape.OnHover(True), shape.Tooltip(tooltip)],
      )
  }
}

fn translate_list(shapes: List(SpecShape)) -> List(PropValue) {
  list.map(shapes, translate)
}

/// Wrap an already-translated layer in ONE affine group. The layer's shapes
/// stay byte-identical across zoom and pan; only this group changes (the
/// package's own contract, `src/bar_stream_chart.gleam:171-185`).
pub fn affine_group(
  children: List(PropValue),
  aff: bar_stream_chart.Affine,
  label: String,
) -> List(PropValue) {
  [
    shape.group(children, [
      shape.Transforms([
        shape.scale(aff.scale_x, aff.scale_y),
        shape.translate(aff.dx, aff.dy),
      ]),
    ])
    |> with_id("affine:" <> label),
  ]
}

fn stroke_of(stroke: bar_stream_chart.Stroke) -> PropValue {
  case stroke {
    bar_stream_chart.Stroke(color:, width:) -> shape.stroke(color, width, [])
  }
}

fn translate_transform(transform: bar_stream_chart.SpecTransform) -> PropValue {
  case transform {
    bar_stream_chart.SpecScale(x:, y:) -> shape.scale(x, y)
    bar_stream_chart.SpecTranslate(x:, y:) -> shape.translate(x, y)
  }
}

fn id_string(id: bar_stream_chart.ShapeId) -> String {
  case id {
    bar_stream_chart.ShapeId(spelling) -> spelling
  }
}

/// The shape value carries its own stable id so the renderer never synthesises
/// `auto:shape_N` (try_plushie's `fusion_view.gleam:409-414`).
fn with_id(value: PropValue, id: String) -> PropValue {
  case value {
    DictVal(fields) -> DictVal(dict.insert(fields, "id", StringVal(id)))
    other -> other
  }
}
