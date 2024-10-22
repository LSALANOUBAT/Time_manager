defmodule TimeManagerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :time_manager

  @session_options [
    store: :cookie,
    key: "_time_manager_key",
    signing_salt: "qE8XoDj9",
    same_site: "Lax"
  ]

  # Serve at "/" the static files from "priv/static" directory.
  plug Plug.Static,
    at: "/",
    from: :time_manager,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled if needed
  if code_reloading? do
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :time_manager
  end

  # CORS configuration
  plug CORSPlug,
    origin: ["*"],  # Allow all origins, adjust as necessary
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    headers: ["Authorization", "Content-Type"],
    expose: ["Authorization"],
    max_age: 86400,  # Cache the CORS response for 24 hours
    credentials: true

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug TimeManagerWeb.Router
end