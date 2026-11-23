//// RED tests for the remaining domain-step bodies. Implements
//// `.planning/phases/02-domain-stream/02-01-PLAN.md` Task 3 and
//// `02-02-PLAN.md` Task 1/3.
////
//// These pin the OBSERVABLE promises of the five bodies that were `todo`:
//// `branch.branch_size` / `start_end_move` (Option contract, R1) and
//// `timeframe.leaves` / `branches` / `strategy` (the last three pipe steps).
//// Every rule is ported from frozen glib:
////   - branch size/move: glib `branch.gleam:96-98, 201-204` (a growing branch
////     has no late bar -> None; an ended branch measures start->exit / start->end).
////     glib's `branch_stat` / `recognised_move` are named `start_end_move` /
////     `enter_exit_move` here (owner, 2026-11-23: naming was wrong).
////   - leaves: glib `timeframe.gleam:511-582` (born on first bar; next_yin/yang
////     settle+reborn; CMA written onto the working bar; settled leaves kept as
////     FIELDS here per glibe R40/R42, not returned as a tuple).
////   - branches: glib `timeframe.gleam:630-702` (birth on recognition from the
////     settled leaf's corner; close on leaf_size >= settings.branch_exit_leaf_size,
////     a length test; growing carried unchanged; exit count read from settings).
////   - strategy: glib `timeframe.gleam:732-754` + manual_signal (UC-62):
////     recognised yang -> buy, exited yang -> sell, else no signal; only Yang.
//// Written BEFORE the bodies (R19): each test names a concrete input shape and
//// the field/value it expects, not merely "does not crash".

import fixture
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/time/timestamp
import gleeunit
import glibe/branch
import glibe/config
import glibe/databar.{type DataBar, DataBar}
import glibe/indicator
import glibe/leaf
import glibe/timeframe
import glibe/trading/signal

pub fn main() {
  gleeunit.main()
}

/// A bar with a chosen idx and sma_tiny; everything else neutral. Same fixture
/// shape and name as the other domain tests (`bar_at`), so a value states only
/// what the assertion relies on.
fn bar_at(idx: Int, sma: Float) -> DataBar {
  DataBar(
    idx: idx,
    timestamp: timestamp.from_unix_seconds(1_499_040_000 + idx),
    open: sma,
    high: sma,
    low: sma,
    close: sma,
    volume: 0,
    signal: signal.SignalNoSignal,
    sma_tiny: sma,
    sma_small: sma,
    sma_medium: sma,
    sma_large: sma,
    sma_huge: sma,
    bb_m: 0.0,
    bb_u3: 0.0,
    bb_l3: 0.0,
    bb_u2: 0.0,
    bb_u1: 0.0,
    bb_l1: 0.0,
    bb_l2: 0.0,
    sigma_n: 0,
    sigma_mean: 0.0,
    sigma_m2: 0.0,
    k: 0.0,
    d: 0.0,
    j: 0.0,
    m: 0.0,
    kdj_h: 0.0,
    kdj_h_idx: 0,
    kdj_l: 0.0,
    kdj_l_idx: 0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
  )
}

fn tf_working(working: DataBar, settled: List(DataBar)) -> timeframe.Timeframe {
  fixture.timeframe_with(Some(working), settled)
}

fn settings(exit_size: Int) -> config.IntervalSettings {
  config.IntervalSettings(
    sma_tiny_window_size: 2,
    sma_small_window_size: 70,
    sma_medium_window_size: 2,
    sma_large_window_size: 252,
    sma_huge_window_size: 504,
    kdj_window_size: 7,
    kdj_k_period: 3,
    kdj_d_period: 2,
    kdj_m_period: 10,
    bb_multiplier: 1.99,
    sma_for_bbm: config.SmaMedium,
    branch_exit_leaf_size: exit_size,
  )
}

// --- branch_size / start_end_move (Option contract) ---------------------------

/// An ended YangBranch from idx 10 to exit idx 20 spans 11 bars (both ends
/// inclusive, R6). A growing one (no exit_bar) has NO size -> None (R1).
pub fn branch_size_ended_span_and_growing_none_test() {
  let start = bar_at(10, 100.0)
  let exit = bar_at(20, 120.0)
  let ended =
    branch.YangBranch(
      start_bar: start,
      enter_bar: bar_at(11, 101.0),
      end_bar: Some(bar_at(19, 119.0)),
      exit_bar: Some(exit),
    )
  let growing =
    branch.YangBranch(
      start_bar: start,
      enter_bar: bar_at(11, 101.0),
      end_bar: None,
      exit_bar: None,
    )
  assert branch.branch_size(ended) == Some(11)
  assert branch.branch_size(growing) == None
  Nil
}

