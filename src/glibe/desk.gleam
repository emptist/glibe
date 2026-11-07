//// The ownership root — where every instrument and every timeframe lives.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-01-PLAN.md`.
//// Ruling: `docs/RULINGS.md` R20.
////
//// Ownership chain, top to bottom:
////   Desk -> Broker -> Instrument -> Interval -> settings / state
////
//// `config.gleam` currently holds two parallel lists keyed by composite
//// strings such as `"BTCUSDT_H1"`:
////   `symbols: List(#(String, symbol.Symbol))` and
////   `timeframe_settings: List(#(String, indicator_settings.TimeframeSettings))`.
//// One `String` carries TWO facts (which instrument, which interval), so the
//// compiler cannot tell them apart and neither list has an owner. This module
//// gives both facts their own type and their own key: `Symbol` in
//// `Broker.instruments`, `Interval` in `Instrument.settings` and in
//// `Instrument.timeframes`.
////
//// Identity is a key, not a field: `Broker`, `Instrument` and `Account` never
//// store their own id. `BrokerId`, `AccountId` and `Symbol` are the dict keys.
//// The type relations ARE the consumers — a `Dict(BrokerId, Broker)` field is
//// a compile-time use of `Broker`, so none of these values is orphaned.
////
//// Open, deliberately not fixed here: `timeframe.gleam`'s `Timeframe` still
//// carries its own `symbol` and `interval` fields, so a dict key and its value
//// can disagree. Making that record keyless is a separate architectural change,
//// already recorded in `docs/REVIEW_ROUND5.md` under "Still a design debt".
//// `config.gleam` is NOT migrated in this plan — the home exists first.
////
//// This module was written documentation-first: `////`, then types, then
//// `///` + annotated signatures + `todo` bodies, then `test/desk_test.gleam`,
//// and only then were the bodies filled. See R19 in `docs/RULINGS.md`.

import gleam/dict.{type Dict}
import glibe/api/interval.{type Interval}
import glibe/api/symbol.{type Symbol}
import glibe/indicator_settings.{type TimeframeSettings}
import glibe/timeframe.{type Timeframe}

/// The identity of a broker. Opaque, so a `String` is not a `BrokerId`.
/// The desk holds it as the key of `Desk.brokers`; the broker never stores it.
pub opaque type BrokerId {
  BrokerId(String)
}

/// The identity of an account. Opaque, so a `String` is not an `AccountId`.
/// The broker holds it as the key of `Broker.accounts`.
pub opaque type AccountId {
  AccountId(String)
}

/// One lookup failed. One variant per business-domain failure, each carrying
/// the key that was asked for — never `Error(String)`.
pub type LookupError {
  NoSuchBroker(BrokerId)
  NoSuchAccount(AccountId)
  NoSuchInstrument(Symbol)
  NoSuchSettings(Interval)
  NoSuchTimeframe(Interval)
}

/// A keyless account. Balances and positions are not invented here; the
/// account's identity is the `AccountId` key the broker holds.
pub type Account {
  Account
}

/// One instrument: its per-interval settings and its per-interval state.
/// The `Symbol` key in `Broker.instruments` is its identity, not a field.
/// Two dicts, not one, because settings are configuration and timeframes are
/// live state: they are populated at different times and have different
/// lifetimes.
pub type Instrument {
  Instrument(
    settings: Dict(Interval, TimeframeSettings),
    timeframes: Dict(Interval, Timeframe),
  )
}

/// A broker owns the instruments it trades and the accounts it is responsible
/// for. Both are keyed; the broker itself is keyless.
pub type Broker {
  Broker(
    instruments: Dict(Symbol, Instrument),
    accounts: Dict(AccountId, Account),
  )
}

/// The root of the chain. Every instrument and every timeframe in the running
/// system is reachable from here. A dashboard renders a VIEW of this value;
/// the `Desk` is the model, not the screen. That is why it is `Desk`, the
/// trading-desk term already used in `glib/src/glib/desk.gleam`, and not
/// `Deck` (a slide deck).
pub type Desk {
  Desk(brokers: Dict(BrokerId, Broker))
}

/// Make a `BrokerId` from the spelling used in configuration.
pub fn broker_id(value: String) -> BrokerId {
  BrokerId(value)
}

/// Make an `AccountId` from the spelling used in configuration.
pub fn account_id(value: String) -> AccountId {
  AccountId(value)
}

