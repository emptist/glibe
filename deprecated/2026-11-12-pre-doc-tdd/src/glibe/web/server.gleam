//// The product web layer: a thin BEAM view of the real Desk.
////
//// Plans: `.planning/phases/04-domain-cleanup/04-05-PLAN.md` (adopt R24 A),
//// `.planning/phases/04-domain-cleanup/04-07-PLAN.md` (R30 display boundary),
//// `.planning/phases/04-domain-cleanup/04-10-PLAN.md` (R35 in code docs).
//// Rulings: `docs/RULINGS.md` R15 (root is Erlang-target), R17 (the view is
//// the generated `.mjs`, never hand-written JS), R18 (`webclient/` is the
//// only JS-target package), R19 (docs-first / TDD), R20 (`Desk` is the model,
//// the dashboard is a VIEW), R21 (constructors named in full), R22 (a name is
//// not the thing named), R23 (no stand-in entities), R24 (this framework was
//// chosen by measured demos, not by the owner), R33, R35, R36, R37.
////
//// This module serves the REAL model from `config.default_config().desk` —
//// `Desk ▸ Broker ▸ Instrument ▸ Interval ▸ Timeframe` — not the demo's
//// `SettledBar(42, 123.5)`. `/` is a server-rendered table for human eyes;
//// `/desk` is the same chain as JSON for the generated `.mjs` client. No chart,
//// no invented view model, no composite `"BTCUSDT_H1"` string: the identity
//// of a broker, an instrument and an interval is a key, never a field.
////
//// Written documentation-first: `////` module doc naming the plan, the closed
//// `Route` set, `///` on every function, `todo as "…"` bodies, then the tests
//// in `test/web_server_test.gleam`, and only then the bodies.
////
//// **Time shown to a human is local time (R30, 2026-11-09).** Owner words:
//// *"在web 界面，应该采用本地时间显示日期时间，方便分析操作，因此必然涉及到时间转换和夏令时处理，你可以在相应的模块加上文档，方便实现"*
//// Plan `.planning/phases/04-domain-cleanup/04-07-PLAN.md` owns the
//// implementation. This module documents the display boundary only: it
//// currently serves no bar timestamps at all — `/` shows the `Desk` chain and
//// `/desk` returns its keys as JSON. This is the specification a future
//// time-bearing view must satisfy, not a description of a built feature.
////
//// A standard bar's `timestamp` is `gleam_time.Timestamp`, an absolute
//// instant in unix time (R27). Rendering it is a projection at the output
//// edge: nothing upstream changes, `export/csv.gleam` keeps UTC RFC3339 for
//// machine comparison, and `interval.bucket_ends` stays a UTC-aligned unix
//// grid. No date `String`, wall-clock reading or local offset goes back into
//// `SourceBar` / `DataBar` to make a column printable.
////
//// **R30 is the OUTPUT side; R29 is the INPUT side.** R29 turns an exchange's
//// local session time into an instant in the provider / market adapter: US
//// 09:30 open is HKT 22:30 in winter (EST) and 21:30 in summer (EDT), so one
//// market clock maps to different unix times. R30 turns that one instant into
//// the analyst's local wall clock. Both need an IANA time-zone rule, neither
//// may use a fixed numeric offset or a hand-written DST table, and they must
//// not be merged into one conversion.
////
//// A display zone is an IANA name (`Asia/Hong_Kong`, `America/New_York`),
//// never a number. For the BEAM side R29 verified `tzif` 2.0.0 (+ `zones` or
//// `tzif_loader`), whose `tzcalendar.to_time_and_zone` accepts a
//// `gleam_time.Timestamp`; if rendering lands in the generated `.mjs` view
//// (R17 / `webclient/`), use the browser runtime's IANA support. Which side
//// renders, and where the viewer's zone comes from, are settled when a real
//// consumer exists (R26) — no settings type is invented here. Market local
//// time shown beside viewer local time is another projection of the SAME
//// `Timestamp`, labelled with its own zone; never a second bar or field.
////
//// This round adds documentation only: no conversion code, no `tzif`
//// dependency, no new type, no test. Tests and bodies belong to plan 04-07
//// under R19, starting with both DST sides of one instant.
////
//// **R35 (owner 2026-11-10): why a view updates, and the simplicity check.**
//// The resemblance to SwiftUI is ONLY in the definition and implementation of
//// the View: pure functional + value types. Swift made the rest complicated —
//// a view model with a `class`, a model free to be a `struct` / `class` /
//// `actor`, data races and a large industry of remedies — none of which can
//// occur in Gleam. A SwiftUI view updates because it is a projection of a
//// value; understanding that is understanding *"只有type定义好了，函数定义
//// 对了，系统本身就是活的"* (R33). `page` and `desk_to_json` are pure
//// projections of `config.default_config().desk`: when the value is
//// recomputed, the view is recomputed. There is no subscription, actor or
//// runtime in this module that "makes the view live".
////
//// Concurrency topics are met when they actually arise: read the official
//// docs, build a few competing demos, compare, and decide — that is TDD
//// (R19 + R24's demo method), not a framework built in advance. *"总体上，
//// 很简单。简单是正确的验证码。如果复杂，基本上可以判断type 函数和模块定义
//// 有错误。"* If a change here starts needing actors, a scheduler, a config
//// table, a parser or a guard script, go back and fix the type, function and
//// module definitions. R36 / R37: this view reads the chain as it is —
//// `Desk` holds `Broker` directly (no `Market` gap), and broker, symbol and
//// interval are the holders' KEYS, becoming display strings only here.
////
//// Plan 04-10 adds documentation to this module only. Its tests and body
//// live in `desk.gleam` / `test/level_judgement_test.gleam`; the chain
//// 概念 → type definition → unit test → implementation is recorded there.

