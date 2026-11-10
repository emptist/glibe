//// Tests for the DESIGN JUDGEMENTS, not only for the values they produce.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-10-PLAN.md`, step 3.
//// Written BEFORE `desk.timeframe_under` had a body (R19): the module docs
//// of `desk.gleam` and the `///` of that function are the specification;
//// these assertions are the executable form of the judgement rules.
////
//// R34: both predecessors had ONE broker; the layer they lacked is here.
//// R36: `Desk` holds `Broker` directly. `Market` was rejected in BOTH
//// directions, so it is not a level between them — there is no gap.
//// R37: a level has two ownership relations; attachment is not ownership;
//// identity belongs to the HOLDER's `Dict` key, never to the value.
//// R35: these are deliberately plain value assertions. If checking a
//// structure needs a framework, the type / function / module definitions
//// are wrong — *"简单是正确的验证码"*.
////
//// No deliberately broken source file, no guard script: the compiler checks
//// the shapes (a `Broker` is built with no `BrokerId` argument, a `Timeframe`
//// with no `Interval` argument) and `assert` checks the values.

import gleam/dict
import gleam/option.{Some}
import glibe/api/interval
import glibe/api/symbol
import glibe/config
import glibe/desk
import glibe/indicator_settings
import glibe/timeframe

/// One parameter block, so a `Timeframe` can be built in a test without
/// inventing a second settings entity (R23).
fn settings() -> indicator_settings.TimeframeSettings {
  indicator_settings.TimeframeSettings(
    sma_tiny_window_size: 7,
    sma_small_window_size: 70,
    sma_medium_window_size: 140,
    sma_large_window_size: 252,
    sma_huge_window_size: 504,
    kdj_window_size: 7,
    kdj_k_period: 3,
    kdj_m_period: 10,
    bb_multiplier: 1.99,
    sma_for_bbm: indicator_settings.SmaForBbmMedium,
    branch_exit_leaf_size: 40,
  )
}

/// R34: the layer both single-broker predecessors lacked is a `Dict` of
/// brokers on the ONE `Desk`. Three distinct `BrokerId`s are readable from it.
pub fn one_desk_holds_three_brokers_test() {
  let root = config.default_config().desk
  let binance = desk.broker_id("binance")
  let ib = desk.broker_id("ib")
  let futu = desk.broker_id("futu")
  assert binance != ib as "two broker names are two values"
  assert ib != futu as "two broker names are two values"
  assert dict.size(root.brokers) == 3
    as "the multiple-brokers layer is the desk's one dictionary"
  let assert Ok(_) = desk.get_broker(root, binance)
    as "binance is held under its key"
  let assert Ok(_) = desk.get_broker(root, ib) as "ib is held under its key"
  let assert Ok(_) = desk.get_broker(root, futu) as "futu is held under its key"
}

/// R36: `Desk ▸ Broker` has no gap. `Market` is a catalogue entry in
/// `AppConfig`, not a level above `Broker`; R26 keeps its relations open, so
/// this test asserts only WHERE it is today, not what it belongs to.
pub fn market_is_a_catalogue_entry_not_a_level_test() {
  let cfg = config.default_config()
  let assert Some(_) = config.get_market(cfg, "ib_equity")
    as "the catalogue entry is readable"
  let assert Ok(_) = desk.get_broker(cfg.desk, desk.broker_id("ib"))
    as "the desk still holds its broker directly, with nothing in between"
}

/// R37: a `Broker` is keyless. `new_broker()` takes no `BrokerId` argument,
/// so the SAME value can sit under two different keys — the name belongs to
/// the holder, not to the broker (owner: *"你的左手不知道他是左还是右"*).
pub fn a_broker_does_not_carry_its_own_id_test() {
  let broker = desk.new_broker()
  let id_a = desk.broker_id("ib")
  let id_b = desk.broker_id("futu")
  let root =
    desk.new()
    |> desk.put_broker(id_a, broker)
    |> desk.put_broker(id_b, broker)
  assert dict.size(root.brokers) == 2
    as "one keyless broker value under two distinct names"
  let assert Ok(a) = desk.get_broker(root, id_a)
  let assert Ok(b) = desk.get_broker(root, id_b)
  assert a == b as "the value did not change; only the holder's key did"
}

/// R37: a `Timeframe` does not know its interval. `timeframe.new(settings)`
/// takes no `Interval` argument; the SAME value under two different interval
/// keys stays equal, because the difference is in the key, not the value.
pub fn equal_timeframes_under_two_keys_stay_equal_test() {
  let tf = timeframe.new(settings())
  let instrument =
    desk.new_instrument()
    |> desk.put_timeframe(interval.IntervalOneHour, tf)
    |> desk.put_timeframe(interval.IntervalOneDay, tf)
  assert dict.size(instrument.timeframes) == 2
    as "the instrument has ONE collection, keyed by interval"
  let assert Ok(hourly) =
    desk.get_timeframe(instrument, interval.IntervalOneHour)
  let assert Ok(daily) = desk.get_timeframe(instrument, interval.IntervalOneDay)
  assert hourly == daily
    as "equal state is equal: the interval is in the key, never in the value"
}

/// R36 / R37 / 04-10 step 4: one pure read walks the three holders' keys
/// from `Desk` to `Timeframe`. No address type, no advance, no state (R33).
pub fn timeframe_under_walks_the_three_keys_test() {
  let root = config.default_config().desk
  let bid = desk.broker_id("ib")
  let sym = symbol.from_string("SPY")
  let iv = interval.IntervalOneHour
  let assert Ok(broker) = desk.get_broker(root, bid) as "first holder's key"
  let assert Ok(instrument) = desk.get_instrument(broker, sym)
    as "second holder's key"
  let assert Ok(expected) = desk.get_timeframe(instrument, iv)
    as "third holder's key"
  let assert Ok(actual) = desk.timeframe_under(root, bid, sym, iv)
    as "the whole chain has no gap"
  assert actual == expected
    as "a pure read returns exactly what the three per-level reads return"
}

/// R37: each failure carries the KEY that was asked for. A level that is
/// missing does not turn into a generic `Error(String)` or a catch-all.
pub fn timeframe_under_names_the_key_that_failed_test() {
  let root = config.default_config().desk
  let bid = desk.broker_id("ib")
  let sym = symbol.from_string("SPY")
  let iv = interval.IntervalOneHour

  let missing_broker = desk.broker_id("missing")
  let assert Error(desk.NoSuchBroker(reported_broker)) =
    desk.timeframe_under(root, missing_broker, sym, iv)
    as "a missing broker is that level's error"
  assert reported_broker == missing_broker
    as "the error carries the broker key that was asked for"

  let missing_symbol = symbol.from_string("NOT_LISTED")
  let assert Error(desk.NoSuchInstrument(reported_symbol)) =
    desk.timeframe_under(root, bid, missing_symbol, iv)
    as "a missing instrument is that level's error"
  assert reported_symbol == missing_symbol
    as "the error carries the symbol key that was asked for"

  let missing_interval = interval.IntervalFifteenMinute
  let assert Error(desk.NoSuchTimeframe(reported_interval)) =
    desk.timeframe_under(root, bid, sym, missing_interval)
    as "a missing timeframe is that level's error"
  assert reported_interval == missing_interval
    as "the error carries the interval key that was asked for"
}
