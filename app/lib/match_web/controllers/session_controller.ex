defmodule MatchWeb.SessionController do
  use MatchWeb, :controller

  import Plug.Conn, only: [put_session: 3, get_session: 2]

  def new(conn, _) do
    render(conn, "new.html")
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def redirected(conn, %{"reason" => reason}) do
    auth_token = get_auth_token(conn)
    conn
      |> put_flash(:error, reason)
      |> render("index.html", %{auth_token: auth_token})
  end

  def create(conn, %{"username" => username, "password" => password}) do
    case Match.Logon.get_by_username_and_password(:logon, username, password) do
      nil ->
        conn
          |> put_flash(:error, "incorrect username or password")
          |> render("new.html")
      id ->
        conn
          |> put_session(:user_id, id)
          |> redirect_back_to_game
    end
  end

  defp redirect_back_to_game(conn) do
    path = get_session(conn, :return_to) || Routes.session_path(conn, :index)

    conn
      |> put_session(:return_to, nil)
      |> redirect(to: path)
  end

  defp get_auth_token(conn) do
    case Map.get(conn.assigns, :current_user) do
      nil -> nil
      user -> Phoenix.Token.sign(conn, "player_auth", user)
    end
  end
end
