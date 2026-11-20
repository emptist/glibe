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
//// R13). This module is that gate.
////
//// READS: `plushie/event.Event` (the open framework event).
//// WRITES: `Msg`, consumed by `app/runtime.gleam`'s update.
////
//// VERSION NOTE (challenge B3): the current official guide 16 uses
//// `event.Custom` for broadcast injection, but the pinned plushie_gleam 0.6.0
//// has NO `Custom` Event variant. `on_event` needs only `fn(Event) -> Msg`, so
//// this gate is version-safe; do not build Msg around `Custom`.
////
//// R19 status: first body filled 2026-11-19 — `from_event` is the working
//// line (RED→GREEN via `from_event_wraps_event_test`). All other bodies in this
//// module are `todo as "..."`; the Speaker/SourceBar payloads stay placeholders
//// until the BEAM-side injection carrier lands (not invented here).

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

/// A standard bar arriving on the one stream (R27/R28/R29): the instant,
/// interval (in the key, R23) and the bar value. Kept as a value object so
/// update stays a pure `Desk -> Desk` recompute (06-02 §D3 / R33).
pub type SourceBarArrived {
  SourceBarArrivedPlaceholder
}

/// The gate from the OPEN framework Event to our CLOSED Msg (challenge B1/B2).
/// Official `app.application` calls this `on_event` for every inbound WIRE event.
///
/// THREE ENTRIES, NOT ONE (design solved here at doc level): the renderer wire
/// carries only eye events, so `from_event` maps every framework Event to
/// `MsgEye`. Voice and SourceBar do NOT come over the renderer wire — they are
/// injected on the BEAM side with `plushie.dispatch_event` (official app-lifecycle:
/// it enters the widget-handler chain and reaches `update` as any event). To
/// carry a non-wire Msg through that path, the app wraps it as a framework Event
/// carrying the value; the 0.6.0 pin has no `event.Custom` (challenge B3), so the
/// exact carrier is resolved when the shared actor lands — NOT by inventing a
/// Custom variant here. This is why Msg keeps all three origins explicit.
///
/// Total by construction: every framework Event -> `MsgEye(event)`. No panic,
/// no dropped event, no catch-all over OUR Msg.
pub fn from_event(event: Event) -> Msg {
  MsgEye(event)
}
