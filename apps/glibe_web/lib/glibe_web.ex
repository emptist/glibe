defmodule GlibeWeb do
  @moduledoc """
  The main web module for GlibeWeb.
  """

  use Phoenix.Component

  import Phoenix.HTML
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView.Helpers

  @doc """
  When used with `:router`, it sets up the router for the application.
  """
  defmacro __using__(:router) do
    quote do
      use Phoenix.Router
      import GlibeWeb
    end
  end

  @doc """
  When used with `:controller`, it sets up the controller for the application.
  """
  defmacro __using__(:controller) do
    quote do
      use Phoenix.Controller
      import GlibeWeb
    end
  end

  @doc """
  When used with `:live_view`, it sets up the live view for the application.
  """
  defmacro __using__(:live_view) do
    quote do
      use Phoenix.LiveView
      import GlibeWeb
      unquote(html_helpers())
    end
  end

  @doc """
  When used with `:view`, it sets up the view for the application.
  """
  defmacro __using__(:view) do
    quote do
      use Phoenix.View
      import GlibeWeb
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      import Phoenix.HTML
      import Phoenix.LiveView.Helpers
    end
  end
end