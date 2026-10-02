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