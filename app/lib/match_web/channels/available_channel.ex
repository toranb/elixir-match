defmodule MatchWeb.AvailableChannel do
  use MatchWeb, :channel

  def join("available", _params, socket) do
    send(self(), {:after_join})
    {:ok, socket}
  end

  def handle_info({:after_join}, socket) do
    public = :ets.match(:games_table, {:"$1", :"$2", :public})
    games = Enum.map(public, fn([_, map]) -> map end)
    push(socket, "public_games", %{games: games})
    {:noreply, socket}
  end
end
