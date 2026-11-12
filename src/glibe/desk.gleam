//// The ONE top-level Value. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: `Interval`, `Symbol`, `Timeframe`.
//// WRITES: `Desk`, `Broker`, `Instrument`, `Account`, their identities, and
//// the read-down / write-back services of the whole ownership chain.
////
//// R42 (owner, verbatim): *"Desk就是中心控制室，所有的声控app，web或者
//// 桌面端，以及分析决策等等type都会从这里直接或者逐层展开出来。"* and
//// *"Desk 从type上面来看，也可以说是 top type，也可以说是根，随便怎么
//// 理解，但是他上面不再有东西，这是设计要求，没有其他原因。你系统一定要
//// 有一个顶部的东西的。"* There is NOTHING above `Desk`: this is a design
//// requirement, not a consequence to be derived. In particular there is no
//// `AppConfig` wrapping it — that shape contradicted this ruling.
////
//// R33: *"Desk是顶层的唯一的一个Value，整个系统都在他里面，然后逐层嵌套，
//// 形成完整系统"*. `config.default_config()` returns this one Value.
////
//// R20 / R37 — the main chain, each level has TWO ownership relations:
//// `Desk ▸ Broker ▸ Instrument ▸ Timeframe`. R37 (owner): *"有层次关系的
//// 那些types，构成层次关系某一层的type必须是跟上下级之间存在两个隶属
//// 关系的type"*. `Broker` also holds a group of `accounts` (R33 / R36).
////
//// R37 / R23 — IDENTITY LIVES IN THE HOLDER'S DICT KEY:
//// `Desk.brokers: Dict(BrokerId, Broker)`,
//// `Broker.instruments: Dict(Symbol, Instrument)`,
//// `Instrument.timeframes: Dict(Interval, Timeframe)`.
//// Owner: *"我举例说，你的左手不知道他是左还是右，同样，Timeframe不应该
//// 知道他是什么interval"*. The owned value never names its owner.
////
//// R22: `Symbol` is a NAME, never `Instrument`. R36: no `Market` sits
//// between `Desk` and `Broker` — neither direction of that relation holds.
//// R26 / R32: `Asset` / `Exchange` / `Market` relations are NOT decided;
//// a catalogue is added as one field when a real consumer exists, and its
//// place is found by walking the real ownership backwards. They are not
//// invented here.
////
//// R34: the layer the single-broker predecessor lacked IS this
//// `Dict(BrokerId, Broker)`. No separate provider / data-source framework.
////
//// R42: voice apps, web / desktop front ends and analysis / decision types
//// unfold from here, directly or level by level. A dashboard is a VIEW
//// (R20), a pure-value projection of this Value, not a level of the chain.
//// Per R26 those types are added when their consumer exists, so the
//// skeleton names the place but does not fabricate them.
////
//// R30: the web view shows local wall-clock time. That is an OUTPUT-side
//// projection of this Value; it never changes the input-side UTC unix grid
//// (R29), and CSV stays UTC RFC3339. The view type unfolds from `Desk`
//// when its consumer exists (R26 / R42), so the OUTPUT boundary is named
//// here and no `web/server.gleam` is invented for it.
////
//// R33 / R35: the system is ALREADY LIVE. Data moves → the Value is
//// recomputed → the view is its projection. No actor, scheduler, clock,
//// poll, heartbeat, monitor or advance step belongs here.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/dict.{type Dict}
import glibe/api/interval.{type Interval}
import glibe/api/symbol.{type Symbol}
import glibe/timeframe.{type Timeframe}

/// The identity of a broker, held as the KEY of `Desk.brokers`. Opaque so a
/// `String` is not a `BrokerId` (R13). The broker never stores it (R37).
pub opaque type BrokerId {
  BrokerId(String)
}

/// The identity of an account, held as the KEY of `Broker.accounts`.
pub opaque type AccountId {
  AccountId(String)
}

/// One lookup failed. One variant per business-domain failure, carrying the
/// key that was asked for — never `Error(String)` (R20 / R13). The
/// `NoSuch*` wording is the owner's own: R23 names `NoSuchSettings` when
/// striking the parallel settings dictionary. There is no `NoSuchSettings`
/// here because settings are a field of `Timeframe` (R23).
pub type LookupError {
  /// No broker under this key.
  NoSuchBroker(BrokerId)
  /// No account under this key.
  NoSuchAccount(AccountId)
  /// No instrument under this name.
  NoSuchInstrument(Symbol)
  /// No timeframe under this interval key.
  NoSuchTimeframe(Interval)
}

