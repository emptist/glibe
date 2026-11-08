//// Tests for the ownership chain in `src/glibe/desk.gleam`.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-01-PLAN.md`.
//// Written BEFORE the module's `todo` bodies were replaced (R19). Every
//// assertion is a promise made by a `///` doc in that module.

import glibe/api/asset
import glibe/api/exchange
import glibe/api/interval
import glibe/api/symbol
import glibe/desk
import glibe/indicator_settings
import glibe/timeframe

/// One instrument identity, built the way `config.gleam` spells it.
fn btc() -> symbol.Symbol {
  symbol.Symbol(
    market_id: "binance_spot_crypto",
    asset_id: "BTC",
    market_symbol: "BTCUSDT",
    base_asset: asset.AssetRef(id: "BTC", name: "Bitcoin", class: asset.Crypto),
    quote_asset: asset.AssetRef(id: "USDT", name: "Tether", class: asset.Crypto),
    available_brokers: ["binance"],
    available_data_providers: ["binance"],
    primary_execution_venue: "binance",
  )
}

/// One per-interval settings value.
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

/// An instrument lives under its broker, keyed by `Symbol`.
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

/// Settings are keyed by `Interval`, so `IntervalOneHour` and `IntervalOneDay` cannot be confused.
pub fn settings_are_keyed_by_interval_test() {
  let h1 = settings()
  let d1 = indicator_settings.TimeframeSettings(..h1, branch_exit_leaf_size: 41)
  let instrument =
    desk.new_instrument()
    |> desk.put_settings(interval.IntervalOneHour, h1)
    |> desk.put_settings(interval.IntervalOneDay, d1)
  let assert Ok(got_h1) =
    desk.get_settings(instrument, interval.IntervalOneHour)
  let assert Ok(got_d1) = desk.get_settings(instrument, interval.IntervalOneDay)
  assert got_h1 == h1 as "IntervalOneHour keeps its own settings"
  assert got_d1 == d1 as "IntervalOneDay keeps its own settings"
  let assert Error(desk.NoSuchSettings(missing)) =
    desk.get_settings(instrument, interval.IntervalFifteenMinute)
    as "an interval with nothing put has no settings"
  assert missing == interval.IntervalFifteenMinute
    as "the error names the interval asked for"
}

/// Live state is keyed by `Interval` too — this is the list that had no home.
pub fn timeframes_are_keyed_by_interval_test() {
  let h1 = timeframe.new(btc(), interval.IntervalOneHour, exchange.Crypto)
  let d1 = timeframe.new(btc(), interval.IntervalOneDay, exchange.Crypto)
  let instrument =
    desk.new_instrument()
    |> desk.put_timeframe(interval.IntervalOneHour, h1)
    |> desk.put_timeframe(interval.IntervalOneDay, d1)
  let assert Ok(got_h1) =
    desk.get_timeframe(instrument, interval.IntervalOneHour)
  let assert Ok(got_d1) =
    desk.get_timeframe(instrument, interval.IntervalOneDay)
  assert got_h1 == h1 as "IntervalOneHour keeps its own state"
  assert got_d1 == d1 as "IntervalOneDay keeps its own state"
  assert got_h1 != got_d1 as "one interval per key"
  let assert Error(desk.NoSuchTimeframe(missing)) =
    desk.get_timeframe(instrument, interval.IntervalFifteenMinute)
    as "an interval with nothing put has no state"
  assert missing == interval.IntervalFifteenMinute
    as "the error names the interval asked for"
}

/// Insertion never mutates: this is why the type relations are safe to share.
pub fn put_does_not_mutate_the_instrument_test() {
  let empty = desk.new_instrument()
  let _ = desk.put_settings(empty, interval.IntervalOneHour, settings())
  let assert Error(desk.NoSuchSettings(_)) =
    desk.get_settings(empty, interval.IntervalOneHour)
    as "the original instrument is unchanged"
}

/// The whole chain reaches one timeframe: Desk -> Broker -> Instrument -> Interval.
pub fn the_whole_chain_reaches_a_timeframe_test() {
  let bid = desk.broker_id("ib")
  let sym = btc()
  let tf = timeframe.new(sym, interval.IntervalOneHour, exchange.Crypto)
  let instrument =
    desk.new_instrument()
    |> desk.put_settings(interval.IntervalOneHour, settings())
    |> desk.put_timeframe(interval.IntervalOneHour, tf)
  let broker = desk.put_instrument(desk.new_broker(), sym, instrument)
  let root = desk.put_broker(desk.new(), bid, broker)
  let assert Ok(b) = desk.get_broker(root, bid)
  let assert Ok(i) = desk.get_instrument(b, sym)
  let assert Ok(got) = desk.get_timeframe(i, interval.IntervalOneHour)
  assert got == tf
    as "every instrument and timeframe is reachable from the desk"
}
