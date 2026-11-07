// Shared settings and types for indicators
//
// One closed set, one home. `SmaSeries` used to be declared here as well as in
// `sma.gleam`, with FOUR constructors here and FIVE there — a second, smaller
// copy of a set nothing used. It lives in `sma.gleam`, the module that owns it.

pub type SmaForBbm {
  SmaForBbmTiny
  SmaForBbmSmall
  SmaForBbmMedium
  SmaForBbmLarge
  SmaForBbmHuge
}

pub type TimeframeSettings {
  TimeframeSettings(
    sma_tiny_window_size: Int,
    sma_small_window_size: Int,
    sma_medium_window_size: Int,
    sma_large_window_size: Int,
    sma_huge_window_size: Int,
    kdj_window_size: Int,
    kdj_k_period: Int,
    kdj_m_period: Int,
    bb_multiplier: Float,
    sma_for_bbm: SmaForBbm,
    branch_exit_leaf_size: Int,
  )
}
