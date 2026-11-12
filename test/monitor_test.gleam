//// One addressed bar advances one timeframe and leaves every other
//// instrument and interval untouched.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-08-PLAN.md`.
//// Tests first (R19): these pin the isolation that "many instruments, each
//// with many intervals, monitored at the same time" actually promises.

import gleam/list
import gleam/option.{None}
import gleam/time/timestamp
import glibe/api/interval
import glibe/api/sourcebar.{type SourceBar, SourceBar}
import glibe/api/symbol
import glibe/config
import glibe/desk
import glibe/monitor
import glibe/timeframe.{type Timeframe}

/// A test clock built through the same wire conversion the adapters use.
fn at(raw: String) -> timestamp.Timestamp {
  let assert Ok(instant) = sourcebar.unix_timestamp(raw)
    as "test clock label parses"
  instant
}

/// One well-formed bar at a given instant, with a recognisable close.
fn quote(raw: String, close_price: Float) -> SourceBar {
  SourceBar(
    timestamp: at(raw),
    open: close_price -. 0.5,
    high: close_price +. 1.0,
    low: close_price -. 1.0,
    close: close_price,
    volume: 10,
  )
}

/// Read the `Timeframe` at one full address, for "untouched" assertions.
fn timeframe_at(
  d: desk.Desk,
  broker: String,
  name: String,
  iv: interval.Interval,
) -> Timeframe {
  let assert Ok(b) = desk.get_broker(d, desk.broker_id(broker))
    as "broker is configured"
  let assert Ok(i) = desk.get_instrument(b, symbol.from_string(name))
    as "instrument is configured"
  let assert Ok(tf) = desk.get_timeframe(i, iv) as "interval is configured"
  tf
}

/// The typed address of one monitored timeframe.
fn address(
  broker: String,
  name: String,
  iv: interval.Interval,
) -> monitor.TimeframeAddress {
  monitor.TimeframeAddress(
    broker: desk.broker_id(broker),
    symbol: symbol.from_string(name),
    interval: iv,
  )
}

/// One arriving market bar with its address attached at the boundary.
fn arriving(
  addr: monitor.TimeframeAddress,
  bar: SourceBar,
) -> monitor.IncomingBar {
  monitor.IncomingBar(address: addr, bar: bar)
}

/// Add a four-hour timeframe to the configured BTCUSDT instrument, reusing
/// its own empty `Timeframe` so the test invents no settings of its own.
fn with_four_hour(d: desk.Desk) -> desk.Desk {
  let assert Ok(b) = desk.get_broker(d, desk.broker_id("binance"))
  let assert Ok(i) = desk.get_instrument(b, symbol.from_string("BTCUSDT"))
  let assert Ok(hourly) = desk.get_timeframe(i, interval.IntervalOneHour)
  let i = desk.put_timeframe(i, interval.IntervalFourHour, hourly)
  let b = desk.put_instrument(b, symbol.from_string("BTCUSDT"), i)
  desk.put_broker(d, desk.broker_id("binance"), b)
}

/// The core promise: one bar changes exactly one of the six configured states.
pub fn one_bar_advances_only_the_addressed_timeframe_test() {
  let d0 = config.default_config().desk
  let addr = address("binance", "BTCUSDT", interval.IntervalOneHour)
  let assert Ok(d1) =
    monitor.advance(d0, arriving(addr, quote("2024-01-15 09:00:00", 100.0)))
    as "an hourly bucket ends on the hour"

  assert list.length(
      timeframe_at(d1, "binance", "BTCUSDT", interval.IntervalOneHour).databar_list,
    )
    == 1
    as "the addressed timeframe advanced by one settled bar"
  assert timeframe_at(d1, "binance", "BTCUSDT", interval.IntervalOneDay)
    == timeframe_at(d0, "binance", "BTCUSDT", interval.IntervalOneDay)
    as "the other interval of the SAME instrument is untouched"
  assert timeframe_at(d1, "ib", "SPY", interval.IntervalOneHour)
    == timeframe_at(d0, "ib", "SPY", interval.IntervalOneHour)
    as "another broker's instrument is untouched"
  assert timeframe_at(d1, "futu", "SPY_FUTU", interval.IntervalOneDay)
    == timeframe_at(d0, "futu", "SPY_FUTU", interval.IntervalOneDay)
    as "a third instrument's other interval is untouched"
}

