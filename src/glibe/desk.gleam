//// The ownership root — where every instrument and every timeframe lives.
////
//// Plans: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`,
//// `.planning/phases/04-domain-cleanup/04-10-PLAN.md` — the latter carries
//// the DESIGN JUDGEMENTS themselves into this file's docs, tests and bodies.
//// Rulings: `docs/RULINGS.md` R19, R20, R22, R23, R26, R33, R34, R35, R36,
//// R37. Full verbatim owner words and reasoning live there; this module doc
//// states the rule that a type or function here must satisfy.
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
//// **How to judge a level (R36 / R37, 2026-11-10).** A type that forms one
//// level of this chain must have TWO ownership relations: one to the level
//// above and one to the level below. Every other type either ATTACHES to one
//// type without being owned as a level — it is never inserted between two
//// levels — or attaches to nothing at all and is held by `Desk`, because it at
//// least belongs to the system. Attachment is not ownership and creates no
//// level. `Market` was tested in BOTH directions: `Market ▸ Broker` and
//// `Broker ▸ Market` are both false, so `Market` is REJECTED as a level and
//// `Desk` holds `Broker` directly. There is NO gap here (R36). The older note
//// in this file saying "Market is not a level yet, adding it is a separate
//// architectural change" is CORRECTED: it is not an open option. `Asset` /
//// `Exchange` / `Market` relations stay open until a consumer needs one
//// (R26); none is preset, none is inserted into this chain.
////
//// **Why identity is a key (R37).** Owner 2026-11-10, verbatim: *"我举例说，
//// 你的左手不知道他是左还是右，同样，Timeframe不应该知道他是什么interval"*.
//// Left / right is the holder's label, not a property of the hand. So
//// `BrokerId` is the key of `Desk.brokers`, `Symbol` the key of
//// `Broker.instruments`, `Interval` the key of `Instrument.timeframes`, and
//// the value never names its holder. A `Timeframe` does not know its interval.
////
//// **The system is already live (R33 / R35).** `Desk` is the single top-level
//// Value; every type here is recomputed as a pure value when data moves.
//// `put_broker` / `put_instrument` / `put_timeframe` return NEW values and
//// leave their arguments unchanged — that IS the update a view renders. No
//// actor, clock, polling, subscription or runtime that "makes leaves alive"
//// belongs in this module. "叶子" in this system means `YinLeaf` / `YangLeaf`
//// from `glibe/leaf.gleam`, never a `Timeframe`. If a change starts needing
//// an actor, a scheduler, a config table or a guard script, fix the type,
//// function and module definitions instead: *"简单是正确的验证码"* (R35).
////
//// **The layer both predecessors lacked (R34).** seib and ibOptions each had
//// ONE broker — the only thing they share, and they are *"完全两码事"*
//// (owner 11:10). **seib is CoffeeScript, the owner's own system design**: no
//// Python + pandas limitation, no "cannot tell types apart" problem. Its
//// structure was right and lacked only the layer of multiple brokers / data
//// providers; `Desk(brokers: Dict(BrokerId, Broker))` with `binance` / `ib`
//// / `futu` in `config.default_config()` IS that layer. No provider framework
//// is added. **ibOptions was a workaround for Python + pandas**, 五脏俱全
//// but *"都不对劲"* (*"为了迁就语言凑合的"*): structural relations could
//// not be types, so its settings were flattened types. A requirements list
//// only; nothing is imported from it here.
////
//// This module was written documentation-first (R19): `////` naming the
//// `.planning` item, types, `///` + annotated signatures + `todo` bodies,
//// then the tests in `test/desk_test.gleam` and
//// `test/level_judgement_test.gleam`, and only then the bodies.
//// `gleam docs build` renders these comments into
//// `package-interface.json`, so the judgements above are part of the
//// compiled interface — not prose kept somewhere else that nobody reads.

