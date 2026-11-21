//// The settings file. Gleam IS the config: no external data file, no parser,
//// no `panic` on an unknown spelling. Implements the plan in
//// `.planning/phases/02-domain-stream/02-01-PLAN.md` (doc-first; written
//// before this code) and the 2026-11-20 correction to `docs/RULINGS.md` R46
//// (owner verbatim: *"R46 作废了 settings 容器，这是错的，config.gleam is a
//// must, see glib for some of the use case"*). The O(n²) ban the parameters
//// feed into is carried by the same plan, sourced to `glib/docs/DESIGN.md:1427`.
////
//// WHAT THIS IS (against the R46 misreading): `config.gleam` is the settings
//// file itself. It holds the indicator numbers as Gleam literals, each under
//// the type that owns it, and assembles one interval's values into
//// `IntervalSettings`. That record is passed as a PARAMETER to the indicator
//// computation — `glib/indicator.gleam:35-39`: `compute_bar(databar,
//// databar_list, settings)`. It is NOT a field stuffed into `Timeframe`. R46
//// deleted the AI-invented empty shell `TimeframeSettings` + `Timeframe.settings`
//// + `new()` (owner: *"我不知道是什么玩意"*); it did NOT delete this file. The
//// two coexist in glib, where config is imported by sma / bollinger / kdj /
//// indicator (`glib/sma.gleam:11`, `bollinger.gleam:47`, `kdj.gleam:11`,
//// `indicator.gleam:24`).
////
//// OWNERSHIP (glib `config.gleam:1-51`): every number stated once, under its
//// owner; the two per-interval tables (`sma_for_bbm`, `branch_exit_leaf_size`)
//// are keyed by `Interval` because that is what they vary by. A number or a
//// mapping the system needs belongs in the module that owns it (sma / bollinger
//// / kdj / leaf / branch / timeframe / sourcebar), NOT here. This module imports
//// no engine module — only stdlib and `glibe/api/interval`. `validate` checks
//// COMPLETENESS (every interval present), never truth.
////
//// SCOPE (R26 / R32): this file carries the indicator + structure parameters —
//// the use case owner pointed at. The market / broker / provider catalogues of
//// glib's `Settings` need domain types not yet present in glibe's active `src/`;
//// they are a different consumer and are NOT invented here.
////
//// R19 gdltdd: `////` → types → `///` + annotated signatures → `todo` → tests
//// RED → one body at a time to GREEN. Every code file follows this protocol.

import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import glibe/api/interval.{
  type Interval, IntervalFifteenMinute, IntervalFourHour, IntervalOneDay,
  IntervalOneHour, IntervalOneMinute, IntervalOneMonth, IntervalOneWeek,
  IntervalThirtyMinute, IntervalThreeMinute,
}

/// Which of the five simple moving averages a setting or a bar names. A closed
/// set (R13): adding a series makes every incomplete `case` a compile error.
/// Mirrors glib `config.gleam:91-97`; the constructors carry the type name (R21).
pub type SmaSeries {
  SmaTiny
  SmaSmall
  SmaMedium
  SmaLarge
  SmaHuge
}

/// The indicator's own numbers — one block for every interval and market. The
/// five SMA windows, the four KDJ numbers, the Bollinger multiplier, and the
/// one indicator setting that varies by interval (`sma_for_bbm`, keyed by
/// `Interval`). Mirrors glib `config.gleam:109-130`; values are sourced there
/// (owner's idib/seib), not invented.
pub type IndicatorSettings {
  IndicatorSettings(
    sma_tiny_window_size: Int,
    sma_small_window_size: Int,
    sma_medium_window_size: Int,
    sma_large_window_size: Int,
    sma_huge_window_size: Int,
    kdj_window_size: Int,
    kdj_k_period: Int,
    kdj_d_period: Int,
    kdj_m_period: Int,
    bb_multiplier: Float,
    sma_for_bbm: Dict(Interval, SmaSeries),
  )
}

