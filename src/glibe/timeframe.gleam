// The `Timeframe` — one `(symbol, interval)` and everything that belongs to it.
//
// **This module holds the record and its birth, and nothing else.**
//
// It used to hold the ingest, the whole pipeline, a CSV exporter and three
// hooks, which is how it became the file the reviews kept calling a mixture.
// The reason given for keeping the pipeline here was Gleam's import cycle:
// `leaves` and `branches` need both the `Timeframe` type and the `Leaf` /
// `Branch` types, and putting them in `leaf.gleam` would make that module
// import `timeframe`, which imports it back. Splitting the **state** from the
// **pipeline that threads it** dissolves the cycle instead of arguing with it:
// `engine.gleam` imports all three and nothing imports `engine` from below.
//
// So: this file is a record and the one function that makes an empty one.
// Every step that moves it lives in `engine.gleam`, and
// `scripts/no_timeframe_mixture.sh` fails the build if one of them comes back.

import gleam/option.{type Option}
import glibe/api/exchange.{type MarketType}
import glibe/api/interval.{type Interval}
import glibe/api/symbol.{type Symbol}
import glibe/branch.{type DataBranch}
import glibe/databar.{type DataBar}
import glibe/leaf.{type DataLeaf}

pub type Timeframe {
  Timeframe(
    symbol: Symbol,
    interval: Interval,
    market_type: MarketType,
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
pub fn new(
  symbol: Symbol,
  interval: Interval,
  market_type: MarketType,
) -> Timeframe {
  Timeframe(
    symbol: symbol,
    interval: interval,
    market_type: market_type,
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
