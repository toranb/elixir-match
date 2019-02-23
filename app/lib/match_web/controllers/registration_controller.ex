defmodule MatchWeb.RegistrationController do
  use MatchWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"username" => username, "invite" => invite, "password" => password}) do
    case Match.Logon.put(:logon, username, password, invite) do
      {:ok, {_id, _username, _icon}} ->
        path = Routes.session_path(conn, :new)
        conn
          |> put_flash(:info, "Account Created!")
          |> redirect(to: path)
      {:error, {_id, message}} ->
        path = Routes.registration_path(conn, :new)
        conn
          |> put_flash(:error, message)
          |> redirect(to: path)
    end
  end
end
