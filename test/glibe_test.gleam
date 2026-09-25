import gleam/list
import glibe/api/asset
import glibe/api/rules

pub fn main() {
  Nil
}

pub fn asset_class_from_string_crypto_test() {
  let result = asset.asset_class_from_string("Crypto")
  case result {
    asset.Crypto -> Nil
    _ -> panic as "Expected Crypto"
  }
}

pub fn asset_class_from_string_equity_test() {
  let result = asset.asset_class_from_string("Equity")
  case result {
    asset.Equity -> Nil
    _ -> panic as "Expected Equity"
  }
}

pub fn asset_class_from_string_invalid_test() {
  let result = asset.asset_class_from_string("Invalid")
  case result {
    asset.Crypto -> panic as "Should panic on invalid"
    _ -> Nil
  }
}

pub fn trading_hours_twenty_four_seven_test() {
  let result = rules.trading_hours_from_string("TwentyFourSeven")
  case result {
    rules.TwentyFourSeven -> Nil
    _ -> panic as "Expected TwentyFourSeven"
  }
}

pub fn trading_hours_twenty_four_five_test() {
  let result = rules.trading_hours_from_string("TwentyFourFive")
  case result {
    rules.TwentyFourFive -> Nil
    _ -> panic as "Expected TwentyFourFive"
  }
}

pub fn trading_hours_rth_test() {
  let result = rules.trading_hours_from_string("RTH;09:30;16:00;America/New_York")
  case result {
    rules.RTH(open: "09:30", close: "16:00", timezone: "America/New_York") -> Nil
    _ -> panic as "Expected RTH"
  }
}

pub fn trading_hours_custom_test() {
  let result = rules.trading_hours_from_string("Custom;09:30:12:00:Asia/Hong_Kong|13:00:16:00:Asia/Hong_Kong")
  case result {
    rules.Custom(sessions) -> {
      case list.length(sessions) == 2 {
        True -> Nil
        False -> panic as "Expected 2 sessions"
      }
    }
    _ -> panic as "Expected Custom"
  }
}

pub fn settlement_type_instant_test() {
  let result = rules.settlement_type_from_string("Instant")
  case result {
    rules.Instant -> Nil
    _ -> panic as "Expected Instant"
  }
}

pub fn settlement_type_tplus2_test() {
  let result = rules.settlement_type_from_string("TPlus2")
  case result {
    rules.TPlus2 -> Nil
    _ -> panic as "Expected TPlus2"
  }
}

pub fn auction_type_both_test() {
  let result = rules.auction_type_from_string("Both")
  case result {
    rules.Both -> Nil
    _ -> panic as "Expected Both"
  }
}

pub fn circuit_breaker_test() {
  let result = rules.circuit_breaker_from_string("CircuitBreaker;0.07;300;15")
  case result {
    rules.CircuitBreaker(threshold_pct: 0.07, window_seconds: 300, halt_minutes: 15) -> Nil
    _ -> panic as "Expected CircuitBreaker"
  }
}

pub fn asset_class_all_values_test() {
  // Test all valid AssetClass values
  let classes = ["Crypto", "Equity", "ETF", "BStock", "Future", "Option", "Currency"]
  list.each(classes, fn(c) {
    let _ = asset.asset_class_from_string(c)
    Nil
  })
  Nil
}

pub fn trading_hours_all_formats_test() {
  // Test all TradingHours formats
  let _ = rules.trading_hours_from_string("TwentyFourSeven")
  let _ = rules.trading_hours_from_string("TwentyFourFive")
  let _ = rules.trading_hours_from_string("RTH;09:30;16:00;America/New_York")
  let _ = rules.trading_hours_from_string("Custom;09:30:12:00:Asia/Hong_Kong|13:00:16:00:Asia/Hong_Kong")
  Nil
}