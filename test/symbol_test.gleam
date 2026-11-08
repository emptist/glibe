//// Tests for `src/glibe/api/symbol.gleam` — R22: a name is not the thing named.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`.
//// Written BEFORE the module bodies were replaced (R19). Every assertion is a
//// promise made by a `///` doc in that module.

import gleam/dict
import glibe/api/symbol

/// Two different spellings are two different names.
pub fn different_spellings_are_different_names_test() {
  assert symbol.from_string("BTCUSDT") != symbol.from_string("SPY")
    as "two names are two values"
}

/// The spelling round-trips at the text boundary and nowhere else.
pub fn spelling_round_trips_at_the_boundary_test() {
  assert symbol.to_string(symbol.from_string("600000.SH")) == "600000.SH"
    as "codec round-trips"
  assert symbol.to_string(symbol.from_string("BTCUSDT")) == "BTCUSDT"
    as "the provider spelling is unchanged"
}

/// A name can be a dict key: that is its whole job (R22, R23).
pub fn a_name_can_be_a_dict_key_test() {
  let named =
    dict.from_list([
      #(symbol.from_string("BTCUSDT"), 1),
      #(symbol.from_string("SPY"), 2),
    ])
  let assert Ok(1) = dict.get(named, symbol.from_string("BTCUSDT"))
    as "the name looks up what it names"
  assert dict.get(named, symbol.from_string("600000.SH")) == Error(Nil)
    as "a spelling nobody used names nothing"
}

/// The same entity may be spelled differently by different brokers — the
/// spelling is not the entity, so two spellings are not merged.
pub fn one_entity_many_names_test() {
  let yahoo = symbol.from_string("600000")
  let ib = symbol.from_string("600000.SH")
  assert yahoo != ib as "a name is not the thing named"
  assert symbol.to_string(yahoo) != symbol.to_string(ib)
    as "each broker keeps its own spelling"
}
