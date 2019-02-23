defmodule MatchWeb.PageControllerTest do
  use MatchWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Elixir Match"
  end
end
