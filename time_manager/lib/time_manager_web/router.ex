defmodule TimeManagerWeb.Router do
  use TimeManagerWeb, :router

  # Pipeline for HTML requests (browser)
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {TimeManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # Pipeline for JSON requests (API)
  pipeline :api do
    plug :accepts, ["json"]
  end

  # Pipeline for JWT token verification
  pipeline :auth do
    plug TimeManagerWeb.Auth.Pipeline # Assuming this plug is responsible for authentication
  end

  # Pipeline for checking admin or manager roles, must follow auth
  pipeline :admin_or_manager do
    plug TimeManagerWeb.Plugs.AdminOrManager  # Authorization plug for admin/manager
  end

  pipeline :admin do
    plug TimeManagerWeb.Plugs.Admin  # Authorization plug for admin
  end
  # Routes accessible via the browser
  scope "/", TimeManagerWeb do
    pipe_through :browser

    # Define the root route
    get "/", PageController, :index
  end

  # Public API routes (without authentication)
  scope "/api", TimeManagerWeb do
    pipe_through :api

    # Route for login (generates a JWT)
    post "/sign_in", AuthController, :sign_in

    # User management routes (only index and show for unauthenticated users)

  end


  # Additional routes for authenticated users (working times, etc.)
  scope "/api", TimeManagerWeb do
    pipe_through [:api, :auth]  # Routes that require authentication
    resources "/users", UserController, only: [:index, :show], plug: Admin

    post "/users", UserController, :create, plug: AdminOrManager
    delete "/users/:id", UserController, :delete, plug: Admin
    put "/users/:id", UserController, :update, plug: Admin
    # Routes for working times
    get "/workingtime/:userID", WorkingtimeController, :index
    get "/workingtime/:userID/:id", WorkingtimeController, :show
    post "/workingtime/:userID", WorkingtimeController, :create
    put "/workingtime/:id", WorkingtimeController, :update, plug: AdminOrManager
    delete "/workingtime/:id", WorkingtimeController, :delete
    put "/update_password", PasswordController, :update_password
  end

  # Development routes
  if Application.compile_env(:time_manager, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TimeManagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
