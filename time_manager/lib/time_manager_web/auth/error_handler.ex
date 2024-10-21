defmodule TimeManagerWeb.Auth.ErrorHandler do
  import Plug.Conn
  import Phoenix.Controller  # Importer le module Phoenix.Controller pour utiliser json/2

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Unauthorized"})  # Maintenant json/2 est disponible
  end
end