/// start_end_move measures start->END (the magnitude question), not
/// enter->exit. start sma 100 -> end sma 120 over idx 10..19 = 10 bars:
/// magnitude 0.2, duration 10, per_bar 0.02. Growing (no end_bar) -> None.
pub fn start_end_move_ended_measure_and_growing_none_test() {
  let start = bar_at(10, 100.0)
  let end = bar_at(19, 120.0)
  let ended =
    branch.YinBranch(
      start_bar: start,
      enter_bar: bar_at(11, 101.0),
      end_bar: Some(end),
      exit_bar: Some(bar_at(20, 121.0)),
    )
  let growing =
    branch.YinBranch(
      start_bar: start,
      enter_bar: bar_at(11, 101.0),
      end_bar: None,
      exit_bar: None,
    )
  let assert Some(m) = branch.start_end_move(ended)
  assert m.magnitude == 0.2
  assert m.duration == 10
  assert m.per_bar == 0.02
  assert branch.start_end_move(growing) == None
  Nil
}

// --- leaves ------------------------------------------------------------------

/// First working bar: both growing leaves are None, so `leaves` births a
/// YinLeaf and a YangLeaf on that bar (start=corner=this bar, no end), writes
/// the settled fields to None, and writes the two CMAs onto the working bar
/// (a leaf born this bar has CMA = its own sma_tiny, R3).
pub fn leaves_birth_both_twins_on_first_bar_test() {
  let working = bar_at(0, 50.0)
  let out = timeframe.leaves(tf_working(working, []), settings(3))
  let assert Some(yin) = out.growing_yin_leaf
  let assert Some(yang) = out.growing_yang_leaf
  assert leaf.start_bar(yin).idx == 0
  assert leaf.corner_bar(yin).idx == 0
  assert leaf.end_bar(yin) == None
  assert leaf.start_bar(yang).idx == 0
  assert out.yin_leaf_settled == None
  assert out.yang_leaf_settled == None
  let assert Some(bar) = out.working_databar
  assert bar.yin_leaf_cma == 50.0
  assert bar.yang_leaf_cma == 50.0
  Nil
}

/// A yin leaf dies on a new HIGH sma_tiny above its start (frozen glib
/// leaf.gleam:212-223). The settled leaf ends at the LAST bar (the killing bar
/// belongs to the newborn), the growing yin leaf is reborn on this bar, and
/// the settled leaf is written into `yin_leaf_settled` (a FIELD here, R40/R42).
pub fn leaves_settle_and_reborn_on_death_test() {
  let start = bar_at(1, 100.0)
  let last = bar_at(2, 99.0)
  let growing_yin = leaf.YinLeaf(start, None, bar_at(3, 98.0))
  let working = bar_at(4, 101.0)
  let tf =
    timeframe.Timeframe(
      ..tf_working(working, [last]),
      growing_yin_leaf: Some(growing_yin),
    )
  let out = timeframe.leaves(tf, settings(3))
  let assert Some(settled) = out.yin_leaf_settled
  assert leaf.start_bar(settled).idx == 1
  let assert Some(end) = leaf.end_bar(settled)
  // last_bar is the HEAD of databar_list (idx 2), not the killing bar (idx 4).
  assert end.idx == 2
  let assert Some(reborn) = out.growing_yin_leaf
  assert leaf.start_bar(reborn).idx == 4
  Nil
}

/// R68: a settled leaf of size >= 2 is recorded in the complete list AND, when
/// it also reached `branch_exit_leaf_size`, in the significant list. The death
/// test above settles a leaf spanning idx 1..2 (size 2) with exit_size 3: it
/// must land in `yin_leaf_list` but NOT in `signif_yin_leaf_list`.
pub fn leaves_records_settled_leaf_in_lists_test() {
  let start = bar_at(1, 100.0)
  let last = bar_at(2, 99.0)
  let growing_yin = leaf.YinLeaf(start, None, bar_at(3, 98.0))
  let working = bar_at(4, 101.0)
  let tf =
    timeframe.Timeframe(
      ..tf_working(working, [last]),
      growing_yin_leaf: Some(growing_yin),
    )
  let out = timeframe.leaves(tf, settings(3))
  assert list.length(out.yin_leaf_list) == 1
  assert out.signif_yin_leaf_list == []
  let assert [recorded] = out.yin_leaf_list
  assert leaf.start_bar(recorded).idx == 1
  assert out.yang_leaf_list == []
  assert out.signif_yang_leaf_list == []
  Nil
}