/// The configuration / CSV spelling of a `BrokerId`. The only place the
/// wrapper is opened for display.
pub fn broker_id_to_string(id: BrokerId) -> String {
  let BrokerId(value) = id
  value
}

/// The configuration / CSV spelling of an `AccountId`. The only place the
/// wrapper is opened for display.
pub fn account_id_to_string(id: AccountId) -> String {
  let AccountId(value) = id
  value
}

/// An empty `Desk`: no brokers, therefore no instruments and no timeframes.
pub fn new() -> Desk {
  Desk(brokers: dict.new())
}

/// An empty `Broker`: no instruments and no accounts.
pub fn new_broker() -> Broker {
  Broker(instruments: dict.new(), accounts: dict.new())
}

/// An empty `Instrument`: no settings and no timeframes for any interval.
pub fn new_instrument() -> Instrument {
  Instrument(settings: dict.new(), timeframes: dict.new())
}

/// A keyless `Account`. Its identity is supplied by the broker that holds it.
pub fn new_account() -> Account {
  Account
}

/// Put a broker under its id. Returns a NEW `Desk`; the argument is unchanged.
pub fn put_broker(desk: Desk, id: BrokerId, broker: Broker) -> Desk {
  Desk(brokers: dict.insert(desk.brokers, id, broker))
}

/// Read the broker under its id, or `NoSuchBroker` carrying the id asked for.
pub fn get_broker(desk: Desk, id: BrokerId) -> Result(Broker, LookupError) {
  case dict.get(desk.brokers, id) {
    Ok(broker) -> Ok(broker)
    Error(Nil) -> Error(NoSuchBroker(id))
  }
}

/// Put an account under its id. Returns a NEW `Broker`.
pub fn put_account(broker: Broker, id: AccountId, account: Account) -> Broker {
  Broker(..broker, accounts: dict.insert(broker.accounts, id, account))
}

/// Read the account under its id, or `NoSuchAccount` carrying that id.
pub fn get_account(
  broker: Broker,
  id: AccountId,
) -> Result(Account, LookupError) {
  case dict.get(broker.accounts, id) {
    Ok(account) -> Ok(account)
    Error(Nil) -> Error(NoSuchAccount(id))
  }
}

/// Put an instrument under its `Symbol`. Returns a NEW `Broker`.
pub fn put_instrument(
  broker: Broker,
  symbol: Symbol,
  instrument: Instrument,
) -> Broker {
  Broker(
    ..broker,
    instruments: dict.insert(broker.instruments, symbol, instrument),
  )
}

/// Read the instrument under its `Symbol`, or `NoSuchInstrument` carrying it.
pub fn get_instrument(
  broker: Broker,
  symbol: Symbol,
) -> Result(Instrument, LookupError) {
  case dict.get(broker.instruments, symbol) {
    Ok(instrument) -> Ok(instrument)
    Error(Nil) -> Error(NoSuchInstrument(symbol))
  }
}

/// Put the settings for ONE interval. Returns a NEW `Instrument`.
pub fn put_settings(
  instrument: Instrument,
  interval: Interval,
  settings: TimeframeSettings,
) -> Instrument {
  Instrument(
    ..instrument,
    settings: dict.insert(instrument.settings, interval, settings),
  )
}

/// Read the settings for ONE interval, or `NoSuchSettings(interval)`.
pub fn get_settings(
  instrument: Instrument,
  interval: Interval,
) -> Result(TimeframeSettings, LookupError) {
  case dict.get(instrument.settings, interval) {
    Ok(settings) -> Ok(settings)
    Error(Nil) -> Error(NoSuchSettings(interval))
  }
}

/// Put the live state for ONE interval. Returns a NEW `Instrument`.
pub fn put_timeframe(
  instrument: Instrument,
  interval: Interval,
  timeframe: Timeframe,
) -> Instrument {
  Instrument(
    ..instrument,
    timeframes: dict.insert(instrument.timeframes, interval, timeframe),
  )
}

/// Read the live state for ONE interval, or `NoSuchTimeframe(interval)`.
pub fn get_timeframe(
  instrument: Instrument,
  interval: Interval,
) -> Result(Timeframe, LookupError) {
  case dict.get(instrument.timeframes, interval) {
    Ok(timeframe) -> Ok(timeframe)
    Error(Nil) -> Error(NoSuchTimeframe(interval))
  }
}
