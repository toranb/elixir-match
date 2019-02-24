defmodule MatchWeb.Router do
  use MatchWeb, :router

  import Plug.Conn, only: [put_session: 3, fetch_session: 2, halt: 1]

  def redirect_unauthorized(conn, _opts) do
    current_user = Map.get(conn.assigns, :current_user)
    if current_user != nil and current_user.username != nil do
      conn
    else
      conn
        |> put_session(:return_to, conn.request_path)
        |> redirect(to: MatchWeb.Router.Helpers.session_path(conn, :new))
        |> halt()
    end
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MatchWeb.Authenticator
  end

  pipeline :restricted do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MatchWeb.Authenticator
    plug :redirect_unauthorized
  end

  scope "/", MatchWeb do
    pipe_through :browser

    get "/", SessionController, :index
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/redirected", SessionController, :redirected
  end

  scope "/signup", MatchWeb do
    pipe_through :browser

    get "/", RegistrationController, :new
    post "/", RegistrationController, :create
  end

  scope "/logout", MatchWeb do
    pipe_through :browser

    get "/", LogoutController, :index
  end

  scope "/game", MatchWeb do
    pipe_through :restricted

    get "/", PageController, :new
    get "/:id", PageController, :show
  end

end
