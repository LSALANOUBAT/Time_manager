defmodule TimeManagerWeb.Plugs.AdminOrManager do
  import Plug.Conn
  import Guardian.Plug

  def init(default), do: default

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        |> halt()

      user ->
        if user.role in ["admin", "manager"] do
          assign(conn, :current_user, user)  # Assign the user to the connection for further use
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden: Insufficient permissions"})
          |> halt()
        end
    end
  end
end