import gleam/dict
import gleam/erlang/process
import gleam/http.{type Method, Get}
import gleam/json
import gleam/list
import gleam/string
import glibe/api/interval
import glibe/api/symbol
import glibe/config
import glibe/desk.{type Desk}
import mist
import wisp.{type Request, type Response}
import wisp/wisp_mist

/// The closed set of endpoints. A path `String` is never allowed to stand in
/// for a route: pattern matching here is exhaustive, so adding an endpoint
/// makes the compiler name every place that must answer for it.
pub type Route {
  RouteDeskPage
  RouteDeskJson
  RouteNotFound
}

/// Classify one request. Pure, so the whole routing table is a unit test and
/// no fake `Request` has to be built to check it.
pub fn route(method: Method, segments: List(String)) -> Route {
  case method, segments {
    Get, [] -> RouteDeskPage
    Get, ["desk"] -> RouteDeskJson
    _, _ -> RouteNotFound
  }
}

/// The whole ownership chain as JSON, for the generated browser client.
/// Keys become display strings only here, at the text boundary — every value
/// upstream is a `BrokerId`, a `Symbol` or an `Interval`.
pub fn desk_to_json(desk: Desk) -> String {
  let brokers =
    dict.to_list(desk.brokers)
    |> list.map(fn(pair) { broker_to_json(pair.0, pair.1) })
  json.to_string(
    json.object([
      #("brokers", json.preprocessed_array(brokers)),
    ]),
  )
}

/// One broker's JSON object.
fn broker_to_json(id: desk.BrokerId, broker: desk.Broker) -> json.Json {
  let instruments =
    dict.to_list(broker.instruments)
    |> list.map(fn(pair) { instrument_to_json(pair.0, pair.1) })
  json.object([
    #("id", json.string(desk.broker_id_to_string(id))),
    #("instruments", json.preprocessed_array(instruments)),
  ])
}

/// One instrument's JSON object: its `Symbol` name and its interval keys.
fn instrument_to_json(
  name: symbol.Symbol,
  instrument: desk.Instrument,
) -> json.Json {
  let intervals =
    dict.to_list(instrument.timeframes)
    |> list.map(fn(pair) { json.string(interval.to_string(pair.0)) })
  json.object([
    #("symbol", json.string(symbol.to_string(name))),
    #("intervals", json.preprocessed_array(intervals)),
  ])
}

/// A server-rendered table of the same chain, so a human can see the
/// ownership structure without running any browser script.
pub fn page(desk: Desk) -> String {
  let rows =
    dict.to_list(desk.brokers)
    |> list.map(fn(pair) { broker_rows(pair.0, pair.1) })
    |> string.join(with: "")
  "<!doctype html><html><head><meta charset=utf-8>"
  <> "<title>glibe desk</title></head><body>"
  <> "<h1>Desk</h1>"
  <> "<table><thead><tr><th>broker</th><th>symbol</th><th>intervals</th>"
  <> "</tr></thead><tbody>"
  <> rows
  <> "</tbody></table></body></html>"
}

/// One broker's rows: one row per instrument/interval pair.
fn broker_rows(id: desk.BrokerId, broker: desk.Broker) -> String {
  let broker_name = desk.broker_id_to_string(id)
  dict.to_list(broker.instruments)
  |> list.map(fn(pair) {
    let #(name, instrument) = pair
    let intervals =
      dict.to_list(instrument.timeframes)
      |> list.map(fn(tf) { interval.to_string(tf.0) })
      |> string.join(with: ", ")
    "<tr><td>"
    <> broker_name
    <> "</td><td>"
    <> symbol.to_string(name)
    <> "</td><td>"
    <> intervals
    <> "</td></tr>"
  })
  |> string.join(with: "")
}

/// The Wisp request handler. It serves the configured `Desk`; it does not
/// manufacture a view model of its own.
pub fn handle_request(request: Request) -> Response {
  let cfg = config.default_config()
  case route(request.method, wisp.path_segments(request)) {
    RouteDeskPage -> wisp.html_response(page(cfg.desk), 200)
    RouteDeskJson -> wisp.json_response(desk_to_json(cfg.desk), 200)
    RouteNotFound -> wisp.not_found()
  }
}

/// Start Mist with the Wisp adapter on port 8610. Run with
/// `gleam run -m glibe/web/server` so the root library keeps no global
/// `main` slot. A data source hands one standard `SourceBar` at a time to
/// `engine.sourcebar_gate`; the stream has no rewind (R38).
pub fn main() -> Nil {
  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    handle_request
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8610)
    |> mist.start
  process.sleep_forever()
}
