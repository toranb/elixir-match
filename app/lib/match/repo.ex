defmodule Match.Repo do
  use Ecto.Repo,
    otp_app: :match,
    adapter: Ecto.Adapters.Postgres
end
