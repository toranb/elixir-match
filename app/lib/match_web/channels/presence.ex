defmodule MatchWeb.Presence do
  use Phoenix.Presence,
    otp_app: :match,
    pubsub_server: Match.PubSub
end