/// R68: with exit_size 2 the SAME size-2 leaf is significant too, so both the
/// complete and the significant list gain one entry. `branches` still reads the
/// settled FIELD, never these lists.
pub fn leaves_records_significant_leaf_in_both_lists_test() {
  let start = bar_at(1, 100.0)
  let last = bar_at(2, 99.0)
  let growing_yin = leaf.YinLeaf(start, None, bar_at(3, 98.0))
  let working = bar_at(4, 101.0)
  let tf =
    timeframe.Timeframe(
      ..tf_working(working, [last]),
      growing_yin_leaf: Some(growing_yin),
    )
  let out = timeframe.leaves(tf, settings(2))
  assert list.length(out.yin_leaf_list) == 1
  assert list.length(out.signif_yin_leaf_list) == 1
  Nil
}

// --- bar_admitted (UC-60) -----------------------------------------------------

/// UC-60 (review doc §7, frozen glib `timeframe.gleam:394,470-485`): a bar whose
/// seven bands are out of order is NOT admitted. `bar_admitted` clears its
/// `working_databar` to None so every downstream step is a no-op and the bar
/// never reaches a leaf, branch, signal, chart point or the history list.
pub fn bar_admitted_refuses_out_of_order_bands_test() {
  let broken =
    databar.DataBar(
      ..bar_at(7, 100.0),
      bb_l3: 1.0,
      bb_l2: 2.0,
      bb_l1: 3.0,
      bb_m: 4.0,
      bb_u1: 5.0,
      bb_u2: 6.0,
      bb_u3: 7.0,
    )
  // Make it genuinely broken: upper band below the centre fails the test.
  let broken = databar.DataBar(..broken, bb_m: 9.0)
  assert indicator.single_bar_test(broken) != Ok(Nil)
  let out = timeframe.bar_admitted(fixture.timeframe_with(Some(broken), []))
  assert out.working_databar == None
  assert out.databar_list == []
  Nil
}

/// The mirror: an in-order bar is admitted unchanged — its idx and identity
/// survive, so the downstream steps see the very bar `indicator` computed.
pub fn bar_admitted_passes_ordered_bands_test() {
  let good =
    databar.DataBar(
      ..bar_at(7, 100.0),
      bb_l3: 1.0,
      bb_l2: 2.0,
      bb_l1: 3.0,
      bb_m: 4.0,
      bb_u1: 5.0,
      bb_u2: 6.0,
      bb_u3: 7.0,
    )
  assert indicator.single_bar_test(good) == Ok(Nil)
  let out = timeframe.bar_admitted(fixture.timeframe_with(Some(good), []))
  assert out.working_databar == Some(good)
  Nil
}

/// No working bar (the state between two bars) is a no-op: bar_admitted must
/// not invent one. This is the invariant the refused branch restores.
pub fn bar_admitted_no_working_bar_is_noop_test() {
  let out = timeframe.bar_admitted(fixture.timeframe_with(None, []))
  assert out.working_databar == None
  Nil
}

// --- branches ----------------------------------------------------------------

/// A YangBranch is born on the bar a yin leaf starts (recognition, R4): the
/// growing branch is None, `working.idx == growing_yin_leaf.start_bar.idx`, and
/// a yin leaf just settled (its corner becomes the branch's start_bar). The
/// branch's enter_bar is this bar; late bars are None.
pub fn branches_birth_on_recognition_test() {
  let corner = bar_at(5, 90.0)
  let settled_yin = leaf.YinLeaf(bar_at(5, 90.0), Some(bar_at(6, 89.0)), corner)
  let working = bar_at(7, 88.0)
  // A yin leaf born on THIS bar recognises a yang branch; the riding yin leaf
  // grows on this bar (start_bar.idx == working.idx).
  let riding_yin = leaf.YinLeaf(working, None, working)
  let tf =
    timeframe.Timeframe(
      ..tf_working(working, [bar_at(6, 89.0)]),
      growing_yin_leaf: Some(riding_yin),
      growing_yang_leaf: Some(leaf.YangLeaf(working, None, working)),
      yin_leaf_settled: Some(settled_yin),
    )
  let out = timeframe.branches(tf, settings(40))
  let assert Some(growing) = out.growing_yang_branch
  assert branch.start_bar(growing).idx == 5
  assert branch.enter_bar(growing).idx == 7
  assert branch.end_bar(growing) == None
  assert out.yang_branch_list == []
  Nil
}

