defmodule Match.GameSupervisor do
  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(name, user, scope) do
    child_spec = %{
      id: Match.Session,
      start: {Match.Session, :start_link, [name, user, scope]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def stop_game(name) do
    :ets.delete(:games_table, name)
    child_pid = Match.Session.session_pid(name)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
    broadcast_public_games()
  end

  def broadcast_public_games do
    public = :ets.match(:games_table, {:"$1", :"$2", :public})
    games = Enum.map(public, fn([_, map]) -> map end)
    MatchWeb.Endpoint.broadcast_from!(self(), "available", "public_games", %{games: games})
  end

end
