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
        render(conn, "show.html")
      nil ->
        conn
          |> put_flash(:error, "game not found")
          |> redirect(to: Routes.session_path(conn, :index))
    end
  end

end
