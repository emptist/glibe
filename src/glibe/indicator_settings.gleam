//// The parameter block ONE `Timeframe` runs on — a value, not an entity.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`.
//// Ruling: `docs/RULINGS.md` R23 (thorough correction), R19, R21.
////
//// R23 answers the owner's question *"TimeframeSettings这是什么type？现实中
//// 存在这个type吗？"*: there is no such ENTITY in the domain. These are twelve
//// numbers that the indicators and structures need when one engine processes
//// one bar. One interval has one engine, so one interval has one of these
//// values, and its only home is `Timeframe.settings` in
//// `src/glibe/timeframe.gleam`. glib landed the same shape as
//// `Timeframe(settings: IntervalSettings, …)` in
//// `glib/src/glib/timeframe.gleam:76-78`.
////
//// What used to stand here was a circle: `desk.gleam` held a SECOND dictionary
//// `Dict(Interval, TimeframeSettings)` beside `Dict(Interval, Timeframe)`,
//// `config.gleam` held a table keyed by `"BTCUSDT_H1"`, and
//// `engine.databar_processing` took settings as a separate argument. R23
//// deletes all three. This type has no id, no dictionary, no config table and
//// no lookup function. It is NOT renamed: a name the owner never used is an
//// invention, not a decision (`docs/RULINGS.md` R23 §1, R21).
////
//// `SmaForBbm` lives here because it is one closed set with one home; its
//// constructors are written in full, prefixed by the type name (R21).

/// Which SMA series is the Bollinger centre. The centre is a name, not a
/// period: `bbm` is never computed (owner, `docs/RULINGS.md` R12).
pub type SmaForBbm {
  SmaForBbmTiny
  SmaForBbmSmall
  SmaForBbmMedium
  SmaForBbmLarge
  SmaForBbmHuge
}

/// The numbers one engine runs on. A plain value: no identity, no owner of its
/// own, no lookup. It is carried by exactly one `Timeframe`.
pub type TimeframeSettings {
  TimeframeSettings(
    sma_tiny_window_size: Int,
    sma_small_window_size: Int,
    sma_medium_window_size: Int,
    sma_large_window_size: Int,
    sma_huge_window_size: Int,
    kdj_window_size: Int,
    kdj_k_period: Int,
    kdj_m_period: Int,
    bb_multiplier: Float,
    sma_for_bbm: SmaForBbm,
    branch_exit_leaf_size: Int,
  )
}
