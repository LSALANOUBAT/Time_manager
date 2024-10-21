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

  # Routes de l'API publique (sans authentification)
  scope "/api", TimeManagerWeb do
    pipe_through :api

    # Routes de gestion des utilisateurs (création, etc.)
    resources "/users", UserController, except: [:new, :edit]

    # Route pour la connexion (génère un JWT)
    post "/sign_in", AuthController, :sign_in
  end

  # Routes de l'API protégées par authentification JWT
  scope "/api", TimeManagerWeb do
    pipe_through [:api, :auth]  # Les routes ici nécessitent une authentification

    # Routes pour les clocks
    get "/clocks/:user_id", ClockController, :index
    post "/clocks/:user_id", ClockController, :create

    # Routes pour les working times
    get "/workingtime/:userID", WorkingtimeController, :index
    get "/workingtime/:userID/:id", WorkingtimeController, :show
    post "/workingtime/:userID", WorkingtimeController, :create
    put "/workingtime/:id", WorkingtimeController, :update
    delete "/workingtime/:id", WorkingtimeController, :delete
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
