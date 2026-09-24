defmodule GlibeWeb.DataController do
  use GlibeWeb, :controller

  alias GlibeWeb.DataGenerator

  def bars(conn, _params) do
    bars = DataGenerator.get_bars()
    json(conn, %{data: bars})
  end

  def leaves(conn, _params) do
    leaves = DataGenerator.get_leaves()
    json(conn, %{data: leaves})
  end

  def branches(conn, _params) do
    branches = DataGenerator.get_branches()
    json(conn, %{data: branches})
  end
end