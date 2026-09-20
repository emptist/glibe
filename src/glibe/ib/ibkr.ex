defmodule Glibe.Ibkr do
  @moduledoc """
  Elixir wrapper for IB Client Portal API using ibkr_api library.
  """

  alias IbkrApi.ClientPortal.Auth
  alias IbkrApi.ClientPortal.Portfolio
  alias IbkrApi.ClientPortal.MarketData
  alias IbkrApi.ClientPortal.Contract
  alias IbkrApi.ClientPortal.Order

  def setup(port \\ "5001") do
    Application.put_env(:ibkr_api, :port, port)
    Application.put_env(:ibkr_api, :host, "https://localhost")
    :ok = Application.ensure_all_started(:ibkr_api)
    :ok
  end

  def check_auth_status do
    Auth.check_auth_status()
    |> convert_response()
  end

  def ping_server do
    Auth.ping_server()
    |> convert_response()
  end

  def get_accounts do
    Portfolio.list_brokerage_accounts()
    |> convert_response()
  end

  def get_positions(account_id) do
    Portfolio.portfolio_positions(account_id)
    |> convert_response()
  end

  def search_contracts(symbol) do
    Contract.search_contracts(symbol)
    |> convert_response()
  end

  def get_market_snapshot(conids, fields \\ "31,55,84,86") do
    MarketData.live_market_data_snapshots(conids, fields: String.split(fields, ","))
    |> convert_response()
  end

  def get_historical(conid, period, bar) do
    MarketData.get_historical_data(conid, period, bar)
    |> convert_response()
  end

  def get_orders do
    Order.get_live_orders()
    |> convert_response()
  end

  def preview_order(account_id, orders) do
    Order.preview_order(account_id, orders)
    |> convert_response()
  end

  def place_order(account_id, orders) do
    Order.place_orders(account_id, orders)
    |> convert_response()
  end

  def cancel_order(account_id, order_id) do
    Order.cancel_order(account_id, order_id)
    |> convert_response()
  end

  defp convert_response({:ok, data}) do
    {:ok, to_map(data)}
  end

  defp convert_response({:error, reason}) do
    {:error, to_string(reason)}
  end

  defp to_map(data) when is_map(data), do: data
  defp to_map(data) when is_struct(data) do
    Map.from_struct(data)
  end
  defp to_map(list) when is_list(list) do
    Enum.map(list, &to_map/1)
  end
  defp to_map(other), do: other
end