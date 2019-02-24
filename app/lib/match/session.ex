defmodule Match.Session do
  use GenServer

  @timeout :timer.minutes(60)

  def start_link(name, user, scope) do
    GenServer.start_link(__MODULE__, {:ok, name, user, scope}, name: via(name))
  end

  defp via(name), do: Match.Registry.via(name)

  @impl GenServer
  def init({:ok, name, user, scope}) do
    state = Match.Game.new()
    send(self(), {:available, name, user, scope})
    {:ok, state, @timeout}
  end

  def session_pid(name) do
    name
      |> via()
      |> GenServer.whereis()
  end

  def join(name, player_id) do
    GenServer.call(via(name), {:join, player_id})
  end

  def leave(name, player_id) do
    GenServer.call(via(name), {:leave, player_id})
  end

  def flip(name, id, player_id) do
    GenServer.call(via(name), {:flip, id, player_id})
  end

  def unflip(name) do
    Process.sleep(1000)
    GenServer.call(via(name), {:unflip})
  end

  def restart(name) do
    GenServer.call(via(name), {:restart})
  end

  @impl GenServer
  def handle_call({:join, player_id}, _from, state) do
    case Match.Game.join(state, player_id) do
      {:ok, new_state} ->
        %Match.Game{players: players} = new_state
        if Enum.count(players) == 2 do
          remove_listing()
        end
        {:reply, {:ok, new_state}, new_state, @timeout}
      {:error, reason} ->
        {:reply, {:error, reason}, state, @timeout}
    end
  end

  @impl GenServer
  def handle_call({:leave, player_id}, _from, state) do
    new_state = Match.Game.leave(state, player_id)
    {:reply, new_state, new_state, @timeout}
  end

  @impl GenServer
  def handle_call({:flip, id, player_id}, _from, state) do
    new_state = Match.Game.flip(state, id, player_id)
    {:reply, new_state, new_state, @timeout}
  end

  @impl GenServer
  def handle_call({:unflip}, _from, state) do
    new_state = Match.Game.unflip(state)
    {:reply, new_state, new_state, @timeout}
  end

  @impl GenServer
  def handle_call({:restart}, _from, state) do
    new_state = Match.Game.restart(state)
    {:reply, new_state, new_state, @timeout}
  end

  @impl GenServer
  def handle_info({:available, name, user, scope}, state) do
    if scope == :public do
      created = DateTime.utc_now
      :ets.insert(:games_table, {name, %{"name" => name, "username" => user.username, "icon" => user.icon, "created" => created}, scope})
      Match.GameSupervisor.broadcast_public_games()
    end
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:timeout, session) do
    {:stop, {:shutdown, :timeout}, session}
  end

  @impl GenServer
  def terminate({:shutdown, :timeout}, _session) do
    remove_listing()
    :ok
  end

  @impl GenServer
  def terminate(_reason, _session) do
    :ok
  end

  def session_name do
    Registry.keys(Match.Registry, self()) |> List.first
  end

  defp remove_listing do
    :ets.delete(:games_table, session_name())
    Match.GameSupervisor.broadcast_public_games()
  end

end
