//// RED→GREEN tests for the Binance LIVE REST data source. Implements
//// Task 1 of `.planning/phases/05-live-feed/05-01-PLAN.md`.
////
//// The decoder is pinned with a REAL response captured from
//// `data-api.binance.vision/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=3`
//// on 2026-11-25 — not a synthetic bar. Every assertion below checks that
//// the exact numbers the exchange sent survive into standard `SourceBar`s.

import gleam/list
import gleam/time/timestamp
import glibe/api/interval.{IntervalOneMinute}
import glibe/api/sourcebar.{type SourceBar, SourceBarOneMinute}
import glibe/binance/rest

/// A real captured kline window: three one-minute BTCUSDT bars. Field order
/// is Binance's own (open_time, open, high, low, close, volume, close_time,
/// quote_asset_volume, number_of_trades, taker_buy_base, taker_buy_quote,
/// ignore). Copied verbatim from the live response on 2026-11-25.
const real_payload =
  "[[1795543680000,\"60127.99000000\",\"60152.38000000\",\"60090.92000000\",\"60151.56000000\",\"6.90149000\",1795543739999,\"414869.40223180\",1642,\"3.07468000\",\"184852.55052500\",\"0\"],[1795543740000,\"60151.55000000\",\"60184.12000000\",\"60138.00000000\",\"60138.01000000\",\"7.47379000\",1795543799999,\"449628.77297470\",1902,\"3.08079000\",\"185337.41767210\",\"0\"],[1795543800000,\"60138.01000000\",\"60163.50000000\",\"60120.28000000\",\"60120.29000000\",\"4.41353000\",1795543859999,\"265446.80814490\",754,\"2.12193000\",\"127629.14337440\",\"0\"]]"

/// A real three-bar response decodes to exactly three standard bars.
pub fn decode_real_payload_yields_three_bars_test() {
  let assert Ok(bars) = rest.decode_klines(real_payload, IntervalOneMinute)
  assert list.length(bars) == 3
  Nil
}

/// The first real bar's six fields survive exactly, and its epoch-ms opens
/// became the same absolute Timestamp. Volume is truncated to Int.
pub fn decode_real_bar_preserves_ohlcv_and_timestamp_test() {
  let assert Ok(bars) = rest.decode_klines(real_payload, IntervalOneMinute)
  let assert [first, ..] = bars
  assert first
    == SourceBarOneMinute(
      timestamp: timestamp.from_unix_seconds_and_nanoseconds(1_795_543_680, 0),
      open: 60_127.99,
      high: 60_152.38,
      low: 60_090.92,
      close: 60_151.56,
      volume: 6,
    )
  Nil
}

/// Every decoded bar is of the interval the caller asked for (R23/R37).
pub fn decode_real_bars_carry_the_requested_interval_test() {
  let assert Ok(bars) = rest.decode_klines(real_payload, IntervalOneMinute)
  assert list.all(bars, is_one_minute)
  Nil
}

/// A body that is not a kline array is refused with a typed error, not a
/// crash and not an empty list silently taken as "no data".
pub fn decode_garbage_returns_error_test() {
  case rest.decode_klines("not-json", IntervalOneMinute) {
    Error(_) -> Nil
    Ok(_) -> panic as "garbage payload must be refused"
  }
}

/// Binance's own interval spellings (wire codes, never constructors, R21).
pub fn interval_wire_spellings_test() {
  assert rest.interval_to_binance_string(IntervalOneMinute) == "1m"
  Nil
}

fn is_one_minute(bar: SourceBar) -> Bool {
  case bar {
    SourceBarOneMinute(..) -> True
    _ -> False
  }
}
