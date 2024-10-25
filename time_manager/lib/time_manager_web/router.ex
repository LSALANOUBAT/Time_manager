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

    post "/users", UserController, :create, plug: Admin
    delete "/users/:id", UserController, :delete, plug: Admin
    put "/users/:id", UserController, :update, plug: Admin
    put "/update_password", PasswordController, :update_password

    # Routes for working times
    scope "/workingtime" do
      get "/", WorkingtimeController, :all, plug: Admin # Get all working times OK
      get "/:userID", WorkingtimeController, :index # List working times for a specific user OK
      get "/:userID/:id", WorkingtimeController, :show # Show a specific working time entry OK
      post "/:userID", WorkingtimeController, :create, plug: Admin # Create a new working time for a user OK
      put "/:id", WorkingtimeController, :update, plug: Admin # Update a specific working time entry OK
      delete "/:id", WorkingtimeController, :delete, plug: Admin # Delete a working time entry (admin only) OK
      post "/:userID/clock_in", WorkingtimeController, :clock_in # Clock in for a user (no specific role required) OK
      post "/:userID/clock_out", WorkingtimeController, :clock_out # Clock out for a user (no specific role required) OK
    end

    # Routes for teams
    scope "/teams" do
      get "", AdminTeamController, :all, plug: Admin #OK
      post "", AdminTeamController, :create, plug: Admin #OK
      put "/:id", AdminTeamController, :update_name, plug: Admin #OK
      delete "/:id", AdminTeamController, :delete, plug: Admin #OK
      put "/:team_id/assign_manager/:id", AdminTeamController, :assign_manager, plug: Admin #OK
      put "/:team_id/add_employee/:id", AdminTeamController, :add_employee, plug: AdminorManager #
    end
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
