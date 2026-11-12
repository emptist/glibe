import gleam/dynamic.{type Dynamic}
import gleam/result

pub type IbkrError {
  ConnectionError(String)
  HttpError(Int, String)
}

@external(erlang, "Elixir.Glibe.Ibkr", "setup")
fn do_setup(port: String) -> Result(Nil, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "check_auth_status")
fn do_check_auth_status() -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "ping_server")
fn do_ping_server() -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "get_accounts")
fn do_get_accounts() -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "get_positions")
fn do_get_positions(account_id: String) -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "search_contracts")
fn do_search_contracts(symbol: String) -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "get_market_snapshot")
fn do_get_market_snapshot(conids: String, fields: String) -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "get_historical")
fn do_get_historical(conid: String, period: String, bar: String) -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "get_orders")
fn do_get_orders() -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "preview_order")
fn do_preview_order(account_id: String, orders: Dynamic) -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "place_order")
fn do_place_order(account_id: String, orders: Dynamic) -> Result(Dynamic, Dynamic)

@external(erlang, "Elixir.Glibe.Ibkr", "cancel_order")
fn do_cancel_order(account_id: String, order_id: String) -> Result(Dynamic, Dynamic)

pub fn setup(port: String) -> Result(Nil, IbkrError) {
  case do_setup(port) {
    Ok(_) -> Ok(Nil)
    Error(e) -> Error(ConnectionError(dynamic.classify(e)))
  }
}

pub fn check_auth_status() -> Result(Dynamic, IbkrError) {
  do_check_auth_status()
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn ping_server() -> Result(Dynamic, IbkrError) {
  do_ping_server()
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn get_accounts() -> Result(Dynamic, IbkrError) {
  do_get_accounts()
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn get_positions(account_id: String) -> Result(Dynamic, IbkrError) {
  do_get_positions(account_id)
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn search_contracts(symbol: String) -> Result(Dynamic, IbkrError) {
  do_search_contracts(symbol)
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn get_market_snapshot(conids: String, fields: String) -> Result(Dynamic, IbkrError) {
  do_get_market_snapshot(conids, fields)
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn get_historical(conid: String, period: String, bar: String) -> Result(Dynamic, IbkrError) {
  do_get_historical(conid, period, bar)
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn get_orders() -> Result(Dynamic, IbkrError) {
  do_get_orders()
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn preview_order(account_id: String, orders: Dynamic) -> Result(Dynamic, IbkrError) {
  do_preview_order(account_id, orders)
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn place_order(account_id: String, orders: Dynamic) -> Result(Dynamic, IbkrError) {
  do_place_order(account_id, orders)
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}

pub fn cancel_order(account_id: String, order_id: String) -> Result(Dynamic, IbkrError) {
  do_cancel_order(account_id, order_id)
  |> result.map_error(fn(e) { HttpError(0, dynamic.classify(e)) })
}