defmodule TimeManagerWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :time_manager,
                              module: TimeManagerWeb.Auth.Guardian,
                              error_handler: TimeManagerWeb.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
