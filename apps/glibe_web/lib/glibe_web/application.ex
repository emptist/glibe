defmodule GlibeWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: GlibeWeb.PubSub},
      GlibeWeb.Endpoint,
      # Start a sample data generator for testing
      {GlibeWeb.DataGenerator, []}
    ]

    opts = [strategy: :one_for_one, name: GlibeWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GlibeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end