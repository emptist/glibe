//// Empty skeleton tests. Implements
//// `.planning/BRIEF.md`.
////
//// R42 07:39 (owner, verbatim): *"最初的空架子，unit test 跟对应的 type fn
//// 也都一样是空的，仅仅要求将 in out types 搞对；这一步gleam test or
//// gleam build就已经能发现设计问题"*.
////
//// The shape tests bind a function to an explicitly annotated type: if a
//// signature drifts away from the design, the compiler rejects this file.
//// Real assertions arrive together with the bodies (R19); the first one,
//// `binance_kline_to_sourcebar_test`, arrived 2026-11-14 with the first
//// filled body.
////
//// R19 status: nineteen real-assertion tests live —
//// `binance_kline_to_sourcebar_test` (2026-11-14),
//// `bars_listed_reads_head_idx_test` (2026-11-15), `symbol_codec_shape_test`
//// round-trip (2026-11-17), three `ib_composition_*` tests (start / accumulate /
//// close, pinning the nine `five_second_to_*` bodies), two `instrument_*` tests
//// (Dict round-trip; compose dispatch writing growing back), three `leaf_*`
//// tests (birth + readers, leaf_size idx arithmetic, cma_recurrence), three
//// `branch_*` tests (readers + polarity, recognition, exited-head), two
//// `timeframe_*` tests (sourcebar_gate door; archived prepends to head), and
//// `whole_chain_by_identity_keys_test` (Desk ▸ Broker ▸ Instrument ▸
//// Timeframe written and read back by identity keys — the lab's whole-desk
//// proof reduced to glibe's one Value), and three structure-measurement tests
//// (`leaf_depth_share_test`, `branch_move_between_test`,
//// `branch_recognised_move_test`, R3 selected-MA shares). The rest pin types.

import gleam/dict
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/time/timestamp.{type Timestamp}
import gleeunit
import glibe/account.{type Account}
import glibe/api/interval.{type Interval, IntervalOneDay, IntervalOneHour}
import glibe/api/sourcebar.{type SourceBar, type SourceBarRejection}
import glibe/api/symbol.{type Symbol, string_to_symbol}
import glibe/binance/kline.{type BinanceKline}
import glibe/branch
import glibe/broker.{type Broker}
import glibe/databar.{type DataBar}
import glibe/desk.{type Desk}
import glibe/ib/sourcebar as ib_sourcebar
import glibe/id.{type AccountId, type BrokerId, string_to_broker_id}
import glibe/instrument.{type Instrument, Instrument}
import glibe/leaf
import glibe/timeframe.{type Timeframe, Timeframe}
import glibe/trading/signal

pub fn main() {
  gleeunit.main()
}

/// R40 / R41: every step of the straight line is ONE shape, so the body of
/// `databar_processing` can be a single pipe. A step that starts taking a
/// bar, or returning anything but `Timeframe`, fails to compile here.
pub fn pipeline_steps_shape_test() {
  let _steps: List(fn(Timeframe) -> Timeframe) = [
    timeframe.indicator,
    timeframe.leaves,
    timeframe.branches,
    timeframe.strategy,
    timeframe.working_databar_archived,
  ]
  Nil
}

/// R40: the whole line is itself one `fn(Timeframe) -> Timeframe` step.
pub fn databar_processing_shape_test() {
  let _line: fn(Timeframe) -> Timeframe = timeframe.databar_processing
  Nil
}

/// R39 / R23: the gate receives one bar and the interval key the caller
/// already holds; it never asks the Timeframe for its own identity.
pub fn sourcebar_gate_shape_test() {
  let _gate: fn(Timeframe, Interval, SourceBar) ->
    Result(Timeframe, SourceBarRejection) = timeframe.sourcebar_gate
  Nil
}

/// R39 / R42: one qualified SourceBar is born whole into one DataBar at
/// the SOURCE boundary, and only there.
pub fn birth_shape_test() {
  let _birth: fn(SourceBar, Int) -> DataBar = sourcebar.to_databar
  Nil
}

/// R8 / R13: the price checker refuses with a typed reason, never a String.
pub fn price_checker_shape_test() {
  let _check: fn(SourceBar) -> Result(SourceBar, SourceBarRejection) =
    sourcebar.validate
  Nil
}

/// R39: `bars_listed` reads the HEAD of the archived list, not an
/// "accepted" set and not a count of the List's cells.
pub fn bars_listed_shape_test() {
  let _listed: fn(List(DataBar)) -> Int = timeframe.bars_listed
  Nil
}

/// A `DataBar` for the archived list. Only `idx` is read by `bars_listed`.
fn listed_bar(idx: Int) -> DataBar {
  databar.DataBar(
    idx: idx,
    timestamp: timestamp.from_unix_seconds(1_499_040_000),
    open: 0.0,
    high: 0.0,
    low: 0.0,
    close: 0.0,
    volume: 0,
    signal: signal.SignalNoSignal,
    sma_tiny: 0.0,
    sma_medium: 0.0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
    k: 0.0,
    d: 0.0,
    j: 0.0,
    bb_u3: 0.0,
    bb_l3: 0.0,
  )
}

