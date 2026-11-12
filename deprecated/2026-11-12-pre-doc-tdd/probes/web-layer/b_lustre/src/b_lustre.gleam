//// Demo B — Mist + Wisp + a Lustre server component; one settled bar from the
//// BEAM runtime into a DOM patch, not just an HTML string.
////
//// Plan item: `.planning/phases/04-domain-cleanup/04-04-PLAN.md`, demo B (R24).
//// Rulings: `docs/RULINGS.md` R15, R17, R18, R19, R24. `server_component.script()`
//// inlines the client runtime shipped inside the `lustre` Hex package; that is
//// NOT hand-written project JavaScript.
////
//// Unlike demos A and C, the bar also travels over `/poll`: Lustre's server
//// runtime owns the model and sends a `Mount` DOM patch to any registered
//// client, which the polling transport fetches as JSON. A real `curl /poll`
//// therefore proves the bar reached the view's data path, not just the page.
////
//// Written documentation-first: module doc, types, documented signatures,
//// `todo` bodies, then the tests in `test/b_lustre_test.gleam`, then bodies.

import gleam/erlang/process
import gleam/float
import gleam/http.{Get}
import gleam/int
import gleam/json
import lustre
import lustre/element
import lustre/element/html
import lustre/server_component
import mist
import wisp.{type Request, type Response}
import wisp/wisp_mist

/// One bar that has closed. The whole payload this demo moves.
pub type SettledBar {
  SettledBar(index: Int, close: Float)
}

/// The server component has no interactive events yet. A closed set, not a
/// catch-all: adding an event makes every `case` in this module a compile error.
pub type Message {
  NoEvent
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

/// The Lustre view of one settled bar, used by the server component runtime.
pub fn view(bar: SettledBar) -> element.Element(Message) {
  html.p([], [
    html.text("settled bar #" <> int.to_string(bar.index) <> ": "),
    html.text(float.to_string(bar.close)),
  ])
}

/// The Lustre application whose model IS the settled bar.
pub fn app() -> lustre.App(SettledBar, SettledBar, Message) {
  lustre.simple(
    init: fn(bar) { bar },
    update: fn(model, _message) { model },
    view: view,
  )
}

/// The HTML document served at `GET /`: typed Lustre HTML, the server
/// component element and the package-shipped client runtime.
pub fn page(bar: SettledBar) -> String {
  html.html([], [
    html.head([], [html.title([], "Demo B - Lustre")]),
    html.body([], [
      html.h1([], [html.text("One settled bar")]),
      html.p([], [html.text(float.to_string(bar.close))]),
      server_component.element(
        [
          server_component.route("/poll"),
          server_component.method(server_component.Polling),
        ],
        [],
      ),
      server_component.script(),
    ]),
  ])
  |> element.to_document_string
}

/// Register a client with the Lustre server runtime and return the `Mount` DOM
/// patch it sends back, JSON-encoded for the polling transport.
fn poll(runtime: lustre.Runtime(Message)) -> Response {
  let client = process.new_subject()
  let runtime_subject = server_component.subject(runtime)
  process.send(runtime_subject, server_component.register_subject(client))
  let payload = case process.receive(client, 1000) {
    Ok(message) ->
      json.to_string(server_component.client_message_to_json(message))
    Error(Nil) -> "{}"
  }
  process.send(runtime_subject, server_component.deregister_subject(client))
  wisp.json_response(payload, 200)
}

/// Wisp request handler: `GET /`, `GET /bar` and `GET /poll`.
pub fn handle_request(
  runtime: lustre.Runtime(Message),
) -> fn(Request) -> Response {
  fn(request: Request) {
    case request.method, wisp.path_segments(request) {
      Get, [] -> wisp.html_response(page(settled_bar()), 200)
      Get, ["bar"] -> wisp.json_response(bar_to_json(settled_bar()), 200)
      Get, ["poll"] -> poll(runtime)
      _, _ -> wisp.not_found()
    }
  }
}

/// Start the Lustre runtime, then Mist with the Wisp adapter on port 8602.
pub fn main() -> Nil {
  let assert Ok(runtime) =
    lustre.start_server_component(app(), with: settled_bar())
  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    handle_request(runtime)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8602)
    |> mist.start
  process.sleep_forever()
}
