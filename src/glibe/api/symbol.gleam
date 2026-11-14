//// A name, not a thing. Implements
//// `.planning/phases/05-doc-tdd/05-01-PLAN.md`.
////
//// READS: nothing. This is at the bottom of the chain.
//// WRITES: `Symbol`, used as the key of `Broker.instruments`.
////
//// R22 (owner, verbatim): *"Symbol never is Instrument, people may call you
//// with different titles and names they like, but you are you, how can a
//// title and name be you?"* A broker spells an instrument its own way; the
//// instrument itself never stores that spelling. There is no `InstrumentId`,
//// no alias and no compatibility layer.
////
//// R37: identity lives in the HOLDER's Dict key. R26: each broker's dialect
//// is an adapter concern, not a new type in the model. R13: an identifier is
//// its own type, opaque so a `String` is not a `Symbol`.
////
//// R19 status: skeleton. Bodies are `todo as "..."`; no working line here.

/// The spelling a broker uses for an instrument. Opaque: a spelling can only
/// be made through `from_string`, and is never confused with a plain `String`.
pub opaque type Symbol {
  /// <**human: variants should be used here, so you should try whether if you should define Symbol types in broker modules, instead of in symbol module：
  /// in Binance module, perhaps opaque one:
  /// pub type BinanceSymbol {
  ///   BinanceStockBSymbol(string: String)
  ///   BinanceFuturesSymbol(string: String)
  /// }
  /// you should compare the two approaches to see which is more suitable for your case
  /// 
  /// 
  /// all the variants below are just examples, not to take the names without careful consideration**>
  BinanceStockBSymbol(string: String)
  BinanceFuturesSymbol(string: String)
  IbStockSymbol(string: String)
  IbOptionSymbol(string: String)
  IbForexSymbol(string: String)
  //Symbol(spelling: String)
}

/// A broker's spelling becomes a `Symbol`. The wire spelling is boundary
/// data; the entity is not built here (R22).
/// <**human: string_to_symbol is a gleam convetion for a function that takes a string and returns a symbol, https://gleam.run/documentation/conventions-patterns-and-anti-patterns/
/// the following code is just an example, I even don't know if they are correct in syntax, not to take the code without careful consideration**>
///  
/// pub fn string_to_symbol(string: String, symbol_type:Symbol.type) -> Symbol {
///   case symbol_type {
///       BinanceStockBSymbol -> BinanceStockBSymbol(string)
///       BinanceFuturesSymbol -> BinanceFuturesSymbol(string)
///       IbStockSymbol -> IbStockSymbol(string)
///       IbOptionSymbol -> IbOptionSymbol(string)
///       IbForexSymbol -> IbForexSymbol(string)
///   }
/// }
/// 
/// echo symbol.string_to_symbol("SPYBUSDT", BinanceStockBSymbol)
/// or:
/// echo symbol.string_to_symbol(symbol_type:IbStockSymbol, string:"SPY")
/// **>
pub fn from_string(spelling: String) -> Symbol {
  todo as "05-01: a name is given by the holder, not by the thing"
}

/// 
/// <**human: use symbol_to_string to convert a symbol to a string **>
/// 
/// The spelling back out, for codecs and view projections only.
pub fn symbol_to_string(symbol: Symbol) -> String {
  //pub fn to_string(symbol: Symbol) -> String {
  case symbol {
    // <**human: you can still use todo here, but it's so simple why wait?**>
    BinanceStockBSymbol(string) -> todo as "will return the string here"
    BinanceFuturesSymbol(string) -> string
    IbStockSymbol(string) -> string
    IbOptionSymbol(string) -> string
    IbForexSymbol(string) -> string
    // <**human: now, this will cause a compile warning, I intend this**>
    _ -> todo as "05-01: project the name at a boundary"
  }
}
