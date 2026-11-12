//// Empty skeleton tests. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// R42 07:39 (owner, verbatim): *"最初的空架子，unit test 跟对应的 type fn
//// 也都一样是空的，仅仅要求将 in out types 搞对；这一步gleam test or
//// gleam build就已经能发现设计问题"*.
////
//// So there are NO assertions here and NO call to a `todo` body. Each test
//// binds a function to an explicitly annotated type: if a signature drifts
//// away from the design, the compiler rejects this file. At this stage
//// THAT is the test. Real assertions arrive together with the bodies.
////
//// R19 status: skeleton. No working line here.

import gleeunit
import glibe/api/interval.{type Interval}
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection}
import glibe/api/symbol.{type Symbol}
import glibe/binance/kline.{type Kline}
import glibe/config
import glibe/databar.{type DataBar}
import glibe/desk.{type BrokerId, type Desk, type LookupError}
import glibe/indicator_settings.{type TimeframeSettings}
import glibe/timeframe.{type Timeframe}

pub fn main() {
  gleeunit.main()
}

/// R40 / R41: every step of the straight line is ONE shape, so the body of
/// `databar_processing` can be a single pipe. A step that starts taking a
/// bar, or returning anything but `Timeframe`, fails to compile here.
pub fn pipeline_steps_shape_test() {
  let _steps: List(fn(Timeframe) -> Timeframe) = [
    timeframe.indicator,
    timeframe.leaves,
    timeframe.branches,
    timeframe.strategy,
    timeframe.working_databar_archived,
  ]
  Nil
}

/// R40: the whole line is itself one `fn(Timeframe) -> Timeframe` step.
pub fn databar_processing_shape_test() {
  let _line: fn(Timeframe) -> Timeframe = timeframe.databar_processing
  Nil
}

/// R39 / R23: the gate receives one bar and the interval key the caller
/// already holds; it never asks the Timeframe for its own identity.
pub fn sourcebar_gate_shape_test() {
  let _gate: fn(Timeframe, Interval, SourceBar) ->
    Result(Timeframe, SourceBarRejection) = timeframe.sourcebar_gate
  Nil
}

/// R39 / R42: one qualified SourceBar is born whole into one DataBar at
/// the SOURCE boundary, and only there.
pub fn birth_shape_test() {
  let _birth: fn(SourceBar, Int) -> DataBar = sourcebar.to_databar
  Nil
}

/// R8 / R13: the price checker refuses with a typed reason, never a String.
pub fn price_checker_shape_test() {
  let _check: fn(SourceBar) -> Result(SourceBar, SourceBarRejection) =
    sourcebar.validate
  Nil
}

/// R23: settings travel WITH the engine; they are not a second dictionary.
pub fn timeframe_birth_shape_test() {
  let _new: fn(TimeframeSettings) -> Timeframe = timeframe.new
  Nil
}

/// R39: `bars_listed` counts the archived list, not an "accepted" set.
pub fn bars_listed_shape_test() {
  let _count: fn(List(DataBar)) -> Int = timeframe.bars_listed
  Nil
}

/// R42 / R33: the whole chain is read down and written back as one Value,
/// with the keys supplied by the caller.
pub fn desk_chain_shape_test() {
  let _read: fn(Desk, BrokerId, Symbol, Interval) ->
    Result(Timeframe, LookupError) = desk.timeframe_under
  let _write: fn(Desk, BrokerId, Symbol, Interval, Timeframe) ->
    Result(Desk, LookupError) = desk.put_timeframe_under
  Nil
}

/// R33: `default_config()` returns the ONE top-level Value, with nothing
/// above it — not an `AppConfig`.
pub fn config_shape_test() {
  let _config: fn() -> Desk = config.default_config
  Nil
}

/// R28 / R27: each provider has its own native shape and its own one exit
/// into the standard layer; the standard layer is the only meeting point.
pub fn provider_exit_shape_test() {
  let _exit: fn(Kline) -> Result(SourceBar, Nil) = kline.to_sourcebar
  Nil
}
