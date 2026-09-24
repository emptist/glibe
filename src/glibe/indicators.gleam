/// Bollinger Bands indicator
pub type BollingerBands {
  BollingerBands(
    bb_m: Float,
    bb_u3: Float,
    bb_l3: Float,
    bb_u2: Float,
    bb_u1: Float,
    bb_l1: Float,
    bb_l2: Float,
  )
}

/// KDJ oscillator indicator
pub type KDJ {
  KDJ(k: Float, d: Float, j: Float, m: Float)
}

/// SMA selection for Bollinger center line
pub type SmaForBbm {
  SmaForBbmTiny
  SmaForBbmSmall
  SmaForBbmMedium
  SmaForBbmLarge
}

/// SMA series identifiers
pub type SmaSeries {
  SmaSeriesTiny
  SmaSeriesSmall
  SmaSeriesMedium
  SmaSeriesLarge
}

/// Configuration for all indicators (per market)
pub type TimeframeSettings {
  TimeframeSettings(
    sma_tiny_window_size: Int,
    sma_small_window_size: Int,
    sma_medium_window_size: Int,
    sma_large_window_size: Int,
    window_kdj_size: Int,
    kdj_k_period: Int,
    kdj_d_period: Int,
    bb_multiplier: Float,
    sma_for_bbm: SmaForBbm,
    branch_exit_leaf_size: Int,
  )
}

/// Default indicator configuration (Crypto defaults)
pub fn default_timeframe_settings() -> TimeframeSettings {
  TimeframeSettings(
    sma_tiny_window_size: 7,
    sma_small_window_size: 70,
    sma_medium_window_size: 140,
    sma_large_window_size: 252,
    window_kdj_size: 9,
    kdj_k_period: 3,
    kdj_d_period: 2,
    bb_multiplier: 1.99,
    sma_for_bbm: SmaForBbmMedium,
    branch_exit_leaf_size: 40,
  )
}