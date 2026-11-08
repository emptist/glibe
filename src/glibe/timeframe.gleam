//// The `Timeframe` — one interval of one instrument, and everything it runs on.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-03-PLAN.md`.
//// Ruling: `docs/RULINGS.md` R23 (thorough correction), R22, R20, R19.
////
//// *"即然你的左手不知道他是左手你也活的好好的，为什么instrument的timeframe
//// 必须要知道他的interval？有这么愚蠢的设计吗？"* [user 2026-11-04,
//// `glib/.planning/HANDOFF-2026-11-03.md:96`]
////
//// This record stores NO `symbol`, NO `interval` and NO market tag. The
//// interval is the KEY in `Instrument.timeframes`; the symbol is the KEY in
//// `Broker.instruments`. The caller that selected this value already holds
//// both, which is why `engine.sourcebar_gate` is handed the interval as an
//// argument. `settings` is a FIELD of this record, not a second dictionary on
//// the `Instrument` — that second dictionary was the circle R23 deletes.
////
//// **This module holds the record and its birth, and nothing else.**
////
//// It used to hold the ingest, the whole pipeline, a CSV exporter and three
//// hooks, which is how it became the file the reviews kept calling a mixture.
//// The reason given for keeping the pipeline here was Gleam's import cycle:
//// `leaves` and `branches` need both the `Timeframe` type and the `Leaf` /
//// `Branch` types, and putting them in `leaf.gleam` would make that module
//// import `timeframe`, which imports it back. Splitting the **state** from the
//// **pipeline that threads it** dissolves the cycle instead of arguing with it:
//// `engine.gleam` imports all three and nothing imports `engine` from below.
////
//// So: this file is a record and the one function that makes an empty one.
//// Every step that moves it lives in `engine.gleam`, and
//// `scripts/no_timeframe_mixture.sh` fails the build if one of them comes back.

import gleam/option.{type Option}
import glibe/branch.{type DataBranch}
import glibe/databar.{type DataBar}
import glibe/indicator_settings.{type TimeframeSettings}
import glibe/leaf.{type DataLeaf}

/// The whole live state of ONE interval of ONE instrument. Its owner and its
/// interval are the keys above it; neither is a field here.
pub type Timeframe {
  Timeframe(
    // The parameter block this engine runs on. One value per `Timeframe`; it
    // is not an entity with a dictionary or a config table of its own (R23).
    settings: TimeframeSettings,
    // **No bar is in hand when a `Timeframe` is born** — the first source bar
    // is what opens a bucket, so this starts at `None` and is `None` again for
    // the moment between a close and the next source bar.
    working_databar: Option(DataBar),
    // Newest-first. `accept` is its only writer and prepends, so the head bar's
    // `idx` *is* how many bars have been accepted — no second counter.
    databar_list: List(DataBar),
    // **The two twins every bar belongs to.** `None` until the first bar, and
    // `Some` from then on: a leaf is born on a bar, so before any bar arrives
    // there is nothing to name. Not sentineled — a bar of zeros standing in for
    // "nothing yet" is a number that lies, and its `idx` of 0 collides with
    // the first real bar's.
    growing_yin_leaf: Option(DataLeaf),
    growing_yang_leaf: Option(DataLeaf),
    // **A branch is optional; a leaf is not.** No branch exists until a leaf
    // settles and its corner can name a start, so both are `None` most of the
    // time, and a growing branch is carried unchanged until the bar it is
    // recognised as dead on.
    growing_yin_branch: Option(DataBranch),
    growing_yang_branch: Option(DataBranch),
    yin_branch_list: List(DataBranch),
    yang_branch_list: List(DataBranch),
    // **The manual strategy** (UC-62): a branch's `enter_bar` and `exit_bar`
    // *are* the manual enter and exit points, so these two carry them forward.
    // Bars, not indices.
    manual_enter: Option(DataBar),
    manual_exit: Option(DataBar),
  )
}

/// **An empty `Timeframe`, born before any bar.** Nothing is seeded with a
/// value: there is no bar to seed it from, and a seed would be read as a fact.
/// `settings` is the one thing it does carry, because an engine cannot run
/// without the numbers it runs on.
pub fn new(settings: TimeframeSettings) -> Timeframe {
  Timeframe(
    settings: settings,
    working_databar: option.None,
    databar_list: [],
    growing_yin_leaf: option.None,
    growing_yang_leaf: option.None,
    growing_yin_branch: option.None,
    growing_yang_branch: option.None,
    yin_branch_list: [],
    yang_branch_list: [],
    manual_enter: option.None,
    manual_exit: option.None,
  )
}
