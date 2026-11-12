//// The design goals of the 04-13 straight line: ONE `Timeframe` module, ONE
//// pipeline, ONE `Desk` above the whole chain.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-13-PLAN.md` §6 / §8.
//// Written BEFORE the bodies (R19): these tests hold what the design MEANS,
//// not what the code happens to do. The RED run is recorded, then each `todo`
//// in `src/glibe/timeframe.gleam`, `src/glibe/desk.gleam` and
//// `src/glibe/api/sourcebar.gleam` is filled until this file is green.

import gleam/list
import gleam/option.{None, Some}
import gleam/time/timestamp.{type Timestamp}
import glibe/api/interval
import glibe/api/sourcebar
import glibe/api/symbol
import glibe/config
import glibe/desk
import glibe/indicator_settings
import glibe/timeframe
import glibe/trading/signal.{NoSignal}

/// A test clock: the same wire conversion the provider adapters use.
fn at(raw: String) -> Timestamp {
  let assert Ok(instant) = sourcebar.unix_timestamp(raw)
    as "test clock label parses"
  instant
}

/// One parameter block, carried by the `Timeframe` itself (R23).
fn settings() -> indicator_settings.TimeframeSettings {
  indicator_settings.TimeframeSettings(
    sma_tiny_window_size: 7,
    sma_small_window_size: 14,
    sma_medium_window_size: 30,
    sma_large_window_size: 60,
    sma_huge_window_size: 504,
    kdj_window_size: 7,
    kdj_k_period: 3,
    kdj_m_period: 10,
    bb_multiplier: 2.0,
    sma_for_bbm: indicator_settings.SmaForBbmSmall,
    branch_exit_leaf_size: 40,
  )
}

/// A valid OHLC source bar on an hourly boundary, so `bucket_ends` is True.
fn bar_at(raw: String, close: Float) -> sourcebar.SourceBar {
  sourcebar.SourceBar(
    timestamp: at(raw),
    open: close,
    high: close +. 1.0,
    low: close -. 1.0,
    close: close,
    volume: 10,
  )
}

/// ONE arriving bar calls the two top-level functions in order — no third
/// wrapper, no batch implementation, no replay (R38).
fn one_bar(
  tf: timeframe.Timeframe,
  raw: String,
  close: Float,
) -> timeframe.Timeframe {
  let assert Ok(gated) =
    timeframe.sourcebar_gate(tf, interval.IntervalOneHour, bar_at(raw, close))
    as "a qualified bar is admitted"
  timeframe.databar_processing(gated)
}

/// ② A QUALIFIED source bar becomes ONE whole working databar — born, not
/// folded from several source bars (R39, glib phase 42).
pub fn one_qualified_bar_is_born_whole_in_hand_test() {
  let tf = timeframe.new(settings())
  let assert Ok(gated) =
    timeframe.sourcebar_gate(
      tf,
      interval.IntervalOneHour,
      bar_at("2024-01-15 09:00:00", 100.0),
    )
    as "a bar on an hourly boundary is qualified"
  let assert Some(bar) = gated.working_databar as "one whole bar is in hand"
  assert bar.idx == 0 as "the first bar's position is 0"
  assert bar.close == 100.0 as "close is the source's close, unmodified"
  assert bar.high == 101.0 as "high is the source's high"
  assert bar.low == 99.0 as "low is the source's low"
  assert bar.volume == 10 as "volume is the source's volume"
  assert bar.signal == NoSignal as "no verdict has been written yet"
}

/// A bar whose own numbers disagree is refused with a typed reason; the
/// value it was offered to is unchanged, and nothing is repaired (R13).
pub fn an_invalid_bar_is_refused_and_changes_nothing_test() {
  let tf = timeframe.new(settings())
  let bad =
    sourcebar.SourceBar(..bar_at("2024-01-15 09:00:00", 100.0), high: 90.0)
  let assert Error(reason) =
    timeframe.sourcebar_gate(tf, interval.IntervalOneHour, bad)
    as "a high below the low is not a bar"
  assert reason == sourcebar.HighBelowLow
    as "the reason names the check that failed"
  assert tf.working_databar == None as "the offered value was left alone"
}

