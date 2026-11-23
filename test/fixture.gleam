//// The model's records, built once for the whole test tree.
////
//// WHY THIS MODULE EXISTS (2026-11-23): the empty `Timeframe` was spelled out
//// field by field in **six** places — `glibe_test`, `domain_steps_test`,
//// `timeframe_steps_test`, `runtime_publish_test` and `dashboard_test` each
//// carried their own copy. A Gleam record constructor must be given EVERY
//// field, so the day the `Timeframe` record grows one (R32: fields land one at
//// a time, as their consumers appear) those six constructor sites break at
//// once — six edits for one fact.
////
//// This module is the ONE place the record's field list is written. Each test
//// file keeps its own readable name for the shape it wants, as a one-line
//// delegation, so the tests still read the way they did.
////
//// NO argument-less birth helper (owner 2026-11-23: *"在新生 timeframe 的时候，
//// 不应该有一个什么 new，因为 type 定义本身，已经包含了 constructor，就应该直接用来
//// 生成。"*). So there is no `empty_timeframe()` here — a function that takes
//// nothing and hands back a fresh record IS the `new` the owner ruled out. The
//// record is built **directly**, inside the one function that needs it, and a
//// caller that wants an empty one says so by its arguments:
//// `timeframe_with(None, [])`.
////
//// It is TEST-ONLY and cannot ship: it lives under `test/`, so `src/` can
//// never import it. It holds no production logic — every value here is a
//// plain record with nothing in it, which is why the production code has no
//// way to build one either (the birth of a `Timeframe` is a decision the
//// owner still has to rule on).

import gleam/dict
import gleam/option.{type Option, None}
import glibe/api/interval.{IntervalOneMinute}
import glibe/api/symbol
import glibe/broker
import glibe/databar.{type DataBar}
import glibe/desk.{type Desk, Desk}
import glibe/id
import glibe/instrument
import glibe/timeframe

/// A Timeframe carrying the bar being worked and the history already archived.
/// `working` is `None` for a record that has never been worked, and `settled`
/// is the archived history — `timeframe_with(None, [])` is the empty holder.
///
/// The record is written **here, directly** — no `new`, no wrapper that hides
/// the constructor (owner 2026-11-23).
pub fn timeframe_with(
  working: Option(DataBar),
  settled: List(DataBar),
) -> timeframe.Timeframe {
  timeframe.Timeframe(
    growing_target_sourcebar: None,
    working_databar: working,
    databar_list: settled,
    growing_yin_leaf: None,
    growing_yang_leaf: None,
    growing_yin_branch: None,
    growing_yang_branch: None,
    yin_branch_list: [],
    yang_branch_list: [],
    yin_leaf_settled: None,
    yang_leaf_settled: None,
  )
}

/// A Desk holding one broker -> one instrument -> one timeframe, so a bar for
/// that identity has somewhere to land. The identity is `broker-1` / `BTCUSD`
/// / one minute.
pub fn desk_with_one_timeframe() -> Desk {
  let instrument_value =
    instrument.Instrument(
      dict.from_list([
        #(IntervalOneMinute, timeframe_with(None, [])),
      ]),
    )
  let broker_value =
    broker.Broker(
      instruments: dict.from_list([
        #(symbol.string_to_symbol("BTCUSD"), instrument_value),
      ]),
      accounts: dict.new(),
    )
  Desk(dict.from_list([#(id.string_to_broker_id("broker-1"), broker_value)]))
}
