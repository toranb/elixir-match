defmodule MatchWeb.PageController do
  use MatchWeb, :controller

  def new(conn, %{"visibility" => visibility}) do
    render(conn, "new.html")
  end
end
