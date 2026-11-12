//// A name, not a thing. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: nothing. This is at the bottom of the chain.
//// WRITES: `Symbol`, used as the key of `Broker.instruments`.
////
//// R22 (owner, verbatim): *"Symbol never is Instrument, people may call you
//// with different titles and names they like, but you are you, how can a
//// title and name be you?"* A broker spells an instrument its own way; the
//// instrument itself never stores that spelling. There is no `InstrumentId`,
//// no alias and no compatibility layer.
////
//// R37: identity lives in the HOLDER's Dict key. R26: each broker's dialect
//// is an adapter concern, not a new type in the model. R13: an identifier is
//// its own type, opaque so a `String` is not a `Symbol`.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

/// The spelling a broker uses for an instrument. Opaque: a spelling can only
/// be made through `from_string`, and is never confused with a plain `String`.
pub opaque type Symbol {
  Symbol(spelling: String)
}

/// A broker's spelling becomes a `Symbol`. The wire spelling is boundary
/// data; the entity is not built here (R22).
pub fn from_string(spelling: String) -> Symbol {
  todo as "05-01: a name is given by the holder, not by the thing"
}

/// The spelling back out, for codecs and view projections only.
pub fn to_string(symbol: Symbol) -> String {
  todo as "05-01: project the name at a boundary"
}
