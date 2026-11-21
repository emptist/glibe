//// The `Timeframe` type and ALL of its functions, in ONE module. Implements
//// `.planning/phases/02-domain-stream/02-01-PLAN.md`.
////
//// R42 (owner, verbatim): *"timeframe.gleam 定义 Timeframe type以及相关的
//// fn，你那个是什么鬼东西"* — a separate `engine.gleam` was an invented
//// mechanism module; there is none here. This file holds the record and
//// every transition of it.
////
//// READS: `SourceBar`, `SourceBarRejection`, `DataBar`, `DataLeaf`,
//// `DataBranch`. (No `Interval` param since the 2026-11-21 二选一 — the
//// closed `SourceBar` variant is the interval's one type source.)
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
//// states — `None` → `Some(bar)` → `None`; a `SourceBar` that has not closed
//// is ignored and held NOWHERE. There is no `SourceBar` accumulator.
////
//// BEFORE THIS FILE: what arrives at the system is a data source's OWN
//// external bar (`binance/kline.BinanceKline`, `ib/sourcebar.IbSourceBar`),
//// not a `SourceBar` and not a `DataBar`. The caller already holds the
//// `Interval` as the key of `Instrument.timeframes` (R23 / R37; owner:
//// *"你的左手不知道他是左还是右"*). Each provider writes ONE whole
//// standard `SourceBar` of the interval the caller selected. Binance serves
//// all nine intervals and maps one-to-one with `kline.to_sourcebar`; IB's
//// realtime stream serves ONLY five seconds, so
//// `ib/sourcebar.five_second_to_*` accumulates ONE arriving bar at a time
//// into ONE `growing_target_sourcebar` and emits a closed standard
//// `SourceBar` when the UTC grid period is reached (owner 2026-11-13). That
//// accumulation happens in `instrument.gleam` — the layer that holds the
//// `Interval` key and reads / writes `Timeframe.growing_target_sourcebar`.
//// The composition FUNCTIONS are defined in the module that owns IB's bar
//// (R50); a call site is not an owner. `sourcebar.validate` refuses the
//// closed `SourceBar` if unqualified
//// (R8). The closed bar's variant is the ONE type source of its interval
//// (owner 2026-11-21 二选一): `sourcebar_gate` takes only the `SourceBar`,
//// not a second `interval` argument. No bar and no `Timeframe` stores an
//// interval or a key, and NO period is ever changed here.
//// Nothing in this module decodes a provider or invents a bar type —
//// that boundary is upstream of the `Timeframe`.
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
//// R38: one stream, no second path — history and live data are the SAME
//// straight line (R33): a batch is just this same pair of entry points run
//// n times. R33: no actor, scheduler, clock, poll or heartbeat.
////
//// R19 status (2026-11-17): filled — `bars_listed` (owner 2026-11-15),
//// `sourcebar_gate` (the ONE door: validate -> born whole into
//// working_databar), `working_databar_archived` (prepend to list head, clear
//// working), and `databar_processing` (the single pipe shape, R40/R41).
//// Four remain: `indicator` / `leaves` / `branches` / `strategy` — every one
//// needs a value the current skeleton holds back (a measurement series on
//// DataBar, the leaf-death criterion, the branch_exit_leaf_size, the decision
//// rule), all recorded in `docs/PENDING_DECISIONS.md` R.5. None invented.

import gleam/option.{type Option, None, Some}
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection} as sb
import glibe/branch.{type DataBranch}
import glibe/databar.{type DataBar}
import glibe/leaf.{type DataLeaf}

/// One symbol at one interval — but it stores NEITHER as a name.
/// `working_databar` is the bar being dealt with; `databar_list` holds the
/// settled bars, newest first. R46: no settings field — a parameter
/// arrives only with its real consumer (R26 / R32).
///
/// `growing_target_sourcebar` is the ONE bar being composed from a finer
/// source stream (owner 2026-11-13): `None → Some(bar) → None`, the same
/// three states as `working_databar`. It is an `Option(SourceBar)`, so its
/// target interval IS the bar's variant — this `Timeframe` still does not
/// know its own name (R37). `Instrument` holds the `Interval` key and is
/// the layer that reads / writes this field through
/// `instrument.compose_ib_realtime_bar`; this module never composes and
/// never reads an `Interval` here. A `SourceBar` that has not closed is
/// never passed to `sourcebar_gate` (R39).
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
    growing_target_sourcebar: Option(SourceBar),
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

