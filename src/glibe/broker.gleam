//// One broker and the two dictionaries it holds. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
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
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/dict.{type Dict}
import glibe/account.{type Account}
import glibe/api/symbol.{type Symbol}
import glibe/id.{type AccountId}
import glibe/instrument.{type Instrument}

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
  todo as "05-01: read the instrument named by the broker's key"
}

/// WRITE: the recomputed instrument back under this name.
pub fn put_instrument(
  broker: Broker,
  symbol: Symbol,
  instrument: Instrument,
) -> Broker {
  todo as "05-01: write back the recomputed instrument"
}

/// READ down: the account under this key.
pub fn get_account(broker: Broker, id: AccountId) -> Result(Account, Nil) {
  todo as "05-01: read the account named by the broker's key"
}

/// WRITE: the recomputed account back under this key.
pub fn put_account(broker: Broker, id: AccountId, account: Account) -> Broker {
  todo as "05-01: write back the recomputed account"
}
