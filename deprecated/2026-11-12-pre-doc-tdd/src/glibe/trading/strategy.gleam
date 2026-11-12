//// The manual strategy — the only strategy that is not the AI's, and the
//// place a verdict lives.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-13-PLAN.md` §5 (upstream
//// contracts). This module is an UPSTREAM of `glibe/timeframe`: the
//// pipeline's `strategy` step asks `manual_signal` for the word and writes
//// it onto `Timeframe.working_databar`. The step reads the branch lists and
//// the working bar from the record; this module judges nothing about a
//// `Timeframe` and imports none — the two booleans are its whole input.
////
//// The `////` above is a retrofit of the missing module doc (R19); the
//// definition below is the existing, tested one.

// The manual strategy — the only strategy that is not the AI's, and the place
// a verdict lives.
//
// **A verdict belongs to whoever decides.** The `DataBar` used to carry six
// boolean verdicts as fields, and no module ever wrote them, so every reader
// got `False`. They are not coming back as fields: what a bar carries is a
// measurement, and a strategy derives its verdict from the measurements. When
// the two idib-defined ones (`kdj_cross_up`, `kdj_bearish_left`) land, they
// land here.
//
// **The manual strategy judges nothing of its own** (UC-62): *"the branch
// enter_idx and exit_idx are manual enter and exit points, no other manual
// strateties are needed for now."* A `YangBranch`'s `enter_bar` *is* the buy
// and its `exit_bar` *is* the sell, because a `YangBranch` is the up structure.
// Trading the `YinBranch` too would be a **second** manual strategy — shorting
// the down-leg — which is what that sentence rules out.
//
// The AI attempts are deliberately absent. They are NOT waiting on glib:
// glib's owner ordered them deleted from that tree in 2026-09 ("delete them
// ALL"), and no `ai_s1` / `learn` / `boost` / `knn` codebase exists there to
// port. glibe does not wait for a feature the reference project removed.
import glibe/trading/signal.{type Signal, Buy, NoSignal, Sell}

/// **The word the bar carries, on the bar that carries it.** It is a `Signal`,
/// not a String: the three cases are the whole closed set (RULINGS.md R13).
///
/// The two cases cannot collide: recognising a `YangBranch` as dead births the
/// opposite polarity, never another yang. A bar with neither is simply a bar
/// with no signal — `NoSignal` is not a third verdict.
pub fn manual_signal(recognised_yang: Bool, exited_yang: Bool) -> Signal {
  case recognised_yang, exited_yang {
    True, _ -> Buy
    _, True -> Sell
    _, _ -> NoSignal
  }
}