/// A `DataBar` with a chosen index and selected MA (R3), for the structure
/// measurement tests. Only `idx` and `sma_tiny` are read there.
fn ma_bar(idx: Int, sma: Float) -> DataBar {
  databar.DataBar(
    idx: idx,
    timestamp: timestamp.from_unix_seconds(1_499_040_000),
    open: 0.0,
    high: 0.0,
    low: 0.0,
    close: 0.0,
    volume: 0,
    signal: signal.SignalNoSignal,
    sma_tiny: sma,
    sma_medium: 0.0,
    yin_leaf_cma: 0.0,
    yang_leaf_cma: 0.0,
    k: 0.0,
    d: 0.0,
    j: 0.0,
    bb_u3: 0.0,
    bb_l3: 0.0,
  )
}

// An ended yang branch (R5): the move opened at idx 10, was recognised at 12,
// died at 15 and was found dead at 17. Used to pin branch readers/projections.
fn ended_yang_branch() -> branch.DataBranch {
  branch.YangBranch(
    start_bar: listed_bar(10),
    enter_bar: listed_bar(12),
    end_bar: Some(listed_bar(15)),
    exit_bar: Some(listed_bar(17)),
  )
}

// A Timeframe with no bar and no growing value: the empty holder used to pin
// the instrument-level read/write of its one Dict and the compose dispatch.
fn empty_timeframe() -> Timeframe {
  Timeframe(
    growing_target_sourcebar: None,
    working_databar: None,
    databar_list: [],
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

/// R13 / R21: `interval(of:)` reads the grade FROM the variant — never a
/// field, never a caller's claim. All nine variants answer their own key.
pub fn sourcebar_interval_reads_variant_test() {
  let ts = timestamp.from_unix_seconds(1_499_040_000)
  let mk = fn(o, h, l, c) {
    sourcebar.SourceBarOneHour(
      timestamp: ts,
      open: o,
      high: h,
      low: l,
      close: c,
      volume: 1,
    )
  }
  let b = mk(1.0, 2.0, 0.5, 1.5)
  // The single fully-typed reader is exercised through the other shape test;
  // here pin that the grade is a pure function of the variant, stable across
  // the bar's numbers.
  assert sourcebar.interval(b) == interval.IntervalOneHour
  assert sourcebar.interval(mk(9.0, 9.0, 9.0, 9.0)) == interval.IntervalOneHour
    as "same variant, different numbers, same grade"
}

/// R8 (reject, never repair): a bar whose own numbers disagree is refused with
/// the typed reason; a qualified bar passes unchanged. The single-constructor
/// rejection type is deliberate (R26) — no invented fine-grained reasons.
pub fn sourcebar_validate_checks_test() {
  let ts = timestamp.from_unix_seconds(1_499_040_000)
  let good =
    sourcebar.SourceBarOneHour(
      timestamp: ts,
      open: 1.0,
      high: 2.0,
      low: 0.5,
      close: 1.5,
      volume: 10,
    )
  assert sourcebar.validate(good) == Ok(good) as "a qualified bar passes"
  // high below low.
  let bad_high_low =
    sourcebar.SourceBarOneHour(
      timestamp: ts,
      open: 1.0,
      high: 0.4,
      low: 0.5,
      close: 1.5,
      volume: 10,
    )
  assert sourcebar.validate(bad_high_low)
    == Error(sourcebar.SourceBarRejectionUnqualified)
  // negative price.
  let bad_price =
    sourcebar.SourceBarOneHour(
      timestamp: ts,
      open: -1.0,
      high: 2.0,
      low: 0.5,
      close: 1.5,
      volume: 10,
    )
  assert sourcebar.validate(bad_price)
    == Error(sourcebar.SourceBarRejectionUnqualified)
  // negative volume.
  let bad_volume =
    sourcebar.SourceBarOneHour(
      timestamp: ts,
      open: 1.0,
      high: 2.0,
      low: 0.5,
      close: 1.5,
      volume: -1,
    )
  assert sourcebar.validate(bad_volume)
    == Error(sourcebar.SourceBarRejectionUnqualified)
    as "reject, never repair"
}

/// R39 / R27: one qualified `SourceBar` is born into one whole `DataBar` —
/// six fields + idx carried straight across, no accumulator, no period asked.
pub fn sourcebar_to_databar_birth_test() {
  let ts = timestamp.from_unix_seconds(1_499_040_000)
  let bar =
    sourcebar.SourceBarOneHour(
      timestamp: ts,
      open: 1.0,
      high: 2.0,
      low: 0.5,
      close: 1.5,
      volume: 100,
    )
  assert sourcebar.to_databar(bar, 7)
    == databar.DataBar(
      idx: 7,
      timestamp: ts,
      open: 1.0,
      high: 2.0,
      low: 0.5,
      close: 1.5,
      volume: 100,
      signal: signal.SignalNoSignal,
      sma_tiny: 0.0,
      sma_medium: 0.0,
      yin_leaf_cma: 0.0,
      yang_leaf_cma: 0.0,
      k: 0.0,
      d: 0.0,
      j: 0.0,
      bb_u3: 0.0,
      bb_l3: 0.0,
    )
    as "one whole bar born with the caller's idx and a neutral decision"
}

/// R50 / R37 / R23: each level reads and writes ONLY its own Dict, keyed by
/// the id its holder keeps. `Desk.brokers` is keyed by `BrokerId`; a miss is
/// `Error(Nil)` and a write is a new `Desk` with the recomputed broker.
pub fn desk_brokers_dict_test() {
  let key = id.string_to_broker_id("ib")
  let broker = broker.Broker(dict.new(), dict.new())
  let empty = desk.Desk(dict.new())
  assert desk.get_broker(empty, key) == Error(Nil)
    as "no broker under the key yet"
  let with_broker = desk.put_broker(empty, key, broker)
  assert desk.get_broker(with_broker, key) == Ok(broker)
    as "the recomputed broker is read back under the same key"
  // The original is unchanged: a write returns a new Value, no mutation.
  assert desk.get_broker(empty, key) == Error(Nil)
}

/// The whole chain `Desk ▸ Broker ▸ Instrument ▸ Timeframe` composed by
/// identity keys, verified end to end. This is the lab's
/// `desk_model_represented_test` shape (`try_plushie`, 2 brokers / 5
/// instruments / 14 timeframes) reduced to glibe's ONE top-level Value:
/// write a timeframe down through the three write pairs, read it back up
/// through the three read pairs, and confirm each key selects exactly one
/// branch. R33: no second `tf` is held beside the `Desk` — the Desk IS the
/// one Value, and the read-back is the view. R23 / R37: identity lives in
/// the holder's Dict key, never on the stored value.
pub fn whole_chain_by_identity_keys_test() {
  let binance = string_to_broker_id("binance")
  let ib = string_to_broker_id("ib")
  let btc = string_to_symbol("BTCUSDT")
  let aapl = string_to_symbol("AAPL")
  let h1 = IntervalOneHour
  let d1 = IntervalOneDay
  let tf_h1 = empty_timeframe()
  let tf_d1 = Timeframe(..empty_timeframe(), databar_list: [listed_bar(7)])

  // Write down: Instrument.timeframes → Broker.instruments → Desk.brokers.
  let binance_btc =
    instrument.put_timeframe(
      instrument.put_timeframe(Instrument(dict.new()), h1, tf_h1),
      d1,
      tf_d1,
    )
  let broker_one =
    broker.put_instrument(
      broker.put_instrument(
        broker.Broker(dict.new(), dict.new()),
        btc,
        binance_btc,
      ),
      aapl,
      Instrument(dict.new()),
    )
  let desk_one =
    desk.put_broker(
      desk.put_broker(desk.Desk(dict.new()), binance, broker_one),
      ib,
      broker.Broker(dict.new(), dict.new()),
    )

  // Read back up by the same keys: the exact timeframe lands under each key.
  assert desk.get_broker(desk_one, binance)
    |> result.try(fn(b) { broker.get_instrument(b, btc) })
    |> result.try(fn(i) { instrument.get_timeframe(i, h1) })
    == Ok(tf_h1)
    as "Desk → binance → BTCUSDT → 1h reads back the stored timeframe"
  assert desk.get_broker(desk_one, binance)
    |> result.try(fn(b) { broker.get_instrument(b, btc) })
    |> result.try(fn(i) { instrument.get_timeframe(i, d1) })
    == Ok(tf_d1)
    as "the 1d key selects a different timeframe under the same instrument"
  // A key that was never written misses at its own level and nowhere else.
  assert desk.get_broker(desk_one, ib)
    |> result.try(fn(b) { broker.get_instrument(b, btc) })
    == Error(Nil)
    as "the ib broker has no BTCUSDT — identity is the holder's key"
  // AAPL was written under binance with no timeframes: present as an
  // instrument, but the 1h key under it misses. The truly absent key is
  // binance·AAPL·1h, not binance·AAPL itself.
  assert desk.get_broker(desk_one, binance)
    |> result.try(fn(b) { broker.get_instrument(b, aapl) })
    |> result.try(fn(i) { instrument.get_timeframe(i, h1) })
    == Error(Nil)
    as "AAPL is present but has no 1h timeframe — key identity at the leaf"
}

/// R50: `Broker` owns TWO Dicts. The account pair is keyed by `AccountId`
/// and needs no open design (unlike Symbol), so it is fully tested here.
pub fn broker_accounts_dict_test() {
  let key = id.string_to_account_id("acct-1")
  let empty = broker.Broker(dict.new(), dict.new())
  assert broker.get_account(empty, key) == Error(Nil)
  let with_account = broker.put_account(empty, key, account.Account)
  assert broker.get_account(with_account, key) == Ok(account.Account)
    as "account read back under its key"
  assert broker.get_account(empty, key) == Error(Nil)
    as "the original broker is unchanged"
}

/// R39 / R1 / R4 / R27 / R10: the three named readers of `DataBar` return
/// exactly the values the bar was born with — no recompute, no parse.
pub fn databar_readers_test() {
  let ts = timestamp.from_unix_seconds(1_499_040_000)
  let bar =
    databar.DataBar(
      idx: 7,
      timestamp: ts,
      open: 1.0,
      high: 2.0,
      low: 0.5,
      close: 1.5,
      volume: 100,
      signal: signal.SignalBuy,
      sma_tiny: 0.0,
      sma_medium: 0.0,
      yin_leaf_cma: 0.0,
      yang_leaf_cma: 0.0,
      k: 0.0,
      d: 0.0,
      j: 0.0,
      bb_u3: 0.0,
      bb_l3: 0.0,
    )
  assert databar.idx(bar) == 7 as "idx is the bar's stream index"
  assert databar.timestamp(bar) == ts as "absolute Timestamp, not a spelling"
  assert databar.signal(bar) == signal.SignalBuy
    as "the decision written on this bar"
}

/// R10 / R11 / R13 / R21: the signal codec is the only home of the three
/// wire words (`buy` / `sell` / `""`), two-way over the closed set.
pub fn signal_codec_test() {
  assert signal.to_string(signal.SignalBuy) == "buy"
  assert signal.to_string(signal.SignalSell) == "sell"
  assert signal.to_string(signal.SignalNoSignal) == ""
  assert signal.from_string("buy") == Ok(signal.SignalBuy)
  assert signal.from_string("sell") == Ok(signal.SignalSell)
  assert signal.from_string("") == Ok(signal.SignalNoSignal)
  assert signal.from_string("hold") == Error(Nil)
    as "a word outside the closed set is refused"
}

/// Owner 2026-11-15 in-code review: `bars_listed` is NOT a count of the
/// List. `databar_list` is newest-first by design, so the head bar's
/// `idx + 1` IS the number of bars listed, reachable in O(1); a Gleam
/// `List` is a linked list, and `list.length` would walk every cell.
/// Two cells with head `idx: 41` must answer 42, not 2.
pub fn bars_listed_reads_head_idx_test() {
  let newest = listed_bar(41)
  let older = listed_bar(40)
  assert timeframe.bars_listed([]) == 0 as "no bar listed yet"
  assert timeframe.bars_listed([newest]) == 42 as "one cell, head idx 41 -> 42"
  assert timeframe.bars_listed([newest, older]) == 42
    as "two cells: head idx + 1, not the List's length"
}

/// R42 / R50: EACH level owns the read / write pair of the ONE Dict it
/// holds. A function that crosses from `Desk` straight down to `Timeframe`
/// does not belong to any level, so it does not exist (R50 / R38).
pub fn chain_levels_shape_test() {
  let _desk_read: fn(Desk, BrokerId) -> Result(Broker, Nil) = desk.get_broker
  let _desk_write: fn(Desk, BrokerId, Broker) -> Desk = desk.put_broker
  let _broker_instrument_read: fn(Broker, Symbol) -> Result(Instrument, Nil) =
    broker.get_instrument
  let _broker_instrument_write: fn(Broker, Symbol, Instrument) -> Broker =
    broker.put_instrument
  let _broker_account_read: fn(Broker, AccountId) -> Result(Account, Nil) =
    broker.get_account
  let _broker_account_write: fn(Broker, AccountId, Account) -> Broker =
    broker.put_account
  let _instrument_read: fn(Instrument, Interval) -> Result(Timeframe, Nil) =
    instrument.get_timeframe
  let _instrument_write: fn(Instrument, Interval, Timeframe) -> Instrument =
    instrument.put_timeframe
  Nil
}

/// R50 / R13: the ONLY ways to build the two opaque keys live in the same
/// module as the keys. Measured: an `opaque` constructor used from another
/// module is `error: Use of private value`. Owner 2026-11-14 review: these
/// are `x_to_y` conversions, so they are named `string_to_*`, symmetric
/// with the existing `*_to_string` readers.
pub fn identity_shape_test() {
  let _broker_key: fn(String) -> BrokerId = id.string_to_broker_id
  let _account_key: fn(String) -> AccountId = id.string_to_account_id
  Nil
}

/// R50 §3: the readers are the second direction of each opaque key and, like
/// the constructors, must live in the type's own module (measured: an opaque
/// constructor or field used elsewhere is `error: Use of private value`).
pub fn identity_readers_shape_test() {
  let _broker_out: fn(BrokerId) -> String = id.broker_id_to_string
  let _account_out: fn(AccountId) -> String = id.account_id_to_string
  Nil
}

/// R37 / R23 / R47: a key is the KEY in its holder's Dict (`Desk.brokers`
/// keyed by `BrokerId`, `Broker.accounts` keyed by `AccountId`), never a field
/// of the value it names. Each key is a two-way codec over a boundary
/// spelling: build it from the spelling, read that same spelling back out.
pub fn identity_round_trip_test() {
  assert id.broker_id_to_string(id.string_to_broker_id("ib")) == "ib"
    as "broker key preserves its boundary spelling both ways"
  assert id.account_id_to_string(id.string_to_account_id("acct-42"))
    == "acct-42"
    as "account key preserves its boundary spelling both ways"
}

/// R21 / R13: the wire spelling lives ONLY in this codec; all nine
/// constructors map to the exchange's own code (glib source, verbatim).
pub fn interval_wire_codes_test() {
  assert interval.to_string(interval.IntervalOneMinute) == "1m"
  assert interval.to_string(interval.IntervalThreeMinute) == "3m"
  assert interval.to_string(interval.IntervalFifteenMinute) == "15m"
  assert interval.to_string(interval.IntervalThirtyMinute) == "30m"
  assert interval.to_string(interval.IntervalOneHour) == "1h"
  assert interval.to_string(interval.IntervalFourHour) == "4h"
  assert interval.to_string(interval.IntervalOneDay) == "1d"
  assert interval.to_string(interval.IntervalOneWeek) == "1wk"
  assert interval.to_string(interval.IntervalOneMonth) == "1mo"
    as "nine constructors, nine wire codes"
}

/// R13: an unknown wire spelling is a typed Error(Nil), never a panic and
/// never a default interval — a typo must fail, not silently close a bar.
pub fn interval_unknown_wire_code_test() {
  assert interval.from_string("2h") == Error(Nil)
    as "a wire code outside the closed set is refused"
}

/// R21 codec: every wire code reads back to the SAME constructor.
pub fn interval_wire_round_trip_test() {
  assert interval.from_string(interval.to_string(interval.IntervalFourHour))
    == Ok(interval.IntervalFourHour)
  assert interval.from_string(interval.to_string(interval.IntervalOneWeek))
    == Ok(interval.IntervalOneWeek)
    as "wire codec is two-way over the closed set"
}

/// R27 / R29: `sourcebar_closed` is a UTC unix-second grid — no calendar, no
/// offset. A bar closes when the instant lands exactly on the grid boundary
/// (`unix_second % span_seconds == 0`); mid-period instants do not close it.
pub fn sourcebar_closed_grid_test() {
  // 1h grid: 3600s. 1_499_040_000 is a whole hour (00:00:00 UTC).
  assert interval.sourcebar_closed(
    interval.IntervalOneHour,
    timestamp.from_unix_seconds(1_499_040_000),
  )
    as "hour boundary closes the bar"
  assert !interval.sourcebar_closed(
    interval.IntervalOneHour,
    timestamp.from_unix_seconds(1_499_040_001),
  )
    as "one second into the hour does not"
  // 4h grid: 14400s.
  assert interval.sourcebar_closed(
    interval.IntervalFourHour,
    timestamp.from_unix_seconds(1_499_040_000),
  )
    as "4h boundary closes the bar"
  assert !interval.sourcebar_closed(
    interval.IntervalFourHour,
    timestamp.from_unix_seconds(1_499_040_001),
  )
  // 3m grid: 180s.
  assert interval.sourcebar_closed(
    interval.IntervalThreeMinute,
    timestamp.from_unix_seconds(180),
  )
    as "3m boundary closes the bar"
  assert !interval.sourcebar_closed(
    interval.IntervalThreeMinute,
    timestamp.from_unix_seconds(181),
  )
}

/// Owner 2026-11-14 review: the grade reader takes a LABELLED argument, and
/// the value is named `sourcebar`, not the generic `bar`. MEASURED: a
/// labelled argument is NOT part of a function type — `fn(of: SourceBar) ->
/// Interval` is `error: Syntax error` — so a type binding cannot pin it.
/// This UNCALLED function is the check: the compiler checks the call site,
/// so removing or renaming the `of:` label fails the build without ever
/// running a `todo` body.
fn grade_call_is_labelled(sourcebar: SourceBar) -> Interval {
  sourcebar.interval(of: sourcebar)
}

pub fn sourcebar_interval_shape_test() {
  let _grade: fn(SourceBar) -> Interval = sourcebar.interval
  let _call: fn(SourceBar) -> Interval = grade_call_is_labelled
  Nil
}

/// R29 / owner 2026-11-15: the boundary reader is named after the
/// `SourceBar` Type and its `close`, so this pins
/// `fn(Interval, Timestamp) -> Bool` — no `SourceBar` in the signature,
/// one `Bool` written out.
pub fn sourcebar_closed_shape_test() {
  let _close: fn(Interval, Timestamp) -> Bool = interval.sourcebar_closed
  Nil
}

/// The boundary projection of a `Symbol` (R22): a spelling goes in, the same
/// spelling comes out. With the single-constructor standard `Symbol` filled,
/// this is a real round-trip, not just a signature pin. Names are an open set:
/// any spelling is a valid name, so no broker variant belongs here (R28 +
/// governance root, `docs/RULINGS.md` 「2026-11-17 08:37」).
pub fn symbol_codec_shape_test() {
  let _spelling_in: fn(String) -> Symbol = symbol.string_to_symbol
  let _spelling_out: fn(Symbol) -> String = symbol.to_string
  assert symbol.to_string(symbol.string_to_symbol("BTCUSDT")) == "BTCUSDT"
  assert symbol.to_string(symbol.string_to_symbol("SPY")) == "SPY"
  Nil
}

/// R28 / R27: each provider has its own native shape and its own one exit
/// into the standard layer; the standard layer is the only meeting point.
pub fn provider_exit_shape_test() {
  let _exit: fn(BinanceKline) -> Result(SourceBar, Nil) = kline.to_sourcebar
  Nil
}

/// Owner 2026-11-13: IB serves ONLY five seconds, so IB's own module
/// accumulates ONE arriving bar at a time into ONE
/// `growing_target_sourcebar`, with the three states of `working_databar`.
/// Nine target grades — one per `Interval` constructor — and no `List` of
/// saved bars. The target grade is in the FUNCTION NAME, so no `Interval`
/// parameter can claim a grade that disagrees with the bars in hand.
/// The compiler checks all nine shapes here.
pub fn ib_composition_shape_test() {
  let _one_minute: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_minute
  let _three_minute: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_three_minute
  let _fifteen_minute: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_fifteen_minute
  let _thirty_minute: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_thirty_minute
  let _one_hour: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_hour
  let _four_hour: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_four_hour
  let _one_day: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_day
  let _one_week: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_week
  let _one_month: fn(Option(SourceBar), ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Option(SourceBar)) =
    ib_sourcebar.five_second_to_one_month
  Nil
}

/// Owner 2026-11-13: composition is DISPATCHED at the `Instrument` layer,
/// because the `Interval` key lives there and `Instrument` knows which
/// timeframe gets which grade. It reads that key's
/// `Timeframe.growing_target_sourcebar`, calls ONE `five_second_to_*`,
/// and writes the recomputed `Instrument` back. ONE arriving bar in, ONE
/// recomputed Value out, at most ONE closed `SourceBar` emitted.
pub fn instrument_composition_shape_test() {
  let _dispatch: fn(Instrument, Interval, ib_sourcebar.IbSourceBar) ->
    #(Option(SourceBar), Instrument) = instrument.compose_ib_realtime_bar
  Nil
}

/// R28 / R27: one native Binance kline becomes the standard bar of THAT SAME
/// grade. The grade is read off the variant, never handed in by a caller. The
/// absolute `Timestamp` and OHLCV are carried across; the provider-only fields
/// stay on the native value and reach no consumer. Binance's own wire shape is
/// `GET /api/v3/klines` (12 fields, in order): Open time, Open, High, Low,
/// Close, Volume, Close time, Quote asset volume, Number of trades, Taker buy
/// base asset volume, Taker buy quote asset volume, Ignore.
pub fn binance_kline_to_sourcebar_test() {
  let open_time = timestamp.from_unix_seconds(1_499_040_000)
  let native =
    kline.BinanceKlineOneMinute(
      open_time:,
      open: 0.0163479,
      high: 0.8,
      low: 0.015758,
      close: 0.015771,
      volume: 148_976.11427815,
      close_time: timestamp.from_unix_seconds(1_499_644_799),
      quote_asset_volume: 2434.19055334,
      number_of_trades: 308,
      taker_buy_base_asset_volume: 1756.87402397,
      taker_buy_quote_asset_volume: 28.46694368,
      ignore: "0",
    )
  let assert Ok(sourcebar) = kline.to_sourcebar(native)
  assert sourcebar
    == sourcebar.SourceBarOneMinute(
      timestamp: open_time,
      open: 0.0163479,
      high: 0.8,
      low: 0.015758,
      close: 0.015771,
      volume: 148_976,
    )
    as "same grade; the absolute Timestamp and OHLCV are carried across"
}

/// R19 (4) 2026-11-17: the FIRST arriving 5s bar starts ONE growing target
/// bar of the function's grade; nothing closes on that arrival. The grade is
/// the function's name (one_hour -> SourceBarOneHour), never a parameter.
pub fn ib_composition_starts_growing_test() {
  let t = timestamp.from_unix_seconds(100)
  let arriving =
    ib_sourcebar.IbSourceBarFiveSecond(
      time: t,
      open: 10.0,
      high: 12.0,
      low: 9.0,
      close: 11.0,
      volume: 5,
      wap: 10.5,
      count: 3,
    )
  let #(closed, growing) = ib_sourcebar.five_second_to_one_hour(None, arriving)
  assert closed == None
  assert growing
    == Some(sourcebar.SourceBarOneHour(
      timestamp: t,
      open: 10.0,
      high: 12.0,
      low: 9.0,
      close: 11.0,
      volume: 5,
    ))
  Nil
}

/// R19 (4) 2026-11-17: inside the SAME UTC grid period the growing bar keeps
/// the FIRST open, takes MAX high / MIN low, the LATEST close, and ADDS
/// volume. The arriving bar's own open/wap/count never overwrite the grower.
pub fn ib_composition_accumulates_test() {
  let t0 = timestamp.from_unix_seconds(100)
  let growing_bar =
    sourcebar.SourceBarOneHour(
      timestamp: t0,
      open: 10.0,
      high: 12.0,
      low: 9.0,
      close: 11.0,
      volume: 5,
    )
  let arriving =
    ib_sourcebar.IbSourceBarFiveSecond(
      time: timestamp.from_unix_seconds(105),
      open: 99.0,
      high: 13.0,
      low: 8.0,
      close: 8.5,
      volume: 7,
      wap: 0.0,
      count: 1,
    )
  let #(closed, growing) =
    ib_sourcebar.five_second_to_one_hour(Some(growing_bar), arriving)
  assert closed == None
  assert growing
    == Some(sourcebar.SourceBarOneHour(
      timestamp: t0,
      open: 10.0,
      high: 13.0,
      low: 8.0,
      close: 8.5,
      volume: 12,
    ))
  Nil
}

/// R19 (4) 2026-11-17: at the UTC grid boundary the whole grown bar is
/// emitted as `closed` and growing returns to `None` (the three states of
/// `working_databar`). `interval.sourcebar_closed` decides the boundary from
/// the arriving Timestamp; the boundary is a period, not a bar count.
pub fn ib_composition_closes_test() {
  let t0 = timestamp.from_unix_seconds(100)
  let growing_bar =
    sourcebar.SourceBarOneHour(
      timestamp: t0,
      open: 10.0,
      high: 12.0,
      low: 9.0,
      close: 11.0,
      volume: 5,
    )
  let arriving =
    ib_sourcebar.IbSourceBarFiveSecond(
      time: timestamp.from_unix_seconds(3600),
      open: 11.0,
      high: 11.5,
      low: 10.5,
      close: 11.2,
      volume: 7,
      wap: 0.0,
      count: 1,
    )
  let #(closed, growing) =
    ib_sourcebar.five_second_to_one_hour(Some(growing_bar), arriving)
  assert closed == Some(growing_bar)
  assert growing == None
  Nil
}

/// R19 (4) 2026-11-17: the instrument reads/writes ONLY its `timeframes`
/// Dict, keyed by `Interval`. put then get returns the same timeframe; an
/// absent key is `Error(Nil)` (R37).
pub fn instrument_timeframes_round_trip_test() {
  let tf = empty_timeframe()
  let empty = Instrument(dict.new())
  assert instrument.get_timeframe(empty, interval.IntervalOneHour) == Error(Nil)
  let stored = instrument.put_timeframe(empty, interval.IntervalOneHour, tf)
  assert instrument.get_timeframe(stored, interval.IntervalOneHour) == Ok(tf)
  // a different key was never written
  assert instrument.get_timeframe(stored, interval.IntervalOneMinute)
    == Error(Nil)
  Nil
}

/// R19 (4) 2026-11-17: ONE arriving 5s bar is dispatched by the `Interval`
/// key to the matching `five_second_to_*`, the growing value is written back
/// into that Timeframe, and the recomputed Timeframe goes back under the
/// same key. First bar: no closed sourcebar, growing holds the target grade.
pub fn instrument_compose_first_bar_test() {
  let t = timestamp.from_unix_seconds(100)
  let arriving =
    ib_sourcebar.IbSourceBarFiveSecond(
      time: t,
      open: 10.0,
      high: 12.0,
      low: 9.0,
      close: 11.0,
      volume: 5,
      wap: 10.5,
      count: 3,
    )
  let stored =
    instrument.put_timeframe(
      Instrument(dict.new()),
      interval.IntervalOneHour,
      empty_timeframe(),
    )
  let #(closed, updated) =
    instrument.compose_ib_realtime_bar(
      stored,
      interval.IntervalOneHour,
      arriving,
    )
  assert closed == None
  let assert Ok(tf) =
    instrument.get_timeframe(updated, interval.IntervalOneHour)
  assert tf.growing_target_sourcebar
    == Some(sourcebar.SourceBarOneHour(
      timestamp: t,
      open: 10.0,
      high: 12.0,
      low: 9.0,
      close: 11.0,
      volume: 5,
    ))
  Nil
}

/// R19 (4) 2026-11-17: a yin/yang leaf is born on one bar — start and corner
/// are that bar, end is None (R1) — and the three readers return those bars.
pub fn leaf_birth_and_readers_test() {
  let bar = listed_bar(10)
  let yin = leaf.born_yin(bar)
  let yang = leaf.born_yang(bar)
  assert leaf.start_bar(yin) == bar
  assert leaf.corner_bar(yin) == bar
  assert leaf.end_bar(yin) == None
  assert leaf.start_bar(yang) == bar
  assert leaf.corner_bar(yang) == bar
  assert leaf.end_bar(yang) == None
  Nil
}

/// R6 / R1: leaf_size is idx arithmetic, both ends included, NEVER a price
/// test and never a walk of databar_list. A growing leaf has no end_bar, so
/// the bar in hand is its last bar: start idx 10, bar idx 15 -> 6 bars.
pub fn leaf_size_idx_arithmetic_test() {
  let start = listed_bar(10)
  let later = listed_bar(15)
  let growing = leaf.born_yin(start)
  assert leaf.leaf_size(growing, later) == 6
  assert leaf.leaf_size(growing, start) == 1
  Nil
}

/// R3 2026-11-17: cma_recurrence is ONE forward step, `(prev*N + raw)/(N+1)`
/// with `N = idx - start_idx`, reading the previous mean off the HEAD of the
/// newest-first list (O(1), never walked). A leaf born this bar (N=0) returns
/// its own raw value, never a zero sentinel. Readers are injected here so the
/// step is tested without a real moving-average field on DataBar (R26).
pub fn leaf_cma_recurrence_test() {
  let raw = fn(bar: databar.DataBar) -> Float { bar.close }
  // born this bar: N = 0 -> raw, list is irrelevant
  let born = listed_bar(10)
  assert leaf.cma_recurrence(born, [], 10, raw, raw) == born.close
  // second bar: N = 1, prev mean from HEAD = 10.0, raw of current = 20.0
  let prev = databar.DataBar(..listed_bar(9), close: 10.0)
  let cur = databar.DataBar(..listed_bar(10), close: 20.0)
  assert leaf.cma_recurrence(cur, [prev], 9, raw, raw) == 15.0
  Nil
}

/// R3 (owner verbatim): `leaf_depth` is a share of the SELECTED MA, read off
/// start_bar and corner_bar — a yin leaf's top is its start (the corner is the
/// low), a yang leaf's top is its corner. pin the share and the polarity, and
/// that it is a share (finite ratio), not a price difference.
pub fn leaf_depth_share_test() {
  let yin = leaf.YinLeaf(ma_bar(0, 100.0), None, ma_bar(1, 80.0))
  assert leaf.leaf_depth(yin) == 0.2 as "yin: (100-80)/100"
  let yang = leaf.YangLeaf(ma_bar(0, 80.0), None, ma_bar(1, 100.0))
  assert leaf.leaf_depth(yang) == 0.2 as "yang: (100-80)/100"
  Nil
}

/// branch.move_between is the one P&L measurement: a share of the selected
/// MA (R3) plus an idx-based bar count, both ends included (R6). No series is
/// walked; the two bars already carry both values.
pub fn branch_move_between_test() {
  let #(move, bars, per_bar) =
    branch.move_between(ma_bar(0, 100.0), ma_bar(4, 125.0))
  assert move == 0.25 as "share: (125-100)/100"
  assert bars == 5.0 as "both ends included: idx 0..4"
  assert per_bar == 0.05 as "slope: 0.25/5"
  Nil
}

/// recognised_move is the actionable window enter_bar -> exit_bar (R11);
/// None while no exit_bar exists, because one end of a move is not a move (R1).
pub fn branch_recognised_move_test() {
  let growing =
    branch.YangBranch(ma_bar(0, 100.0), ma_bar(1, 100.0), None, None)
  assert branch.recognised_move(growing) == option.None as "no exit, no move"
  let ended =
    branch.YangBranch(
      ma_bar(0, 100.0),
      ma_bar(1, 100.0),
      None,
      Some(ma_bar(4, 125.0)),
    )
  let #(move, bars, _) = branch.move_between(ma_bar(1, 100.0), ma_bar(4, 125.0))
  assert branch.recognised_move(ended)
    == option.Some(#(move, bars, move /. bars))
    as "enter->exit window, no end_bar needed"
  Nil
}

/// R19 (4) 2026-11-17: branch readers return the four bars from the right
/// variant, and the polarity name is projected off the constructor (R2), so
/// its spelling cannot contradict the value.
pub fn branch_readers_and_polarity_test() {
  let b = ended_yang_branch()
  assert branch.start_bar(b) == listed_bar(10)
  assert branch.enter_bar(b) == listed_bar(12)
  assert branch.end_bar(b) == Some(listed_bar(15))
  assert branch.exit_bar(b) == Some(listed_bar(17))
  assert branch.lower_case_type_name(b) == "yang"
  assert branch.lower_case_type_name(branch.YinBranch(
      start_bar: listed_bar(1),
      enter_bar: listed_bar(1),
      end_bar: None,
      exit_bar: None,
    ))
    == "yin"
  Nil
}

/// R4 / R11: recognition is one line — a branch was recognised on this bar
/// iff its enter_bar.idx == idx; None is False. recognised_start_idx reads
/// start_bar.idx only when recognised is True, never searching a second time.
pub fn branch_recognition_test() {
  let b = ended_yang_branch()
  assert branch.recognised_this_bar(Some(b), 12) == True
  assert branch.recognised_this_bar(Some(b), 11) == False
  assert branch.recognised_this_bar(None, 12) == False
  assert branch.recognised_start_idx(Some(b), True) == Some(10)
  assert branch.recognised_start_idx(Some(b), False) == None
  assert branch.recognised_start_idx(None, True) == None
  Nil
}

/// R5: exited_branch reads ONLY the head of the newest-first list (O(1), no
/// list.find). Some only when the head's exit_bar.idx == idx, so one exit is
/// never marked twice; None on any other bar or empty list.
pub fn branch_exited_head_test() {
  let b = ended_yang_branch()
  assert branch.exited_branch([b], 17) == Some(b)
  assert branch.exited_branch([b], 16) == None
  assert branch.exited_branch([], 17) == None
  Nil
}

/// R39 / R8: sourcebar_gate is the ONE door. A qualified bar is born whole
/// into working_databar, with idx from bars_listed (the head's idx + 1, not a
/// list count). An unqualified bar is refused with a typed reason and the
/// timeframe is left unchanged (reject, never repair).
pub fn timeframe_sourcebar_gate_test() {
  let t = timestamp.from_unix_seconds(1_499_040_000)
  let qualified =
    sourcebar.SourceBarOneHour(
      timestamp: t,
      open: 10.0,
      high: 12.0,
      low: 9.0,
      close: 11.0,
      volume: 5,
    )
  let assert Ok(updated) =
    timeframe.sourcebar_gate(
      empty_timeframe(),
      interval.IntervalOneHour,
      qualified,
    )
  let assert Some(working) = updated.working_databar
  assert working.idx == 0
  assert working.close == 11.0
  // an unqualified bar (negative volume) is refused, timeframe unchanged
  let bad = sourcebar.SourceBarOneHour(..qualified, volume: -1)
  assert timeframe.sourcebar_gate(
      empty_timeframe(),
      interval.IntervalOneHour,
      bad,
    )
    == Error(sourcebar.SourceBarRejectionUnqualified)
  Nil
}

/// R39 / R41: archiving takes the ONE working bar, prepends it to the HEAD of
/// databar_list (O(1), newest stays first) and clears working back to None.
/// It takes no bar argument — the bar archived is the one in the field.
pub fn timeframe_archived_prepends_test() {
  let working = listed_bar(41)
  let tf = Timeframe(..empty_timeframe(), working_databar: Some(working))
  let updated = timeframe.working_databar_archived(tf)
  assert updated.working_databar == None
  assert updated.databar_list == [working]
  assert timeframe.bars_listed(updated.databar_list) == 42
  Nil
}
