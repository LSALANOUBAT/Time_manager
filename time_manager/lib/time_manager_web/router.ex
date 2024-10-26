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

  pipeline :manager do
    plug TimeManagerWeb.Plugs.Manager  # Authorization plug for admin/manager
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

    # Routes for users
    get "/users/unsigned_employee", UserController, :list_unassigned_employees, plug: AdminOrManager #
    get "/users/managers", UserController, :list_managers, plug: Admin #
    get "/users/unassigned_managers", UserController, :unasign_managers, plug: Admin #
    get "/users", UserController, :index, plug: AdminOrManager
    get "/users/:id", UserController, :show
    post "/users", UserController, :create, plug: Admin
    delete "/users/:id", UserController, :delete, plug: Admin
    put "/users/:id", UserController, :update, plug: Admin
    put "/update_password", PasswordController, :update_password

    # Routes for working times
    scope "/workingtime" do
      get "/", WorkingtimeController, :all, plug: Admin # Get all working times OK
      get "/:userID", WorkingtimeController, :index # List working times for a specific user OK => use bearer token
      get "/:userID/:id", WorkingtimeController, :show # Show a specific working time entry OK => use bearer token
      post "/:userID", WorkingtimeController, :create, plug: Admin # Create a new working time for a user OK
      put "/:id", WorkingtimeController, :update, plug: Admin # Update a specific working time entry OK
      delete "/:id", WorkingtimeController, :delete, plug: Admin # Delete a working time entry (admin only) OK
      post "/:userID/clock_in", WorkingtimeController, :clock_in # Clock in for a user (no specific role required) OK
      post "/:userID/clock_out", WorkingtimeController, :clock_out # Clock out for a user (no specific role required) OK
    end

    # Routes for teams
    scope "/teams" do
      get "/", TeamController, :all, plug: Admin #OK
      post "/", TeamController, :create, plug: Admin #OK
      put "/:id", TeamController, :update_name, plug: Admin #OK
      delete "/:id", TeamController, :delete, plug: Admin #OK
      post "/:team_id/assign_manager/:id", TeamController, :assign_manager, plug: Admin #OK
    end

    scope "/team_members" do #OK
      post "/:id/team/", TeamMembersController, :add_employee, plug: AdminOrManager #OK
      delete "/:id/team/:team_id", TeamMembersController, :delete_team_member, plug: AdminOrManager #OK
      get "/", TeamMembersController, :get_team_members_token, plug: AdminOrManager #OK
      get "/:team_id", TeamMembersController, :get_team_members_id, plug: AdminOrManager #OK
      post "/:id/team/:team_id", TeamMembersController, :add_employee_admin, plug: AdminOrManager #OK
    end

    scope "/metrics" do
      get "/overtime_ratios", MetricsController, :overtime_ratio, plug: Manager
      get "/night_ratios", MetricsController, :night_ratio, plug: Manager
      get "/undertime_ratios", MetricsController, :undertime_ratio, plug: Manager
      get "/time_per_over_overtime", MetricsController, :time_per_over_overtime, plug: Manager
      get "/users_overtime_hours_sum", MetricsController, :sum_user_overtime_hours
      get "/users_night_hours_sum", MetricsController, :sum_user_night_hours
      get "/users_hours_per_working_time", MetricsController, :hours_per_working_time
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
