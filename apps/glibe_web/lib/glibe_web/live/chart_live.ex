defmodule GlibeWeb.ChartLive do
  use GlibeWeb, :live_view

  alias GlibeWeb.DataGenerator

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to data updates
    Phoenix.PubSub.subscribe(GlibeWeb.PubSub, "chart_updates")

    # Get initial data
    bars = DataGenerator.get_bars()
    leaves = DataGenerator.get_leaves()
    branches = DataGenerator.get_branches()

    {:ok,
     socket
     |> assign(:bars, bars)
     |> assign(:leaves, leaves)
     |> assign(:branches, branches)
     |> assign(:symbol, "BTCUSDT")
     |> assign(:interval, "1h")}
  end

  @impl true
  def handle_info({:new_bar, bar}, socket) do
    {:noreply, assign(socket, :bars, [bar | socket.assigns.bars] |> Enum.take(500))}
  end

  @impl true
  def handle_info({:new_leaf, leaf}, socket) do
    {:noreply, assign(socket, :leaves, [leaf | socket.assigns.leaves] |> Enum.take(100))}
  end

  @impl true
  def handle_info({:new_branch, branch}, socket) do
    {:noreply, assign(socket, :branches, [branch | socket.assigns.branches] |> Enum.take(50))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <div class="mb-4 flex justify-between items-center">
        <h1 class="text-2xl font-bold">glibe Stream Processing Visualization</h1>
        <div class="flex gap-4 text-sm text-gray-600">
          <span>Symbol: {@symbol}</span>
          <span>Interval: {@interval}</span>
          <span>Bars: {length(@bars)}</span>
          <span>Leaves: {length(@leaves)}</span>
          <span>Branches: {length(@branches)}</span>
        </div>
      </div>

      <div id="chart-container" class="w-full h-[600px] bg-white rounded-lg shadow" phx-hook="ChartHook"
           data-bars={@bars} data-leaves={@leaves} data-branches={@branches}></div>

      <div class="mt-4 grid grid-cols-2 gap-4">
        <div class="p-4 bg-gray-50 rounded">
          <h3 class="font-semibold mb-2">Latest Leaf</h3>
          <pre class="text-xs overflow-auto">{inspect(List.first(@leaves))}</pre>
        </div>
        <div class="p-4 bg-gray-50 rounded">
          <h3 class="font-semibold mb-2">Latest Branch</h3>
          <pre class="text-xs overflow-auto">{inspect(List.first(@branches))}</pre>
        </div>
      </div>
    </div>
    """
  end
end