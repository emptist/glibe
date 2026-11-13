//// Binance's OWN external bar, before this system has any bar at all.
//// Implements `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// WORK OF THIS MODULE: hold the shape Binance sends as a FAMILY of grades
//// and normalise one of them into the matching variant of the ONE internal
//// standard bar. It does not validate a bar, compute on a bar, archive a
//// bar, or know any internal timeframe key.
////
//// WHERE A BAR COMES FROM: an api provider / data source (R33). A data
//// source that is also a `Broker` appears as `Broker` under its `BrokerId`
//// key in `Desk.brokers` (R50); a data source that is not a broker does not
//// appear there at all. So `Broker` is neither the parent nor the child of
//// a data source — the two are separate types with separate identities
//// (R36's shape), and one real institution can hold both. The provider is
//// the INPUT boundary (R33), not a level of `Desk ▸ Broker ▸ Instrument ▸
//// Timeframe`; this module imports no broker.
////
//// WHAT ARRIVES: not `api/sourcebar.SourceBar` (the ONE internal standard
//// bar) and not `databar.DataBar` (the ONE internal working bar). What
//// arrives is each data source's own external raw bar. R28 (owner,
//// verbatim): *"binance的kline包含很多特殊字段，其他提供商不提供 比如ib不
//// 提供那些字段，所以他们两家的sourcebar绝对不同，要保留原生态，并且各自
//// 标准化"* and *"你看他原生的名字都不一样，binance称为kline，别人家可能
//// 成为bar，quote之类的形形色色"*. So THIS type is named `BinanceKline`, the
//// provider's own word for its raw source bar. Another data source gets its
//// own type in its own module; there is no union of providers and no
//// generic raw bar here.
////
//// NAMING (owner, verbatim, 2026-11-13): *"基本的构成是 来源+bar名称+
//// 时间跨度，是一贯的"*. So the constructors below are
//// `BinanceKlineOneMinute` … `BinanceKlineOneMonth`: source + the
//// provider's own bar word + the span, with the unit singular as in the
//// standard family's `SourceBarOneHour`. A second provider keeps its own
//// word: `ib/sourcebar.IbSourceBarFiveSecond` is a real one, under the
//// same three-part rule. The source prefix is not decoration: another data
//// source — say a second broker — may also call its own bar `Kline`, and
//// `KlineOneHour` alone cannot say whose bar it is. The standard
//// `SourceBar` has no source prefix because there is exactly ONE of it and
//// it names no provider at all.
////
//// WHICH PERIOD, AND WHY THE CONVERTER HAS NO `Interval` PARAMETER:
//// `Interval` has exactly ONE home — the key of `Instrument.timeframes`
//// (R23 / R37; owner: *"你的左手不知道他是左还是右"*). A provider sits at
//// the input boundary and never holds that key. If `to_sourcebar` accepted
//// an `Interval`, the grade would be a number claimed by a caller that
//// could disagree with the bar in hand — the same disagreement owner
//// ruled out with *"校服就是变体，通过类型即可知道是什么，不需要改变bar到
//// 身体，懂吗？"* (2026-10-26). So the grade of an external bar is a
//// VARIANT of `BinanceKline`, just as it is a variant of `SourceBar`: the decoder
//// builds the variant for the stream it subscribed to, and `to_sourcebar`
//// maps it one-to-one. Owner 2026-11-01 (verbatim): *"sourcebar存在利用
//// 小段生成大段 sourcebar 的需要，即无法用timeframe隔离，要混用，所以要
//// 变体"*. The caller separately holds its `Interval` key to select the
//// `Timeframe`; that key never crosses into this module.
////
//// WHY THIS MODULE HAS NO COMPOSITION. Binance's kline endpoint ALREADY
//// serves all nine grades the system needs, one native variant each, so
//// `to_sourcebar` is a one-to-one mapping and every `SourceBar` grade has
//// a way in. A source that does NOT serve them — IB's realtime stream
//// gives only five seconds — accumulates ONE arriving bar at a time into
//// `Timeframe.growing_target_sourcebar`, dispatched by
//// `instrument.compose_ib_realtime_bar` to ONE of
//// `ib/sourcebar.five_second_to_one_minute` and its eight siblings (owner
//// 2026-11-13). R50 (owner, verbatim): *"even if it is called, it should
//// be defined in its belonging to module"*: the functions live in IB's
//// module, while the DISPATCH lives at the layer that holds the `Interval`
//// key. Composition is not a standard-layer job and is not a
//// `Timeframe` job: each provider repairs only its own granularity
//// (R28), before a `DataBar` exists.
////
//// EACH VARIANT CARRIES THE SAME NATIVE FIELDS, in the same order and with
//// the same types, so a reader writes `kline.close` without matching the
//// grade. The wire spellings `closeTime`, `quoteAssetVolume`,
//// `numberOfTrades`, `takerBuyBaseAssetVolume`,
//// `takerBuyQuoteAssetVolume`, `ignore` (R28) are spelled here the way
//// Gleam fields are spelled, never kept as a `String` to be parsed later
//// (R13 / R21). Adding a tenth span is a new variant plus one arm in
//// `to_sourcebar`; the compiler's exhaustiveness check is the bill.
////
//// WHERE IT GOES AND HOW: `to_sourcebar` is this provider's ONLY exit
//// (R28) and takes ONLY its own bar. It writes the standard `SourceBar`
//// variant of the same grade; the standard layer is the only meeting point
//// and absorbs none of these native names. From there `sourcebar.validate`
//// refuses an unqualified bar (R8), `sourcebar.to_databar` gives it one
//// whole birth (R39 / R42), and `timeframe.sourcebar_gate` writes it into
//// `Timeframe.working_databar`. R27: Binance's epoch-milliseconds become
//// an absolute unix `Timestamp` HERE at the boundary, and nowhere else
//// (R9 / R28).
////
//// WHO READS THESE FIELDS: `to_sourcebar` reads the OHLCV and `open_time`.
//// The other native fields are held because R28 requires the native shape
//// kept, and each gains a reader in this module when its consumer exists
//// (R26 / R32).
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

