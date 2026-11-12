//// The decision a strategy writes on the working databar. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: nothing.
//// WRITES: `Signal`, a field of `DataBar` (R39: every decision is made IN
//// the working databar, so the decision is written on the bar).
////
//// R10 / R11: the word written on the bar is `"buy"`, `"sell"` or `""`;
//// the branch `enter_bar` / `exit_bar` ARE the manual enter and exit, and
//// no second strategy is added. R39: those decisions are made in the
//// working databar. `manual_enter` / `manual_exit` were struck by the
//// owner on 2026-10-31 (R38 / R39) — there are no provisional fields.
////
//// R13: a closed set is a type, never a `String` or a pair of `Bool`s.
//// R21: constructors carry the type name and spell the value out. The
//// three constructors below are the type-level form of the three words
//// above; the wire spellings belong only to a codec / view boundary.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

/// The outcome of the strategy step on one bar.
pub type Signal {
  /// The `"buy"` decision.
  SignalBuy
  /// The `"sell"` decision.
  SignalSell
  /// The empty word: no decision on this bar.
  SignalNoSignal
}

/// The wire / view spelling of a signal. Boundary data only.
pub fn to_string(signal: Signal) -> String {
  todo as "05-01: project a closed-set decision at a boundary"
}
