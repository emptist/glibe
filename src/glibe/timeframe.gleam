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

import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection} as sb
import glibe/branch.{type DataBranch}
import glibe/config.{type IntervalSettings}
import glibe/databar.{type DataBar}
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
  |> leaves
  |> branches(settings)
  |> strategy
  |> working_databar_archived
}

/// Step: indicators, computed IN the working databar. `settings` supplies the
/// window sizes / KDJ periods / band multiplier from `config.gleam` (R46: a
/// pipe-call argument, not a field on this record).
///
/// Three O(1) recurrences, ported from the frozen glib source
/// (`sma.gleam:60-89`, `bollinger.gleam:123-186`, `kdj.gleam:15-139`):
/// SMA carries its mean and adds the arriving close / subtracts the one
/// leaving (never a full-window fold); σ carries a Welford M2 state and does
/// the same; KDJ caches the window extremes and rescans only when the leaving
/// bar was an extreme. No `Σx²−(Σx)²/n`, no per-bar window walk.
///
/// The COMPLETE frozen-glib indicator set (owner 2026-11-23: *"所有技术指标，
/// glib有的，你不能残缺不全"*), in the exact order of glib
/// `indicator.gleam:35-54`:
///   1. all five SMA series (tiny/small/medium/large/huge) — `sma_series_stream`;
///   2. `bb_m` = `sma_of(working, settings.sma_for_bbm)` — the SELECTED centre,
///      never a hard-coded `sma_medium` (glib `indicator.gleam:45`); week and
///      month select small/tiny, which is now possible because the bar carries
///      all five series;
///   3. Welford σ over that centre's OWN span — `size_of(settings,
///      settings.sma_for_bbm)` (glib `bollinger.gleam:165`);
///   4. all seven Bollinger lines — `band` + `write_band`; the lower edge is
///      floored BEFORE the 0.618/0.382 interpolation (glib
///      `bollinger.gleam:199-246`);
///   5. KDJ — `kdj_stream`: cached-extreme RSV, K/D/J and M (glib
///      `kdj.gleam:15-72`).
///
/// Every recurrence is O(1): add-arriving/subtract-leaving (SMA, M), a Welford
/// M2 state (σ), cached-extreme amortised rescan (KDJ). No `Σx²−(Σx)²/n`, no
/// per-bar window walk.
pub fn indicator(
  timeframe: Timeframe,
  settings: IntervalSettings,
) -> Timeframe {
  case timeframe.working_databar {
    None -> timeframe
    Some(working) -> {
      let settled = timeframe.databar_list
      // 1. All five SMA series — each an O(1) add-arriving / subtract-leaving
      //    recurrence carried on its own field (glib indicator.gleam:40-44).
      let working =
        sma_series_stream(working, settled, settings, config.SmaTiny)
      let working =
        sma_series_stream(working, settled, settings, config.SmaSmall)
      let working =
        sma_series_stream(working, settled, settings, config.SmaMedium)
      let working =
        sma_series_stream(working, settled, settings, config.SmaLarge)
      let working =
        sma_series_stream(working, settled, settings, config.SmaHuge)
      // 2. bb_m is the SELECTED centre, never recomputed (glib
      //    indicator.gleam:45). σ spans that centre's own window (glib
      //    bollinger.gleam:165): week/month select small/tiny, now possible
      //    because the bar carries all five series.
      let bb_m = sma_of(working, settings.sma_for_bbm)
      let #(sigma, sigma_state) =
        sigma_stream(working, settled, size_of(settings, settings.sma_for_bbm))
      // 3. All seven Bollinger lines, lower edge floored then interpolated.
      let lines = band(bb_m, sigma, settings.bb_multiplier)
      let working = write_band(working, lines, sigma_state)
      // 4. KDJ — cached-extreme RSV, K/D/J and the O(1) rolling mean M.
      let bar = kdj_stream(working, settled, settings)
      Timeframe(..timeframe, working_databar: Some(bar))
    }
  }
}

/// The streaming mean over ANY raw field — the one recurrence behind all five
/// SMA series AND KDJ's M (glib `sma.gleam:60-89` / `kdj.gleam:55-63`).
/// `raw_of` reads the value to average, `read_mean` the previous bar's carried
/// mean, `write_mean` writes the new one. Invertible: add the arriving value,
/// subtract the one that left — no fold over the window, no `Σx²` trick.
/// `settled` is newest-first and does NOT include `working`; `size` includes
/// the bar in hand.
fn sma_stream(
  working: DataBar,
  settled: List(DataBar),
  size: Int,
  raw_of: fn(DataBar) -> Float,
  read_mean: fn(DataBar) -> Float,
  write_mean: fn(DataBar, Float) -> DataBar,
) -> DataBar {
  let arriving = raw_of(working)
  case list.split(settled, size - 1) {
    // Nothing settled (or a span of one): the mean is the bar's own value.
    #([], _) -> write_mean(working, arriving)
    // Fewer settled than the span: none has left; divide by bars held.
    #([previous, ..] as held, []) -> {
      let divisor = int.to_float(list.length(held))
      let mean =
        { divisor *. read_mean(previous) +. arriving } /. { divisor +. 1.0 }
      write_mean(working, mean)
    }
    // Full window: add the arriving value, subtract the one that left.
    #([previous, ..], [leaving, ..]) -> {
      let divisor = int.to_float(size)
      let mean =
        { divisor *. read_mean(previous) +. arriving -. raw_of(leaving) }
        /. divisor
      write_mean(working, mean)
    }
  }
}

