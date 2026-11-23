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
//// `timeframe |> f1(settings) |> f2 ... |> fN |> working_databar_archived`.
//// Each step is `fn(Timeframe, ...extra) -> Timeframe` (any number of extra
//// args, but the subject is FIRST and is what comes back). `indicator` and
//// `branches` take `IntervalSettings` as a pipe-call argument (R46: never a
//// `Timeframe` field); `leaves` / `strategy` need no parameter. NO step takes
//// a bar as an argument: the bar is the `working_databar` field. R41: the
//// pipe is a SHAPE constraint enforced by the compiler, not a formatting
//// preference; it stops an AI from inventing parameter order and return
//// types. A fact that must reach a later step is a FIELD, never a tuple on
//// the side.
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

import gleam/list
import gleam/option.{type Option, None, Some}
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection} as sb
import glibe/branch.{type DataBranch}
import glibe/config.{type IntervalSettings}
import glibe/databar.{type DataBar}
import glibe/indicator
import glibe/leaf.{type DataLeaf}
import glibe/trading/signal

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
    /// Every settled YinLeaf of `leaf_size >= 2`, newest first (R68; frozen
    /// glib's historical `yin_leaf_list`, restored for traceability research).
    /// A RECORD, not a mechanism: `branches` does NOT read it and must not
    /// (glib `timeframe.gleam:120-127` measured that reading a branch off a
    /// leaf list drops branches). WRITER: `leaves`. READER: research (a test
    /// today). Single-bar leaves are never listed (glib leaf law 4).
    yin_leaf_list: List(DataLeaf),
    /// The settled YangLeaf mirror of `yin_leaf_list` (R68). WRITER `leaves`,
    /// READER research; `branches` must not read it.
    yang_leaf_list: List(DataLeaf),
    /// Settled YinLeaves whose `leaf_size >= settings.branch_exit_leaf_size`,
    /// newest first (R68; glib `signif_yin_leaf_list`). A record for research,
    /// not the source of a branch's start (that is `yin_leaf_settled`, R66 §1).
    /// WRITER: `leaves`. READER: research (a test today).
    signif_yin_leaf_list: List(DataLeaf),
    /// The settled YangLeaf mirror of `signif_yin_leaf_list` (R68). WRITER
    /// `leaves`, READER research.
    signif_yang_leaf_list: List(DataLeaf),
    growing_yin_branch: Option(DataBranch),
    growing_yang_branch: Option(DataBranch),
    yin_branch_list: List(DataBranch),
    yang_branch_list: List(DataBranch),
    /// The leaf that settled **ON THIS BAR** — `Some` only on the bar the
    /// leaf dies, `None` on every other bar (glib `timeframe.gleam:133-141`:
    /// *"the leaf that just settled is a fact about this bar"*).
    ///
    /// It is **NOT "the last leaf"**: nothing here remembers the most recent
    /// settled leaf, and this field must not become it. WRITER: `leaves`
    /// (every bar). READER: `branches` — the RETIRED leaf whose corner opens
    /// the new branch (glib `timeframe.gleam:398-412`). A sticky value would
    /// hand `branches` a stale leaf on a bar where only the opposite polarity
    /// settled, so the retired corner would be the wrong one (R63 §2).
    yin_leaf_settled: Option(DataLeaf),
    /// The leaf that settled **ON THIS BAR**, opposite polarity — same
    /// contract as `yin_leaf_settled`: `Some` only on the bar the leaf dies,
    /// `None` otherwise; WRITER `leaves`, READER `branches` (R63 §2).
    yang_leaf_settled: Option(DataLeaf),
  )
}

/// The price checker's sourcebar_gate: ONE arriving standard `SourceBar`, already
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
/// ended upstream, so this sourcebar_gate receives ONE closed `SourceBar` and never
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

/// The whole straight line. Its body is a single pipe of steps, each subject
/// first and returning `Timeframe`, ending at `working_databar_archived`
/// (R40 / R40-A / R41). `settings` is the one interval's numbers, read by the
/// caller off the closed `SourceBar` variant (R39 / R46); it is a pipe-call
/// argument to the steps that need numbers, never a `Timeframe` field.
/// Infinitely extensible: adding a step is adding one `|>`.
pub fn databar_processing(
  timeframe: Timeframe,
  settings: IntervalSettings,
) -> Timeframe {
  // R40 / R40-A / R41: ONE pipe shape — every step takes and returns a
  // Timeframe, so adding a step is adding one `|>` and no step invents its
  // own argument order. indicator / branches take `settings` at the pipe
  // call site; leaves / strategy need no parameter. Each step's body is
  // filled independently; this is only the straight line they sit on (R39).
  timeframe
  |> indicator(settings)
  |> leaves(settings)
  |> branches(settings)
  |> strategy
  |> working_databar_archived
}

