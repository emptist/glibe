//// One broker and the two dictionaries it holds. Implements
//// `.planning/BRIEF.md`.
////
//// R50 (owner, verbatim, review of `desk.gleam`): *"should be in its own
//// file"* on this type and on `get_instrument` / `put_instrument`.
//// `get_account` / `put_account` come here by the SAME rule — they read
//// and write `Broker.accounts`, whose holder is `Broker`, not `Desk`.
//// The owner did not label those two individually; this is the rule he
//// stated applied one level further, not a new name.
////
//// READS: `Symbol`, `AccountId`, `Instrument`, `Account`.
//// WRITES: `Broker.instruments` and `Broker.accounts`. Every function here
//// takes a `Broker` as its subject; none takes a `Desk`. A missing key
//// is `Nil` (core §6 / R37); see `id.gleam`.
////
//// R20 / R37: `Desk ▸ Broker ▸ Instrument ▸ Timeframe`; a level of the
//// main chain has TWO ownership relations, up and down. `Broker` is
//// keyless: its `BrokerId` is the key in `Desk.brokers`, held by `Desk`.
//// R33 / R36: a broker also holds a group of accounts; `Account` is not a
//// level of the chain. No `Market` sits above `Broker` — neither
//// direction of that relation holds (R36).
//// R34: a broker IS an api provider seen from another angle; no separate
//// provider / data-source framework is layered on top.
////
//// R65 §3 / R69 §3 (owner): the nested chain had NO birth point, so a Desk
//// starting empty could never process one bar. `instrument_at` is the birth
//// point at THIS level: it reads `Broker.instruments` and, on a miss, writes
//// the `Instrument` constructor directly at the point of need (R64 — no
//// `new`). The recomputed instrument is put back by `put_instrument` in the
//// same route (R50). The same rule is applied one level up (`desk.broker_at`)
//// and one level down (`instrument.timeframe_at`). No type changes.
////
//// R19 status: 5 bodies filled — `instrument_at` (RED→GREEN via
//// `test/runtime_publish_test.gleam`), `get_instrument` / `put_instrument`
//// and `get_account` / `put_account`, the read/write pairs of this layer
//// (R50: a function goes with the Dict it reads and writes). No `todo` remains.

import gleam/dict.{type Dict}
import glibe/account.{type Account}
import glibe/api/symbol.{type Symbol}
import glibe/id.{type AccountId}
import glibe/instrument.{type Instrument, Instrument}

/// A broker owns the instruments it trades and the accounts it is
/// responsible for. Both are keyed; the broker itself is keyless.
pub type Broker {
  Broker(
    instruments: Dict(Symbol, Instrument),
    accounts: Dict(AccountId, Account),
  )
}

/// READ down: the instrument under this name.
pub fn get_instrument(
  broker: Broker,
  symbol: Symbol,
) -> Result(Instrument, Nil) {
  let Broker(instruments, ..) = broker
  dict.get(instruments, symbol)
}

/// READ down, with the birth of an empty holder on a miss: the instrument
/// under this name, or a fresh `Instrument` written directly here (R64 — no
/// `new`). It is only a READ of `Broker.instruments`; `put_instrument` in the
/// same step writes the recomputed one back (R50).
pub fn instrument_at(broker: Broker, symbol: Symbol) -> Instrument {
  let Broker(instruments, ..) = broker
  case dict.get(instruments, symbol) {
    Ok(instrument) -> instrument
    Error(Nil) -> Instrument(dict.new())
  }
}

/// WRITE: the recomputed instrument back under this name.
pub fn put_instrument(
  broker: Broker,
  symbol: Symbol,
  instrument: Instrument,
) -> Broker {
  let Broker(instruments, accounts) = broker
  Broker(dict.insert(instruments, symbol, instrument), accounts)
}

/// READ down: the account under this key.
pub fn get_account(broker: Broker, id: AccountId) -> Result(Account, Nil) {
  let Broker(accounts: accounts, ..) = broker
  dict.get(accounts, id)
}

/// WRITE: the recomputed account back under this key.
pub fn put_account(broker: Broker, id: AccountId, account: Account) -> Broker {
  let Broker(instruments, accounts) = broker
  Broker(instruments, dict.insert(accounts, id, account))
}
