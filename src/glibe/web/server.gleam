//// The product web layer: a thin BEAM view of the real Desk.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-05-PLAN.md` (adopt R24 A).
//// Rulings: `docs/RULINGS.md` R15 (root is Erlang-target), R17 (the view is
//// the generated `.mjs`, never hand-written JS), R18 (`webclient/` is the
//// only JS-target package), R19 (docs-first / TDD), R20 (`Desk` is the model,
//// the dashboard is a VIEW), R21 (constructors named in full), R22 (a name is
//// not the thing named), R23 (no stand-in entities), R24 (this framework was
//// chosen by measured demos, not by the owner).
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
  todo as "04-05: classify GET / and GET /desk exhaustively"
}

/// The whole ownership chain as JSON, for the generated browser client.
/// Keys become display strings only here, at the text boundary — every value
/// upstream is a `BrokerId`, a `Symbol` or an `Interval`.
pub fn desk_to_json(desk: Desk) -> String {
  todo as "04-05: encode Desk > Broker > Instrument > Interval"
}

/// One broker's JSON object.
fn broker_to_json(id: desk.BrokerId, broker: desk.Broker) -> json.Json {
  todo as "04-05: encode one broker and its instruments"
}

/// One instrument's JSON object: its `Symbol` name and its interval keys.
fn instrument_to_json(
  name: symbol.Symbol,
  instrument: desk.Instrument,
) -> json.Json {
  todo as "04-05: encode one instrument and its intervals"
}

/// A server-rendered table of the same chain, so a human can see the
/// ownership structure without running any browser script.
pub fn page(desk: Desk) -> String {
  todo as "04-05: render the Desk as an HTML table"
}

/// One broker's rows: one row per instrument/interval pair.
fn broker_rows(id: desk.BrokerId, broker: desk.Broker) -> String {
  todo as "04-05: render one broker's rows"
}

/// The Wisp request handler. It serves the configured `Desk`; it does not
/// manufacture a view model of its own.
pub fn handle_request(request: Request) -> Response {
  todo as "04-05: dispatch the Route with Wisp responses"
}

/// Start Mist with the Wisp adapter on port 8610. Run with
/// `gleam run -m glibe/web/server` so the root library keeps no global
/// `main` slot for Stage F's replay CLI.
pub fn main() -> Nil {
  todo as "04-05: start Mist with the Wisp adapter"
}
