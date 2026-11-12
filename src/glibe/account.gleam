//// An account, attached to one broker. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// R50 (owner, verbatim, review of `desk.gleam`): *"should be in its own
//// file"*. It attaches to `Broker` but has no level below it, so it is NOT
//// a level of the main chain (R37). Its identity is the `AccountId` KEY of
//// `Broker.accounts`, held by the broker, never a field here.
////
//// READS: nothing.
//// WRITES: `Account` — the value under that key. `broker.get_account`
//// reads it and `broker.put_account` writes the recomputed one back;
//// those two live in `broker.gleam` because the Dict they act on belongs
//// to `Broker`, not to `Account`.
////
//// R26 / R32: its fields are deliberately NOT invented. No consumer for
//// one exists yet, so a field is added when a real consumer appears.
//// This is an empty FIELDS list, not an empty relation: the holder, the
//// key and the read / write pair are all named above (R47).
////
//// R19 status: skeleton. No working line here.

/// One account. It does not know its own key (R37).
pub type Account {
  Account
}
