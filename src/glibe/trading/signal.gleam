//// The signal a bar carries — a closed set, therefore a type, not a `String`.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-13-PLAN.md` §5 (upstream
//// contracts). This module is an UPSTREAM of `glibe/timeframe`: the
//// pipeline's `strategy` step writes one of these three values onto
//// `Timeframe.working_databar`, and `glibe/databar` holds it as a field.
//// `sourcebar.to_databar` seeds every bar with `NoSignal`. The wire
//// spelling lives here and only here — the boundary codec, not the value
//// the pipeline reasons about (R13).
////
//// The `////` above is a retrofit of the missing module doc (R19); the
//// definitions below are the existing, tested ones.

// The signal a bar carries — a closed set, therefore a type, not a `String`.
//
// *"Gleam is a typed language, don't you know?"* [user 2026-10-12, glib
// `RULINGS.md` §1.11]. A closed set held as a String can only be described,
// and prose is what nothing checks. The three constructors are exactly the
// three cases `strategy.manual_signal` can produce; no fourth one exists to
// be invented by a reader, and no field on `DataBar` is left unwritten.
//
// One type, one module (NAMING.md). The String spelling lives here and only
// here — it is the CSV/wire codec at the boundary, not the value the engine
// reasons about.

pub type Signal {
  Buy
  Sell
  NoSignal
}

/// The wire spelling. An absent signal is an empty column, not a third
/// verdict. Called by `export/csv.gleam` and nothing else.
pub fn to_string(signal: Signal) -> String {
  case signal {
    Buy -> "buy"
    Sell -> "sell"
    NoSignal -> ""
  }
}
