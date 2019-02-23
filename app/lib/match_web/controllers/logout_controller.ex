defmodule MatchWeb.LogoutController do
  use MatchWeb, :controller

  import Plug.Conn, only: [clear_session: 1, configure_session: 2]

  def index(conn, _params) do
    conn
      |> clear_session()
      |> configure_session(drop: true)
      |> redirect(to: Routes.session_path(conn, :index))
  end

end
