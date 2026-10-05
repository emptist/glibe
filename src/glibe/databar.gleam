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
    sma_huge: Float,

    // Bollinger Bands
    bb_m: Float,
    bb_u3: Float,
    bb_l3: Float,
    bb_u2: Float,
    bb_u1: Float,
    bb_l1: Float,
    bb_l2: Float,

    // Welford σ recurrence carried on the bar (plan 31-02 §3); read by
    // bollinger.sigma/1 and extended O(1) by the next bar. Added to complete
    // the Welford port, which referenced them but never declared them.
    sigma_n: Int,
    sigma_mean: Float,
    sigma_m2: Float,

    // KDJ oscillator
    k: Float,
    d: Float,
    j: Float,
    m: Float,
    // Amortised-constant LLV/HHV extremes (plan 31-04, UC-64)
    kdj_h: Float,
    kdj_h_idx: Int,
    kdj_l: Float,
    kdj_l_idx: Int,

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