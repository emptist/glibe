//// The one typed boundary for glibe's two `WidgetEvent.CustomWidget` wire
//// kinds. Implements `.planning/phases/03-app-view/03-01-PLAN.md` and consumes
//// `.planning/phases/03-app-view/03-00-ARCH-FINDINGS.md` §D/§E.
////
//// WHY THIS MODULE EXISTS: plushie 0.6.0's TOP-LEVEL `Event` has no `Custom`
//// (`plushie/event.gleam:33-58`), but `WidgetEvent.CustomWidget(kind, target,
//// value, data)` DOES exist (`plushie/event.gleam:230`). All older "no Custom"
//// claims were about the wrong layer. This module is the ONLY place that
//// writes or reads those two kinds; both ends are glibe code, so the `Dynamic`
//// field is a protocol boundary, not a domain type (core §0/§11, R47).
////
//// READS: `SourceBar`, `DataBar`, identity keys.
//// WRITES: two closed wire kinds and their typed payloads. The producer of
//// `SourceBarArrived` writes the payload in main; `app/runtime.gleam` reads it
//// and produces the publish request; `app/publish.gleam` carries that request;
//// `app/dashboard.gleam` reads the chart-push payload. No model type holds a
//// `Chart`, a `Dynamic`, or a widget id — and no ARRIVAL holds a capability
//// (R58: the publish channel is captured by the App's update closure at
//// wiring time, never carried per bar).
////
//// R13/R21: `WireKind` is our closed set; `kind_string` is its ONLY String
//// codec. R50: this file owns the wire protocol; no other module hard-codes a
//// kind string. Stable IDs are derived from the three identity keys already
//// owned by `id.gleam` / `api/symbol.gleam` / `api/interval.gleam`; there is
//// no composite key type, no parser and no second source of identity.
////
//// THE `Dynamic` BOUNDARY IS BEAM-NATIVE (R58, measured by probe): gleam_stdlib
//// 1.0.5 has NEITHER `dynamic.from` NOR `dynamic.unsafe_coerce` (the whole
//// module is `classify`/`bool`/`string`/`float`/`int`/`bit_array`/`list`/`array`/
//// `properties`/`nil`). On the BEAM a `Dynamic` IS the term — the stdlib's own
//// private `cast` is `@external(erlang, "gleam_stdlib", "identity")`
//// (`gleam/dynamic.gleam:97-99`) — so this module casts with the same shape.
//// The probe round-tripped a record holding an opaque `BrokerId`, an opaque
//// `Symbol` and a closed-set `Interval`, every field equal. **Zero hand-written
//// codec, zero string parsing** (core §0/§2: a Gleam value needs no parser).
//// R47 is carried by "this module writes and reads the same kind" — not by a
//// decoder that could disagree.

import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option, None, Some}
import glibe/api/interval
import glibe/api/sourcebar.{type SourceBar}
import glibe/api/symbol
import glibe/databar.{type DataBar}
import glibe/id.{type BrokerId}
import plushie/event.{
  type Event, type EventTarget, CustomWidget, EventTarget, Widget,
}

/// The closed set of CustomWidget kinds this app can emit or consume.
/// Adding a kind is a compile error at every `case` over this type (R13).
pub type WireKind {
  WireSourceBarArrived
  WireChartPush
}

/// The inbound data-stream message. Identity is carried in the typed payload
/// because the value itself owns no keys (R23/R37).
///
/// **It carries DATA ONLY.** The publish channel is an app-level capability
/// captured by the App's update closure at wiring time (R58) — it is the same
/// shape as frozen glib's `ingest.feed(timeframe, bar, publish)`
/// (`glib/src/glib/trading/ingest.gleam:57-71`), where the owner bakes the
/// publish closure at the composition root instead of threading it per bar.
/// A `Subject` field here would be a wrong-but-well-formed value: it could name
/// a dead channel, and the type would not object (core §2.2).
pub type SourceBarArrived {
  SourceBarArrived(
    broker_id: BrokerId,
    symbol: symbol.Symbol,
    interval: interval.Interval,
    sourcebar: SourceBar,
  )
}

/// The identity triple that names one chart. It is a VALUE, not a key type:
/// the key owner is still the Dict in Desk/Broker/Instrument (R50).
pub type ChartIdentity {
  ChartIdentity(
    broker_id: BrokerId,
    symbol: symbol.Symbol,
    interval: interval.Interval,
  )
}

/// The one outgoing effect value: identity plus exactly ONE archived DataBar
/// read from `databar_list` head. Never a bar list, never a `Chart`.
pub type ChartPushRequest {
  ChartPushRequest(identity: ChartIdentity, bar: DataBar)
}

/// The only codec from our closed kind set to the SDK's String kind field.
/// A kind string is boundary data, never a model name (R21).
pub fn kind_string(kind: WireKind) -> String {
  case kind {
    WireSourceBarArrived -> "source_bar_arrived"
    WireChartPush -> "chart_push"
  }
}

