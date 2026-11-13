//// Every identity of the chain, in ONE module. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// R50 (owner, verbatim, review of `desk.gleam`): *"try put all id types in
//// one file/module, to avoid circular, and to make it easier to check"*.
//// This module imports NOTHING from the project; no level of the chain
//// imports another level through here, so `desk.gleam` and `broker.gleam`
//// never import each other.
////
//// READS: nothing.
//// WRITES: `BrokerId`, `AccountId` — the two keys. `broker_id` /
//// `account_id` are here because an `opaque` constructor is invisible
//// outside its own module, so the only way to build these keys must live
//// with them (R13, core §3; measured `error: Use of private value`).
////
//// NOT here: a lookup-failure type. A missing key has nothing to say —
//// the caller already holds the key (R37) — so each `get_*` returns
//// `Result(value, Nil)` (core §6), as `api/interval.from_string` already
//// does. A typed error carrying the key back would also let a value like
//// `NoSuchTimeframe(..)` come out of `get_broker`: well-formed, absurd,
//// and unobjected-to (core §2.2). `NoSuch*` was never an owner word
//// (R47); the whole cross-level error union is DELETED by R50.
////
//// R37 / R23: an id is the KEY in its holder's Dict, never a field of the
//// value it names. `BrokerId` keys `Desk.brokers`; `AccountId` keys
//// `Broker.accounts`. Neither `Broker` nor `Account` stores one.
////
//// R50 (owner, verbatim): *"there will always be only one desk in the
//// system"* — so there is NO `DeskId`. The one Desk is not looked up by a
//// key, and nothing sits above it to construct it (R42 / R49 / R50).
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

/// The key of `Desk.brokers`. Opaque so a `String` is not a `BrokerId` (R13).
pub opaque type BrokerId {
  BrokerId(String)
}

/// The key of `Broker.accounts`. Opaque so a `String` is not an `AccountId`.
pub opaque type AccountId {
  AccountId(String)
}

/// A boundary spelling becomes the key of `Desk.brokers`. The only way in,
/// because `BrokerId` is opaque.
pub fn broker_id(spelling: String) -> BrokerId {
  todo as "05-01: a holder's key, not the broker's own field"
}

/// A boundary spelling becomes the key of `Broker.accounts`.
pub fn account_id(spelling: String) -> AccountId {
  todo as "05-01: a holder's key, not the account's own field"
}

/// `BrokerId` read back at a boundary. The constructor is `opaque`, so
/// this half of the codec must sit in the SAME module as the type (R50 §3,
/// measured `error: Use of private value`); a caller outside cannot
/// destructure it. `broker_id` and this function are the two directions of
/// the one key.
pub fn broker_id_to_string(id: BrokerId) -> String {
  todo as "05-01: read the spelling out of the opaque broker key"
}

/// `AccountId` read back at a boundary; the same `opaque` rule as above.
pub fn account_id_to_string(id: AccountId) -> String {
  todo as "05-01: read the spelling out of the opaque account key"
}
