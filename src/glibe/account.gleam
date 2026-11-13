//// `Account` — the value stored under one `AccountId` key of
//// `Broker.accounts`. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// WORK OF THIS MODULE: define the `Account` value. R50 (owner, verbatim):
//// *"should be in its own file"*. Its identity is the `AccountId` KEY held
//// by `Broker`, never a field of this value (R37). It has no level below
//// it, so it is not a level of the main chain (R37).
////
//// WHO READS / WRITES IT: `broker.get_account` reads the value under a key
//// of `Broker.accounts`; `broker.put_account` writes the recomputed value
//// back under that key. Those two are in `broker.gleam` because the Dict
//// they act on is held by `Broker`. Bringing them here would make
//// `Account` do `Broker`'s work (R50 §1, owner: *"what? you ask a desk to
//// do the things that should be done by the instrument? are you mad?"*).
////
//// This value has no fields yet. R26 / R32: a field is added when its real
//// consumer appears, one at a time; owner 2026-10-31 struck invented
//// provisional fields (*"based on this to invent fields is not expected
//// behaviour … keep things clean"*, R38). With no field there is no value
//// of `Account` for a function HERE to read or write, and a birth function
//// is the `new` ruled out by R49. So this module's own work is the type
//// definition alone; its holder, its key and its read / write pair are
//// named above.

/// One account. It does not know its own key (R37).
pub type Account {
  Account
}
