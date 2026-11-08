//// Demo C — no framework: a bare Mist handler returning one settled bar.
////
//// Plan item: `.planning/phases/04-domain-cleanup/04-04-PLAN.md`, demo C (R24).
//// Rulings: `docs/RULINGS.md` R15, R17, R18, R19, R24.
////
//// This is the control in the comparison. Mist is an HTTP server, not a
//// framework: the handler is a plain `fn(Request) -> Response` with no Wisp
//// middleware, no routing helpers and no UI library. The browser half is the
//// same generated `.mjs` demo A uses.
////
//// Written documentation-first: module doc, types, documented signatures,
//// `todo` bodies, then the tests in `test/c_static_test.gleam`, then bodies.

import gleam/bytes_tree
import gleam/erlang/process
import gleam/float
import gleam/http.{Get}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/json
import mist

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
  <> "<title>Demo C - bare Mist</title></head><body>"
  <> "<h1>One settled bar</h1>"
  <> "<p>index: "
  <> int.to_string(bar.index)
  <> "</p>"
  <> "<p id=close>"
  <> float.to_string(bar.close)
  <> "</p>"
  <> "</body></html>"
}

/// Build one response with Mist's byte body. There is no response helper
/// library in this demo: `gleam/http/response` is the whole API used here.
fn reply(
  status: Int,
  content_type: String,
  body: String,
) -> Response(mist.ResponseData) {
  response.new(status)
  |> response.set_header("content-type", content_type)
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

/// Bare Mist handler: `GET /` and `GET /bar`; every other request is 404.
pub fn handle_request(
  request: Request(mist.Connection),
) -> Response(mist.ResponseData) {
  case request.method, request.path_segments(request) {
    Get, [] -> reply(200, "text/html; charset=utf-8", page(settled_bar()))
    Get, ["bar"] -> reply(200, "application/json", bar_to_json(settled_bar()))
    _, _ -> reply(404, "text/plain", "not found")
  }
}

/// Start Mist on port 8603.
pub fn main() -> Nil {
  let assert Ok(_) =
    handle_request
    |> mist.new
    |> mist.port(8603)
    |> mist.start
  process.sleep_forever()
}