import gleam/dict.{type Dict}
import gleam/result
import glibe/api/interval.{type Interval}
import glibe/api/symbol.{type Symbol}
import glibe/timeframe.{type Timeframe}

/// The identity of a broker. Opaque, so a `String` is not a `BrokerId`.
/// The desk holds it as the key of `Desk.brokers`; the broker never stores it.
/// R37: the name belongs to the HOLDER. A broker no more knows its own id
/// than a left hand knows it is left.
pub opaque type BrokerId {
  BrokerId(String)
}

/// The identity of an account. Opaque, so a `String` is not an `AccountId`.
/// The broker holds it as the key of `Broker.accounts` (R37).
pub opaque type AccountId {
  AccountId(String)
}

/// One lookup failed. One variant per business-domain failure, each carrying
/// the key that was asked for — never `Error(String)`. There is no
/// `NoSuchSettings` any more: settings are a field of the `Timeframe`, not a
/// second keyed collection (R23).
/// R37: this error type ATTACHES to the chain (it describes its lookups) but
/// is not owned as a level and is never inserted between two levels.
pub type LookupError {
  NoSuchBroker(BrokerId)
  NoSuchAccount(AccountId)
  NoSuchInstrument(Symbol)
  NoSuchTimeframe(Interval)
}

/// A keyless account. Balances and positions are not invented here; the
/// account's identity is the `AccountId` key the broker holds.
/// R37: `Broker` holds it, but it has no level below it, so it attaches to
/// the chain without becoming one of its levels.
pub type Account {
  Account
}

/// One instrument: the thing that is traded, owned by one broker under one
/// name. It stores its timeframes and nothing about its own identity — the
/// `Symbol` key in `Broker.instruments` is its name, and the `Interval` key
/// inside `timeframes` is each engine's interval. One dictionary, not two.
/// R37: TWO ownership relations — owned by `Broker` and owning
/// `Dict(Interval, Timeframe)` — which is what makes it a level of the chain.
pub type Instrument {
  Instrument(timeframes: Dict(Interval, Timeframe))
}

/// A broker owns the instruments it trades and the accounts it is responsible
/// for. Both are keyed; the broker itself is keyless.
/// R37: TWO ownership relations — owned by `Desk` and owning `instruments` —
/// so it is a level. R36: NO `Market` sits above it; both directions of that
/// relation were rejected.
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
/// R33: the ONE top-level Value; the whole system is nested inside it.
/// R36: it holds `Broker` directly, with no gap. R37: a type that attaches to
/// nothing else is held here, because it at least belongs to the system.
/// R34: this `Dict(BrokerId, Broker)` IS the multiple-brokers layer that both
/// single-broker predecessors lacked — no separate provider framework.
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

/// Read one `Timeframe` all the way down from the top-level `Desk`, following
/// the three holders' keys: `Desk.brokers`, `Broker.instruments`,
/// `Instrument.timeframes`. A failure at any level is that level's
/// `LookupError` variant carrying the key asked for.
///
/// R36: the chain has NO gap — `Desk` holds `Broker` directly, no `Market`
/// level appears. R37: every argument after `desk` is a KEY owned by the level
/// above, not a field of the value being read. R33: this is a pure READ, not
/// `monitor.advance`, not an `IncomingBar`, not an address type and not a
/// scheduler; it advances nothing and keeps no state. The values it returns
/// are recomputed by their holders, which is why the view stays current.
///
/// Plan: `.planning/phases/04-domain-cleanup/04-10-PLAN.md`, step 2 signature,
/// step 3 test, step 4 body. This `///` is the specification the test asserts.
pub fn timeframe_under(
  desk: Desk,
  broker_id: BrokerId,
  symbol: Symbol,
  interval: Interval,
) -> Result(Timeframe, LookupError) {
  use broker <- result.try(get_broker(desk, broker_id))
  use instrument <- result.try(get_instrument(broker, symbol))
  get_timeframe(instrument, interval)
}
