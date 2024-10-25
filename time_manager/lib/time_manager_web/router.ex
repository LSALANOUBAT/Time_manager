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
    get "/", PageController, :index
  end

  # Public API routes (without authentication)
  scope "/api", TimeManagerWeb do
    pipe_through :api
    post "/sign_in", AuthController, :sign_in
  end

  # Additional routes for authenticated users (working times, etc.)
  scope "/api", TimeManagerWeb do
    pipe_through [:api, :auth]

    resources "/users", UserController, only: [:index, :show] do
      pipe_through :admin
    end

    post "/users", UserController, :create, plug: AdminOrManager
    delete "/users/:id", UserController, :delete, plug: Admin
    put "/users/:id", UserController, :update, plug: Admin
    put "/update_password", PasswordController, :update_password

    # Routes for working times
    scope "/workingtime" do
      get "/", WorkingtimeController, :all, plug: AdminOrManager # Get all working times
      get "/:userID", WorkingtimeController, :index, plug: AdminOrManager # List working times for a specific user
      get "/:userID/:id", WorkingtimeController, :show, plug: AdminOrManager # Show specific working time entry for a user
      post "/:userID", WorkingtimeController, :create, plug: AdminOrManager # Create a new working time for a user
      put "/:id", WorkingtimeController, :update, plug: AdminOrManager # Update a specific working time entry
      delete "/:id", WorkingtimeController, :delete, plug: Admin # Delete a working time entry (admin only)
      post "/:userID/clock_in", WorkingtimeController, :clock_in # Clock in for a user (no specific role required)
      post "/:userID/clock_out", WorkingtimeController, :clock_out # Clock out for a user (no specific role required)
    end

    # Admin routes for t
    get "/teams/", AdminTeamController, :index
    post "/teams/", AdminTeamController, :create
    put "/teams/:id", AdminTeamController, :update
    delete "/teams/:id", AdminTeamController, :delete
    post "/teams/:team_id/assign_manager/:id", AdminTeamController, :assign_manager
    post "/teams/:team_id/add_user/:id", AdminTeamController, :add_user
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
