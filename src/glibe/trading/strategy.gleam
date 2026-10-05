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
// The AI attempts are deliberately absent: that work is being built in glib
// right now and is ported when it settles.

/// **The word the bar carries, on the bar that carries it.**
///
/// The two cases cannot collide: recognising a `YangBranch` as dead births the
/// opposite polarity, never another yang. A bar with neither is simply a bar
/// with no signal, and an empty string says that — it is not a third signal.
pub fn manual_signal(recognised_yang: Bool, exited_yang: Bool) -> String {
  case recognised_yang, exited_yang {
    True, _ -> "buy"
    _, True -> "sell"
    _, _ -> ""
  }
}
