//// Tests for plan `.planning/phases/04-domain-cleanup/04-02-PLAN.md`.
////
//// Written BEFORE the bodies they pin: the closed set, the codec, the two new
//// bucket-end rules, the Binance adapter, and the typed per-interval limits.
//// Assertion style follows the Gleam Tour: bool `assert … as "message"` and
//// `let assert` for a partial pattern. No `panic`, no `case Bool`.

import gleam/dict
import gleam/list
import gleam/option.{Some}
import glibe/api/interval
import glibe/api/market.{type Market}
import glibe/api/rules
import glibe/binance/kline
import glibe/config

/// The closed set has nine values, including the `IntervalFourHour` config used to name as a
/// `String` because the seven-variant type could not represent it.
pub fn closed_set_has_nine_intervals_test() {
  assert list.length(interval.all()) == 9
    as "IntervalThreeMinute and IntervalFourHour must be values of Interval, not spellings"
}

/// Every value of the closed set survives a codec round trip. An unknown
/// spelling is a typed `Error(Nil)`, never a `panic`.
pub fn codec_covers_every_interval_test() {
  list.each(interval.all(), fn(i) {
    assert interval.from_string(interval.to_string(i)) == Ok(i)
      as "to_string and from_string must agree for every Interval"
  })
  assert interval.from_string("not-an-interval") == Error(Nil)
    as "an unknown spelling is a typed error"
}

/// The two new spellings. These are settings-file names, not Binance names.
pub fn min3_and_h4_spellings_test() {
  assert interval.to_string(interval.IntervalThreeMinute) == "3m"
    as "IntervalThreeMinute spells 3m"
  assert interval.to_string(interval.IntervalFourHour) == "4h"
    as "IntervalFourHour spells 4h"
  assert interval.from_string("3m") == Ok(interval.IntervalThreeMinute)
    as "3m reads IntervalThreeMinute"
  assert interval.from_string("4h") == Ok(interval.IntervalFourHour)
    as "4h reads IntervalFourHour"
}

/// A 3-minute bucket ends on the hour-aligned 3-minute grid.
pub fn min3_bucket_end_test() {
  assert interval.bucket_ends(
    interval.IntervalThreeMinute,
    "2024-01-15 09:03:00",
  )
    as "minute 03 closes a IntervalThreeMinute bucket"
  assert interval.bucket_ends(
      interval.IntervalThreeMinute,
      "2024-01-15 09:04:00",
    )
    == False
    as "minute 04 does not close a IntervalThreeMinute bucket"
}

/// A 4-hour bucket ends at 00, 04, 08 … on the hour, and only at minute 00.
pub fn h4_bucket_end_test() {
  assert interval.bucket_ends(interval.IntervalFourHour, "2024-01-15 08:00:00")
    as "08:00 closes an IntervalFourHour bucket"
  assert interval.bucket_ends(interval.IntervalFourHour, "2024-01-15 09:00:00")
    == False
    as "09:00 is not an IntervalFourHour boundary, even though it is an IntervalOneHour boundary"
  assert interval.bucket_ends(interval.IntervalFourHour, "2024-01-15 08:30:00")
    == False
    as "a half hour is not an IntervalFourHour boundary"
  assert interval.bucket_ends(interval.IntervalFourHour, "2024-01-15T00:00:00")
    as "the T-separated ISO form is read too"
}

/// An unreadable timestamp is not a bucket end: folding the bar in loses no
/// data, it only waits.
pub fn unreadable_timestamp_is_not_a_bucket_end_test() {
  assert interval.bucket_ends(interval.IntervalThreeMinute, "2024-01-15")
    == False
    as "a bare date has no minute field"
  assert interval.bucket_ends(interval.IntervalFourHour, "2024-01-15") == False
    as "a bare date has no hour field"
}

/// The adapter answers for the whole closed set; exhaustiveness is the
/// compiler's checklist when a constructor is added.
pub fn binance_spells_new_intervals_test() {
  assert kline.interval_to_binance_string(interval.IntervalThreeMinute) == "3m"
    as "Binance spells IntervalThreeMinute as 3m"
  assert kline.interval_to_binance_string(interval.IntervalFourHour) == "4h"
    as "Binance spells IntervalFourHour as 4h"
}

/// The 14 config tables are `Dict(Interval, Int)`, and their accessors return
/// a domain error carrying the interval that was asked for.
pub fn data_limits_are_keyed_by_interval_test() {
  let assert Some(found) =
    config.get_market(config.default_config(), "binance_spot_crypto")
    as "the binance spot market is in the default config"
  let spot: Market = found
  let limits: rules.DataRequestLimits = spot.rules.data_limits

  assert dict.get(limits.max_bars_per_request, interval.IntervalFourHour)
    == Ok(500)
    as "IntervalFourHour is now a typed key, not the string \"IntervalFourHour\""
  assert rules.max_bars_per_request_for(limits, interval.IntervalFourHour)
    == Ok(500)
    as "the IntervalFourHour bar limit is reachable through the typed accessor"
  assert rules.max_history_days_for(limits, interval.IntervalFourHour)
    == Ok(1825)
    as "the IntervalFourHour history limit is reachable through the typed accessor"
  assert rules.max_bars_per_request_for(limits, interval.IntervalThreeMinute)
    == Error(rules.NoBarLimit(interval.IntervalThreeMinute))
    as "a missing bar limit names the missing interval"
  assert rules.max_history_days_for(limits, interval.IntervalThreeMinute)
    == Error(rules.NoHistoryLimit(interval.IntervalThreeMinute))
    as "a missing history limit names the missing interval"
}
