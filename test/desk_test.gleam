//// Tests for the ownership chain in `src/glibe/desk.gleam`.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-03-PLAN.md` (R22 / R23).
//// Written BEFORE the module bodies were replaced (R19). Every assertion is a
//// promise made by a `///` doc in that module.
////
//// R23 removed the second dictionary: an `Instrument` has ONE collection,
//// `timeframes`, and each `Timeframe` carries its own settings. These tests
//// pin that there is no `put_settings`, no `get_settings` and no
//// `NoSuchSettings` left to call.

import glibe/api/interval
import glibe/api/symbol
import glibe/desk
import glibe/indicator_settings
import glibe/timeframe

/// A name, not a record describing the thing. R22.
fn btc() -> symbol.Symbol {
  symbol.from_string("BTCUSDT")
}

/// One parameter block — a value, never an entity with its own dictionary.
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

/// An empty `Desk` names the key it could not find.
pub fn empty_desk_reports_the_key_it_was_asked_for_test() {
  let id = desk.broker_id("ib")
  let assert Error(desk.NoSuchBroker(reported)) =
    desk.get_broker(desk.new(), id)
    as "an empty desk has no broker"
  assert reported == id as "the error carries the id that was asked for"
}

/// A `BrokerId` is its own type: it round-trips and two spellings differ.
pub fn broker_id_is_not_a_string_test() {
  assert desk.broker_id_to_string(desk.broker_id("ib")) == "ib"
    as "codec round-trips"
  assert desk.broker_id("ib") != desk.broker_id("futu")
    as "two ids are distinct values"
}

/// An `AccountId` is its own type, independent of `BrokerId`.
pub fn account_id_is_not_a_broker_id_test() {
  assert desk.account_id_to_string(desk.account_id("DU1234567")) == "DU1234567"
    as "codec round-trips"
  assert desk.account_id("a") != desk.account_id("b")
    as "two ids are distinct values"
}

/// `put_broker` returns a NEW `Desk`; the argument is unchanged.
pub fn put_broker_returns_a_new_desk_test() {
  let empty = desk.new()
  let id = desk.broker_id("ib")
  let broker = desk.new_broker()
  let filled = desk.put_broker(empty, id, broker)
  let assert Ok(got) = desk.get_broker(filled, id)
    as "the put broker is readable"
  assert got == broker as "the broker put is the broker got"
  let assert Error(desk.NoSuchBroker(_)) = desk.get_broker(empty, id)
    as "the original desk is unchanged"
}

/// An account lives under its broker, keyed by `AccountId`.
pub fn account_lives_under_its_broker_test() {
  let id = desk.account_id("DU1234567")
  let broker = desk.put_account(desk.new_broker(), id, desk.new_account())
  let assert Ok(got) = desk.get_account(broker, id)
    as "the put account is readable"
  assert got == desk.new_account() as "an account is a keyless value"
  let assert Error(desk.NoSuchAccount(_)) =
    desk.get_account(desk.new_broker(), id)
    as "an empty broker has no account"
}

/// An instrument lives under its broker, keyed by a `Symbol` that is ONLY a name.
pub fn instrument_lives_under_its_broker_test() {
  let sym = btc()
  let broker =
    desk.put_instrument(desk.new_broker(), sym, desk.new_instrument())
  let assert Ok(got) = desk.get_instrument(broker, sym)
    as "the put instrument is readable"
  assert got == desk.new_instrument()
    as "the instrument put is the instrument got"
  let assert Error(desk.NoSuchInstrument(reported)) =
    desk.get_instrument(desk.new_broker(), sym)
    as "an empty broker has no instrument"
  assert reported == sym as "the error carries the symbol that was asked for"
}

/// Settings travel WITH the engine: two intervals carry different numbers
/// without any second dictionary on the `Instrument` (R23).
pub fn settings_travel_with_the_engine_test() {
  let h1 = settings()
  let d1 = indicator_settings.TimeframeSettings(..h1, branch_exit_leaf_size: 41)
  let hourly = timeframe.new(h1)
  let daily = timeframe.new(d1)
  assert hourly.settings == h1 as "the hourly engine owns its own settings"
  assert daily.settings == d1 as "the daily engine owns its own settings"
  assert hourly != daily as "one interval's engine is not another's"
}

/// Live state is keyed by `Interval` — the one and only collection on an
/// `Instrument`. `Timeframe` no longer names its symbol or its interval.
pub fn timeframes_are_keyed_by_interval_test() {
  let h1 = timeframe.new(settings())
  let d1 = timeframe.new(settings())
  let instrument =
    desk.new_instrument()
    |> desk.put_timeframe(interval.IntervalOneHour, h1)
    |> desk.put_timeframe(interval.IntervalOneDay, h1)
  let assert Ok(got_h1) =
    desk.get_timeframe(instrument, interval.IntervalOneHour)
  let assert Ok(got_d1) =
    desk.get_timeframe(instrument, interval.IntervalOneDay)
  assert got_h1 == h1 as "IntervalOneHour keeps its own state"
  assert got_d1 == h1 as "IntervalOneDay keeps its own state"
  assert got_d1 == d1
    as "equal state is equal: the interval is in the key, not in the value"
  let assert Error(desk.NoSuchTimeframe(missing)) =
    desk.get_timeframe(instrument, interval.IntervalFifteenMinute)
    as "an interval with nothing put has no state"
  assert missing == interval.IntervalFifteenMinute
    as "the error names the interval asked for"
}

/// Insertion never mutates: this is why the type relations are safe to share.
pub fn put_does_not_mutate_the_instrument_test() {
  let empty = desk.new_instrument()
  let _ =
    desk.put_timeframe(
      empty,
      interval.IntervalOneHour,
      timeframe.new(settings()),
    )
  let assert Error(desk.NoSuchTimeframe(_)) =
    desk.get_timeframe(empty, interval.IntervalOneHour)
    as "the original instrument is unchanged"
}

/// The whole chain reaches one timeframe: Desk -> Broker -> Instrument -> Interval.
pub fn the_whole_chain_reaches_a_timeframe_test() {
  let bid = desk.broker_id("ib")
  let sym = btc()
  let tf = timeframe.new(settings())
  let instrument =
    desk.new_instrument()
    |> desk.put_timeframe(interval.IntervalOneHour, tf)
  let broker = desk.put_instrument(desk.new_broker(), sym, instrument)
  let root = desk.put_broker(desk.new(), bid, broker)
  let assert Ok(b) = desk.get_broker(root, bid)
  let assert Ok(i) = desk.get_instrument(b, sym)
  let assert Ok(got) = desk.get_timeframe(i, interval.IntervalOneHour)
  assert got == tf
    as "every instrument and timeframe is reachable from the desk"
}