/// Two different instruments can be monitored in the same `Desk` without
/// their bars leaking into each other.
pub fn two_instruments_are_monitored_independently_test() {
  let d0 = config.default_config().desk
  let btc = address("binance", "BTCUSDT", interval.IntervalOneHour)
  let spy = address("ib", "SPY", interval.IntervalOneHour)
  let assert Ok(d1) =
    monitor.advance(d0, arriving(btc, quote("2024-01-15 09:00:00", 100.0)))
  let assert Ok(d2) =
    monitor.advance(d1, arriving(spy, quote("2024-01-15 09:00:00", 300.0)))

  let btc_tf = timeframe_at(d2, "binance", "BTCUSDT", interval.IntervalOneHour)
  let spy_tf = timeframe_at(d2, "ib", "SPY", interval.IntervalOneHour)
  assert list.length(btc_tf.databar_list) == 1
  assert list.length(spy_tf.databar_list) == 1
  let assert [btc_bar, ..] = btc_tf.databar_list
  let assert [spy_bar, ..] = spy_tf.databar_list
  assert btc_bar.close == 100.0 as "the first instrument kept its own close"
  assert spy_bar.close == 300.0 as "the second instrument kept its own close"
}

/// A bar that does not close a period is IGNORED and held NOWHERE (R39):
/// `working_databar` is not a bucket accumulator. This assertion replaced the
/// 04-08 one that expected a half-built bar to wait for the next arrival.
pub fn non_boundary_bar_is_ignored_and_held_nowhere_test() {
  let d0 = config.default_config().desk
  let addr = address("binance", "BTCUSDT", interval.IntervalOneHour)
  let assert Ok(d1) =
    monitor.advance(d0, arriving(addr, quote("2024-01-15 09:30:00", 100.0)))
  let tf = timeframe_at(d1, "binance", "BTCUSDT", interval.IntervalOneHour)
  assert tf.databar_list == [] as "a bar inside the hour settles nothing"
  assert tf.working_databar == None
    as "no bucket is opened; nothing waits for a later arrival"
}

/// The interval belongs to the ADDRESS, not to the bar: the very same bar
/// closes an hourly period at 09:00 but not a four-hour one.
pub fn the_interval_is_part_of_the_address_test() {
  let d0 = with_four_hour(config.default_config().desk)
  let hourly = address("binance", "BTCUSDT", interval.IntervalOneHour)
  let four_hourly = address("binance", "BTCUSDT", interval.IntervalFourHour)
  let bar = quote("2024-01-15 09:00:00", 100.0)
  let assert Ok(d1) = monitor.advance(d0, arriving(hourly, bar))
  let assert Ok(d2) = monitor.advance(d1, arriving(four_hourly, bar))

  assert list.length(
      timeframe_at(d2, "binance", "BTCUSDT", interval.IntervalOneHour).databar_list,
    )
    == 1
    as "09:00 closes the hourly period"
  let four = timeframe_at(d2, "binance", "BTCUSDT", interval.IntervalFourHour)
  assert four.databar_list == []
    as "the SAME bar at 09:00 does not close a four-hour period"
  assert four.working_databar == None
    as "the four-hour timeframe ignores it rather than holding a bucket"
}

/// An address with no configured instrument fails as a typed error that
/// carries the address and the desk-level reason, not a message string.
pub fn an_unmonitored_address_is_a_typed_error_test() {
  let d0 = config.default_config().desk
  let missing = address("binance", "NOT_CONFIGURED", interval.IntervalOneHour)
  let assert Error(monitor.AddressNotMonitored(
    reported,
    desk.NoSuchInstrument(_),
  )) =
    monitor.advance(d0, arriving(missing, quote("2024-01-15 09:00:00", 100.0)))
    as "an address with no instrument fails as a typed error"
  assert reported == missing as "the error names the address that failed"
}

/// A bar refused at the gate reports WHICH address and WHY, so a supervisor
/// can tell one monitored stream from another.
pub fn a_refused_bar_carries_its_address_in_the_error_test() {
  let d0 = config.default_config().desk
  let addr = address("binance", "BTCUSDT", interval.IntervalOneHour)
  let bad =
    SourceBar(
      timestamp: at("2024-01-15 09:00:00"),
      open: 100.0,
      high: 90.0,
      low: 99.0,
      close: 100.5,
      volume: 10,
    )
  let assert Error(monitor.BarRejected(reported, sourcebar.HighBelowLow)) =
    monitor.advance(d0, arriving(addr, bad))
    as "a high-below-low bar is refused with a typed reason"
  assert reported == addr as "the error names the address whose bar was refused"
}
