//// Empty skeleton tests. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// R42 07:39 (owner, verbatim): *"最初的空架子，unit test 跟对应的 type fn
//// 也都一样是空的，仅仅要求将 in out types 搞对；这一步gleam test or
//// gleam build就已经能发现设计问题"*.
////
//// The shape tests bind a function to an explicitly annotated type: if a
//// signature drifts away from the design, the compiler rejects this file.
//// Real assertions arrive together with the bodies (R19); the first one,
//// `binance_kline_to_sourcebar_test`, arrived 2026-11-14 with the first
//// filled body.
////
//// R19 status: one assertion live; the remaining tests still pin types only.

import gleam/option.{type Option}
import gleam/time/timestamp
import gleeunit
import glibe/account.{type Account}
import glibe/api/interval.{type Interval}
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection}
import glibe/api/symbol.{type Symbol}
import glibe/binance/kline.{type BinanceKline}
import glibe/broker.{type Broker}
import glibe/databar.{type DataBar}
import glibe/desk.{type Desk}
import glibe/ib/sourcebar as ib_sourcebar
import glibe/id.{type AccountId, type BrokerId}
import glibe/instrument.{type Instrument}
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

/// R39: `bars_listed` counts the archived list, not an "accepted" set.
pub fn bars_listed_shape_test() {
  let _count: fn(List(DataBar)) -> Int = timeframe.bars_listed
  Nil
}

/// R42 / R50: EACH level owns the read / write pair of the ONE Dict it
/// holds. A function that crosses from `Desk` straight down to `Timeframe`
/// does not belong to any level, so it does not exist (R50 / R38).
pub fn chain_levels_shape_test() {
  let _desk_read: fn(Desk, BrokerId) -> Result(Broker, Nil) = desk.get_broker
  let _desk_write: fn(Desk, BrokerId, Broker) -> Desk = desk.put_broker
  let _broker_instrument_read: fn(Broker, Symbol) -> Result(Instrument, Nil) =
    broker.get_instrument
  let _broker_instrument_write: fn(Broker, Symbol, Instrument) -> Broker =
    broker.put_instrument
  let _broker_account_read: fn(Broker, AccountId) -> Result(Account, Nil) =
    broker.get_account
  let _broker_account_write: fn(Broker, AccountId, Account) -> Broker =
    broker.put_account
  let _instrument_read: fn(Instrument, Interval) -> Result(Timeframe, Nil) =
    instrument.get_timeframe
  let _instrument_write: fn(Instrument, Interval, Timeframe) -> Instrument =
    instrument.put_timeframe
  Nil
}

/// R50 / R13: the ONLY ways to build the two opaque keys live in the same
/// module as the keys. Measured: an `opaque` constructor used from another
/// module is `error: Use of private value`.
pub fn identity_shape_test() {
  let _broker_key: fn(String) -> BrokerId = id.broker_id
  let _account_key: fn(String) -> AccountId = id.account_id
  Nil
}

/// R28 / R27: each provider has its own native shape and its own one exit
/// into the standard layer; the standard layer is the only meeting point.
pub fn provider_exit_shape_test() {
  let _exit: fn(BinanceKline) -> Result(SourceBar, Nil) = kline.to_sourcebar
  Nil
}

/// Owner 2026-11-13: IB serves ONLY five seconds, so IB's own module
/// accumulates ONE arriving bar at a time into ONE
/// `growing_target_sourcebar`, with the three states of `working_databar`.
/// Nine target grades — one per `Interval` constructor — and no `List` of
/// saved bars. The target grade is in the FUNCTION NAME, so no `Interval`
/// parameter can claim a grade that disagrees with the bars in hand.
/// The compiler checks all nine shapes here.
pub fn ib_composition_shape_test() {
  let _one_minute: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_minute
  let _three_minute: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_three_minute
  let _fifteen_minute: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_fifteen_minute
  let _thirty_minute: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_thirty_minute
  let _one_hour: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_hour
  let _four_hour: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_four_hour
  let _one_day: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_day
  let _one_week: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_week
  let _one_month: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_month
  Nil
}

/// Owner 2026-11-13: composition is DISPATCHED at the `Instrument` layer,
/// because the `Interval` key lives there and `Instrument` knows which
/// timeframe gets which grade. It reads that key's
/// `Timeframe.growing_target_sourcebar`, calls ONE `five_second_to_*`,
/// and writes the recomputed `Instrument` back. ONE arriving bar in, ONE
/// recomputed Value out, at most ONE finished standard bar emitted.
pub fn instrument_composition_shape_test() {
  let _dispatch: fn(Instrument, Interval, ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Instrument) = instrument.compose_ib_realtime_bar
  Nil
}

/// R28 / R27: one native Binance kline becomes the standard bar of THAT SAME
/// grade. The grade is read off the variant, never handed in by a caller. The
/// absolute instant and OHLCV are carried across; the provider-only fields
/// stay on the native value and reach no consumer. Binance's own wire shape is
/// `GET /api/v3/klines` (12 fields, in order): Open time, Open, High, Low,
/// Close, Volume, Close time, Quote asset volume, Number of trades, Taker buy
/// base asset volume, Taker buy quote asset volume, Ignore.
pub fn binance_kline_to_sourcebar_test() {
  let instant = timestamp.from_unix_seconds(1_499_040_000)
  let native =
    kline.BinanceKlineOneMinute(
      open_time: instant,
      open: 0.0163479,
      high: 0.8,
      low: 0.015758,
      close: 0.015771,
      volume: 148_976.11427815,
      close_time: timestamp.from_unix_seconds(1_499_644_799),
      quote_asset_volume: 2434.19055334,
      number_of_trades: 308,
      taker_buy_base_asset_volume: 1756.87402397,
      taker_buy_quote_asset_volume: 28.46694368,
      ignore: "0",
    )
  let assert Ok(bar) = kline.to_sourcebar(native)
  assert bar
    == sourcebar.SourceBarOneMinute(
      timestamp: instant,
      open: 0.0163479,
      high: 0.8,
      low: 0.015758,
      close: 0.015771,
      volume: 148_976,
    )
    as "same grade; the absolute instant and OHLCV are carried across"
}
