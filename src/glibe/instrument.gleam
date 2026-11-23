//// One instrument and the timeframes it holds. Implements
//// `.planning/BRIEF.md`.
////
//// R50 (owner, verbatim, review of `desk.gleam`): *"should be in its own
//// file"* on this type and on `get_timeframe` / `put_timeframe`; and
//// *"what? you ask a desk to do the things that should be done by the
//// instrument? are you mad?"* — reading and writing a timeframe is THIS
//// module's work, not `Desk`'s.
////
//// READS: `Interval`, `Timeframe`, `SourceBar`, `IbSourceBar`.
//// WRITES: `Instrument.timeframes` — the ONE Dict this level holds.
//// `get_timeframe` reads the timeframe under an interval key;
//// `put_timeframe` writes the recomputed one back under that key. Both
//// take an `Instrument` as their subject, never a `Desk`. A missing key
//// is `Nil` (core §6 / R37); see `id.gleam`.
////
//// R23 / R37: identity lives in the holder's Dict key. ONE dictionary,
//// not two; no composite string key, no `list.find`. The `Interval` is the
//// key here and is NOT a field of `Timeframe` — *"你的左手不知道他是左还是
//// 右"*. The `Symbol` naming this instrument is the key in
//// `Broker.instruments` (R22) and is not stored here either.
////
//// WHY COMPOSITION IS AT THIS LAYER (owner 2026-11-13): *"what timeframe
//// will get what kind of target (interval), this is KNOWN to Instument,
//// and the composing work seems ought to be at instument layer, you can
//// try it in different layers to see which one can make types satisfied
//// in the most natural simplest way"*. Three shapes were compiled in a
//// throwaway package (`/tmp/glibe_layer_probe/src/layer_probe.gleam`,
//// `gleam build` exit 0 for all three, 0 errors); the difference is who
//// is forced to carry a value it does not own:
//// ① THIS layer — `case interval` uses the key of the Dict it already
////    holds, and `growing_target_sourcebar` is a `Timeframe` field.
////    Nothing is handed down. **This is the shape used here.**
//// ② `timeframe.gleam` — `Interval` would have to be passed DOWN to a
////    value that cannot know its own name (R37), and the closed
////    `SourceBar` has no exit from there.
//// ③ the input boundary — `growing_target_sourcebar` would leave the
////    `Timeframe`, and the key held here would be wasted.
//// So `Instrument` is the ONE place that knows which timeframe gets which
//// interval. It still does not define a composition function: R50 (owner,
//// verbatim) *"even if it is called, it should be defined in its
//// belonging to module"*, and owner 2026-11-13 put
//// `five_second_to_one_minute` and its siblings in `ib/sourcebar.gleam`.
//// A CALL SITE is not an owner; this module only dispatches by its key.
////
//// THE TARGET INTERVAL IS NEVER A FIELD. `Timeframe.growing_target_sourcebar`
//// is an `Option(SourceBar)` and the bar's variant IS its interval —
//// `SourceBarOneHour` and friends. That is why adding this field does NOT
//// give a `Timeframe` an `interval` field: the period is in the type, not
//// in the record (owner: *"校服就是变体，通过类型即可知道是什么"*). The
//// nine `Interval` constructors are the whole `case` below; a tenth interval
//// is a compile error here and in `sourcebar.interval` (R13).
////
//// THIS IS NOT THE `working_databar` ACCUMULATOR. R39 struck
//// `fold_sourcebar(working, bar)` for
//// accumulating source bars INSIDE `working_databar`. Here the growing
//// bar is a DIFFERENT field of a DIFFERENT type; only when the UTC grid
//// period is reached is ONE whole `SourceBar` emitted for
//// `sourcebar.validate` → `sourcebar.to_databar` → `sourcebar_gate`, and
//// `databar_processing` then receives a `DataBar` whose period will never
//// change again. No actor, scheduler, clock or poll (R33).
////
//// R65 §3 / R69 §3 (owner *"谁，在哪里，生成 timeframe？"*): THIS is the
//// birth point of a `Timeframe`. `timeframe_at` reads `Instrument.timeframes`
//// under the `Interval` key and, on a miss, writes the `Timeframe`
//// constructor directly at the point of need (R64 — the constructor IS the
//// birth, no `new`); `put_timeframe` writes the recomputed one back under the
//// same key in the same step (R50). No type changes: `growing_target_sourcebar`
//// stays a `Timeframe` field, `sourcebar_gate` stays in `timeframe.gleam`
//// (R70/R71). The same rule is applied one level up (`desk.broker_at`,
//// `broker.instrument_at`).
////
//// R19 status: 4 bodies filled — `timeframe_at` (RED→GREEN via
//// `test/runtime_publish_test.gleam`), `get_timeframe` / `put_timeframe`
//// (the Dict read / write pair) and `compose_ib_realtime_bar` (dispatch by
//// the `Interval` key). Pinned by `instrument_timeframes_round_trip_test` and
//// `instrument_compose_first_bar_test` in `test/glibe_test.gleam`.
//// No `todo` remains here.

