//// Tests for the ONE stream — the design goal of plan 04-11.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-11-PLAN.md`, step 3.
//// Written BEFORE `replay.replay` had a body (R19): the `////` module doc and
//// the `///` of that function are the specification; these assertions are
//// their executable form.
////
//// R33: history and live are the same stream, and the system is already live
//// — no actor, clock, cursor or "wake up" step is being tested here.
//// R37: identity lives in the holder's key, so no address type is built.
//// R35: plain value assertions. If checking this needs a runtime, the type,
//// function or module definitions are wrong — *"简单是正确的验证码"*.

import gleam/list
import gleam/option
import gleam/time/timestamp
import glibe/api/interval
import glibe/api/sourcebar.{type SourceBar, HighBelowLow, SourceBar}
import glibe/engine
import glibe/indicator_settings
import glibe/replay
import glibe/timeframe

/// One parameter block, so a `Timeframe` can be built without inventing a
/// second settings entity (R23).
fn settings() -> indicator_settings.TimeframeSettings {
  indicator_settings.TimeframeSettings(
    sma_tiny_window_size: 7,
    sma_small_window_size: 70,
    sma_medium_window_size: 140,
    sma_large_window_size: 252,
    sma_huge_window_size: 504,
    kdj_window_size: 7,
    kdj_k_period: 3,
    kdj_m_period: 10,
    bb_multiplier: 1.99,
    sma_for_bbm: indicator_settings.SmaForBbmMedium,
    branch_exit_leaf_size: 40,
  )
}

/// A test clock built through the same wire conversion the adapters use.
fn at(raw: String) -> timestamp.Timestamp {
  let assert Ok(instant) = sourcebar.unix_timestamp(raw)
    as "test clock label parses"
  instant
}

/// One well-formed standard bar at a given instant (R28: no provider fields).
fn quote(raw: String, close_price: Float) -> SourceBar {
  SourceBar(
    timestamp: at(raw),
    open: close_price -. 0.5,
    high: close_price +. 1.0,
    low: close_price -. 1.0,
    close: close_price,
    volume: 10,
  )
}

/// **R33: with no data the system sleeps and waits.** An empty stream is not
/// a step: the very same `Timeframe` comes back.
pub fn empty_stream_returns_the_same_timeframe_test() {
  let tf = timeframe.new(settings())
  assert replay.replay(tf, interval.IntervalOneHour, []) == Ok(tf)
    as "no bars is not a step"
}

/// A bar inside a bucket only opens the working bar; no finished bar has
/// been accepted yet.
pub fn bar_inside_a_bucket_opens_a_working_bar_test() {
  let tf = timeframe.new(settings())
  let assert Ok(next) =
    replay.replay(tf, interval.IntervalOneHour, [
      quote("2024-01-15 09:30:00", 100.0),
    ])
    as "a well-formed bar is admitted"
  assert next.databar_list == [] as "nothing was accepted yet"
  assert option.is_some(next.working_databar) as "a bucket is in hand"
}

/// An hour boundary closes a bucket AND runs the whole pipeline on the
/// closed bar: a growing leaf exists afterwards, which only
/// `engine.databar_processing` creates.
pub fn bucket_boundary_runs_the_whole_pipeline_test() {
  let tf = timeframe.new(settings())
  let assert Ok(next) =
    replay.replay(tf, interval.IntervalOneHour, [
      quote("2024-01-15 09:00:00", 100.0),
    ])
    as "an hourly bucket ends on minute 00"
  assert engine.bars_accepted(next.databar_list) == 1
    as "one finished bar joined the history"
  assert option.is_none(next.working_databar)
    as "a closed bucket leaves no bar in hand"
  assert option.is_some(next.growing_yin_leaf)
    as "databar_processing grew both twins"
  let assert Ok(head) = list.first(next.databar_list)
    as "the accepted bar is readable"
  assert head.close == 100.0 as "the closed bar carries the source close"
}

/// A refused bar stops the stream and reports its position and the gate's
/// own closed-set reason (R13). Nothing after it is processed.
pub fn refused_bar_reports_position_and_reason_test() {
  let tf = timeframe.new(settings())
  let bad =
    SourceBar(
      timestamp: at("2024-01-15 10:00:00"),
      open: 100.0,
      high: 90.0,
      low: 99.0,
      close: 100.5,
      volume: 10,
    )
  assert replay.replay(tf, interval.IntervalOneHour, [
      quote("2024-01-15 09:00:00", 100.0),
      bad,
      quote("2024-01-15 11:00:00", 101.0),
    ])
    == Error(replay.BarRejected(at: 1, reason: HighBelowLow))
    as "the second bar was refused and replay stopped there"
}

/// **R33: history and live are ONE stream.** Feeding three bars in one call
/// or in two calls — a history batch, then a live arrival — gives the SAME
/// value. No cursor, clock or session is hidden in the state.
pub fn history_and_live_are_the_same_stream_test() {
  let tf = timeframe.new(settings())
  let bars = [
    quote("2024-01-15 09:30:00", 100.0),
    quote("2024-01-15 10:00:00", 101.0),
    quote("2024-01-15 10:30:00", 102.0),
  ]
  let assert Ok(one_go) = replay.replay(tf, interval.IntervalOneHour, bars)
    as "the whole stream replays"
  let assert Ok(after_history) =
    replay.replay(tf, interval.IntervalOneHour, [
      quote("2024-01-15 09:30:00", 100.0),
    ])
    as "history arrives first"
  let assert Ok(then_live) =
    replay.replay(after_history, interval.IntervalOneHour, [
      quote("2024-01-15 10:00:00", 101.0),
      quote("2024-01-15 10:30:00", 102.0),
    ])
    as "live data arrives later through the same function"
  assert one_go == then_live
    as "nothing distinguishes history from live in the state"
}

/// Several boundaries accept several finished bars, in stream order.
pub fn several_boundaries_accept_several_bars_test() {
  let tf = timeframe.new(settings())
  let assert Ok(next) =
    replay.replay(tf, interval.IntervalOneHour, [
      quote("2024-01-15 09:00:00", 100.0),
      quote("2024-01-15 10:00:00", 101.0),
      quote("2024-01-15 11:00:00", 102.0),
    ])
    as "three hourly bars replay"
  assert engine.bars_accepted(next.databar_list) == 3
    as "one finished bar per boundary"
  let assert Ok(head) = list.first(next.databar_list)
    as "the newest bar is at the head"
  assert head.close == 102.0 as "the head bar is the last source bar"
}
