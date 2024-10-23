defmodule TimeManagerWeb.Router do
  use TimeManagerWeb, :router

  # Pipeline pour les requêtes HTML (browser)
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {TimeManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # Pipeline pour les requêtes JSON (API)
  pipeline :api do
    plug :accepts, ["json"]
  end

  # Pipeline pour la vérification du token JWT
  pipeline :auth do
    plug TimeManagerWeb.Auth.Pipeline
  end

  # Routes accessibles via le navigateur
  scope "/", TimeManagerWeb do
    pipe_through :browser

    # Définir la route racine
    get "/", PageController, :index
  end


  # Routes de l'API protégées par authentification JWT
  scope "/api", TimeManagerWeb do
  end

  # Routes de développement
  if Application.compile_env(:time_manager, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TimeManagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