/// One SMA series: a moving average of `close` written to the named field.
/// Thin wrapper binding `sma_stream` to that field's accessors — the five
/// calls in `indicator` differ only in `name` (glib `sma.sma_series:94-108`).
fn sma_series_stream(
  working: DataBar,
  settled: List(DataBar),
  settings: IntervalSettings,
  name: config.SmaSeries,
) -> DataBar {
  sma_stream(
    working,
    settled,
    size_of(settings, name),
    fn(b) { b.close },
    fn(b) { sma_of(b, name) },
    fn(b, v) { set_sma_of(b, name, v) },
  )
}

/// Read the named SMA series off a bar (glib `sma.sma_of:18-26`).
fn sma_of(bar: DataBar, name: config.SmaSeries) -> Float {
  case name {
    config.SmaTiny -> bar.sma_tiny
    config.SmaSmall -> bar.sma_small
    config.SmaMedium -> bar.sma_medium
    config.SmaLarge -> bar.sma_large
    config.SmaHuge -> bar.sma_huge
  }
}

/// Write the named SMA series onto a bar (glib `sma.set_sma_of:29-37`).
fn set_sma_of(bar: DataBar, name: config.SmaSeries, value: Float) -> DataBar {
  case name {
    config.SmaTiny -> databar.DataBar(..bar, sma_tiny: value)
    config.SmaSmall -> databar.DataBar(..bar, sma_small: value)
    config.SmaMedium -> databar.DataBar(..bar, sma_medium: value)
    config.SmaLarge -> databar.DataBar(..bar, sma_large: value)
    config.SmaHuge -> databar.DataBar(..bar, sma_huge: value)
  }
}

/// The named series' window, in bars (glib `sma.size_of:40-48`).
fn size_of(settings: IntervalSettings, name: config.SmaSeries) -> Int {
  case name {
    config.SmaTiny -> settings.sma_tiny_window_size
    config.SmaSmall -> settings.sma_small_window_size
    config.SmaMedium -> settings.sma_medium_window_size
    config.SmaLarge -> settings.sma_large_window_size
    config.SmaHuge -> settings.sma_huge_window_size
  }
}

/// Welford moving-window σ over the closes. Returns σ and the carried state
/// #(n, mean, m2) to store on the bar for the next one (glib
/// `bollinger.gleam:160-186`). `sigma_add` then the inverse `sigma_remove`
/// keeps the window sliding in O(1) without materialising it (UC-63).
fn sigma_stream(
  working: DataBar,
  settled: List(DataBar),
  size: Int,
) -> #(Float, #(Int, Float, Float)) {
  let #(n, mean, m2) = case list.first(settled) {
    Ok(b) -> #(b.sigma_n, b.sigma_mean, b.sigma_m2)
    Error(_) -> #(0, 0.0, 0.0)
  }
  let #(an, amean, am2) = sigma_add(n, mean, m2, working.close)
  let state = case n >= size {
    True -> {
      let leaving = case list.drop(settled, size - 1) |> list.first {
        Ok(b) -> b.close
        Error(_) -> working.close
      }
      sigma_remove(an, amean, am2, leaving)
    }
    False -> #(an, amean, am2)
  }
  let sigma = case state.0 {
    0 -> 0.0
    _ ->
      result.unwrap(
        float.square_root(float.max(0.0, state.2 /. int.to_float(state.0))),
        0.0,
      )
  }
  #(sigma, state)
}

/// The one artificial floor on the lower edge, as a FRACTION of the centre —
/// glib `bollinger.gleam:121`. A fraction (not a fixed constant) cannot invert
/// the band order at any price: bb_l3 becomes `1e-6·bb_m`, below bb_m whatever
/// bb_m is, and the inner lines are convex blends of that edge and the basis.
pub const band_floor_ratio: Float = 0.000001

