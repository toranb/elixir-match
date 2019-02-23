use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :match, MatchWeb.Endpoint,
  secret_key_base: "TY34345435ADFADfadfasd6S8Aa2dsfadddd5324kiaSdfwe98de54Aidalhlhzl"

# Configure your database
config :match, Match.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: System.get_env("POSTGRES_DB"),
  hostname: System.get_env("POSTGRES_HOST"),
  pool_size: 15
