defmodule MatchWeb.GameChannel do
  use MatchWeb, :channel

  alias MatchWeb.Presence

  intercept ["presence_diff"]
  def handle_out("presence_diff", %{:leaves => leaves}, socket) do
    player_id = extract_leaves(leaves)
    case player_id == nil do
      true ->
        {:noreply, socket}
      false ->
        game_name = extract_game_name(socket)
        send(self(), {:after_leave, game_name, player_id})
        {:noreply, socket}
    end
  end

  def join("games:" <> game_name, _params, socket) do
    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        send(self(), {:after_join, game_name})
        {:ok, socket}
      nil ->
        {:error, %{reason: "Game does not exist"}}
    end
  end

  def handle_info({:after_leave, game_name, player_id}, socket) do
    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        %Match.Game{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores} = Match.Session.leave(game_name, player_id)
        cards = Enum.map(cards, &Map.from_struct(&1))
        broadcast!(socket, "game_summary", %{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores})
        broadcast!(socket, "presence_state", Presence.list(socket))

        {:noreply, socket}
      nil ->
        {:noreply, socket}
    end
  end

  def handle_info({:after_join, game_name}, socket) do
    %{:id => player_id, :username => username} = current_user(socket)

    case Match.Session.join(game_name, player_id) do
      {:ok, game} ->
        %Match.Game{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores} = game
        cards = Enum.map(cards, &Map.from_struct(&1))
        push(socket, "game_summary", %{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores})

        {:ok, _} =
          Presence.track(socket, player_id, %{
            id: player_id,
            username: username,
            online: DateTime.utc_now
          })

        broadcast!(socket, "presence_state", Presence.list(socket))
      {:error, reason} ->
        push(socket, "join_failed", %{reason: reason})
    end

    {:noreply, socket}
  end

  def handle_info({:unflip, game_name}, socket) do
    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        %Match.Game{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores} = Match.Session.unflip(game_name)
        cards = Enum.map(cards, &Map.from_struct(&1))

        broadcast!(socket, "game_summary", %{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores})

        {:noreply, socket}
      nil ->
        {:noreply, socket}
    end
  end

  def handle_in("flip_card", %{"id" => id}, socket) do
    "games:" <> game_name = socket.topic

    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        %{:id => player_id} = current_user(socket)
        %Match.Game{cards: cards, winner: winner, animating: animating, active_player_id: active_player_id, scores: scores} = Match.Session.flip(game_name, id, player_id)
        cards = Enum.map(cards, &Map.from_struct(&1))

        broadcast!(socket, "game_summary", %{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores})

        if animating == true do
          send(self(), {:unflip, game_name})
        end

        {:noreply, socket}
      nil ->
        {:reply, {:error, %{reason: "Game does not exist"}}, socket}
    end
  end

  def handle_in("restart", %{"winner" => _winner}, socket) do
    "games:" <> game_name = socket.topic

    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        %Match.Game{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores} = Match.Session.restart(game_name)
        cards = Enum.map(cards, &Map.from_struct(&1))

        broadcast!(socket, "game_summary", %{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores})

        {:noreply, socket}
      nil ->
        {:reply, {:error, %{reason: "Game does not exist"}}, socket}
    end
  end

  def terminate({:shutdown, :closed}, socket) do
    %{:id => player_id} = current_user(socket)
    game_name = extract_game_name(socket)

    if Match.Session.session_pid(game_name) do
      %Match.Game{winner: winner, players: players} = Match.Session.leave(game_name, player_id)

      if winner != nil and Enum.count(players) == 0 do
        Match.GameSupervisor.stop_game(game_name)
      end
    end

    :ok
  end

  defp current_user(socket) do
    socket.assigns.current_user
  end

  defp extract_game_name(socket) do
    %Phoenix.Socket{:topic => topic} = socket
    # ex: games:foobar-123
    String.slice(topic, 6..String.length(topic))
  end

  defp extract_leaves(leaves) do
    case Enum.count(leaves) > 0 do
      true ->
        [ {player_id, _} ] = Enum.take(leaves, 1) #limitation: 1 leave per diff
        player_id
      false -> nil
    end
  end

end
