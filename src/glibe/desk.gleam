//// The ONE top-level Value. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// R50 (owner, verbatim, review of this file): *"most of the code should
//// not be here"* and *"there will always be only one desk in the system"*.
//// This module now holds ONLY `Desk` and the read / write of the ONE Dict
//// `Desk` owns. `Broker` and its two Dicts are in `broker.gleam`,
//// `Instrument` and its Dict in `instrument.gleam`, `Account` in
//// `account.gleam`, both id types in `id.gleam`.
////
//// READS: `BrokerId`, `Broker`.
//// WRITES: `Desk.brokers`. `get_broker` reads the broker under a key;
//// `put_broker` writes the recomputed broker back under that key.
//// A missing key is `Nil` (core §6 / R37); see `id.gleam`.
////
//// R42 (owner, verbatim): *"但是他上面不再有东西，这是设计要求，
//// 没有其他原因。"* — nothing sits above `Desk`, so there is no
//// `AppConfig` wrapping it. R33 (owner, verbatim): *"Desk是顶层的唯一的
//// 一个Value，整个系统都在他里面，然后逐层嵌套，形成完整系统"*.
//// R50 adds ALWAYS EXACTLY ONE: no `DeskId`, no second Desk, no
//// collection of desks. Nothing sits above it to construct it either
//// (R42 / R49 / R50): `Desk` IS the Value, not a product of a
//// layer above it.
////
//// That is why NO function here walks from `Desk` down to `Timeframe`.
//// `timeframe_under` and `put_timeframe_under` are DELETED (R50): the
//// first had no caller, the second made the root do a leaf's work.
//// Each level calls its OWN read / write pair (R38); a caller holding
//// the keys reaches the owning `Instrument` level by level.
////
//// R37 / R23: identity is the holder's key, so `Broker` never stores its
//// `BrokerId`. R36: no `Market` gap. R20: a dashboard is a VIEW of this
//// Value, not a level of the chain. R33 / R35: the system is ALREADY
//// LIVE; data moves → this Value is recomputed → the view is its
//// projection. No actor, scheduler, clock, poll or monitor belongs here.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/dict.{type Dict}
import glibe/broker.{type Broker}
import glibe/id.{type BrokerId}

/// The root of the chain. The whole system is nested inside this one Value.
/// A dashboard renders a VIEW of it; the `Desk` is the model, not the screen
/// (R20). R36: it holds `Broker` directly, with no gap.
pub type Desk {
  Desk(brokers: Dict(BrokerId, Broker))
}

/// READ down: the broker under this key.
pub fn get_broker(desk: Desk, id: BrokerId) -> Result(Broker, Nil) {
  todo as "05-01: read the broker named by the desk's key"
}

/// WRITE: the recomputed broker back under this key.
pub fn put_broker(desk: Desk, id: BrokerId, broker: Broker) -> Desk {
  todo as "05-01: write back the recomputed broker"
}