/// The seven Bollinger lines from the centre and σ (glib
/// `bollinger.gleam:199-225`). The lower edge is floored BEFORE interpolation,
/// so one floor suffices and `l3 ≤ l2 ≤ l1 ≤ m ≤ u1 ≤ u2 ≤ u3` holds by
/// construction. The inner lines blend edge and basis at 0.382 / 0.618.
fn band(
  bb_m: Float,
  sigma: Float,
  width: Float,
) -> #(Float, Float, Float, Float, Float, Float, Float) {
  let bb_u3 = bb_m +. width *. sigma
  let raw_l3 = bb_m -. width *. sigma
  // The floor is ordinary traffic, not a guard: the raw edge is at or below
  // zero on ~3% of glib's own bars (bollinger.gleam:205-206).
  let bb_l3 = case raw_l3 <=. 0.0 {
    True -> bb_m *. band_floor_ratio
    False -> raw_l3
  }
  #(
    bb_m,
    bb_u3,
    bb_l3,
    0.618 *. bb_u3 +. 0.382 *. bb_m,
    // bb_u2
    0.382 *. bb_u3 +. 0.618 *. bb_m,
    // bb_u1
    0.382 *. bb_l3 +. 0.618 *. bb_m,
    // bb_l1
    0.618 *. bb_l3 +. 0.382 *. bb_m,
    // bb_l2
  )
}

/// Write all seven lines plus the σ state onto the working bar (glib
/// `bollinger.set_bband:232-246`).
fn write_band(
  bar: DataBar,
  lines: #(Float, Float, Float, Float, Float, Float, Float),
  state: #(Int, Float, Float),
) -> DataBar {
  databar.DataBar(
    ..bar,
    bb_m: lines.0,
    bb_u3: lines.1,
    bb_l3: lines.2,
    bb_u2: lines.3,
    bb_u1: lines.4,
    bb_l1: lines.5,
    bb_l2: lines.6,
    sigma_n: state.0,
    sigma_mean: state.1,
    sigma_m2: state.2,
  )
}

fn sigma_add(n: Int, mean: Float, m2: Float, x: Float) -> #(Int, Float, Float) {
  let next = n + 1
  let delta = x -. mean
  let next_mean = mean +. delta /. int.to_float(next)
  let delta2 = x -. next_mean
  #(next, next_mean, m2 +. delta *. delta2)
}

fn sigma_remove(
  n: Int,
  mean: Float,
  m2: Float,
  x: Float,
) -> #(Int, Float, Float) {
  let next = n - 1
  let delta = x -. mean
  let next_mean = mean -. delta /. int.to_float(next)
  let delta2 = x -. next_mean
  #(next, next_mean, m2 -. delta *. delta2)
}

/// KDJ on the working bar, ported from glib `kdj.gleam:15-72`: RSV from
/// cached extremes (amortised O(1) rescan only when the leaving bar WAS an
/// extreme), then K/D/J rolling with one alpha seeded at 50, then M: the O(1)
/// rolling mean of this bar's freshly computed K over `kdj_m_period`.
fn kdj_stream(
  working: DataBar,
  settled: List(DataBar),
  settings: IntervalSettings,
) -> DataBar {
  let #(highest, h_idx, lowest, l_idx) =
    rsv_extrema(working, settled, settings.kdj_window_size)
  let rsv = case highest -. lowest <=. 0.0001 {
    True -> 50.0
    False -> { working.close -. lowest } /. { highest -. lowest } *. 100.0
  }
  let alpha = 1.0 /. int.to_float(settings.kdj_k_period)
  let #(prev_k, prev_d) = case list.first(settled) {
    Ok(b) -> #(b.k, b.d)
    Error(_) -> #(50.0, 50.0)
  }
  let k = { 1.0 -. alpha } *. prev_k +. alpha *. rsv
  let d = { 1.0 -. alpha } *. prev_d +. alpha *. k
  let j = 3.0 *. k -. 2.0 *. d
  // K/D/J are written BEFORE M, because M reads this bar's freshly computed K
  // (glib kdj.gleam:46-63). M is the rolling mean of K over kdj_m_period, the
  // same O(1) sma_stream recurrence — no array mean, no window walk.
  let bar =
    databar.DataBar(..working, k: k, d: d, j: j)
    |> sma_stream(
      settled,
      settings.kdj_m_period,
      fn(b) { b.k },
      fn(b) { b.m },
      fn(b, v) { databar.DataBar(..b, m: v) },
    )
  databar.DataBar(
    ..bar,
    kdj_h: highest,
    kdj_h_idx: h_idx,
    kdj_l: lowest,
    kdj_l_idx: l_idx,
  )
}

