//// The indicators — ONE pure bar → bar computation: the five SMA series,
//// KDJ and the Bollinger bands, in that order.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-13-PLAN.md` §5 (upstream
//// contracts found by writing `timeframe.gleam`'s doc first). This module is
//// an UPSTREAM of `glibe/timeframe`: the pipeline's `indicator` step calls
//// `run` on `Timeframe.working_databar` with `databar_list` and `settings`,
//// and writes the resulting bar back into the record. It takes a bar, a list
//// and a settings value — never the `Timeframe` — so it has no record to
//// thread and closes no import cycle.
////
//// The `////` above is a retrofit: glib had no documentation-first TDD, and
//// glibe inherited that gap. Only the doc is added here; the function is the
//// existing, tested computation.

// Indicator pipeline — composes SMA, KDJ, Bollinger

import glibe/bollinger
import glibe/databar
import glibe/indicator_settings.{type TimeframeSettings}
import glibe/kdj
import glibe/sma

/// Indicator pipeline — SMA series → KDJ → Bollinger
/// Returns updated databar; timeframe update handled by caller
pub fn run(
  databar: databar.DataBar,
  databar_list: List(databar.DataBar),
  settings: TimeframeSettings,
) -> databar.DataBar {
  // SMA series
  let databar = sma.sma(databar, databar_list, settings, sma.SmaSeriesTiny)
  let databar = sma.sma(databar, databar_list, settings, sma.SmaSeriesSmall)
  let databar = sma.sma(databar, databar_list, settings, sma.SmaSeriesMedium)
  let databar = sma.sma(databar, databar_list, settings, sma.SmaSeriesLarge)
  let databar = sma.sma(databar, databar_list, settings, sma.SmaSeriesHuge)

  // KDJ
  let databar = kdj.kdj(databar, databar_list, settings)

  // Bollinger — uses selected SMA as centre
  bollinger.bollinger(databar, databar_list, settings)
}
