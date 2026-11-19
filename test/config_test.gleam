//// Config tests. Implements the 2026-11-20 correction to docs/RULINGS.md R46
//// and active `src/glibe/config.gleam` (owner: *"config.gleam is a must"*).
//// Numbers asserted here are the sourced values from glib `config.gleam:216-294`
//// (owner's idib/seib), re-keyed to glibe's nine full-name Intervals (R21).
//// gdltdd: these assertions are RED while config bodies are `todo`, then
//// GREEN one body at a time.

import gleam/dict
import gleam/list
import gleam/string
import glibe/api/interval
import glibe/config

/// The nine intervals are stated once and round-trip through the wire codec.
/// A tenth constructor makes `to_string`/`from_string` fail to compile, which
/// is what keeps this list (and config's completeness check) honest.
pub fn all_intervals_round_trip_test() {
  assert list.length(interval.all()) == 9
  list.each(interval.all(), fn(each) {
    assert interval.from_string(interval.to_string(each)) == Ok(each)
  })
  Nil
}

/// default_settings carries the sourced window numbers, not invented ones
/// (glib config.gleam:218-238).
pub fn default_settings_window_numbers_test() {
  let s = config.default_settings()
  assert s.indicators.sma_tiny_window_size == 7
  assert s.indicators.sma_small_window_size == 70
  assert s.indicators.sma_medium_window_size == 140
  assert s.indicators.sma_large_window_size == 252
  assert s.indicators.sma_huge_window_size == 504
  assert s.indicators.kdj_window_size == 7
  assert s.indicators.kdj_k_period == 3
  assert s.indicators.kdj_d_period == 2
  assert s.indicators.kdj_m_period == 10
  assert s.indicators.bb_multiplier == 1.99
  Nil
}

/// The two per-interval tables cover all nine intervals (glib config.gleam:
/// 239-275), keyed by glibe's full-name Intervals.
pub fn default_settings_per_interval_tables_test() {
  let s = config.default_settings()
  assert dict.get(s.indicators.sma_for_bbm, interval.IntervalOneDay)
    == Ok(config.SmaMedium)
  assert dict.get(s.indicators.sma_for_bbm, interval.IntervalOneWeek)
    == Ok(config.SmaSmall)
  assert dict.get(s.indicators.sma_for_bbm, interval.IntervalOneMonth)
    == Ok(config.SmaTiny)
  assert dict.get(s.structures.branch_exit_leaf_size, interval.IntervalOneDay)
    == Ok(40)
  assert dict.get(s.structures.branch_exit_leaf_size, interval.IntervalOneWeek)
    == Ok(8)
  assert dict.get(s.structures.branch_exit_leaf_size, interval.IntervalOneMonth)
    == Ok(2)
  Nil
}

/// for_interval reads the two tables at the requested key and assembles one
/// IntervalSettings — the record passed as a PARAMETER to compute_bar.
pub fn for_interval_reads_tables_at_key_test() {
  let s = config.default_settings()
  let assert Ok(day) = config.for_interval(s, interval.IntervalOneDay)
  assert day.sma_for_bbm == config.SmaMedium
  assert day.branch_exit_leaf_size == 40
  assert day.sma_medium_window_size == 140
  let assert Ok(week) = config.for_interval(s, interval.IntervalOneWeek)
  assert week.sma_for_bbm == config.SmaSmall
  assert week.branch_exit_leaf_size == 8
  Nil
}

/// for_interval_default is the file-free entry point: same values as reading
/// default_settings explicitly.
pub fn for_interval_default_matches_test() {
  let assert Ok(d) = config.for_interval_default(interval.IntervalOneDay)
  let assert Ok(e) =
    config.for_interval(config.default_settings(), interval.IntervalOneDay)
  assert d == e
  Nil
}

/// validate is completeness only: a full table is Ok; one missing an interval
/// names the item and the missing key.
pub fn validate_detects_incomplete_table_test() {
  assert config.validate(config.default_settings()) == Ok(Nil)
  let partial =
    config.Settings(
      indicators: config.IndicatorSettings(
        ..config.default_settings().indicators,
        sma_for_bbm: dict.from_list([
          #(interval.IntervalOneMinute, config.SmaTiny),
        ]),
      ),
      structures: config.default_settings().structures,
    )
  case config.validate(partial) {
    Error(config.IncompleteTable(item, missing)) -> {
      assert item == "indicators.sma_for_bbm"
      assert list.contains(missing, interval.IntervalOneDay)
      assert !list.contains(missing, interval.IntervalOneMinute)
    }
    _ -> panic as "validate must reject a partial per-interval table"
  }
  Nil
}

/// describe_error names the table and the offending intervals — loud and
/// actionable, never Error(String).
pub fn describe_error_names_table_test() {
  let err =
    config.IncompleteTable("structures.branch_exit_leaf_size", [
      interval.IntervalOneWeek,
    ])
  let msg = config.describe_error(err)
  assert string.contains(msg, "structures.branch_exit_leaf_size")
  assert string.contains(msg, "1wk")
  Nil
}

/// An interval absent from a table reports UnknownInterval with the known keys.
pub fn for_interval_unknown_key_test() {
  let partial =
    config.Settings(
      indicators: config.IndicatorSettings(
        ..config.default_settings().indicators,
        sma_for_bbm: dict.from_list([
          #(interval.IntervalOneMinute, config.SmaTiny),
        ]),
      ),
      structures: config.default_settings().structures,
    )
  case config.for_interval(partial, interval.IntervalOneHour) {
    Error(config.UnknownInterval(interval, item, known)) -> {
      assert interval == interval.IntervalOneHour
      assert item == "indicators.sma_for_bbm"
      assert list.contains(known, interval.IntervalOneMinute)
    }
    _ -> panic as "for_interval must reject an absent interval key"
  }
  Nil
}
