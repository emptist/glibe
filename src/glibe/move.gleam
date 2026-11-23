//// The measurement of a MOVE — how far it went, how long it took, and the
//// rate per bar. Implements `.planning/phases/02-domain-stream/02-02-PLAN.md`
//// Task 3 and the naming ruling in `docs/RULINGS.md` R51 / R52.
////
//// WHY THIS IS ITS OWN MODULE, AND WHY IT IS A TYPE (owner 2026-11-23):
//// *"从move这个名字完全看不出他 return的东西，也就是说完全看不出他的功能……
//// 我只能问你；但是这正好说明，命名太差了。"* and *"当这 move 和 move_between
//// 同时存在于一个 module 的时候，move 这个名字误导就更强烈。"*
////
//// Two defects were named, and this module closes both:
////
//// 1. **The return value had no name.** `move_between` returned
////    `#(Float, Float, Float)` — three positions with no labels, so a caller
////    reading only a type signature could not tell magnitude from duration
////    from rate. That is the same disease owner named in R47: *"像这种情况……
////    这个 type 说是 the numbers a timeframe run on 这是什么玩意你自己看得懂不？"*
////    A named type makes the value say what it is: `Move` carries
////    `magnitude` / `duration` / `per_bar`, and the signature reads
////    `-> Move` instead of `-> #(Float, Float, Float)`.
////
//// 2. **One word meant two things in one module.** `move` was the CONCEPT
////    (a span between two bars) AND the first RETURNED NUMBER (a share).
////    `move_between`'s own name therefore read as "the move", while it
////    returned three numbers whose first was also called "the move". Separating
////    them: THIS MODULE owns the concept as a type (`Move`); `branch.gleam`
////    keeps only the two branch-shaped windows that PRODUCE one
////    (`start_end_move` / `enter_exit_move`).
////
//// NAMING.md 1.19 / 1.20 (one class, one module) and R50 (one module, one
//// ownership relation) put the type in its own file: this module owns the
//// measurement and reads nothing but two `DataBar`s, so it depends only on
//// `databar.gleam` and `branch.gleam` depends on it — no cycle.
////
//// R19 status (2026-11-23): 2 items filled — the `Move` type and
//// `move_between`. RED -> GREEN via `test/move_test.gleam` (5 tests: the three
//// named numbers, a downward move, a single-bar move, the fields being
//// distinguishable, and the value comparing by field); the RED run was
//// observed (93 passed / 6 failures, every new test crashing on this module's
//// `todo`).

import gleam/int
import glibe/databar.{type DataBar, DataBar}

/// One measured move between two bars, as three numbers that name themselves.
///
/// The three are the ones owner asked for on 2026-10-03 (6th) — *"is there a
/// pattern in the magnitude each time? is there a pattern when combining time
/// length and magnitude?"* — so they carry owner's own words, not names
/// invented here (R45).
///
/// - `magnitude` — how far the move went, as a SHARE of the level it opened
///   on, so a 700-dollar leg and a 60,000-dollar one are comparable (glib
///   `branch.gleam:184-189`). It rides `sma_tiny`, never price (R3; owner
///   *"All three ride `sma_tiny`, never price"*).
/// - `duration` — how many bars the move took, both ends inclusive. An `Int`
///   because a bar count is a count: `10.0` bars is not a thing (R1).
/// - `per_bar` — the rate: `magnitude / duration`. This is the one that
///   separates two strategies covering the same move (glib
///   `branch.gleam:222-228`).
///
/// WRITER: `move.move_between` — the only producer. READERS: the branch
/// windows in `branch.gleam` (`start_end_move` / `enter_exit_move`), and
/// whatever projects a branch onto a view (R20 / R30).
pub type Move {
  Move(magnitude: Float, duration: Int, per_bar: Float)
}

/// The move between ANY two bars — the one measurement every profit and loss
/// reads. `branch.start_end_move` calls it with `start_bar` / `end_bar`,
/// `branch.enter_exit_move` with `enter_bar` / `exit_bar` (R11).
///
/// It reads `idx` and the measurement series off the two bars it is handed
/// (R6) and knows nothing about branches, leaves or timeframes — that is why
/// it lives in this module and not in `branch.gleam`.
///
/// The result is a `Move`, whose three fields say what they are; before this
/// type existed the same three numbers travelled as an unnamed
/// `#(Float, Float, Float)` and a caller could not read them off a signature.
pub fn move_between(from_bar: DataBar, to_bar: DataBar) -> Move {
  // Frozen glib `branch.gleam:229-236`. R3/R6: the share is on the selected
  // MA, not price; the duration is an idx difference with both ends included,
  // never a walk of any list. The rate is the magnitude per bar, not a verdict.
  let DataBar(sma_tiny: from_ma, idx: from_idx, ..) = from_bar
  let DataBar(sma_tiny: to_ma, idx: to_idx, ..) = to_bar
  let magnitude = { to_ma -. from_ma } /. from_ma
  let duration = to_idx - from_idx + 1
  let per_bar = magnitude /. int.to_float(duration)
  Move(magnitude:, duration:, per_bar:)
}
