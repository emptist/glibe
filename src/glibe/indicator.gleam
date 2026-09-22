// Indicator pipeline — composes SMA, KDJ, Bollinger

import glibe/sma
import glibe/kdj
import glibe/bollinger
import glibe/indicator_settings.{type TimeframeSettings}
import glibe/types as types

/// Indicator pipeline — SMA series → KDJ → Bollinger
/// Returns updated databar; timeframe update handled by caller
pub fn run(databar: types.DataBar, databar_list: List(types.DataBar), settings: TimeframeSettings) -> types.DataBar {
  // SMA series
  let databar = sma.sma(databar, databar_list, settings, sma.SmaSeriesTiny)
  let databar = sma.sma(databar, databar_list, settings, sma.SmaSeriesSmall)
  let databar = sma.sma(databar, databar_list, settings, sma.SmaSeriesMedium)
  let databar = sma.sma(databar, databar_list, settings, sma.SmaSeriesLarge)

  // KDJ
  let databar = kdj.kdj(databar, databar_list, settings)

  // Bollinger — uses selected SMA as centre
  bollinger.bollinger(databar, databar_list, settings)
}