/// A period that has not ended is ignored and held NOWHERE: `working_databar`
/// is not a bucket accumulator (R39, glib sourcebar_gate case 2).
pub fn a_period_that_has_not_ended_is_ignored_held_nowhere_test() {
  let tf = timeframe.new(settings())
  let assert Ok(ignored) =
    timeframe.sourcebar_gate(
      tf,
      interval.IntervalFourHour,
      bar_at("2024-01-15 09:00:00", 100.0),
    )
    as "09:00 is not on a four-hour boundary"
  assert ignored == tf as "nothing was accumulated"
  assert ignored.working_databar == None as "no bucket is in hand"
}

/// ③ + ④: the pipeline finishes with the bar filed and the present empty.
pub fn databar_processing_archives_the_bar_it_was_given_test() {
  let tf = one_bar(timeframe.new(settings()), "2024-01-15 09:00:00", 100.0)
  assert list.length(tf.databar_list) == 1 as "the bar joined the history"
  assert tf.working_databar == None as "the present is empty again"
  assert timeframe.bars_listed(tf.databar_list) == 1 as "head idx + 1"
}

/// R40 / R41: every step takes and returns the `Timeframe`, and the body of
/// `databar_processing` IS that five-step pipeline in that order. No step
/// receives a bar and no bar is re-numbered on the way.
pub fn every_step_takes_and_returns_the_timeframe_test() {
  let tf = timeframe.new(settings())
  let assert Ok(gated) =
    timeframe.sourcebar_gate(
      tf,
      interval.IntervalOneHour,
      bar_at("2024-01-15 09:00:00", 100.0),
    )
    as "a qualified bar is in hand"
  let composed =
    gated
    |> timeframe.indicator
    |> timeframe.leaves
    |> timeframe.branches
    |> timeframe.strategy
    |> timeframe.working_databar_archived
  assert composed == timeframe.databar_processing(gated)
    as "the pipeline body is exactly these five steps in this order"
  let separately =
    gated
    |> timeframe.indicator
    |> timeframe.leaves
    |> timeframe.branches
    |> timeframe.strategy
  let assert Some(bar) = separately.working_databar
    as "each step left the same bar in the record"
  assert bar.idx == 0 as "no step re-numbered the bar"
}

/// The indicator step computes ON the working bar, not on a copy handed out.
pub fn indicator_step_computes_on_the_working_bar_test() {
  let tf = timeframe.new(settings())
  let assert Ok(gated) =
    timeframe.sourcebar_gate(
      tf,
      interval.IntervalOneHour,
      bar_at("2024-01-15 09:00:00", 100.0),
    )
    as "a qualified bar is in hand"
  let after = timeframe.indicator(gated)
  let assert Some(bar) = after.working_databar
    as "the computed bar is back in the record"
  assert bar.sma_tiny == 100.0
    as "the first bar's tiny SMA is its own close, not a zero"
}

/// The settled leaf is a FIELD of the present: `leaves` writes it and
/// `branches` reads it from the record, so `branches` needs no bar or leaf
/// among its arguments (owner's requirement, cleanup-audit §7.2.1).
pub fn leaves_writes_the_settled_pair_and_branches_reads_it_test() {
  let first = one_bar(timeframe.new(settings()), "2024-01-15 09:00:00", 100.0)
  let second = one_bar(first, "2024-01-15 10:00:00", 200.0)
  assert option.is_some(second.yin_leaf_settled)
    as "a rising sma_tiny settled the yin leaf, recorded as a field"
  assert list.length(second.databar_list) == 2
    as "both bars went through the same pair of functions"
  let after_branches = timeframe.branches(second)
  assert after_branches.yin_leaf_settled == second.yin_leaf_settled
    as "branches reads the pair from the record and changes no leaf"
}

/// The verdict belongs to the bar: a signal left on the `Timeframe` cannot
/// be listed or drawn. The provisional manual fields are gone (owner 10-31).
pub fn strategy_writes_the_signal_on_the_bar_test() {
  let tf = one_bar(timeframe.new(settings()), "2024-01-15 09:00:00", 100.0)
  let assert [bar, ..] = tf.databar_list as "the bar was listed"
  assert bar.signal == NoSignal as "no branch was recognised, so no verdict"
  assert signal.to_string(bar.signal) == ""
    as "the wire spelling of no signal is empty"
}

