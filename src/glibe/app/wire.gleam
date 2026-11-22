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
//// READS: `SourceBar`, `DataBar`, identity keys, `Subject(ChartPushRequest)`.
//// WRITES: two closed wire kinds and their typed payloads. The producer of
//// `SourceBarArrived` writes `publisher` once in main; `app/runtime.gleam`
//// reads it to emit a publish request; `app/publish.gleam` reads that request.
//// `app/dashboard.gleam` reads the chart-push payload. No model type holds a
//// `Chart`, a `Dynamic`, or a widget id.
////
//// R13/R21: `WireKind` is our closed set; `kind_string` is its ONLY String
//// codec. R50: this file owns the wire protocol; no other module hard-codes a
//// kind string. Stable IDs are derived from the three identity keys already
//// owned by `id.gleam` / `api/symbol.gleam` / `api/interval.gleam`; there is
//// no composite key type, no parser and no second source of identity.

import gleam/dynamic.{type Dynamic}
import gleam/erlang/process.{type Subject}
import gleam/option.{type Option}
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
/// because the value itself owns no keys (R23/R37); `publisher` is a one-shot
/// capability created in main and passed to `runtime.update`, not model state.
pub type SourceBarArrived {
  SourceBarArrived(
    broker_id: BrokerId,
    symbol: symbol.Symbol,
    interval: interval.Interval,
    sourcebar: SourceBar,
    publisher: Subject(ChartPushRequest),
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
pub fn kind_string(kind: WireKind) -> String {
  todo as "03-01: name the two WireKind variants as stable wire strings"
}

/// The one Dashboard window. Multi-chart is stable-ID widgets in this window;
/// a future multi-window form would pass each window's id through EventTarget.
pub fn dashboard_window_id() -> String {
  todo as "03-01: the single top-level window id"
}

/// The stable widget ID derived from R23/R37 keys. Existing codecs are used;
/// no spelling is parsed and no new identity type is invented.
pub fn chart_widget_id(identity: ChartIdentity) -> String {
  todo as "03-01: broker <> separator <> symbol <> separator <> interval"
}

/// Build the SourceBar injection event. Its target deliberately matches no
/// widget, so the runtime passes it through the widget chain to `update`.
pub fn sourcebar_event(payload: SourceBarArrived) -> Event {
  todo as "03-01: CustomWidget(WireSourceBarArrived) with empty-widget EventTarget"
}

/// Decode only OUR sourcebar kind. Other kinds return None; no panic, no
/// catch-all over our Msg (core §4).
pub fn sourcebar_from_event(event: Event) -> Option(SourceBarArrived) {
  todo as "03-01: match CustomWidget kind then unsafe_coerce the same-module payload"
}

/// Build the targeted chart-push event. The EventTarget MUST equal the stable
/// node ID produced by the view; a mismatch is a silent no-op (FINDINGS D).
pub fn chart_push_event(request: ChartPushRequest) -> Event {
  todo as "03-01: CustomWidget(WireChartPush) targeted at chart_widget_id"
}

/// Decode a chart push into `#(stable_id, archived_bar)` for the widget handler.
pub fn chart_push_from_event(event: Event) -> Option(#(String, DataBar)) {
  todo as "03-01: match CustomWidget kind then unsafe_coerce ChartPushRequest"
}

// Private helper used by both builders: the SDK's catch-all payload field.
fn nil_value() -> Dynamic {
  dynamic.nil()
}

// Private helper used by both builders: no widget ancestor is registered for
// an injection event, so scope is empty.
fn injection_target() -> EventTarget {
  todo as "03-01: EventTarget(window_id: dashboard_window_id(), id: '', scope: [], full: '')"
}
