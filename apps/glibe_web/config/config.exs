import Config

config :glibe_web, GlibeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CHANGE_ME_IN_PROD",
  render_errors: [view: GlibeWeb.ErrorView],
  pubsub_server: GlibeWeb.PubSub,
  live_view: [signing_salt: "CHANGE_ME_IN_PROD"],
  telemetry: [router: true, events: [:phoenix_endpoint, :phoenix_live_view]]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{config_env()}.exs"