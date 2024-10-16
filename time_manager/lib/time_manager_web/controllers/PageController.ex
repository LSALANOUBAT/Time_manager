defmodule TimeManagerWeb.PageController do
  use TimeManagerWeb, :controller

  def index(conn, _params) do
    json(conn, %{message: "Welcome to Time Manager API"})
  end
end