/// Step: indicators, computed IN the working databar. `settings` supplies the
/// window sizes / KDJ periods / band multiplier from `config.gleam` (R46: a
/// pipe-call argument, not a field on this record).
///
/// This is the pipeline's THIN ADAPTER; the arithmetic lives in
/// `indicator.gleam` — the module that owns it (owner 2026-11-23: *"他的补充
/// 完全是敷衍，所以全部塞进不应该塞进去的模块，而不去新建应该用的模块"*;
/// frozen glib `indicator.gleam` is its own file and glib's `timeframe.gleam`
/// calls it the same way, `glib/timeframe.gleam:369-379`).
///
/// The step keeps the pipeline shape `fn(Timeframe, ...extra) -> Timeframe`
/// (R40 / R40-A / R41, owner 逐字 2026-11-12 — *"整个流程的在databar
/// processing 内部的主体就是一个简单的gleam经典：timeframe |> function1 |>
/// function2 …"*), so the shape stays compiler-enforced; the pure computation
/// stays in a module that never names the record (glib `indicator.gleam:9-13`:
/// *"a function that names the record cannot leave the record"*).
///
/// The COMPLETE frozen-glib indicator set (owner 2026-11-23: *"所有技术指标，
/// glib有的，你不能残缺不全"*), in the exact order of glib
/// `indicator.gleam:35-54` — see `indicator.gleam` for the list and for the
/// O(1) argument of each recurrence.
pub fn indicator(
  timeframe: Timeframe,
  settings: IntervalSettings,
) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(working) ->
      Timeframe(
        ..timeframe,
        working_databar: Some(indicator.compute_bar(
          working,
          timeframe.databar_list,
          settings,
        )),
      )
  }
}

/// Step: `YinLeaf` / `YangLeaf` recognition; a settled leaf is written into
/// a FIELD so the next step needs no extra argument (R40 / R41). It also
/// records settled leaves into four lists (R68): two complete (`leaf_size >= 2`)
/// and two significant (`leaf_size >= settings.branch_exit_leaf_size`). Those
/// lists are research records, NOT a mechanism: `branches` reads the settled
/// FIELD, never a list. `settings` is a pipe-call argument (R40-A / R46): the
/// significance threshold is the branch's own number, never a Timeframe field.
pub fn leaves(timeframe: Timeframe, settings: IntervalSettings) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(working) -> {
      // Frozen glib timeframe.gleam:515-535: born on this bar when growing is
      // None; otherwise next_*_leaf settles / reborns. last_bar is the HEAD of
      // databar_list (the bar before this one, not yet archived) — a growing
      // leaf implies a prior bar, so this head exists; match it explicitly
      // (no library let assert, core §7) and carry the leaf unchanged if not.
      let previous = list.first(timeframe.databar_list)
      let #(yin_settled, yin_grow) = case timeframe.growing_yin_leaf {
        None -> #(None, leaf.born_yin(working))
        Some(growing) ->
          case previous {
            Ok(last) -> leaf.next_yin_leaf(working, growing, last)
            Error(_) -> #(None, growing)
          }
      }
      let #(yang_settled, yang_grow) = case timeframe.growing_yang_leaf {
        None -> #(None, leaf.born_yang(working))
        Some(growing) ->
          case previous {
            Ok(last) -> leaf.next_yang_leaf(working, growing, last)
            Error(_) -> #(None, growing)
          }
      }
      // Frozen glib timeframe.gleam:542-545: the CMA is written onto the bar
      // carried by the GROWING twin after this bar's growth (on a death bar,
      // the newborn). leaf_cma reads the previous twin's CMA off the head in
      // O(1); a bar born this bar returns its own sma_tiny.
      let bar =
        databar.DataBar(
          ..working,
          yin_leaf_cma: leaf.leaf_cma(working, timeframe.databar_list, yin_grow),
          yang_leaf_cma: leaf.leaf_cma(
            working,
            timeframe.databar_list,
            yang_grow,
          ),
        )
      // R68: record the settled leaves. The complete list takes a leaf of
      // size >= 2 (a one-bar leaf is never listed, glib leaf law 4); the
      // significant list takes one that also reached the branch's own number.
      // Both cons onto the head (newest first, O(1)). These are research
      // RECORDS — `branches` reads the settled FIELD above, never these lists
      // (glib timeframe.gleam:120-127 measured that reading a branch off a
      // list drops branches).
      let exit_size = settings.branch_exit_leaf_size
      let yin_leaf_list =
        cons_if_listed(yin_settled, bar, timeframe.yin_leaf_list)
      let yang_leaf_list =
        cons_if_listed(yang_settled, bar, timeframe.yang_leaf_list)
      let signif_yin_leaf_list =
        cons_if_significant(
          yin_settled,
          bar,
          exit_size,
          timeframe.signif_yin_leaf_list,
        )
      let signif_yang_leaf_list =
        cons_if_significant(
          yang_settled,
          bar,
          exit_size,
          timeframe.signif_yang_leaf_list,
        )
      // R40/R42: settled leaves are FIELDS, not a tuple handed to branches;
      // every step takes and returns only Timeframe.
      Timeframe(
        ..timeframe,
        working_databar: Some(bar),
        growing_yin_leaf: Some(yin_grow),
        growing_yang_leaf: Some(yang_grow),
        yin_leaf_settled: yin_settled,
        yang_leaf_settled: yang_settled,
        yin_leaf_list: yin_leaf_list,
        yang_leaf_list: yang_leaf_list,
        signif_yin_leaf_list: signif_yin_leaf_list,
        signif_yang_leaf_list: signif_yang_leaf_list,
      )
    }
  }
}

