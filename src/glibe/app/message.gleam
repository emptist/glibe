//// The one closed set of messages the Dashboard (view layer, R20 / owner
//// 2026-11-19 08:28) handles. Implements
//// `.planning/phases/03-app-view/03-01-PLAN.md`; the non-obvious
//// design constraint (former §B: open framework Event → our closed Msg) is
//// carried by the frozen glib source cited below and in the plan.
////
//// WHY THIS MODULE EXISTS (challenge B1, official `app.gleam`): plushie's
//// `app.simple` uses the framework's `Event` directly as its msg — a 12-variant
//// OPEN type (`event.gleam:33`: Widget / Key / Window / Timer / Async /
//// Stream / Effect / System / Ime / ModifiersChanged / Error / Session). That
//// is try_plushie's simplification, NOT our boundary. We use `app.application`,
//// whose `on_event: fn(Event) -> Msg` maps the open framework Event into OUR
//// closed `Msg`. `Event` is open and official docs put a catch-all `_ ->` on
//// it; `Msg` is ours and is therefore exhaustive with NO catch-all (core §4,
//// R13). This module is that closed-set decoder.
////
//// READS: `plushie/event.Event` (the open framework event).
//// WRITES: `Msg`, consumed by `app/runtime.gleam`'s update.
////
//// VERSION NOTE (corrected 2026-11-23): the TOP-LEVEL `Event` of plushie_gleam
//// 0.6.0 has no `Custom` variant (`plushie/event.gleam:33-58`), but
//// `WidgetEvent.CustomWidget(kind, target, value, data)` DOES exist
//// (`plushie/event.gleam:230`). The earlier "no Custom" conclusion used the
//// wrong layer. `app/wire.gleam` owns both kinds; this closed-set decoder only decodes them.
////
//// R19 status (2026-11-23): skeleton for 03-01. `Msg`, `VoiceEvent` and the
//// typed `SourceBarArrived` alias are fixed; `from_event` is a `todo` until its
//// new RED test proves the CustomWidget sourcebar closed-set decoder. All pre-03-01 bodies
//// were re-opened deliberately — no body may outrun its doc (R19/R44).

import gleam/option.{None, Some}
import glibe/app/wire
import plushie/event.{type Event}

/// The three origins of an interaction, per owner's eye / ear-mouth split
/// (2026-11-17 16:50) plus the live data stream (R33).
///
/// Challenge B2: this is OUR closed set, so every constructor is named in full
/// with the type prefix (R21) and `on_event` + `update` must handle all of them
/// — no catch-all arm over this type.
pub type Msg {
  /// From the eye: a raw renderer event, mapped 1:1 from the framework Event
  /// by `from_event`. Kept opaque on purpose — the Dashboard decides what a
  /// click means, not this module.
  MsgEye(Event)
  /// From the ear/mouth: a typed voice command or a spoken feedback payload
  /// recognised on the BEAM (glib measured closed set: MarketBuy / MarketSell /
  /// LimitBuy / LimitSell + Proportion + Query — implementation reference only,
  /// owner design is authoritative). The concrete command type is filled in
  /// when the voice boundary lands; not invented here.
  MsgVoice(VoiceEvent)
  /// From the data stream: a standard bar arrived (R33 one stream; R28 the
  /// provider-native shape is already converted to SourceBar at the input edge).
  /// Carried as a value, not fetched here (no clock / poll — R33).
  MsgSourceBarArrived(SourceBarArrived)
}

/// A typed voice event. Skeleton: the concrete command set is NOT invented in
/// doc-first; it follows glib's measured closed set (MarketBuy / MarketSell /
/// LimitBuy / LimitSell, HalfPosition / FullPosition, Quote / Balance) filtered
/// through owner's design when `app/voice/<platform>` lands. See 06-02 §E2–E4
/// for the owner-process / FFI / cache constraints on that boundary.
pub type VoiceEvent {
  VoiceEventPlaceholder
}

/// A standard bar arriving on the one stream (R27/R28/R29). The full typed
/// payload is owned by `app/wire.gleam`, the one module that writes and reads
/// the CustomWidget kind; this alias keeps the Msg variants readable without
/// creating a second type. **The payload is DATA ONLY** — the publish channel
/// is captured by the App's update closure at wiring time, never carried per
/// bar (R58).
pub type SourceBarArrived =
  wire.SourceBarArrived

/// The closed-set decoder from the OPEN framework Event to our CLOSED Msg (challenge B1/B2).
/// Official `app.application` calls this `on_event` for every inbound WIRE event.
///
/// THREE ENTRIES, NOT ONE: the renderer wire carries eye events, which map 1:1
/// to `MsgEye`. SourceBar is injected on the BEAM side as a targeted
/// `CustomWidget` event built by `app/wire.gleam`; its closed kind is decoded
/// here into `MsgSourceBarArrived`. Every OTHER event — including any unknown
/// CustomWidget kind — remains `MsgEye(event)`, so no input is dropped and no
/// catch-all is needed over OUR Msg. Voice stays a placeholder until its own
/// typed boundary lands; it never masquerades as an eye event.
///
/// R47 (readers/writers): `wire.sourcebar_event` writes the kind and payload;
/// this function reads it; `runtime.update` consumes the resulting Msg.
pub fn from_event(event: Event) -> Msg {
  // OUR kind first; every other event — including another library's
  // CustomWidget — stays an eye event. Nothing is dropped and no kind is
  // guessed (R13: the closed set is ours, so the closed-set decoder is exhaustive).
  case wire.sourcebar_from_event(event) {
    Some(payload) -> MsgSourceBarArrived(payload)
    None -> MsgEye(event)
  }
}