/// The cached highest-high / lowest-low of the window ending at `working` and
/// the idx of each (glib `kdj.gleam:79-114`). If the bar leaving the window is
/// not a cached extreme, only the new bar is folded in; otherwise one rescan.
fn rsv_extrema(
  working: DataBar,
  settled: List(DataBar),
  w: Int,
) -> #(Float, Int, Float, Int) {
  let #(prev_h, prev_h_idx, prev_l, prev_l_idx) = case list.first(settled) {
    Ok(b) -> #(b.kdj_h, b.kdj_h_idx, b.kdj_l, b.kdj_l_idx)
    Error(_) -> #(working.high, working.idx, working.low, working.idx)
  }
  let leaving_idx = working.idx - w
  case leaving_idx == prev_h_idx || leaving_idx == prev_l_idx {
    True -> rescan_window(working, settled, w)
    False -> {
      let h_idx = case working.high >. prev_h {
        True -> working.idx
        False -> prev_h_idx
      }
      let l_idx = case working.low <. prev_l {
        True -> working.idx
        False -> prev_l_idx
      }
      #(
        float.max(prev_h, working.high),
        h_idx,
        float.min(prev_l, working.low),
        l_idx,
      )
    }
  }
}

/// The rare path: rescan the bar in hand plus the `w - 1` settled bars before
/// it (glib `kdj.gleam:119-139`, `batch_window`). O(w) only when an extreme
/// left the window; this is the amortised-rescan path, NOT the banned per-bar
/// full-window recompute.
fn rescan_window(
  working: DataBar,
  settled: List(DataBar),
  w: Int,
) -> #(Float, Int, Float, Int) {
  list.take(settled, w - 1)
  |> list.fold(
    #(working.high, working.idx, working.low, working.idx),
    fn(acc, b) {
      let h_idx = case b.high >. acc.0 {
        True -> b.idx
        False -> acc.1
      }
      let l_idx = case b.low <. acc.2 {
        True -> b.idx
        False -> acc.3
      }
      #(float.max(acc.0, b.high), h_idx, float.min(acc.2, b.low), l_idx)
    },
  )
}

/// Step: `YinLeaf` / `YangLeaf` recognition; a settled leaf is written into
/// a FIELD so the next step needs no extra argument (R40 / R41).
pub fn leaves(timeframe: Timeframe) -> Timeframe {
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
      // R40/R42: settled leaves are FIELDS, not a tuple handed to branches;
      // every step takes and returns only Timeframe.
      Timeframe(
        ..timeframe,
        working_databar: Some(bar),
        growing_yin_leaf: Some(yin_grow),
        growing_yang_leaf: Some(yang_grow),
        yin_leaf_settled: yin_settled,
        yang_leaf_settled: yang_settled,
      )
    }
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

/// Why `indicator.single_bar_test` refused a bar — glib
/// `indicator.gleam:80-82`. Names the two bands that broke the strict order
/// and the bar they broke it on, so a failure points at a bar to inspect.
pub type BarError {
  BandOutOfOrder(lower: Float, upper: Float, idx: Int)
}

/// The runtime check on the bar `indicator` produced (glib
/// `indicator.gleam:84-103`, UC-60): the seven bands are strictly ordered
/// l3 ≤ l2 ≤ l1 ≤ m ≤ u1 ≤ u2 ≤ u3. A sign bug in σ or an interpolation error
/// breaks one of the six adjacent pairs; so does a NaN (every comparison
/// against NaN is false). Returns the first broken pair instead of crashing,
/// so one bad bar cannot abort a whole census.
pub fn single_bar_test(bar: DataBar) -> Result(Nil, BarError) {
  let pairs = [
    #(bar.bb_l3, bar.bb_l2),
    #(bar.bb_l2, bar.bb_l1),
    #(bar.bb_l1, bar.bb_m),
    #(bar.bb_m, bar.bb_u1),
    #(bar.bb_u1, bar.bb_u2),
    #(bar.bb_u2, bar.bb_u3),
  ]
  case list.find(pairs, fn(pair) { !ordered(pair.0, pair.1) }) {
    Ok(pair) -> Error(BandOutOfOrder(pair.0, pair.1, bar.idx))
    Error(_) -> Ok(Nil)
  }
}

/// The printed form of a refusal — glib `indicator.gleam:106-116`.
pub fn bar_error_text(error: BarError) -> String {
  case error {
    BandOutOfOrder(lower, upper, idx) ->
      "bands out of order on bar "
      <> int.to_string(idx)
      <> ": "
      <> float.to_string(lower)
      <> " should be at most "
      <> float.to_string(upper)
  }
}

/// Band ordering tolerant of float representation, not of a bug (glib
/// `indicator.gleam:132-135`). Bands mathematically equal can differ by one
/// unit in the last place and land on the wrong side of `<=.`; the slack is
/// one part in a billion of the band's own size, so a whole-sigma inversion
/// still fails.
fn ordered(lower: Float, upper: Float) -> Bool {
  let slack = float_max(float.absolute_value(upper) *. 1.0e-9, 1.0e-12)
  lower <=. upper +. slack
}

/// `gleam/float` has no `max` — glib `indicator.gleam:138-143`.
fn float_max(a: Float, b: Float) -> Float {
  case a >=. b {
    True -> a
    False -> b
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