/// The numbers owned by structures, not by any indicator or interval. One item
/// today: the leaf size at which a branch's `exit_idx` is written (glib
/// `config.gleam:136-144`), keyed by `Interval` because it varies there.
pub type StructureSettings {
  StructureSettings(branch_exit_leaf_size: Dict(Interval, Int))
}

/// What a caller of `for_interval` gets: the constants plus the two per-interval
/// items read at one key. This is the record passed as a PARAMETER to the
/// indicator computation; it is not held by `Timeframe` (R46 correction above).
pub type IntervalSettings {
  IntervalSettings(
    sma_tiny_window_size: Int,
    sma_small_window_size: Int,
    sma_medium_window_size: Int,
    sma_large_window_size: Int,
    sma_huge_window_size: Int,
    kdj_window_size: Int,
    kdj_k_period: Int,
    kdj_d_period: Int,
    kdj_m_period: Int,
    bb_multiplier: Float,
    sma_for_bbm: SmaSeries,
    branch_exit_leaf_size: Int,
  )
}

/// A per-interval table that misses an interval, or a lookup at an absent key.
/// Domain errors carry context (core §6), never `Error(String)`.
pub type SettingsError {
  IncompleteTable(String, List(Interval))
  UnknownInterval(Interval, String, List(Interval))
}

/// The whole settings, written once as values. Numbers mirror glib
/// `config.gleam:216-294`: SMA 7/70/140/252/504, KDJ 7/3/2/10, bb 1.99;
/// `sma_for_bbm` medium for sub-monthly, small for week, tiny for month;
/// `branch_exit_leaf_size` 40 down to day, 8 week, 2 month. Interval keys are
/// glibe's nine full names (R21), not glib's wire-code constructors.
pub fn default_settings() -> Settings {
  let indicators =
    IndicatorSettings(
      sma_tiny_window_size: 7,
      sma_small_window_size: 70,
      sma_medium_window_size: 140,
      sma_large_window_size: 252,
      sma_huge_window_size: 504,
      kdj_window_size: 7,
      kdj_k_period: 3,
      kdj_d_period: 2,
      kdj_m_period: 10,
      bb_multiplier: 1.99,
      // The family rule: medium for minute/hour/day, small for week, tiny for
      // month (glib config.gleam:239-255). This is the one indicator setting
      // that varies by interval; it is a name of an already-computed series.
      sma_for_bbm: dict.from_list([
        #(IntervalOneMinute, SmaMedium),
        #(IntervalThreeMinute, SmaMedium),
        #(IntervalFifteenMinute, SmaMedium),
        #(IntervalThirtyMinute, SmaMedium),
        #(IntervalOneHour, SmaMedium),
        #(IntervalFourHour, SmaMedium),
        #(IntervalOneDay, SmaMedium),
        #(IntervalOneWeek, SmaSmall),
        #(IntervalOneMonth, SmaTiny),
      ]),
    )
  let structures =
    StructureSettings(
      // 40 down to day, 8 week, 2 month (glib config.gleam:259-274). The
      // leaf size at which a branch's exit_idx is written.
      branch_exit_leaf_size: dict.from_list([
        #(IntervalOneMinute, 40),
        #(IntervalThreeMinute, 40),
        #(IntervalFifteenMinute, 40),
        #(IntervalThirtyMinute, 40),
        #(IntervalOneHour, 40),
        #(IntervalFourHour, 40),
        #(IntervalOneDay, 40),
        #(IntervalOneWeek, 8),
        #(IntervalOneMonth, 2),
      ]),
    )
  Settings(indicators: indicators, structures: structures)
}