/// A growing YangBranch closes when the riding yin leaf reaches
/// settings.branch_exit_leaf_size bars (a LENGTH test, R6): end_bar = the
/// leaf's start (where it died), exit_bar = this bar (found dead). The count is
/// read from the settings argument, so exit_size=3 closes a 3-bar leaf here.
pub fn branches_close_on_settings_length_test() {
  let branch_start = bar_at(1, 100.0)
  let growing =
    branch.YangBranch(
      start_bar: branch_start,
      enter_bar: branch_start,
      end_bar: None,
      exit_bar: None,
    )
  // Riding yin leaf spans idx 2..4 (leaf_size 3 with this bar), start idx 2.
  let riding_yin = leaf.YinLeaf(bar_at(2, 100.0), None, bar_at(4, 97.0))
  let working = bar_at(4, 97.0)
  let tf =
    timeframe.Timeframe(
      ..tf_working(working, [bar_at(3, 98.0)]),
      growing_yang_branch: Some(growing),
      growing_yin_leaf: Some(riding_yin),
      growing_yang_leaf: Some(leaf.YangLeaf(working, None, working)),
    )
  let out = timeframe.branches(tf, settings(3))
  assert out.growing_yang_branch == None
  assert list_length(out.yang_branch_list) == 1
  let assert Some(closed) = list_first(out.yang_branch_list)
  let assert Some(end) = branch.end_bar(closed)
  assert end.idx == 2
  let assert Some(exit) = branch.exit_bar(closed)
  assert exit.idx == 4
  Nil
}

// --- strategy ----------------------------------------------------------------

/// UC-62: a YangBranch recognised on this bar -> SignalBuy. With no growing
/// yang branch and no exited branch, the signal is NoSignal. A YinBranch being
/// recognised does NOT trade (only Yang is the manual strategy).
pub fn strategy_buy_on_yang_recognition_test() {
  let working = bar_at(7, 88.0)
  let recognised_yang =
    branch.YangBranch(
      start_bar: bar_at(5, 90.0),
      enter_bar: working,
      end_bar: None,
      exit_bar: None,
    )
  let tf =
    timeframe.Timeframe(
      ..tf_working(working, []),
      growing_yang_branch: Some(recognised_yang),
    )
  let out = timeframe.strategy(tf)
  let assert Some(bar) = out.working_databar
  assert bar.signal == signal.SignalBuy

  let quiet = timeframe.strategy(tf_working(working, []))
  let assert Some(quiet_bar) = quiet.working_databar
  assert quiet_bar.signal == signal.SignalNoSignal
  Nil
}

/// UC-62: a YangBranch whose exit_bar is this bar -> SignalSell. The newest
/// ended branch is the head of `yang_branch_list`; `exited_branch` reads only
/// that head. A yin branch exiting is not an action and yields NoSignal.
pub fn strategy_sell_on_yang_exit_test() {
  let working = bar_at(9, 80.0)
  let exited_yang =
    branch.YangBranch(
      start_bar: bar_at(5, 90.0),
      enter_bar: bar_at(6, 91.0),
      end_bar: Some(bar_at(8, 82.0)),
      exit_bar: Some(working),
    )
  let tf =
    timeframe.Timeframe(..tf_working(working, []), yang_branch_list: [
      exited_yang,
    ])
  let out = timeframe.strategy(tf)
  let assert Some(bar) = out.working_databar
  assert bar.signal == signal.SignalSell
  Nil
}

fn list_length(l: List(a)) -> Int {
  case l {
    [] -> 0
    [_, ..rest] -> 1 + list_length(rest)
  }
}

fn list_first(l: List(a)) -> Option(a) {
  case l {
    [] -> None
    [first, ..] -> Some(first)
  }
}
