//// The ownership root — where every instrument and every timeframe lives.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`.
//// Ruling: `docs/RULINGS.md` R20 (the chain is must-have, `Desk` is the name),
//// R22 (a name is not the thing), R23 (one dictionary, no stand-ins), R19.
////
//// Ownership chain, top to bottom:
////   Desk -> Broker -> Instrument -> Interval -> Timeframe
////
//// `Symbol` is the key in `Broker.instruments`: the spelling a broker uses to
//// NAME an instrument. It is not the instrument and carries none of its facts
//// (R22). `Interval` is the key in `Instrument.timeframes`; a `Timeframe`
//// never stores its own interval, its own symbol or a market tag (R23).
////
//// Identity is a key, not a field: `Broker`, `Instrument` and `Account` never
//// store their own id. The type relations ARE the consumers — a
//// `Dict(BrokerId, Broker)` field is a compile-time use of `Broker`, so none of
//// these values is orphaned.
////
//// `Instrument` has exactly ONE collection. It used to hold a second one,
//// `Dict(Interval, TimeframeSettings)`, beside the timeframes; `config.gleam`
//// used to hold the same numbers under composite strings like
//// `"BTCUSDT_H1"`. Both are deleted, not adapted. The numbers now travel with
//// the engine as `Timeframe.settings`. `src/glibe/config.gleam` holds a `Desk`
//// value directly, so there is no list of strings to look up.
////
//// Open, deliberately not fixed here: `Market` is not a level in this chain
//// yet, so `Instrument` does not carry a `Market` field. glib's landed
//// `Instrument(market, timeframes)` has one; adding it to glibe is a separate
//// architectural change, recorded in the 04-03 plan's out-of-scope section.
////
//// This module was written documentation-first: `////`, then types, then
//// `///` + annotated signatures + `todo` bodies, then its tests, and only then
//// were the bodies filled. See R19 in `docs/RULINGS.md`.

import gleam/dict.{type Dict}
import glibe/api/interval.{type Interval}
import glibe/api/symbol.{type Symbol}
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
/// the key that was asked for — never `Error(String)`. There is no
/// `NoSuchSettings` any more: settings are a field of the `Timeframe`, not a
/// second keyed collection (R23).
pub type LookupError {
  NoSuchBroker(BrokerId)
  NoSuchAccount(AccountId)
  NoSuchInstrument(Symbol)
  NoSuchTimeframe(Interval)
}

/// A keyless account. Balances and positions are not invented here; the
/// account's identity is the `AccountId` key the broker holds.
pub type Account {
  Account
}

/// One instrument: the thing that is traded, owned by one broker under one
/// name. It stores its timeframes and nothing about its own identity — the
/// `Symbol` key in `Broker.instruments` is its name, and the `Interval` key
/// inside `timeframes` is each engine's interval. One dictionary, not two.
pub type Instrument {
  Instrument(timeframes: Dict(Interval, Timeframe))
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

/// An empty `Instrument`: one collection, no timeframes for any interval.
pub fn new_instrument() -> Instrument {
  Instrument(timeframes: dict.new())
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

/// Put an instrument under the `Symbol` that NAMES it. Returns a NEW `Broker`.
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

/// Put the live state for ONE interval. Returns a NEW `Instrument`.
pub fn put_timeframe(
  instrument: Instrument,
  interval: Interval,
  timeframe: Timeframe,
) -> Instrument {
  Instrument(timeframes: dict.insert(instrument.timeframes, interval, timeframe))
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