/// The price checker's gate: ONE arriving standard `SourceBar`, already
/// normalised from a data source's external bar and already qualified
/// (R28 / R8). It is born whole as `working_databar`; an unqualified one
/// is refused with a typed reason; a `SourceBar` that has not closed is
/// ignored and held nowhere (R39).
///
/// The closed `SourceBar` carries its own interval as a variant, read by
/// `sourcebar.interval(of:)`; that variant is the ONE type source of the
/// interval — no separate `interval` argument (owner 2026-11-21 二选一: pass the
/// sourcebar type OR the interval type, never both; the interval argument was
/// a dead param and a second encoding of the same fact). A `Timeframe` does
/// not know its own name, and no bar carries a period field. Composition
/// ended upstream, so this gate receives ONE closed `SourceBar` and never
/// accumulates one: owner 2026-11-13 *"等到了 databar_processing 你按到手的
/// 都是弄好的 databar"*. `bars_listed` supplies the index of the next bar
/// from `databar_list` (R39).
pub fn sourcebar_gate(
  timeframe: Timeframe,
  sourcebar: SourceBar,
) -> Result(Timeframe, SourceBarRejection) {
  // R8 / R39: the ONE door. validate rejects (never repairs); a qualified bar
  // is born whole as working_databar with idx from bars_listed (the head's
  // idx + 1, O(1), never a list count). The ONE interval is carried by the bar's
  // closed variant (2026-11-21 二选一): no separate `interval` argument — that
  // was a dead param (WAE Unused) and a second encoding of the same fact.
  case sb.validate(sourcebar) {
    Error(rejection) -> Error(rejection)
    Ok(qualified) -> {
      let new_bar =
        sb.to_databar(qualified, bars_listed(timeframe.databar_list))
      Ok(Timeframe(..timeframe, working_databar: Some(new_bar)))
    }
  }
}

/// The whole straight line. Its body is a single pipe of steps, each
/// `fn(Timeframe) -> Timeframe`, ending at `working_databar_archived`
/// (R40 / R41). Infinitely extensible: adding a step is adding one `|>`.
pub fn databar_processing(timeframe: Timeframe) -> Timeframe {
  // R40 / R40-A / R41: ONE pipe shape — every step takes and returns a
  // Timeframe, so adding a step is adding one `|>` and no step invents its
  // own argument order. Each step's body is filled independently; this is
  // only the straight line they sit on (R39).
  timeframe
  |> indicator
  |> leaves
  |> branches
  |> strategy
  |> working_databar_archived
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

/// Step: branches; reads the settled leaf fields off the record and reads
/// `branch.branch_exit_leaf_size()` — the branch's OWN closing rule — to
/// hand to `branch.next_yang_branch` / `next_yin_branch`. No pipeline step
/// carries that count as an extra argument (R40-A / R50).
pub fn branches(timeframe: Timeframe) -> Timeframe {
  todo as "05-01: read settled fields and the branch's closing length, write branches, no bar argument"
}

/// Step: the strategy decision, written as a `Signal` ON the working bar
/// (R39). No `manual_enter` / `manual_exit` provisional fields.
pub fn strategy(timeframe: Timeframe) -> Timeframe {
  todo as "05-01: the decision lives on this very bar"
}

/// Archive the working databar into `databar_list`. Takes NO bar argument:
/// the bar archived is the one in the field (R39 / R41).
pub fn working_databar_archived(timeframe: Timeframe) -> Timeframe {
  // R39 / R41: take the ONE bar in the field (no argument), prepend it to the
  // HEAD of databar_list (O(1), newest stays first — bars_listed reads that
  // head), and clear working_databar back to None. No bar is copied or walked.
  case timeframe.working_databar {
    None -> timeframe
    Some(bar) ->
      Timeframe(..timeframe, working_databar: None, databar_list: [
        bar,
        ..timeframe.databar_list
      ])
  }
}

/// The number of bars listed. R39 fixes this name — *"`bars_accepted` 不是
/// `bars_listed`"* — and R43 traced it to `glib/src/glib/timeframe.gleam:827`.
///
/// READS `idx` off the FIRST `DataBar` of `databar_list` (newest first:
/// `working_databar_archived` prepends). WRITES one `Int`, that `idx + 1`,
/// or `0` when the List is empty — the `idx` of the next bar, handed to
/// `sourcebar.to_databar`. The head is O(1); `list.length` is not called.
pub fn bars_listed(databar_list: List(DataBar)) -> Int {
  case databar_list {
    [] -> 0
    [newest, ..] -> newest.idx + 1
  }
}
