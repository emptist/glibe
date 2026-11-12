//// One instrument and the timeframes it holds. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// R50 (owner, verbatim, review of `desk.gleam`): *"should be in its own
//// file"* on this type and on `get_timeframe` / `put_timeframe`; and
//// *"what? you ask a desk to do the things that should be done by the
//// instrument? are you mad?"* — reading and writing a timeframe is THIS
//// module's work, not `Desk`'s.
////
//// READS: `Interval`, `Timeframe`.
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
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/dict.{type Dict}
import glibe/api/interval.{type Interval}
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