import gleam/dict.{type Dict}
import gleam/option.{type Option, None}
import glibe/api/interval.{
  type Interval, IntervalFifteenMinute, IntervalFourHour, IntervalOneDay,
  IntervalOneHour, IntervalOneMinute, IntervalOneMonth, IntervalOneWeek,
  IntervalThirtyMinute, IntervalThreeMinute,
}
import glibe/api/sourcebar.{type SourceBar}
import glibe/ib/sourcebar as ib_sourcebar
import glibe/timeframe.{type Timeframe, Timeframe}

/// One instrument: the thing traded, owned by one broker under one name.
/// It stores its timeframes and nothing about its own identity.
pub type Instrument {
  Instrument(timeframes: Dict(Interval, Timeframe))
}

// The ONE dispatch body shared by all nine `case interval` arms below. READS
// the timeframe under `key` from this instrument's Dict and that timeframe's
// `growing_target_sourcebar`; WRITES the new growing value back into the
// timeframe (record update) and the recomputed timeframe back under the key.
// `compose` is the provider function — the caller passes the one whose NAME
// fixes the target interval, so no Interval parameter can disagree with it
// (R23 / R37). The return type has NO error channel and R33 has the system
// already live as ONE Value: a timeframe for this key exists from the
// instrument's own setup, so a missing key has nothing to compose and the
// instrument is returned unchanged (no panic, no invented timeframe — R49).
fn dispatch_compose(
  instrument: Instrument,
  key: Interval,
  arriving: ib_sourcebar.IbSourceBar,
  compose: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)),
) -> #(Option(SourceBar), Instrument) {
  case get_timeframe(instrument, key) {
    Error(Nil) -> #(None, instrument)
    Ok(timeframe) -> {
      let #(closed, growing) =
        compose(timeframe.growing_target_sourcebar, arriving)
      let updated = Timeframe(..timeframe, growing_target_sourcebar: growing)
      #(closed, put_timeframe(instrument, key, updated))
    }
  }
}

/// READ down: the timeframe under this interval key.
pub fn get_timeframe(
  instrument: Instrument,
  interval: Interval,
) -> Result(Timeframe, Nil) {
  let Instrument(timeframes) = instrument
  dict.get(timeframes, interval)
}

/// READ down, with the birth of an empty holder on a miss: the timeframe
/// under this interval key, or a fresh `Timeframe` written directly here
/// (R64 — no `new`). It is only a READ of `Instrument.timeframes`;
/// `put_timeframe` in the same step writes the recomputed one back (R50).
/// The record is the same empty holder the tests build in `test/fixture.gleam`
/// — no field is invented here, and no settings field exists (R46).
pub fn timeframe_at(instrument: Instrument, interval: Interval) -> Timeframe {
  case get_timeframe(instrument, interval) {
    Ok(timeframe) -> timeframe
    Error(Nil) ->
      Timeframe(
        growing_target_sourcebar: None,
        working_databar: None,
        databar_list: [],
        growing_yin_leaf: None,
        growing_yang_leaf: None,
        yin_leaf_list: [],
        yang_leaf_list: [],
        signif_yin_leaf_list: [],
        signif_yang_leaf_list: [],
        growing_yin_branch: None,
        growing_yang_branch: None,
        yin_branch_list: [],
        yang_branch_list: [],
        yin_leaf_settled: None,
        yang_leaf_settled: None,
      )
  }
}

