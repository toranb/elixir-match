defmodule Match.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Match.Repo,
      MatchWeb.Endpoint,
      MatchWeb.Presence,
      {Registry, keys: :unique, name: Match.Registry},
      Match.GameSupervisor,
      Match.Logon
    ]

    :ets.new(:games_table, [:public, :named_table])

    opts = [strategy: :one_for_one, name: Match.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    MatchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