/// R68: prepend a settled leaf to the complete list iff it spans >= 2 bars
/// (frozen glib `listed_leaf`, timeframe.gleam:457-469). "Settled" is what
/// happened to the leaf; "listed" is only whether it goes in the record. A
/// one-bar leaf settles and is not listed. No price is read — this is the
/// same idx arithmetic as `leaf.leaf_size` (R6).
fn cons_if_listed(
  settled: Option(DataLeaf),
  databar: DataBar,
  listed: List(DataLeaf),
) -> List(DataLeaf) {
  case settled {
    Some(gone) ->
      case leaf.leaf_size(gone, databar) >= 2 {
        True -> [gone, ..listed]
        False -> listed
      }
    None -> listed
  }
}

/// R68: prepend a settled leaf to the significant list iff it reached the
/// branch's own closing number (frozen glib `significant_leaf`,
/// timeframe.gleam:574-593). That number belongs to the branch (UC-51), so it
/// arrives from `settings`, not from the leaf. Separate from `cons_if_listed`:
/// one is the list's own rule, the other a branch number (glib's own reason for
/// keeping two functions).
fn cons_if_significant(
  settled: Option(DataLeaf),
  databar: DataBar,
  exit_size: Int,
  listed: List(DataLeaf),
) -> List(DataLeaf) {
  case settled {
    Some(gone) ->
      case leaf.leaf_size(gone, databar) >= exit_size {
        True -> [gone, ..listed]
        False -> listed
      }
    None -> listed
  }
}

