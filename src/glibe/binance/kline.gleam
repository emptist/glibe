//// Binance's native bar. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: the standard `SourceBar`.
//// WRITES: `Kline`, Binance's OWN shape, and this provider's one exit.
////
//// R28 (owner, verbatim): *"binance的kline包含很多特殊字段，其他提供商不提供
//// 比如ib不提供那些字段，所以他们两家的sourcebar绝对不同，要保留原生态，
//// 并且各自标准化"*; and *"你看他原生的名字都不一样，binance称为kline，
//// 别人家可能成为bar，quote之类的形形色色"*. So this type is called
//// `Kline` — the provider's own word — and is NOT the internal standard
//// `SourceBar`, NOT a union of providers and NOT a generic JSON bar.
////
//// R28 names the wire fields that must not be dropped: `closeTime`,
//// `quoteAssetVolume`, `numberOfTrades`, `takerBuyBaseAssetVolume`,
//// `takerBuyQuoteAssetVolume`, `ignore`, plus the OHLCV the standard
//// layer consumes. They are NOT listed as fields here: per R26 / R32 a
//// field is added when its real consumer — the decoder — exists, one at a
//// time. This skeleton fixes the TYPE and the single exit only; the field
//// shape belongs to the codec, and its names come from the provider.
////
//// R28: `to_sourcebar` is this provider's ONLY exit and the standard layer
//// is the only meeting point; the standard layer absorbs none of these
//// names. R27: the standard bar's time is an absolute unix `Timestamp`,
//// so Binance's epoch-milliseconds are folded HERE, at the boundary, and
//// nowhere else. R29: a market calendar is a later debt for a real
//// consumer, never a fixed offset in this adapter.
////
//// R19 status: skeleton. Body is `todo as "..."`; no working line here.

import glibe/api/sourcebar.{type SourceBar}

/// A Binance kline, in the provider's own shape. Not the standard bar.
pub type Kline {
  Kline
}

/// This provider's one normalisation. Failure has nothing to say here, so
/// the error type is `Nil` (core §6); a real reason becomes a domain error
/// type when its consumer exists (R13 / R26).
pub fn to_sourcebar(kline: Kline) -> Result(SourceBar, Nil) {
  todo as "05-01: fold native time to unix and take the standard OHLCV"
}
