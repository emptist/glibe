//// A parameter block, NOT an entity. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: nothing.
//// WRITES: `TimeframeSettings`, whose ONLY home is `Timeframe.settings`.
////
//// R23 (owner, verbatim): *"TimeframeSettings这是什么type？现实中存在这个type
//// 吗？跟Timeframe什么关系？又是在绕圈子？"* It is not a thing in the
//// domain: no id, no dictionary of its own, no config table, no lookup
//// function. It is the numbers one interval's Timeframe runs on, so it is a
//// FIELD of `Timeframe`, and the interval is not.
////
//// The fields themselves are deliberately NOT listed here. They are the
//// parameters of the indicator / leaf / branch calculations, and per R26 /
//// R32 they are added one at a time when a real consumer exists. Listing
//// them now would be transcribing the old implementation rather than the
//// design. R19: an empty type with a `///` doc is a valid skeleton item.
////
//// R19 status: skeleton. No function here on purpose: a parameter block has
//// no behaviour of its own.

/// The numbers one `Timeframe` runs on. Not an entity: no identity, no
/// collection of its own, no settings table. It travels WITH the engine
/// (R23); the holder's Dict key carries the interval.
pub type TimeframeSettings {
  TimeframeSettings
}