// Module note (not an item doc): this tree has no `is_product_version` flag —
// R33 retired the runtime test steps that flag gated in glib
// (`config.gleam:62-86`). Recorded here only so its absence is not mistaken for
// an omission. Kept as `//` so `gleam docs` does not attach it to `for_interval`.
/// One interval's settings, read from a caller-supplied `Settings`. The only
/// way to obtain `IntervalSettings` from a `Settings`; no fabricated fallback.
pub fn for_interval(
  settings: Settings,
  interval: Interval,
) -> Result(IntervalSettings, SettingsError) {
  use sma_for_bbm <- result.try(at_interval(
    settings.indicators.sma_for_bbm,
    interval,
    "indicators.sma_for_bbm",
  ))
  use branch_exit_leaf_size <- result.try(at_interval(
    settings.structures.branch_exit_leaf_size,
    interval,
    "structures.branch_exit_leaf_size",
  ))
  let i = settings.indicators
  Ok(IntervalSettings(
    sma_tiny_window_size: i.sma_tiny_window_size,
    sma_small_window_size: i.sma_small_window_size,
    sma_medium_window_size: i.sma_medium_window_size,
    sma_large_window_size: i.sma_large_window_size,
    sma_huge_window_size: i.sma_huge_window_size,
    kdj_window_size: i.kdj_window_size,
    kdj_k_period: i.kdj_k_period,
    kdj_d_period: i.kdj_d_period,
    kdj_m_period: i.kdj_m_period,
    bb_multiplier: i.bb_multiplier,
    sma_for_bbm: sma_for_bbm,
    branch_exit_leaf_size: branch_exit_leaf_size,
  ))
}

/// The file-free entry point: read one interval's settings from the literals.
pub fn for_interval_default(
  interval: Interval,
) -> Result(IntervalSettings, SettingsError) {
  for_interval(default_settings(), interval)
}

/// Read one key out of one per-interval table; a miss names the table and the
/// intervals it does have.
fn at_interval(
  table: Dict(Interval, value),
  interval: Interval,
  item: String,
) -> Result(value, SettingsError) {
  case dict.get(table, interval) {
    Error(_) ->
      Error(UnknownInterval(
        interval,
        item,
        list.filter(interval.all(), present(table)),
      ))
    Ok(value) -> Ok(value)
  }
}

/// The present interval keys in the enum's order, not the dict's hash order.
fn present(table: Dict(Interval, value)) -> fn(Interval) -> Bool {
  fn(each) { dict.get(table, each) |> result.is_ok }
}

/// A table over intervals is total or it is wrong — the enum says which
/// intervals exist. Load-time check (called from a test), completeness only.
pub fn validate(settings: Settings) -> Result(Nil, SettingsError) {
  use _ <- result.try(covers_all(
    settings.indicators.sma_for_bbm,
    "indicators.sma_for_bbm",
  ))
  use _ <- result.try(covers_all(
    settings.structures.branch_exit_leaf_size,
    "structures.branch_exit_leaf_size",
  ))
  Ok(Nil)
}

/// A table over intervals is total or it is wrong; this is what makes the check
/// happen at `validate`.
fn covers_all(
  table: Dict(Interval, value),
  item: String,
) -> Result(Nil, SettingsError) {
  let missing =
    list.filter(interval.all(), fn(each) {
      dict.get(table, each) |> result.is_error
    })
  case missing {
    [] -> Ok(Nil)
    _ -> Error(IncompleteTable(item, missing))
  }
}

/// What a caller prints when a table is incomplete or a lookup misses.
pub fn describe_error(error: SettingsError) -> String {
  case error {
    IncompleteTable(item, missing) ->
      "\""
      <> item
      <> "\" does not cover every interval. Missing: "
      <> string.join(list.map(missing, interval.to_string), ", ")
    UnknownInterval(interval, item, known) ->
      "no \""
      <> interval.to_string(interval)
      <> "\" under \""
      <> item
      <> "\". Known: "
      <> string.join(list.map(known, interval.to_string), ", ")
  }
}

/// Top-level settings value: the indicator block and the structure block.
pub type Settings {
  Settings(indicators: IndicatorSettings, structures: StructureSettings)
}
