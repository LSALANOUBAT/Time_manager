defmodule TimeManagerWeb.Plugs.AdminOrManager do
  import Plug.Conn
  import Phoenix.Controller

  alias TimeManagerWeb.Auth.Guardian
  alias TimeManager.User  # Ensure the correct path to the User module

  def init(_opts), do: nil

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      %User{role: "admin"} ->
        conn
      %User{role: "manager"} ->
        conn
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "You must be authenticated to access this resource"})
        |> halt()
      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "You are not authorized to access this resource"})
        |> halt()
    end
  end

end
