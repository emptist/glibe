defmodule GlibeWeb.Router do
  use GlibeWeb, :router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GlibeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GlibeWeb do
    pipe_through :browser

    live "/", ChartLive, :index
    live "/chart", ChartLive, :index
  end

  # API endpoints for data
  scope "/api", GlibeWeb do
    pipe_through :api

    get "/bars", DataController, :bars
    get "/leaves", DataController, :leaves
    get "/branches", DataController, :branches
  end
end