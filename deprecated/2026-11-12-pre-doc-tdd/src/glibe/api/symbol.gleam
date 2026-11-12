//// A name, not the thing named.
////
//// Plans: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`,
//// `.planning/phases/04-domain-cleanup/04-10-PLAN.md`.
//// Rulings: `docs/RULINGS.md` R22 (a name is not the thing), R23 (no stand-in
//// types), R19 (docs-first), R13, R21, R37 (identity is a key, not a field).
////
//// *"Symbol never is Instrument, people may call you with different titles
//// and names they like, but you are you, how can a title and name be you?"*
//// [user 2026-11-09]
////
//// A `Symbol` is the spelling one broker or data provider uses to name an
//// instrument. It is the KEY of `Broker.instruments` in `glibe/desk.gleam`;
//// the `Instrument` is a keyless value and never stores its own name. The same
//// instrument is spelled differently by different providers — `600000`,
//// `600000.sh`, `600000.SH` — so a name cannot carry the entity's facts.
//// The owner's words are collected in `docs/RULINGS.md` R22 §2, from
//// `glib/docs/reference/domain-hierarchy-2026-10-22.md` §1 and
//// `glib/docs/RULINGS.md` §1.17 / UC-47.
////
//// This module used to declare `Symbol = Instrument = Asset on specific
//// Market` and hold nine fields describing the traded thing. That line was
//// wrong, not merely imprecise: it is deleted in full, with no alias, no
//// deprecated copy and no compatibility layer (R22). None of those nine
//// fields was ever read anywhere in `src/` or `test/`.
////
//// The `String` spelling lives only here, at the text boundary. Everything
//// downstream sees a `Symbol` value, never a universal `String`.
////
//// **R37 (2026-11-10)**: this type is a KEY, not a field of `Instrument`.
//// The holder names what it owns — `Broker.instruments: Dict(Symbol,
//// Instrument)` — and the owned value never names its owner. *"你的左手不知道
//// 他是左还是右"*: the name lives in the holder, like left / right lives in
//// the observer. `test/level_judgement_test.gleam` pins this (04-10 plan).

/// The spelling one provider uses to name one instrument. Opaque, so a
/// `String` from a config file or a wire message is not accidentally a name.
pub opaque type Symbol {
  Symbol(spelling: String)
}

/// Build a name from the configuration or wire spelling. This is the only
/// place a `String` becomes a `Symbol`.
pub fn from_string(spelling: String) -> Symbol {
  Symbol(spelling: spelling)
}

/// The spelling to hand back to a provider, a filename or a chart label.
/// This is the only place a `Symbol` becomes a `String`.
pub fn to_string(symbol: Symbol) -> String {
  symbol.spelling
}
