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
////   - ONE publish channel, a **named** Subject, created here and handed to
////     both the App and the publisher process.
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

import gleam/erlang/process.{type Name, type Subject, named_subject, new_name}
import gleam/result
import glibe/app/publish
import glibe/app/runtime
import glibe/app/wire
import glibe/desk
import plushie

/// The publish channel's name. A NAME, not a subject: the publisher runs in its
/// own process, so the channel has to be reachable by name (see the module
/// doc). Created ONCE here — a second `new_name` would burn another atom.
pub type PublishName =
  Name(wire.ChartPushRequest)

/// The one publish channel's name.
pub fn publish_name() -> PublishName {
  new_name(prefix: "glibe.chart_push")
}

/// The publish channel, from its name.
pub fn publish_channel(name: PublishName) -> Subject(wire.ChartPushRequest) {
  named_subject(name)
}

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
  let name = publish_name()
  let channel = publish_channel(name)
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
