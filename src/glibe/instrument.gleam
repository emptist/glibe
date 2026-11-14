//// One instrument and the timeframes it holds. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
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
//// grade. It still does not define a composition function: R50 (owner,
//// verbatim) *"even if it is called, it should be defined in its
//// belonging to module"*, and owner 2026-11-13 put
//// `five_second_to_one_minute` and its siblings in `ib/sourcebar.gleam`.
//// A CALL SITE is not an owner; this module only dispatches by its key.
////
//// THE TARGET GRADE IS NEVER A FIELD. `Timeframe.growing_target_sourcebar`
//// is an `Option(SourceBar)` and the bar's variant IS its grade —
//// `SourceBarOneHour` and friends. That is why adding this field does NOT
//// give a `Timeframe` an `interval` field: the period is in the type, not
//// in the record (owner: *"校服就是变体，通过类型即可知道是什么"*). The
//// nine `Interval` constructors are the whole `case` below; a tenth grade
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
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/dict.{type Dict}
import gleam/option.{type Option}
import glibe/api/interval.{
  type Interval, IntervalFifteenMinute, IntervalFourHour, IntervalOneDay,
  IntervalOneHour, IntervalOneMinute, IntervalOneMonth, IntervalOneWeek,
  IntervalThirtyMinute, IntervalThreeMinute,
}
import glibe/api/sourcebar.{type SourceBar}
import glibe/ib/sourcebar as ib_sourcebar
import glibe/timeframe.{type Timeframe}

/// One instrument: the thing traded, owned by one broker under one name.
/// It stores its timeframes and nothing about its own identity.
pub type Instrument {
  Instrument(timeframes: Dict(Interval, Timeframe))
}

/// READ down: the timeframe under this interval key.
pub fn get_timeframe(
  instrument: Instrument,
  interval: Interval,
) -> Result(Timeframe, Nil) {
  todo as "05-01: read the timeframe named by the instrument's key"
}

/// WRITE: the recomputed timeframe back under this interval key.
pub fn put_timeframe(
  instrument: Instrument,
  interval: Interval,
  timeframe: Timeframe,
) -> Instrument {
  todo as "05-01: write back the recomputed timeframe"
}

/// ONE arriving IB five-second bar, composed into the timeframe named by
/// `interval`. Reads `Instrument.timeframes` under that key and reads that
/// `Timeframe.growing_target_sourcebar`; `case interval` selects ONE of
/// the nine `ib_sourcebar.five_second_to_*` functions (the target grade is
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
/// 2026-11-13). A provider that already serves every grade (Binance) has
/// no such function here — a one-to-one `kline.to_sourcebar` already gives
/// one closed `SourceBar` of the right variant (R28).
pub fn compose_ib_realtime_bar(
  instrument: Instrument,
  interval: Interval,
  arriving: ib_sourcebar.IbSourceBar,
) -> #(Option(SourceBar), Instrument) {
  // Owner review 2026-11-14 (verbatim): *"you can still do meaningful basic
  // things with todo here, for example, a case match to todo in each case,
  // so you can find if the args are designed well"*. The nine arms ARE the
  // nine `Interval` constructors: an incomplete `case` is a compile error
  // (R13), so this skeleton is the check that the key and the nine target
  // grades are ONE closed set. Each arm still names the ONE provider
  // function it will dispatch to; the read/write pair comes with its body.
  case interval {
    IntervalOneMinute ->
      todo as "05-01: ib_sourcebar.five_second_to_one_minute; read and write growing_target_sourcebar"
    IntervalThreeMinute ->
      todo as "05-01: ib_sourcebar.five_second_to_three_minute; read and write growing_target_sourcebar"
    IntervalFifteenMinute ->
      todo as "05-01: ib_sourcebar.five_second_to_fifteen_minute; read and write growing_target_sourcebar"
    IntervalThirtyMinute ->
      todo as "05-01: ib_sourcebar.five_second_to_thirty_minute; read and write growing_target_sourcebar"
    IntervalOneHour ->
      todo as "05-01: ib_sourcebar.five_second_to_one_hour; read and write growing_target_sourcebar"
    IntervalFourHour ->
      todo as "05-01: ib_sourcebar.five_second_to_four_hour; read and write growing_target_sourcebar"
    IntervalOneDay ->
      todo as "05-01: ib_sourcebar.five_second_to_one_day; read and write growing_target_sourcebar"
    IntervalOneWeek ->
      todo as "05-01: ib_sourcebar.five_second_to_one_week; read and write growing_target_sourcebar"
    IntervalOneMonth ->
      todo as "05-01: ib_sourcebar.five_second_to_one_month; read and write growing_target_sourcebar"
  }
}