/// The one Dashboard window. Multi-chart is stable-ID widgets in this window;
/// a future multi-window form would pass each window's id through EventTarget.
pub fn dashboard_window_id() -> String {
  "dashboard"
}

/// The stable widget ID derived from R23/R37 keys. Existing codecs are used;
/// no spelling is parsed and no new identity type is invented.
pub fn chart_widget_id(identity: ChartIdentity) -> String {
  // The three R23/R37 keys, each through its OWN existing codec — no new
  // identity type, no parser, no second source of identity (R50). The
  // separator is the unit separator plushie itself uses for widget keys
  // (`plushie/widget.gleam:861`), so it cannot occur in a spelling.
  id.broker_id_to_string(identity.broker_id)
  <> "\u{001F}"
  <> symbol.to_string(identity.symbol)
  <> "\u{001F}"
  <> interval.to_string(identity.interval)
}

/// Build the SourceBar injection event. Its target deliberately matches no
/// widget, so the runtime passes it through the widget chain to `update`.
pub fn sourcebar_event(payload: SourceBarArrived) -> Event {
  Widget(CustomWidget(
    kind: kind_string(WireSourceBarArrived),
    target: injection_target(),
    value: nil_value(),
    data: to_dynamic(payload),
  ))
}

/// Decode only OUR sourcebar kind. Other kinds return None; no panic, no
/// catch-all over our Msg (core §4).
pub fn sourcebar_from_event(event: Event) -> Option(SourceBarArrived) {
  // `Event` is the OPEN framework type, so the catch-all arm is what the
  // official docs prescribe for it (our own `Msg` is the closed set and has
  // no catch-all — `app/message.gleam`).
  case event {
    Widget(CustomWidget(kind: kind, data: data, ..)) ->
      case kind == kind_string(WireSourceBarArrived) {
        True -> Some(from_sourcebar_dynamic(data))
        False -> None
      }
    _ -> None
  }
}

/// Build the targeted chart-push event. `EventTarget.id` MUST be the SCOPED
/// widget id, not the bare stable id: plushie's normalize prefixes every widget
/// under a window with `<window_id>#` (`plushie/tree.gleam:219 apply_scope`,
/// window scope `"dashboard#"` at `:314`) and keys the widget registry with
/// `widget_key(window_id, scoped_id)` (`widget.gleam:299-300`). Routing rebuilds
/// `widget_key(target.window_id, target.id)` (`widget.gleam:478`); a bare id
/// misses that key, so the event is Bypassed into `MsgEye` and the bar is
/// silently dropped. `full` alone does NOT route — only `id` + `scope` do.
///
/// Found on a real `gleam run` + `get_tree` 2026-11-25: 10 real bars archived
/// into the model but only ONE candle shape in the canvas — the empty window.
pub fn chart_push_event(request: ChartPushRequest) -> Event {
  let scoped_id =
    dashboard_window_id() <> "#" <> chart_widget_id(request.identity)
  Widget(CustomWidget(
    kind: kind_string(WireChartPush),
    target: EventTarget(
      window_id: dashboard_window_id(),
      id: scoped_id,
      scope: [],
      full: scoped_id,
    ),
    value: nil_value(),
    data: to_dynamic(request),
  ))
}

/// Decode a chart push into `#(stable_id, archived_bar)` for the widget handler.
pub fn chart_push_from_event(event: Event) -> Option(#(String, DataBar)) {
  case event {
    Widget(CustomWidget(kind: kind, data: data, ..)) ->
      case kind == kind_string(WireChartPush) {
        True -> {
          let request = from_chart_push_dynamic(data)
          Some(#(chart_widget_id(request.identity), request.bar))
        }
        False -> None
      }
    _ -> None
  }
}

// The Dynamic boundary. On the BEAM a Dynamic IS the term, so the stdlib's own
// private `cast` (`gleam/dynamic.gleam:97-99`) is exactly this shape. The
// reader is MONOMORPHIC — one per payload type — because an unbound return
// type variable cannot be used for record access (the compiler says "I don't
// know what type this is"). No decoder, no parser, no string.
@external(erlang, "gleam_stdlib", "identity")
fn to_dynamic(value: anything) -> Dynamic

@external(erlang, "gleam_stdlib", "identity")
fn from_sourcebar_dynamic(data: Dynamic) -> SourceBarArrived

@external(erlang, "gleam_stdlib", "identity")
fn from_chart_push_dynamic(data: Dynamic) -> ChartPushRequest

// Private helper used by both builders: the SDK's catch-all payload field.
fn nil_value() -> Dynamic {
  dynamic.nil()
}

// Private helper used by both builders: no widget ancestor is registered for
// an injection event, so scope is empty.
fn injection_target() -> EventTarget {
  // No widget ancestor is registered for an injection event, so the scope is
  // empty and the id is empty: the event matches no widget and falls through
  // the widget chain to `update` (03-00 FINDINGS D).
  EventTarget(window_id: dashboard_window_id(), id: "", scope: [], full: "")
}
