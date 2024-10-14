defmodule TimeManagerWeb.Router do
  use TimeManagerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TimeManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TimeManagerWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", TimeManagerWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
    
    get "/clocks/:user_id", ClockController, :index
    
    post "/clocks/:user_id", ClockController, :create
    
    get "/workingtime/:userID", WorkingtimeController, :index

    get "/workingtime/:userID/:id", WorkingtimeController, :show

    post "/workingtime/:userID", WorkingtimeController, :create

    put "/workingtime/:id", WorkingtimeController, :update

    delete "/workingtime/:id", WorkingtimeController, :delete
  end

  if Application.compile_env(:time_manager, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TimeManagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
