//// Tests for the product web layer, written BEFORE the bodies in
//// `src/glibe/web/server.gleam`.
////
//// Plan: `.planning/phases/04-domain-cleanup/04-05-PLAN.md` (R24 A adoption).
//// Rulings: R19 (tests first), R22 / R23 (serve the real Desk), R21.
////
//// These tests pin three things: the closed route set, that both the JSON and
//// the HTML carry the REAL configured chain, and that a real Wisp request
//// produces the right status and body.

import gleam/http.{Get, Post}
import gleam/string
import gleeunit
import glibe/config
import glibe/web/server
import wisp
import wisp/simulate

pub fn main() -> Nil {
  gleeunit.main()
}

/// The routing table is a closed type, so every case is answerable without a
/// fake request. A POST to the page and an unknown path are both NotFound.
pub fn route_closed_set_test() {
  assert server.route(Get, []) == server.RouteDeskPage
    as "GET / is the desk page"
  assert server.route(Get, ["desk"]) == server.RouteDeskJson
    as "GET /desk is the JSON endpoint"
  assert server.route(Post, []) == server.RouteNotFound as "only GET is served"
  assert server.route(Get, ["anything", "else"]) == server.RouteNotFound
    as "an unknown path is 404"
}

/// The JSON is the configured Desk, not a demo fixture. Broker ids, the
/// Symbol names and the Interval codec's spellings must all be present.
pub fn desk_json_carries_the_real_chain_test() {
  let body = server.desk_to_json(config.default_config().desk)
  assert string.contains(body, "binance") as "broker id reaches JSON"
  assert string.contains(body, "BTCUSDT") as "the Symbol name reaches JSON"
  assert string.contains(body, "1h")
    as "the Interval codec spelling reaches JSON"
  assert string.contains(body, "instruments")
    as "the nested ownership level reaches JSON"
}

/// The HTML table is a view of the SAME value, readable with no browser script.
pub fn page_carries_the_real_chain_test() {
  let body = server.page(config.default_config().desk)
  assert string.contains(body, "BTCUSDT")
    as "the Symbol name reaches the HTML table"
  assert string.contains(body, "futu") as "the broker id reaches the HTML table"
  assert string.contains(body, "<table") as "the view is a table"
}

/// A real Wisp request exercises the handler, not just the pure helpers.
/// `wisp/simulate` supplies the canned connection, so status and body are
/// measured on the same path Mist will use in production.
pub fn handler_status_and_body_test() {
  let html = server.handle_request(simulate.request(Get, "/"))
  assert html.status == 200 as "GET / is 200"
  let assert wisp.Text(html_body) = html.body
    as "the HTML response carries a text body"
  assert string.contains(html_body, "BTCUSDT")
    as "the real Desk reaches the HTML response"

  let json_response = server.handle_request(simulate.request(Get, "/desk"))
  assert json_response.status == 200 as "GET /desk is 200"
  let assert wisp.Text(json_body) = json_response.body
    as "the JSON response carries a text body"
  assert string.contains(json_body, "SPY")
    as "the real Desk reaches the JSON response"

  let missing = server.handle_request(simulate.request(Get, "/nope"))
  assert missing.status == 404 as "an unknown path is 404"
}
