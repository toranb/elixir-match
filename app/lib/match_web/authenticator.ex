defmodule MatchWeb.Authenticator do
  import Plug.Conn, only: [get_session: 2, assign: 3]

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil ->
        conn
      id ->
        {username, icon} = Match.Logon.get(:logon, "#{id}")
        assign(conn, :current_user, %{id: id, username: username, icon: icon})
    end
  end
end
