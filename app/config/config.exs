# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :match,
  ecto_repos: [Match.Repo]

# Configures the endpoint
config :match, MatchWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8pvi2WEzD2m1NBsUNjT2zRwH8lizv3DNEnMU4/yfhZ3OMYW1n/u5K4Oj0soopgoG",
  render_errors: [view: MatchWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Match.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "w0g8oe6B8diY4As+2BqhDsykh8GHVzFr"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# LiveView
config :phoenix, :template_engines, leex: Phoenix.LiveView.Engine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
