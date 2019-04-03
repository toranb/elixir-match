defmodule MatchWeb.PageController do
  use MatchWeb, :controller

  def new(conn, %{"visibility" => visibility}) do
    scope = String.to_atom(visibility)
    game_name = Match.Generator.haiku()
    current_user = Map.get(conn.assigns, :current_user)
    case Match.GameSupervisor.start_game(game_name, current_user, scope) do
      {:ok, _pid} ->
        redirect(conn, to: Routes.page_path(conn, :show, game_name))
      {:error, {:already_started, _pid}} ->
        redirect(conn, to: Routes.page_path(conn, :show, game_name))
      {:error, _error} ->
        render(conn, "index.html")
    end
  end

  def show(conn, %{"id" => game_name}) do
    case Match.Session.session_pid(game_name) do
      pid when is_pid(pid) ->
        current_user = Map.get(conn.assigns, :current_user)
        case Match.Session.join(game_name, current_user.id) do
          {:ok, _} -> render_live_view(conn, game_name, current_user)
          {:error, _} -> redirect_user(conn)
        end
      nil -> redirect_user(conn)
    end
  end

  defp redirect_user(conn) do
    conn
      |> put_flash(:error, "game not found")
      |> redirect(to: Routes.session_path(conn, :index))
  end

  defp render_live_view(conn, game_name, current_user) do
    Phoenix.LiveView.Controller.live_render(conn, MatchWeb.GameLive, session: %{
      game_name: game_name,
      player_id: current_user.id,
      username: current_user.username,
      joined_id: nil,
      error: nil
    })
  end

end