/// An account. It attaches to `Broker` but has no level below it, so it is
/// NOT a level of the chain (R37). Its identity is the `AccountId` key.
pub type Account {
  Account
}

/// One instrument: the thing traded, owned by one broker under one name.
/// It stores its timeframes and nothing about its own identity — the
/// `Symbol` key in `Broker.instruments` is its name and the `Interval` key
/// in `timeframes` is each engine's interval. ONE dictionary, not two (R23).
pub type Instrument {
  Instrument(timeframes: Dict(Interval, Timeframe))
}

/// A broker owns the instruments it trades and the accounts it is
/// responsible for. Both are keyed; the broker itself is keyless.
/// R36: no `Market` sits above it. R34: a broker IS an api provider seen
/// from another angle; no provider framework is layered on top.
pub type Broker {
  Broker(
    instruments: Dict(Symbol, Instrument),
    accounts: Dict(AccountId, Account),
  )
}

/// The root of the chain. The whole system is nested inside this one Value.
/// A dashboard renders a VIEW of it; the `Desk` is the model, not the screen
/// (R20). R36: it holds `Broker` directly, with no gap.
pub type Desk {
  Desk(brokers: Dict(BrokerId, Broker))
}

/// Make a `BrokerId` from the spelling used at a boundary. The only way in,
/// because the type is opaque (R13).
pub fn broker_id(spelling: String) -> BrokerId {
  todo as "05-01: a holder's key, not the broker's own field"
}

/// Make an `AccountId` from the spelling used at a boundary.
pub fn account_id(spelling: String) -> AccountId {
  todo as "05-01: a holder's key, not the account's own field"
}

/// READ down: the broker under this key.
pub fn get_broker(desk: Desk, id: BrokerId) -> Result(Broker, LookupError) {
  todo as "05-01: read the broker named by the desk's key"
}

/// WRITE: the broker under this key.
pub fn put_broker(desk: Desk, id: BrokerId, broker: Broker) -> Desk {
  todo as "05-01: write back the recomputed broker"
}

/// READ down: the account under this key.
pub fn get_account(
  broker: Broker,
  id: AccountId,
) -> Result(Account, LookupError) {
  todo as "05-01: read the account named by the broker's key"
}

/// WRITE: the account under this key.
pub fn put_account(broker: Broker, id: AccountId, account: Account) -> Broker {
  todo as "05-01: write back the recomputed account"
}

/// READ down: the instrument under this name.
pub fn get_instrument(
  broker: Broker,
  symbol: Symbol,
) -> Result(Instrument, LookupError) {
  todo as "05-01: read the instrument named by the broker's key"
}

/// WRITE: the instrument under this name.
pub fn put_instrument(
  broker: Broker,
  symbol: Symbol,
  instrument: Instrument,
) -> Broker {
  todo as "05-01: write back the recomputed instrument"
}

/// READ down: the timeframe under this interval key.
pub fn get_timeframe(
  instrument: Instrument,
  interval: Interval,
) -> Result(Timeframe, LookupError) {
  todo as "05-01: read the timeframe named by the instrument's key"
}

/// WRITE: the timeframe under this interval key.
pub fn put_timeframe(
  instrument: Instrument,
  interval: Interval,
  timeframe: Timeframe,
) -> Instrument {
  todo as "05-01: write back the recomputed timeframe"
}

/// READ down the whole chain in one call. The caller already holds the keys,
/// so no step needs to ask a value for its own identity (R37).
pub fn timeframe_under(
  desk: Desk,
  broker_id: BrokerId,
  symbol: Symbol,
  interval: Interval,
) -> Result(Timeframe, LookupError) {
  todo as "05-01: Desk -> Broker -> Instrument -> Timeframe, read only"
}

/// WRITE back up the whole chain. One arriving bar needs BOTH halves: the
/// read above and this symmetric write (R42). The result is a new `Desk`.
pub fn put_timeframe_under(
  desk: Desk,
  broker_id: BrokerId,
  symbol: Symbol,
  interval: Interval,
  timeframe: Timeframe,
) -> Result(Desk, LookupError) {
  todo as "05-01: Desk <- Broker <- Instrument <- Timeframe, write back"
}
