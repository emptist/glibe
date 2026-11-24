//// The LIVE feed pump: drives the ONE App from real Binance REST klines.
//// Implements Task 3 of `.planning/phases/05-live-feed/05-01-PLAN.md`.
////
//// WHAT THIS IS NOT: it is not a second App, not a second Desk, not a clock
//// inside the model (R33 / R60). It is the INPUT boundary's process: it
//// fetches real bars, filters out ones already seen, and dispatches each new
//// one through the SAME `wire.sourcebar_event` entry the archive used. The
//// model stays the pure `Desk → Desk` pipe; this process only sends events.
////
//// WHY THE FILTER IS PURE AND SEPARATE: `newer_than` takes a boundary and a
//// batch and returns only bars strictly newer than it, so a test pins the
//// "frequent read, finite accept" rule (BRIEF) with real timestamps and no
//// network. The `Option(Timestamp)` boundary is carried as a recursion
//// argument — no mutable state, no ETS, no process dictionary.
////
//// R33: history and live are ONE stream. The initial window and the polled
//// batches go through the identical inject path; only the boundary changes.
//// A fetch failure is logged and retried — never a fallback to synthetic
//// bars (owner 2026-11-25: "老老实实做数据源连接获取真实时数据").
////
//// R19 status (2026-11-25): skeleton — `////` → types → `///` + signature →
//// `todo` → RED test → one body at a time to GREEN.

import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/time/duration
import gleam/time/timestamp.{type Timestamp}
import glibe/api/interval.{type Interval}
import glibe/api/sourcebar.{type SourceBar}
import glibe/api/symbol.{type Symbol, to_string as symbol_to_string}
import glibe/app/wire
import glibe/binance/rest
import glibe/desk.{type Desk}
import glibe/id.{type BrokerId}
import plushie

/// Milliseconds between polls. Binance's one-minute kline closes each minute;
/// polling faster only re-reads the still-open bar. Ten seconds gives a new
/// closed bar promptly without hammering the public endpoint.
const poll_interval_ms: Int = 10_000

/// How many bars the startup window pulls to seed a visible chart.
const startup_window: Int = 60

/// How many bars each poll pulls (newest few, to survive a missed minute).
const poll_window: Int = 3

/// Only bars whose timestamp is strictly after `boundary` pass. `None` means
/// nothing has been seen yet, so the whole batch passes. The result keeps the
/// batch's own order (Binance returns oldest-first), so injection stays in
/// chronological order. Pure — no IO, no clock, no mutation.
pub fn newer_than(
  bars: List(SourceBar),
  boundary: Option(Timestamp),
) -> List(SourceBar) {
  case boundary {
    None -> bars
    Some(b) ->
      list.filter(bars, fn(bar) {
        timestamp.compare(bar.timestamp, b) == order.Gt
      })
  }
}

/// The next boundary after injecting `bars`: the newest timestamp among the
/// accepted bars, or the old boundary when nothing new arrived. Pure.
pub fn advance_boundary(
  bars: List(SourceBar),
  boundary: Option(Timestamp),
) -> Option(Timestamp) {
  list.fold(bars, boundary, fn(current, bar) {
    case current {
      None -> Some(bar.timestamp)
      Some(b) ->
        case timestamp.compare(bar.timestamp, b) {
          order.Gt -> Some(bar.timestamp)
          _ -> current
        }
    }
  })
}

/// Dispatch already-filtered bars to the ONE App, oldest-first, through the
/// SAME wire event the archive path used (R33 one stream).
pub fn inject(
  instance: plushie.Instance(Desk),
  broker: BrokerId,
  symbol_name: Symbol,
  interval: Interval,
  bars: List(SourceBar),
) -> Nil {
  list.each(bars, fn(bar) {
    plushie.dispatch_event(
      instance,
      wire.sourcebar_event(wire.SourceBarArrived(
        broker_id: broker,
        symbol: symbol_name,
        interval: interval,
        sourcebar: bar,
      )),
    )
  })
}

/// A one-line, human-readable summary of a real fetch turn: how many real
/// bars were injected and the newest bar's UTC+8 wall-clock time. Pure so a
/// test can pin the format; the pump calls it with the actual count and
/// boundary to make a running feed visibly show live data arriving.
pub fn describe_live(count: Int, boundary: Option(Timestamp)) -> String {
  let head = int.to_string(count) <> " real bars"
  case boundary {
    None -> head
    Some(newest) ->
      head
      <> ", newest "
      <> timestamp.to_rfc3339(newest, duration.seconds(8 * 3600))
  }
}

/// The long-lived poll loop. Carries the last-seen timestamp as a recursion
/// argument. Each turn fetches a fresh window, keeps only new bars, injects
/// them, advances the boundary, sleeps, and recurses. A failed fetch is
/// logged and retried after a sleep, with the boundary unchanged — never a
/// synthetic fallback.
pub fn pump(
  instance: plushie.Instance(Desk),
  broker: BrokerId,
  symbol_name: Symbol,
  interval: Interval,
  boundary: Option(Timestamp),
) -> Nil {
  process.sleep(poll_interval_ms)
  case rest.fetch_klines(symbol_to_string(symbol_name), interval, poll_window) {
    Error(error) -> {
      io.println_error("live feed fetch failed: " <> rest.describe_error(error))
      pump(instance, broker, symbol_name, interval, boundary)
    }
    Ok(batch) -> {
      let fresh = newer_than(batch, boundary)
      inject(instance, broker, symbol_name, interval, fresh)
      let next = advance_boundary(fresh, boundary)
      case fresh {
        [] -> Nil
        _ -> io.println("LIVE " <> describe_live(list.length(fresh), next))
      }
      pump(instance, broker, symbol_name, interval, next)
    }
  }
}

/// Seed the chart with a real startup window, then enter the poll loop. The
/// boundary starts at `None` so the whole window is injected. If the very
/// first fetch fails, log and let `pump` retry — no fake seed.
pub fn run(
  instance: plushie.Instance(Desk),
  broker: BrokerId,
  symbol_name: Symbol,
  interval: Interval,
) -> Nil {
  let symbol_wire = symbol_to_string(symbol_name)
  let boundary = case rest.fetch_klines(symbol_wire, interval, startup_window) {
    Error(error) -> {
      io.println_error(
        "live feed startup fetch failed: " <> rest.describe_error(error),
      )
      None
    }
    Ok(window) -> {
      inject(instance, broker, symbol_name, interval, window)
      let seen = advance_boundary(window, None)
      io.println("LIVE seed " <> describe_live(list.length(window), seen))
      seen
    }
  }
  pump(instance, broker, symbol_name, interval, boundary)
}