/// ④ takes NO bar: the bar it files is `timeframe.working_databar`.
pub fn archive_takes_no_bar_and_files_the_one_in_hand_test() {
  let tf = timeframe.new(settings())
  let assert Ok(gated) =
    timeframe.sourcebar_gate(
      tf,
      interval.IntervalOneHour,
      bar_at("2024-01-15 09:00:00", 100.0),
    )
    as "a qualified bar is in hand"
  let archived = timeframe.working_databar_archived(gated)
  assert archived.working_databar == None as "Some -> None"
  assert list.length(archived.databar_list) == 1 as "one bar joined the list"
  let assert [bar, ..] = archived.databar_list as "the listed bar"
  assert bar.idx == 0 as "it is the bar that was in hand"
}

/// `bars_listed` is not a counter: the head bar's position IS the count.
pub fn bars_listed_is_the_head_bars_position_plus_one_test() {
  assert timeframe.bars_listed([]) == 0 as "an empty history lists nothing"
  let first = one_bar(timeframe.new(settings()), "2024-01-15 09:00:00", 100.0)
  assert timeframe.bars_listed(first.databar_list) == 1 as "one bar listed"
  let second = one_bar(first, "2024-01-15 10:00:00", 110.0)
  assert timeframe.bars_listed(second.databar_list) == 2 as "two bars listed"
}

/// R38: a batch is the SAME pair run n times, not a second implementation.
pub fn five_arriving_bars_are_the_same_pair_run_five_times_test() {
  let arrivals = [
    #("2024-01-15 09:00:00", 100.0),
    #("2024-01-15 10:00:00", 110.0),
    #("2024-01-15 11:00:00", 120.0),
    #("2024-01-15 12:00:00", 115.0),
    #("2024-01-15 13:00:00", 130.0),
  ]
  let tf =
    list.fold(arrivals, timeframe.new(settings()), fn(acc, arrival) {
      let #(raw, close) = arrival
      one_bar(acc, raw, close)
    })
  assert list.length(tf.databar_list) == 5 as "five bars, five runs"
  assert tf.working_databar == None as "nothing is left in flight"
  let positions = list.map(tf.databar_list, fn(bar) { bar.idx })
  assert positions == [4, 3, 2, 1, 0]
    as "newest-first, each bar born knowing its position"
}

/// The backwards chain: `Desk` reads down three keys, the two `Timeframe`
/// functions run, and the recomputed value is written back up into a NEW
/// `Desk`. The old `Desk` is untouched (R33 — one top-level Value).
pub fn desk_reads_down_and_writes_the_recomputed_value_back_test() {
  let cfg = config.default_config()
  let broker = desk.broker_id("binance")
  let sym = symbol.from_string("BTCUSDT")
  let iv = interval.IntervalOneHour
  let assert Ok(before) = desk.timeframe_under(cfg.desk, broker, sym, iv)
    as "the configured hourly timeframe is reachable from the top"
  let moved = one_bar(before, "2024-01-15 09:00:00", 100.0)
  let assert Ok(new_desk) =
    desk.put_timeframe_under(cfg.desk, broker, sym, iv, moved)
    as "the write half returns a new Desk"
  let assert Ok(read_back) = desk.timeframe_under(new_desk, broker, sym, iv)
    as "the new value is reachable from the top again"
  assert read_back == moved as "the top-level Value carries the new state"
  assert list.length(read_back.databar_list) == 1 as "one bar was listed"
  let assert Ok(original) = desk.timeframe_under(cfg.desk, broker, sym, iv)
    as "the original Desk still answers the same keys"
  assert original.databar_list == [] as "the old Desk was not mutated"
}

/// A missing key reports the level that failed, with the key asked for.
pub fn a_missing_key_reports_its_own_level_test() {
  let cfg = config.default_config()
  let missing = desk.broker_id("nobody")
  let assert Error(desk.NoSuchBroker(reported)) =
    desk.put_timeframe_under(
      cfg.desk,
      missing,
      symbol.from_string("BTCUSDT"),
      interval.IntervalOneHour,
      timeframe.new(settings()),
    )
    as "an unknown broker is a typed lookup failure"
  assert reported == missing as "the error carries the key asked for"
}
