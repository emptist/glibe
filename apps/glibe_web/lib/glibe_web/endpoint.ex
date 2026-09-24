defmodule GlibeWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :glibe_web

  socket "/live", Phoenix.LiveView.Socket

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session,
    store: :cookie,
    key: "_glibe_web_key",
    signing_salt: "CHANGE_ME_IN_PROD"

  plug GlibeWeb.Router
end