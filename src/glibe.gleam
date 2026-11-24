//// The ONE app: the composition root. Implements
//// `.planning/phases/03-app-view/03-03-PLAN.md`.
////
//// WHAT IS HERE, AND WHY IT IS ALL HERE:
////   - ONE `plushie.start` for the whole system. **Never one App per chart**
////     (owner 2026-11-23, R60 §1): try_plushie's three `plushie.start` calls
////     really are three Apps — three supervisors, three runtimes, three
////     renderers — and the official multi-window shape is ONE `start` whose
////     `view` returns several windows (`plushie/app.gleam:70-76`). glibe has
////     ONE App; many charts are stable-ID widgets inside its one window.
////   - ONE publish channel, a **named** Subject. Its name and subject are
////     created by `app/publish.gleam` (the channel's owner, R50) and handed
////     here to both the App and the publisher process.
////   - ONE publisher process: the ONLY holder of the plushie `Instance`.
////
//// WHY THE CHANNEL IS NAMED (measured): a `process.new_subject()` is OWNED by
//// the process that created it, and `process.receive` PANICS on a non-named
//// subject owned by another process (`gleam_erlang/process.gleam:226-238`),
//// while `process.send` to a named subject resolves `whereis(Name)` and fails
//// with *"Sending to unregistered name"* when nothing is registered. So the
//// publisher lives in its own process ⇒ the channel is named ⇒ **this module
//// registers the publisher's pid under that name**, before any bar can arrive.
//// try_plushie says the same about its own named mailbox
//// (`try_plushie/src/window_switch.gleam:44-48`: *"必须在 main 里建一次、传给三个
//// App 和 serve——名字是全局唯一的 Erlang atom，不能在各进程里重复 new_name"*).
////
//// WHY THE `Instance` LIVES IN THE PUBLISHER (R58): `plushie.start(app, opts)`
//// creates the `Instance` AFTER the App is built
//// (`plushie/plushie.gleam:191-279`), so the App's update cannot capture it at
//// wiring time. A Subject created BEFORE the App can. So the Subject is the
//// late-binding cell, and the one thing that needs the `Instance` — turning a
//// publish request into a targeted CustomWidget event — happens in the process
//// that holds it.
////
//// NOTHING ELSE IS HERE: no clock, no poll, no second Desk, no per-chart App, no
//// global atom table. The data arrives from the providers by their own native
//// means (R33), and the model is the one Desk.

import gleam/erlang/process
import gleam/io
import gleam/result
import glibe/api/interval.{IntervalOneMinute}
import glibe/api/sourcebar.{type SourceBar}
import glibe/api/symbol
import glibe/app/publish
import glibe/app/runtime
import glibe/app/wire
import glibe/desk
import glibe/id
import glibe/live_feed
import plushie

/// Start the ONE app, and the ONE publisher process that turns its publish
/// requests into targeted chart events.
///
/// The order matters and is the whole point:
///   1. the channel's NAME is created (once);
///   2. the App is built with the channel — it captures it;
///   3. the app starts, and only NOW does the `Instance` exist;
///   4. the publisher process is spawned, and **its pid is registered under the
///      name** — so a later `process.send` finds it (no "unregistered name");
///   5. only then may a bar arrive.
pub fn start() -> Result(plushie.Instance(desk.Desk), plushie.StartError) {
  let name = publish.name("glibe.chart_push")
  let channel = publish.channel(name)
  let app = runtime.app(channel)
  use instance <- result.try(plushie.start(app, plushie.default_start_opts()))
  let publisher =
    process.spawn(fn() {
      publish.serve(channel, fn(request) {
        plushie.dispatch_event(instance, wire.chart_push_event(request))
      })
    })
  let _ = process.register(publisher, name)
  Ok(instance)
}

/// Inject ONE standard SourceBar into the ONE App. R47 readers/writers: main
/// writes the identity triple + bar into a `SourceBarArrived`; `app/wire.gleam`
/// is the only writer of that wire kind and `app/message.gleam` reads it into
/// the closed Msg; `runtime.update` consumes it. The publish channel is NOT
/// carried here — it is captured by the App's update closure at wiring time
/// (R58), exactly as frozen glib bakes its `publish` closure at composition.
pub fn feed_sourcebar(
  instance: plushie.Instance(desk.Desk),
  broker_id: id.BrokerId,
  symbol_name: symbol.Symbol,
  bar_interval: interval.Interval,
  sourcebar: SourceBar,
) -> Nil {
  plushie.dispatch_event(
    instance,
    wire.sourcebar_event(wire.SourceBarArrived(
      broker_id: broker_id,
      symbol: symbol_name,
      interval: bar_interval,
      sourcebar: sourcebar,
    )),
  )
}

/// The executable entry point: start the ONE App, then drive it from the
/// LIVE Binance REST feed — real BTCUSDT one-minute klines, fetched from
/// `data-api.binance.vision` on startup and polled thereafter (R33: history
/// and live are ONE stream, both through the same `feed_sourcebar` wire
/// event). No synthetic data: a failed fetch is logged and retried, never
/// papered over with a generated bar. The renderer is a separate OS process,
/// so main blocks on `sleep_forever` to keep the BEAM node alive (same reason
/// try_plushie blocks). The feed runs in its own process; it holds the
/// `Instance` and `dispatch_event` is a plain process.send, safe from any
/// process.
pub fn main() -> Nil {
  case start() {
    Error(err) -> io.println_error(plushie.start_error_to_string(err))
    Ok(instance) -> {
      let broker = id.string_to_broker_id("binance")
      let symbol_name = symbol.string_to_symbol("BTCUSDT")
      let _feed =
        process.spawn(fn() {
          live_feed.run(instance, broker, symbol_name, IntervalOneMinute)
        })
      process.sleep_forever()
    }
  }
}
