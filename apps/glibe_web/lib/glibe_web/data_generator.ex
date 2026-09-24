defmodule GlibeWeb.DataGenerator do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_bars do
    GenServer.call(__MODULE__, :get_bars)
  end

  def get_leaves do
    GenServer.call(__MODULE__, :get_leaves)
  end

  def get_branches do
    GenServer.call(__MODULE__, :get_branches)
  end

  @impl true
  def init(_) do
    # Generate initial sample data
    bars = generate_initial_bars(200)
    leaves = generate_leaves_from_bars(bars)
    branches = generate_branches_from_leaves(leaves)

    # Schedule periodic updates
    :timer.send_interval(2000, :tick)

    {:ok, %{bars: bars, leaves: leaves, branches: branches}}
  end

  @impl true
  def handle_call(:get_bars, _from, state) do
    {:reply, state.bars, state}
  end

  def handle_call(:get_leaves, _from, state) do
    {:reply, state.leaves, state}
  end

  def handle_call(:get_branches, _from, state) do
    {:reply, state.branches, state}
  end

  @impl true
  def handle_info(:tick, state) do
    new_bar = generate_next_bar(state.bars)
    new_leaves = generate_leaves_from_bars([new_bar | state.bars])
    new_branches = generate_branches_from_leaves(new_leaves)

    # Detect new leaf/branch
    new_leaf = detect_new_leaf(state.leaves, new_leaves)
    new_branch = detect_new_branch(state.branches, new_branches)

    new_state = %{state | bars: [new_bar | state.bars] |> Enum.take(500),
                      leaves: new_leaves |> Enum.take(100),
                      branches: new_branches |> Enum.take(50)}

    # Broadcast updates
    Phoenix.PubSub.broadcast(GlibeWeb.PubSub, "chart_updates", {:new_bar, new_bar})
    if new_leaf, do: Phoenix.PubSub.broadcast(GlibeWeb.PubSub, "chart_updates", {:new_leaf, new_leaf})
    if new_branch, do: Phoenix.PubSub.broadcast(GlibeWeb.PubSub, "chart_updates", {:new_branch, new_branch})

    {:noreply, new_state}
  end

  defp generate_initial_bars(count) do
    base_price = 50000.0
    base_time = (DateTime.utc_now() |> DateTime.to_unix()) - count * 3600

    Enum.reduce(1..count, {base_price, base_time, []}, fn _, {price, time, acc} ->
      change = :rand.uniform() * 200 - 100
      new_price = max(1000, price + change)
      new_time = time + 3600

      bar = %{
        time: new_time,
        open: price,
        high: max(price, new_price) + :rand.uniform() * 50,
        low: min(price, new_price) - :rand.uniform() * 50,
        close: new_price,
        volume: :rand.uniform(1000) + 100,
        sma_tiny: new_price + :rand.uniform() * 20 - 10,
        sma_medium: new_price + :rand.uniform() * 50 - 25,
        yin_leaf_cma: new_price + :rand.uniform() * 10 - 5,
        yang_leaf_cma: new_price + :rand.uniform() * 10 - 5
      }

      {new_price, new_time, [bar | acc]}
    end) |> elem(2) |> Enum.reverse()
  end

  defp generate_next_bar(bars) do
    last = List.first(bars)
    base_price = last.close
    change = :rand.uniform() * 200 - 100
    new_price = max(1000, base_price + change)
    new_time = last.time + 3600

    %{
      time: new_time,
      open: base_price,
      high: max(base_price, new_price) + :rand.uniform() * 50,
      low: min(base_price, new_price) - :rand.uniform() * 50,
      close: new_price,
      volume: :rand.uniform(1000) + 100,
      sma_tiny: new_price + :rand.uniform() * 20 - 10,
      sma_medium: new_price + :rand.uniform() * 50 - 25,
      yin_leaf_cma: new_price + :rand.uniform() * 10 - 5,
      yang_leaf_cma: new_price + :rand.uniform() * 10 - 5
    }
  end

  defp generate_leaves_from_bars(bars) do
    # Simplified: create leaf markers based on SMA crossovers
    Enum.with_index(Enum.reverse(bars))
    |> Enum.filter(fn {bar, i} -> i > 0 && rem(i, 15) == 0 end)
    |> Enum.map(fn {bar, i} ->
      %{
        type: if(rem(i, 30) == 0, do: "yin", else: "yang"),
        time: bar.time,
        price: bar.close,
        start_idx: i,
        end_idx: i + 14,
        corner_idx: i + 7,
        cma: bar.yin_leaf_cma
      }
    end)
  end

  defp generate_branches_from_leaves(leaves) do
    Enum.with_index(leaves)
    |> Enum.filter(fn {_, i} -> rem(i, 5) == 0 end)
    |> Enum.map(fn {leaf, i} ->
      %{
        type: leaf.type,
        time: leaf.time,
        price: leaf.price,
        start_idx: leaf.start_idx,
        end_idx: leaf.end_idx + 100,
        corner_idx: leaf.corner_idx,
        exit_idx: leaf.end_idx + 120
      }
    end)
  end

  defp detect_new_leaf(old, new), do: List.first(new) |> (fn l -> if l != List.first(old), do: l end).()
  defp detect_new_branch(old, new), do: List.first(new) |> (fn b -> if b != List.first(old), do: b end).()
end