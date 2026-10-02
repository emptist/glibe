// Shared settings and types for indicators

pub type SmaSeries {
  SmaSeriesTiny
  SmaSeriesSmall
  SmaSeriesMedium
  SmaSeriesLarge
}

pub type SmaForBbm {
  SmaForBbmTiny
  SmaForBbmSmall
  SmaForBbmMedium
  SmaForBbmLarge
}

pub type TimeframeSettings {
  TimeframeSettings(
    sma_tiny_window_size: Int,
    sma_small_window_size: Int,
    sma_medium_window_size: Int,
    sma_large_window_size: Int,
    window_kdj_size: Int,
    kdj_k_period: Int,
    kdj_d_period: Int,
    kdj_m_period: Int,
    bb_multiplier: Float,
    sma_for_bbm: SmaForBbm,
    branch_exit_leaf_size: Int,
  )
}