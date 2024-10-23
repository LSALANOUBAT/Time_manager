defmodule TimeManagerWeb.AuthController do
  use TimeManagerWeb, :controller

  alias TimeManager.Accounts
  alias TimeManagerWeb.Auth.Guardian

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        claims = %{"sub" => to_string(user.id), "role" => user.role}  # Ensure role is included in claims
        {:ok, token, _} = Guardian.encode_and_sign(user, claims)
        json(conn, %{token: token, user_id: user.id})

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: reason})
    end
  end

end
