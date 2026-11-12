//// The `Timeframe` type and ALL of its functions, in ONE module. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// R42 (owner, verbatim): *"timeframe.gleam 定义 Timeframe type以及相关的
//// fn，你那个是什么鬼东西"* — a separate `engine.gleam` was an invented
//// mechanism module; there is none here. This file holds the record and
//// every transition of it.
////
//// READS: `Interval`, `SourceBar`, `SourceBarRejection`, `DataBar`,
//// `DataLeaf`, `DataBranch`.
//// WRITES: `Timeframe` — the working databar, the archived bars, and the
//// intermediate facts that keep the pipeline a straight line.
////
//// R37: there is NO `interval`, NO `symbol` and NO `market_type` field —
//// the interval is the KEY in `Instrument.timeframes`, and a timeframe
//// does not know its own name. R23: no composite string keys, no second
//// dictionary, no `list.find`.
////
//// R46 (owner, verbatim): *"TimeframeSettings 是AI搞出来的东西，我不知道是
//// 什么玩意"*, *"问题是他做什么，谁用他，为什么存在"*. There is NO
//// settings type, NO settings field and NO birth function taking one.
//// An `indicator_settings.gleam` module existed here and is deleted. When
//// a calculation needs a parameter, that parameter becomes a field of the
//// type that really owns it, added when its real consumer appears
//// (R26 / R32 / R34) — not a placeholder bag invented in advance.
////
//// R39 (owner, verbatim): *"数据来到我们的系统，合格的sourcebar变成working
//// databar，从头到尾所有运算处理决策都在这个databar working中完成，之后他
//// 就被working databar archieved，这就是整个的系统，没有任何旁门左道。"*
//// Four steps, one straight line, no side doors. `working_databar` has three
//// states — `None` → `Some(bar)` → `None`; an unclosed period is ignored and
//// held NOWHERE. There is no bucket accumulator.
////
//// R40 / R40-A / R41: the body of `databar_processing` is
//// `timeframe |> f1 |> f2 ... |> fN |> working_databar_archived`. Each step
//// is `fn(Timeframe, ...extra) -> Timeframe` (any number of extra args, but
//// the subject is FIRST and is what comes back). NO step takes a bar as an
//// argument: the bar is the `working_databar` field. R41: the pipe is a
//// SHAPE constraint enforced by the compiler, not a formatting preference;
//// it stops an AI from inventing parameter order and return types. A fact
//// that must reach a later step is a FIELD, never a tuple on the side.
////
//// R38: no replay, no rewind, no second batch implementation. History and
//// live data are ONE stream (R33): a batch is just this same pair of entry
//// points run n times. R33: no actor, scheduler, clock, poll or heartbeat.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/option.{type Option}
import glibe/api/interval.{type Interval}
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection}
import glibe/branch.{type DataBranch}
import glibe/databar.{type DataBar}
import glibe/leaf.{type DataLeaf}

/// One symbol at one interval — but it stores NEITHER. `working_databar`
/// is the bar being dealt with; `databar_list` holds the settled bars,
/// newest first. R46: no settings field — a parameter arrives only with
/// its real consumer (R26 / R32).
///
/// The four growing twins are the owner's "four twins" (R1); `YinBranch` /
/// `YangBranch` are his words (R2), and R4 names `growing_yang_branch` and
/// `growing_yin_leaf` literally in the one-line recognition rule. A
/// settled leaf is a FIELD, never a tuple or a parameter handed to the
/// next step (R40 / R42), so every step still takes and returns only
/// `Timeframe`. These are persistent structures across bars, not a second
/// place where one bar is worked on: R39 keeps all of a bar's computation
/// IN `working_databar`. Their inner shapes arrive one field at a time
/// when a real consumer exists (R26 / R32); this skeleton fixes the
/// relations, not the maths.
pub type Timeframe {
  Timeframe(
    working_databar: Option(DataBar),
    databar_list: List(DataBar),
    growing_yin_leaf: Option(DataLeaf),
    growing_yang_leaf: Option(DataLeaf),
    growing_yin_branch: Option(DataBranch),
    growing_yang_branch: Option(DataBranch),
    yin_branch_list: List(DataBranch),
    yang_branch_list: List(DataBranch),
    yin_leaf_settled: Option(DataLeaf),
    yang_leaf_settled: Option(DataLeaf),
  )
}

/// The price checker's gate: ONE arriving `SourceBar`. A qualified bar is
/// born whole as the `working_databar`; an unqualified one is refused with a
/// typed reason; an unclosed period is ignored and held nowhere (R39).
/// The `interval` is passed by the caller who selected this timeframe —
/// the key was already in that caller's hand (R23 / R37).
pub fn sourcebar_gate(
  timeframe: Timeframe,
  interval: Interval,
  sourcebar: SourceBar,
) -> Result(Timeframe, SourceBarRejection) {
  todo as "05-01: one qualified bar born whole into working_databar"
}

/// The whole straight line. Its body is a single pipe of steps, each
/// `fn(Timeframe) -> Timeframe`, ending at `working_databar_archived`
/// (R40 / R41). Infinitely extensible: adding a step is adding one `|>`.
pub fn databar_processing(timeframe: Timeframe) -> Timeframe {
  todo as "05-01: timeframe |> indicator |> leaves |> branches |> strategy |> working_databar_archived"
}

/// Step: indicators, computed IN the working databar.
pub fn indicator(timeframe: Timeframe) -> Timeframe {
  todo as "05-01: read and write only the working_databar field"
}

/// Step: `YinLeaf` / `YangLeaf` recognition; a settled leaf is written into
/// a FIELD so the next step needs no extra argument (R40 / R41).
pub fn leaves(timeframe: Timeframe) -> Timeframe {
  todo as "05-01: settle leaves into fields, return only Timeframe"
}

/// Step: branches; reads the settled leaf fields off the record.
pub fn branches(timeframe: Timeframe) -> Timeframe {
  todo as "05-01: read settled fields, write branches, no bar argument"
}

/// Step: the strategy decision, written as a `Signal` ON the working bar
/// (R39). No `manual_enter` / `manual_exit` provisional fields.
pub fn strategy(timeframe: Timeframe) -> Timeframe {
  todo as "05-01: the decision lives on this very bar"
}

/// Archive the working databar into `databar_list`. Takes NO bar argument:
/// the bar archived is the one in the field (R39 / R41).
pub fn working_databar_archived(timeframe: Timeframe) -> Timeframe {
  todo as "05-01: Some -> None, bar appended to databar_list"
}

/// The number of bars listed. R39 fixes this name — *"`bars_accepted` 不是
/// `bars_listed`"* — and R43 traced it to `glib/src/glib/timeframe.gleam:827`.
/// It counts `databar_list`, not an "accepted" collection.
pub fn bars_listed(databar_list: List(DataBar)) -> Int {
  todo as "05-01: count the settled bars"
}