import gleam/time/timestamp.{type Timestamp}
import glibe/api/sourcebar.{type SourceBar}

/// One Binance kline, in the provider's own shape, graded by its variant.
/// It is not the standard `SourceBar` and not a `DataBar`.
pub type BinanceKline {
  BinanceKlineOneMinute(
    open_time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Timestamp,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
  BinanceKlineThreeMinute(
    open_time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Timestamp,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
  BinanceKlineFifteenMinute(
    open_time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Timestamp,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
  BinanceKlineThirtyMinute(
    open_time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Timestamp,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
  BinanceKlineOneHour(
    open_time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Timestamp,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
  BinanceKlineFourHour(
    open_time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Timestamp,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
  BinanceKlineOneDay(
    open_time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Timestamp,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
  BinanceKlineOneWeek(
    open_time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Timestamp,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
  BinanceKlineOneMonth(
    open_time: Timestamp,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Float,
    close_time: Timestamp,
    quote_asset_volume: Float,
    number_of_trades: Int,
    taker_buy_base_asset_volume: Float,
    taker_buy_quote_asset_volume: Float,
    ignore: String,
  )
}

/// This provider's ONE normalisation into the internal standard bar (R28),
/// one external grade to the standard variant of the same grade. It takes
/// ONLY its own bar: the grade is read from the `BinanceKline` variant, never
/// handed in as a parameter that could disagree with it (R23 / R37).
///
/// Failure has nothing to say here, so the error type is `Nil` (core §6);
/// a real reason becomes a domain error type when its consumer exists
/// (R13 / R26). Epoch-ms is folded to unix `Timestamp` here (R27 / R9).
/// This function must name every grade, so a tenth span becomes an
/// `Inexhaustive patterns` error here (R13).
pub fn to_sourcebar(kline: BinanceKline) -> Result(SourceBar, Nil) {
  todo as "05-01: case over the nine BinanceKline grades, fold epoch-ms to unix, take the standard OHLCV, build the matching SourceBar variant"
}
