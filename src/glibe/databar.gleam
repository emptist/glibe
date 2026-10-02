/// The bar the streaming system works with — computed from SourceBar + indicators.
/// Used by timeframe, SMA, KDJ, Bollinger, Leaf, Branch.
pub type DataBar {
  DataBar(
    idx: Int,    // global position in databar_list (0 = oldest settled bar)
    date: String,
    open: Float,
    high: Float,
    low: Float,
    close: Float,
    volume: Int,

    // SMA series
    sma_tiny: Float,
    sma_small: Float,
    sma_medium: Float,
    sma_large: Float,

    // Bollinger Bands
    bb_m: Float,
    bb_u3: Float,
    bb_l3: Float,
    bb_u2: Float,
    bb_u1: Float,
    bb_l1: Float,
    bb_l2: Float,

    // KDJ oscillator
    k: Float,
    d: Float,
    j: Float,
    m: Float,

    // Bias
    bias: Float,

    // Crossovers
    small_above_tiny: Bool,
    cmas_up: Bool,
    bars_k_on_d: Int,
    bars_d_on_k: Int,

    // Leaf CMA
    yin_leaf_cma: Float,
    yang_leaf_cma: Float,
    inner_yin_leaf_cma: Float,
    inner_yang_leaf_cma: Float,
    inner_inner_yin_leaf_cma: Float,
    inner_inner_yang_leaf_cma: Float,

    // KDJ signals
    kdj_cross_up: Bool,
    kdj_bearish_left: Bool,

    // Price action
    price_at_lower_band: Bool,
    sma_tiny_rising: Bool,
    leaf_cmas_rising: Bool,
    leaf_cmas_falling: Bool,

    // Strategy signal
    signal: String,
  )
}