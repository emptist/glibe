//// The one name glibe owns. Implements
//// `.planning/BRIEF.md`.
////
//// READS: nothing — the bottom of the chain.
//// WRITES: `Symbol`, the key of `Broker.instruments`.
////
//// R22: a Symbol is a NAME, never an Instrument. A broker spells an
//// instrument its own way; the instrument never stores that spelling. No
//// alias, no compatibility layer.
////
//// GOVERNING ROOT (owner 2026-11-17 08:37, `docs/RULINGS.md`): type boundary
//// = authority boundary. glibe may define ONLY the one standard `Symbol`; a
//// broker's native symbol belongs to that broker (brokers do not define each
//// other's either), and future sources are unknowable. Freezing foreign
//// variants into this type was wrong by construction. Names are an OPEN set,
//// so the single constructor carries a `String` — it is not a sum of broker
//// dialects (R13: closed sets are types; R26: open set, one type at a time).
////
//// R28: each broker's native symbol lives in ITS OWN module and converts here
//// through its own `to_symbol`. `Broker.instruments` is keyed by this one
//// standard `Symbol` only, so one broker's spelling never crosses to another.
//// Precedent: `binance/kline.BinanceKline` + `to_sourcebar` → the standard
//// `api/sourcebar.SourceBar`.
////
//// The `<human:>` notes in the earlier skeleton were PSEUDOCODE and examples,
//// not decisions (owner 2026-11-17 08:40). `Symbol.type` named a type, not a
//// value. Full record: `docs/RULINGS.md` 「2026-11-17 08:37」.

/// The one standard name for an instrument. Opaque: a spelling can only be
/// made here and is never confused with a bare `String`. Names are an open
/// set, so this is a single constructor over a `String`, not an enumeration
/// of broker dialects — those belong to their brokers (R28, governance root).
pub opaque type Symbol {
  Symbol(spelling: String)
}

/// Give a boundary spelling the standard name. The spelling is boundary data;
/// the entity is not built here (R22).
pub fn string_to_symbol(spelling: String) -> Symbol {
  Symbol(spelling)
}

/// Project the standard name back to a `String`, for codecs and view
/// projections only.
pub fn to_string(symbol: Symbol) -> String {
  let Symbol(spelling) = symbol
  spelling
}
