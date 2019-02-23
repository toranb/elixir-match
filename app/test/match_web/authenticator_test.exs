defmodule MatchWeb.AuthenticatorTest do
  use MatchWeb.ConnCase, async: false

  test "login will authenticate the user and redirect unauthenticated requests", %{conn: conn} do
    name = "toran"
    password = "abcd1234"
    login = %{username: name, password: password}
    data = %{username: name, invite: "elixir2019", password: password}

    request = get(conn, Routes.page_path(conn, :new, %{visibility: "public"}))
    assert String.match?(html_response(request, 302), ~r/.*You are being \<a href=\"\/login.*/)
    assert Map.get(request.assigns, :current_user) == nil

    created = post(request, Routes.registration_path(conn, :create, data))
    assert html_response(created, 302) =~ "redirected"
    assert Map.get(created.assigns, :current_user) == nil

    denied = get(created, Routes.page_path(conn, :new, %{visibility: "public"}))
    assert String.match?(html_response(denied, 302), ~r/.*You are being \<a href=\"\/login.*/)
    assert Map.get(denied.assigns, :current_user) == nil

    authenticated = post(denied, Routes.session_path(conn, :create, login))
    assert html_response(authenticated, 302) =~ "redirected"
    assert Map.get(authenticated.assigns, :current_user) == nil

    authorized = get(authenticated, Routes.page_path(conn, :new, %{visibility: "public"}))
    # assert String.match?(html_response(authorized, 302), ~r/.*You are being \<a href=\"\/game\/.*/)
    assert Map.get(authorized.assigns, :current_user) != nil
    %{id: id, username: username, icon: icon} = Map.get(authorized.assigns, :current_user)
    assert id == "A4E3400CF711E76BBD86C57CA"
    assert username == name
    assert icon != ""

    logout = get(authorized, Routes.logout_path(conn, :index))
    assert html_response(logout, 302) =~ "redirected"
    assert Map.get(logout.assigns, :current_user) != nil

    again = get(conn, Routes.page_path(logout, :new, %{visibility: "public"}))
    assert String.match?(html_response(again, 302), ~r/.*You are being \<a href=\"\/login.*/)
    assert Map.get(again.assigns, :current_user) == nil
  end
end