/// Step: branches; reads the settled leaf fields off the record and the
/// `branch_exit_leaf_size` for this interval out of `settings` (the branch's
/// OWN closing count, glib `config.gleam:259-274`) to hand to
/// `branch.next_yang_branch` / `next_yin_branch`. It arrives as a pipe-call
/// argument (R40-A / R50), never as a `Timeframe` field (R46).
pub fn branches(timeframe: Timeframe, settings: IntervalSettings) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(working) -> {
      // Frozen glib timeframe.gleam:638-702. The exit count is THIS interval's
      // branch rule, read from settings (R40-A: a pipe-call argument, never a
      // Timeframe field, R46). The old no-arg branch.branch_exit_leaf_size()
      // was deleted — this settings value is its one real consumer.
      let exit_size = settings.branch_exit_leaf_size
      // glib: yin leaves settle -> feed the YANG branch (the opposite polarity
      // rides them, R2); the settled leaf's corner becomes its start_bar (R4/R5).
      let yin_prev = timeframe.yin_leaf_settled
      let yang_prev = timeframe.yang_leaf_settled
      // A branch is recognised on the bar a leaf of the opposite class STARTS
      // (R4): the growing twin's start_bar.idx == this bar. A growing twin
      // implies `leaves` ran, so both are Some; match explicitly (core §7).
      let yang_recognised = case timeframe.growing_yin_leaf {
        Some(riding) -> start_idx_of_leaf(riding) == working.idx
        None -> False
      }
      let yin_recognised = case timeframe.growing_yang_leaf {
        Some(riding) -> start_idx_of_leaf(riding) == working.idx
        None -> False
      }
      // glib: next_yang_branch rides the growing yin leaf; next_yin_branch
      // rides the growing yang leaf. Both helpers are filled (02-02).
      let #(yang_exited, yang_next) = case timeframe.growing_yin_leaf {
        Some(riding) ->
          branch.next_yang_branch(
            timeframe.growing_yang_branch,
            working,
            yin_prev,
            riding,
            yang_recognised,
            exit_size,
          )
        None -> #(None, timeframe.growing_yang_branch)
      }
      let #(yin_exited, yin_next) = case timeframe.growing_yang_leaf {
        Some(riding) ->
          branch.next_yin_branch(
            timeframe.growing_yin_branch,
            working,
            yang_prev,
            riding,
            yin_recognised,
            exit_size,
          )
        None -> #(None, timeframe.growing_yin_branch)
      }
      // An exited branch is prepended newest-first, O(1) (R39); none leaves
      // the list unchanged. Growing branches are carried, never rebuilt.
      let yang_branch_list = case yang_exited {
        Some(closed) -> [closed, ..timeframe.yang_branch_list]
        None -> timeframe.yang_branch_list
      }
      let yin_branch_list = case yin_exited {
        Some(closed) -> [closed, ..timeframe.yin_branch_list]
        None -> timeframe.yin_branch_list
      }
      Timeframe(
        ..timeframe,
        growing_yang_branch: yang_next,
        growing_yin_branch: yin_next,
        yang_branch_list: yang_branch_list,
        yin_branch_list: yin_branch_list,
      )
    }
  }
}

/// The idx of a leaf's `start_bar` — R4's one recognition comparison. Reads
/// one field off the bar the leaf already holds; no list walk (R39).
fn start_idx_of_leaf(riding: DataLeaf) -> Int {
  leaf.start_bar(riding).idx
}

/// Step: the strategy decision, written as a `Signal` ON the working bar
/// (R39). No `manual_enter` / `manual_exit` provisional fields.
pub fn strategy(timeframe: Timeframe) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(working) -> {
      // Frozen glib timeframe.gleam:738-754 + manual_signal (UC-62). The
      // manual strategy trades ONLY the YangBranch: a yin branch's death is a
      // branch-observer fact, not an action (a second strategy would be short
      // selling, which UC-62 rules out). Recognition = its enter_bar is this
      // bar; exit = the newest ended yang branch (list head) was found dead on
      // this bar. Both readers are head/O(1), never a list search (R39).
      let recognised_yang =
        branch.recognised_this_bar(timeframe.growing_yang_branch, working.idx)
      let exited_yang =
        option.is_some(branch.exited_branch(
          timeframe.yang_branch_list,
          working.idx,
        ))
      let mark = manual_signal(recognised_yang, exited_yang)
      // R39/R41: the signal is written onto the working bar — a bar is what
      // gets archived and published; a signal left on Timeframe no chart can
      // draw. No provisional manual_enter / manual_exit fields (owner 10-31).
      Timeframe(
        ..timeframe,
        working_databar: Some(databar.DataBar(..working, signal: mark)),
      )
    }
  }
}

/// The manual strategy's one output (UC-62, frozen glib `manual_signal`):
/// recognised yang -> buy, exited yang -> sell, else no signal. A bar carries
/// one mark; recognition and exit cannot collide (recognising a yang death
/// births the opposite branch, never another yang).
fn manual_signal(recognised_yang: Bool, exited_yang: Bool) -> signal.Signal {
  case recognised_yang, exited_yang {
    True, _ -> signal.SignalBuy
    _, True -> signal.SignalSell
    _, _ -> signal.SignalNoSignal
  }
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
