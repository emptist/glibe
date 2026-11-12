//// Demo A — Mist + Wisp endpoints; one settled bar from BEAM into an HTML view.
////
//// Plan item: `.planning/phases/04-domain-cleanup/04-04-PLAN.md`, demo A (R24).
//// Rulings: `docs/RULINGS.md` R15 (the engine stays Erlang), R17 (generated
//// `.mjs` preferred), R18 (`webclient/` is the only JS-target package), R19
//// (docs-first, tests-first), R24 (framework choice is a measured comparison).
////
//// This is measurement apparatus, not a product package. It moves ONE settled
//// bar from a BEAM value into an HTTP response; it does not wire in the
//// fractal engine. The browser half is the single generated `.mjs` shared by
//// demos A and C, measured separately in the plan's metrics.
////
//// Written documentation-first: module doc, types, documented signatures,
//// `todo` bodies, then the tests in `test/a_wisp_test.gleam`, then these bodies.

import gleam/erlang/process
import gleam/float
import gleam/http.{Get}
import gleam/int
import gleam/json
import mist
import wisp.{type Request, type Response}
import wisp/wisp_mist

/// One bar that has closed. The whole payload this demo moves.
pub type SettledBar {
  SettledBar(index: Int, close: Float)
}

/// The single bar every endpoint serves, so all three demos are comparable.
pub fn settled_bar() -> SettledBar {
  SettledBar(index: 42, close: 123.5)
}

/// The JSON payload served at `GET /bar`.
pub fn bar_to_json(bar: SettledBar) -> String {
  json.to_string(
    json.object([
      #("index", json.int(bar.index)),
      #("close", json.float(bar.close)),
    ]),
  )
}

/// The HTML document served at `GET /`. The bar is rendered server-side, so a
/// real HTTP request proves the value reached the view without a browser.
pub fn page(bar: SettledBar) -> String {
  "<!doctype html><html><head><meta charset=utf-8>"
  <> "<title>Demo A - Mist + Wisp</title></head><body>"
  <> "<h1>One settled bar</h1>"
  <> "<p>index: "
  <> int.to_string(bar.index)
  <> "</p>"
  <> "<p id=close>"
  <> float.to_string(bar.close)
  <> "</p>"
  <> "</body></html>"
}

/// Wisp request handler: `GET /` and `GET /bar`; every other request is 404.
pub fn handle_request(request: Request) -> Response {
  case request.method, wisp.path_segments(request) {
    Get, [] -> wisp.html_response(page(settled_bar()), 200)
    Get, ["bar"] -> wisp.json_response(bar_to_json(settled_bar()), 200)
    _, _ -> wisp.not_found()
  }
}

/// Start Mist with the Wisp adapter on port 8601.
pub fn main() -> Nil {
  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    handle_request
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8601)
    |> mist.start
  process.sleep_forever()
}
