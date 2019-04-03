defmodule MatchWeb.GameLive do
  use Phoenix.LiveView

  alias MatchWeb.Presence
  alias Phoenix.Socket.Broadcast

  def render(assigns) do
    ~L"""
      <style>
        html {
          background: rgb(147,209,245);
        }
      </style>

      <script type="text/javascript" src="<%= MatchWeb.Router.Helpers.static_path(MatchWeb.Endpoint, "/js/phoenix.js") %>"></script>
      <script type="text/javascript" src="<%= MatchWeb.Router.Helpers.static_path(MatchWeb.Endpoint, "/js/live.js") %>"></script>
      <script type="text/javascript">
        let liveSocket = new LiveSocket("/live");
        liveSocket.connect();
      </script>

      <div id="card-game" class="card-game">
        <div class="sticky-header">
          <header class="header header-game">
            <span class="label">active player: </span><span class="active-player"><%= player(assigns) %></span>
            <span class="label score">score: </span><span class="active-player-score"><%= score(assigns) %></span>
          </header>
        </div>

        <div class="game-container">
          <div class="game">
            <div class="cards">
              <%= for card <- rows(assigns) do %>
              <div class="card <%= clazz(card) %>" phx-click="flip" phx-value=<%= card.id %>>
                <div class="back"></div>
                <div class="front" style="background-image: url(<%= card.image %>)"></div>
              </div>
              <% end %>
            </div>
            <%= if splash(assigns) do %>
              <div class="splash">
                <div class="overlay"></div>
                <div class="content">
                  <%= cond do %>
                  <% winner(assigns) -> %>
                    <h1><%= winner(assigns) %> won!</h1>
                    <h2>Want more action?</h2>
                    <a class="icon-padding action-button animate margin-right green" href="javascript:void(0)" phx-click="prepare_restart">Play Again</a>
                    <a href="/" class="icon-padding action-button animate purple">Home</a>
                  <% joined(assigns) -> %>
                    <div class="joined">
                      <h1><%= joined(assigns) %> joined!</h1>
                    </div>
                    <a class="icon-padding action-button animate purple" href="javascript:void(0)" phx-click="continue">Continue</a>
                  <% error(assigns) -> %>
                    <div class="joined">
                      <h1><%= error(assigns) %></h1>
                    </div>
                    <a href="/" class="icon-padding action-button animate purple">Try Again</a>
                  <% true -> %>
                    <!-- nothing -->
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    """
  end

  def mount(session, socket) do
    if connected?(socket), do: subscribe(session)

    game_state(session, socket)
  end

  def handle_event("continue", _value, socket) do
    {:noreply, set_joined(socket, nil)}
  end

  def handle_event("prepare_restart", _value, socket) do
    %{:game_name => game_name} = socket.assigns
    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        game = Match.Session.prepare_restart(game_name)
        MatchWeb.Endpoint.broadcast_from!(self(), "game:#{game_name}", "summary", game)
        send(self(), {:restart, game_name})
        {:noreply, set_state(socket, game, socket.assigns)}
      nil ->
        {:noreply, set_error(socket)}
    end
  end

  def handle_event("flip", id, socket) do
    %{:game_name => game_name, :player_id => player_id} = socket.assigns
    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        game = Match.Session.flip(game_name, id, player_id)
        MatchWeb.Endpoint.broadcast_from!(self(), "game:#{game_name}", "summary", game)

        %Match.Game{animating: animating, winner: winner, scores: scores} = game
        if animating == true do
          send(self(), {:unflip, game_name})
        end
        if winner != nil do
          Match.Record.statistics(:record, scores, winner)
        end

        {:noreply, set_state(socket, game, socket.assigns)}
      nil ->
        {:noreply, set_error(socket)}
    end
  end

  def handle_info({:unflip, game_name}, socket) do
    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        game = Match.Session.unflip(game_name)

        MatchWeb.Endpoint.broadcast_from!(self(), "game:#{game_name}", "summary", game)

        {:noreply, set_state(socket, game, socket.assigns)}
      nil ->
        {:noreply, set_error(socket)}
    end
  end

  def handle_info({:restart, game_name}, socket) do
    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        game = Match.Session.restart(game_name)

        MatchWeb.Endpoint.broadcast_from!(self(), "game:#{game_name}", "summary", game)

        {:noreply, set_state(socket, game, socket.assigns)}
      nil ->
        {:noreply, set_error(socket)}
    end
  end

  def handle_info(%Broadcast{event: "summary", payload: game}, socket) do
    {:noreply, set_state(socket, game, socket.assigns)}
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply, set_users(socket)}
  end

  def handle_info(%Broadcast{event: "join", payload: %{:player_id => player_id}}, socket) do
    %{active_player_id: active_player_id} = socket.assigns
    joined_id =
      case player_id != active_player_id do
        true -> player_id
        false -> nil
      end
    {:noreply, set_joined(socket, joined_id)}
  end

  def terminate({:shutdown, :closed}, socket) do
    %{:game_name => game_name, :player_id => player_id} = socket.assigns
    if Match.Session.session_pid(game_name) do
      game = Match.Session.leave(game_name, player_id)
      MatchWeb.Endpoint.broadcast_from!(self(), "game:#{game_name}", "summary", game)
    end

    :ok
  end

  def terminate(:shutdown, _socket) do
    :ok
  end

  defp subscribe(session) do
    %{:game_name => game_name, :player_id => player_id, :username => username} = session
    Phoenix.PubSub.subscribe(Match.PubSub, "game:#{game_name}")
    Phoenix.PubSub.subscribe(Match.PubSub, "users:#{game_name}")
    Presence.track(self(), "users:#{game_name}", player_id, %{username: username})
    MatchWeb.Endpoint.broadcast_from!(self(), "game:#{game_name}", "join", %{player_id: player_id})
  end

  defp game_state(session, socket) do
    %{game_name: game_name} = session
    game = Match.Session.game_state(game_name)
    {:ok, set_state(socket, game, session)}
  end

  defp set_state(socket, game, session) do
    %Match.Game{cards: cards, winner: winner, active_player_id: active_player_id, scores: scores} = game
    %{game_name: game_name, player_id: player_id, username: username, joined_id: joined_id, error: error} = session
    assign(socket,
      game_name: game_name,
      player_id: player_id,
      username: username,
      joined_id: joined_id,
      error: error,
      cards: cards,
      winner: winner,
      active_player_id: active_player_id,
      scores: scores,
      users: Presence.list("users:#{game_name}")
    )
  end

  defp set_users(socket) do
    %{game_name: game_name} = socket.assigns
    assign(socket,
      users: Presence.list("users:#{game_name}")
    )
  end

  defp set_joined(socket, player_id) do
    assign(socket,
      joined_id: player_id
    )
  end

  defp set_error(socket) do
    assign(socket,
      error: "an error occurred"
    )
  end

  defp rows(%{cards: cards}) do
    Enum.map(cards, &Map.from_struct(&1))
  end

  defp score(%{active_player_id: active_player_id, scores: scores}) do
    Map.get(scores, active_player_id, 0)
  end

  defp player(%{active_player_id: active_player_id, users: users}) do
    player(users, active_player_id, %{metas: [%{username: active_player_id}]})
  end

  defp player(users, id, fallback) do
    %{:metas => metas} = Map.get(users, id, fallback)
    [%{:username => username}] = metas
    username
  end

  defp joined(%{users: users, joined_id: joined_id}) do
    case joined_id == nil do
      true -> nil
      false ->
        case Enum.count(users) == 2 do
          true -> player(users, joined_id, %{metas: [%{username: joined_id}]})
          false -> nil
        end
    end
  end

  defp winner(%{winner: winner, users: users}) do
    name = player(users, winner, %{metas: [%{username: winner}]})
    cond do
      name == winner and winner != nil -> String.slice(name, 0..6)
      name == nil -> nil
      true -> name
    end
  end

  defp error(%{error: error}) do
    error
  end

  defp splash(assigns) do
    cond do
      winner(assigns) ->
        true
      joined(assigns) ->
        true
      error(assigns) ->
        true
      true ->
        false
    end
  end

  defp clazz(%{flipped: flipped, paired: paired}) do
    case paired == true do
      true -> "found"
      false ->
        case flipped == true do
          true -> "flipped"
          false -> ""
        end
    end
  end

end
