defmodule Match.Record do
  use GenServer

  alias Match.Statistic
  alias Match.Statistics

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: via(:record))
  end

  defp via(name), do: Match.Registry.via(name)

  @impl GenServer
  def init(:ok) do
    statistics = Statistics.all()
    state = Statistic.transform_previous(statistics)
    {:ok, state, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, state) do
    {:noreply, state}
  end

  def statistics(name, scores, winner) do
    GenServer.cast(via(name), {:statistics, scores, winner})
  end

  @impl GenServer
  def handle_cast({:statistics, scores, winner}, state) do
    new_state = Statistic.insert_statistics(scores, winner, state)
    {:noreply, new_state}
  end
end
