defmodule TimeManagerWeb.PageController do
  use TimeManagerWeb, :controller

  def index(conn, _params) do
    json(conn, %{message: "Welcome to Time Team API"})
  end
end
