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
    only: ~w()

  # Code reloading can be explicitly enabled if needed
  if code_reloading? do
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :time_manager
  end

  plug CORSPlug, 
    origin: ["http://localhost:8080", "https://vue.orbesle.fr", "http://localhost:4000"],
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    headers: ["Authorization", "Content-Type"],
    expose: ["Authorization"]

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
