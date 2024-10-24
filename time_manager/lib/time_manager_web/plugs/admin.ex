defmodule TimeManagerWeb.Plugs.Admin do
  import Plug.Conn
  import Phoenix.Controller

  alias TimeManagerWeb.Auth.Guardian
  alias TimeManager.User  # Ensure the correct path to the User module

  # Allows passing options (could be expanded in the future)
  def init(opts), do: opts

  # Call is responsible for checking if the user is authenticated and authorized
  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      %User{role: "admin"} ->
        conn  # User is an admin, allow access

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
