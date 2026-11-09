//// Tests first (R19): pin what "N bars at the same time" actually promises,
//// and pin the OWNERSHIP fact that N parallel `Desk` values are N partial
//// views rather than one merged state.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-09-PLAN.md`.

import gleam/list
import gleam/result
import gleeunit
import glibe/config
import glibe/desk
import glibe/monitor
import glibe/timeframe.{type Timeframe}
import parallel_bars

/// gleeunit's entrypoint; every `pub fn *_test()` above is discovered.
pub fn main() -> Nil {
  gleeunit.main()
}

/// Read the `Timeframe` at one full address. Every address in the probe is
/// configured, so a missing one would be a broken fixture, not a result.
fn timeframe_at(
  desk_value: desk.Desk,
  address: monitor.TimeframeAddress,
) -> Timeframe {
  let assert Ok(broker) = desk.get_broker(desk_value, address.broker)
    as "the broker is configured"
  let assert Ok(instrument) = desk.get_instrument(broker, address.symbol)
    as "the instrument is configured"
  let assert Ok(timeframe_value) =
    desk.get_timeframe(instrument, address.interval)
    as "the interval is configured"
  timeframe_value
}

/// Every arrival really ran in a DIFFERENT BEAM process, and every pure step
/// succeeded. No actor, supervisor or lock is involved in this assertion.
pub fn parallel_steps_run_in_distinct_beam_processes_test() {
  let initial = config.default_config().desk
  let arrivals = parallel_bars.sample_arrivals()
  let assert Ok(replies) = parallel_bars.advance_in_parallel(initial, arrivals)
    as "every spawned worker answers within the timeout"

  assert list.length(replies) == list.length(arrivals)
    as "one typed reply per arriving bar"
  let workers = list.map(replies, fn(reply) { reply.worker })
  assert list.length(list.unique(workers)) == list.length(workers)
    as "each arriving bar ran in its own BEAM process"
  assert list.all(replies, fn(reply) { result.is_ok(reply.outcome) })
    as "every addressed step succeeded"
}

/// A parallel worker's `Desk` changed ONLY its own address. The other five
/// addresses in that same value are still the original ones.
pub fn each_parallel_result_is_one_partial_view_test() {
  let initial = config.default_config().desk
  let arrivals = parallel_bars.sample_arrivals()
  let assert Ok(replies) = parallel_bars.advance_in_parallel(initial, arrivals)
    as "every spawned worker answers within the timeout"

  assert list.all(replies, fn(reply) {
    let assert Ok(partial) = reply.outcome as "the addressed step succeeded"
    let others =
      list.filter(arrivals, fn(arrival) { arrival.address != reply.address })
    timeframe_at(initial, reply.address) != timeframe_at(partial, reply.address)
    && list.all(others, fn(arrival) {
      timeframe_at(initial, arrival.address)
      == timeframe_at(partial, arrival.address)
    })
  })
    as "each parallel Desk advanced one address and left the other five alone"
}

/// The honest ownership result: NO single parallel reply equals the state
/// with all six updates. N immutable values do not merge themselves; that is
/// a data-flow decision, not a synchronisation problem.
pub fn no_parallel_result_contains_every_update_test() {
  let initial = config.default_config().desk
  let arrivals = parallel_bars.sample_arrivals()
  let assert Ok(replies) = parallel_bars.advance_in_parallel(initial, arrivals)
    as "every spawned worker answers within the timeout"
  let ordered = parallel_bars.advance_in_order(initial, arrivals)

  assert list.all(replies, fn(reply) {
    let assert Ok(partial) = reply.outcome as "the addressed step succeeded"
    partial != ordered
  })
    as "a parallel Desk is a partial view, never the merged state"
}

/// One owner folding the same pure steps holds every update. This is the
/// shape that needs no lock: the only writer of the `Desk` is the fold.
pub fn one_owner_folds_all_six_addressed_steps_test() {
  let initial = config.default_config().desk
  let arrivals = parallel_bars.sample_arrivals()
  let ordered = parallel_bars.advance_in_order(initial, arrivals)

  assert list.all(arrivals, fn(arrival) {
    timeframe_at(initial, arrival.address)
    != timeframe_at(ordered, arrival.address)
  })
    as "all six addresses advanced in the single Desk"
}
