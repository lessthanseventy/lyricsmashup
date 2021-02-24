# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phxtwit,
  ecto_repos: [Phxtwit.Repo]

# Configures the endpoint
config :phxtwit, PhxtwitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fl+ZBX0c8Sb2Y535RI78YTVDi5psIfJrL6KmZAO1rFhTJyZJiKQGNuKuoF6K/la5",
  render_errors: [view: PhxtwitWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Phxtwit.PubSub,
  live_view: [signing_salt: "TATMt0JZrV/XnuUzIBksI75n63LMv5N8"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
