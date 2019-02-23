defmodule MatchWeb.SessionControllerTest do
  use MatchWeb.ConnCase, async: false

  import Plug.Conn, only: [get_session: 2]

  @name "toran"
  @password "abcd1234"
  @login %{username: @name, password: @password}
  @data %{username: @name, invite: "elixir2019", password: @password}
  @login_form "<form accept-charset=\"UTF-8\" action=\"/login"

  test "successful login will put user id into session and redirect", %{conn: conn} do
    result = post(conn, Routes.registration_path(conn, :create, @data))
    assert html_response(result, 302) =~ "redirected"
    assert get_flash(result, :error) == nil
    assert get_flash(result, :info) == "Account Created!"
    for {"location", value} <- result.resp_headers, do: assert value == "/login"

    session_id = get_session(result, :user_id)
    assert session_id == nil

    login = post(conn, Routes.session_path(conn, :create, @login))
    assert html_response(login, 302) =~ "redirected"
    assert get_flash(login, :error) == nil
    assert get_flash(login, :info) == nil
    for {"location", value} <- login.resp_headers, do: assert value == "/"

    session_id = get_session(login, :user_id)
    assert session_id == "A4E3400CF711E76BBD86C57CA"
  end

  test "failed login redirects to login form and does not put user id into session", %{conn: conn} do
    credentials = %{username: "brandon", password: @password}

    login = post(conn, Routes.session_path(conn, :create, credentials))
    assert html_response(login, 200) =~ @login_form
    assert get_flash(login, :error) == "incorrect username or password"
    assert get_flash(login, :info) == nil
    session_id = get_session(login, :user_id)
    assert session_id == nil
  end

  test "new route will return the login form", %{conn: conn} do
    login = get(conn, Routes.session_path(conn, :new))
    assert html_response(login, 200) =~ @login_form
  end
end