/// WRITE: the recomputed timeframe back under this interval key.
pub fn put_timeframe(
  instrument: Instrument,
  interval: Interval,
  timeframe: Timeframe,
) -> Instrument {
  let Instrument(timeframes) = instrument
  Instrument(dict.insert(timeframes, interval, timeframe))
}

/// ONE arriving IB five-second bar, composed into the timeframe named by
/// `interval`. Reads `Instrument.timeframes` under that key and reads that
/// `Timeframe.growing_target_sourcebar`; `case interval` selects ONE of
/// the nine `ib_sourcebar.five_second_to_*` functions (the target interval is
/// in the function name, never a parameter that could disagree with the
/// key). Writes the new growing value back into that `Timeframe` and puts
/// the recomputed timeframe back under the same key.
///
/// Returns `#(closed, instrument)`: `closed` is `Some(SourceBar)` ONLY
/// on the bar whose `Timestamp` reaches the UTC grid boundary, and is the ONE
/// whole standard bar handed to `sourcebar.validate`; `None` on every
/// other bar. `growing_target_sourcebar` has the three states of
/// `working_databar` — `None → Some(bar) → None` (R39). The call happens
/// ONCE per arriving bar: no list, no batch, no saved bars (owner
/// 2026-11-13). A provider that already serves every interval (Binance) has
/// no such function here — a one-to-one `kline.to_sourcebar` already gives
/// one closed `SourceBar` of the right variant (R28).
///
/// If no timeframe exists under `interval`, there is nothing to compose
/// into: the instrument is returned unchanged and `closed` is `None`. The
/// return type carries no error channel and this function does not birth one
/// (R49) — the birth point is `timeframe_at` above (R74); this composition
/// step only reads and updates a timeframe that is already present.
pub fn compose_ib_realtime_bar(
  instrument: Instrument,
  interval: Interval,
  arriving: ib_sourcebar.IbSourceBar,
) -> #(Option(SourceBar), Instrument) {
  // The nine arms ARE the nine `Interval` constructors: an incomplete
  // `case` is a compile error (R13), so the key and the nine target intervals
  // are ONE closed set. Each arm hands `dispatch_compose` the ONE provider
  // function whose name fixes that interval. A missing key returns the
  // instrument unchanged (see `dispatch_compose`): the return type has no
  // error channel and there is no timeframe to compose into.
  case interval {
    IntervalOneMinute ->
      dispatch_compose(
        instrument,
        interval,
        arriving,
        ib_sourcebar.five_second_to_one_minute,
      )
    IntervalThreeMinute ->
      dispatch_compose(
        instrument,
        interval,
        arriving,
        ib_sourcebar.five_second_to_three_minute,
      )
    IntervalFifteenMinute ->
      dispatch_compose(
        instrument,
        interval,
        arriving,
        ib_sourcebar.five_second_to_fifteen_minute,
      )
    IntervalThirtyMinute ->
      dispatch_compose(
        instrument,
        interval,
        arriving,
        ib_sourcebar.five_second_to_thirty_minute,
      )
    IntervalOneHour ->
      dispatch_compose(
        instrument,
        interval,
        arriving,
        ib_sourcebar.five_second_to_one_hour,
      )
    IntervalFourHour ->
      dispatch_compose(
        instrument,
        interval,
        arriving,
        ib_sourcebar.five_second_to_four_hour,
      )
    IntervalOneDay ->
      dispatch_compose(
        instrument,
        interval,
        arriving,
        ib_sourcebar.five_second_to_one_day,
      )
    IntervalOneWeek ->
      dispatch_compose(
        instrument,
        interval,
        arriving,
        ib_sourcebar.five_second_to_one_week,
      )
    IntervalOneMonth ->
      dispatch_compose(
        instrument,
        interval,
        arriving,
        ib_sourcebar.five_second_to_one_month,
      )
  }
}
