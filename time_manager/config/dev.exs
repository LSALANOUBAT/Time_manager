import Config

# Configure your database
config :time_manager, TimeManager.Repo,
  url: System.get_env("DATABASE_URL") || "ecto://gotham_admin:gotham_password@db/time_manager",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Endpoint configuration for development
config :time_manager, TimeManagerWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "+/6AbIOwaRJ1jqEgHEV2h959LQxxRlQk3misUhSPmOReSWjMZgiqdhA4Obp3aSAS"

# Optional: SSL configuration, uncomment if needed
# https: [
#   port: 4001,
#   cipher_suite: :strong,
#   keyfile: "priv/cert/selfsigned_key.pem",
#   certfile: "priv/cert/selfsigned.pem"
# ],

# Live reload configuration (for backend code changes)
config :time_manager, TimeManagerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/gettext/.*(po)$",
      ~r"lib/time_manager_web/(controllers|components)/.*(ex)$"
    ]
  ]

# Enable dev routes for Phoenix LiveDashboard, if required
config :time_manager, dev_routes: true

# Logger configuration
config :logger, :console, format: "[$level] $message\n"

# Development-specific Phoenix configuration
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh API client as it's not needed in development
config :swoosh, :api_client, false
