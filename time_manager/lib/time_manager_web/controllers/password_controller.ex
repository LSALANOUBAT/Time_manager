defmodule TimeManagerWeb.PasswordController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManagerWeb.Auth.Guardian
  alias TimeManager.User
  # Endpoint to update password
  def update_password(conn, %{"password" => password}) do
    # Extract the current user from the Bearer token
    current_user = Guardian.Plug.current_resource(conn)

    case current_user do
      %User{id: user_id} ->
        user = Accounts.get_user!(user_id)

        # Ensure password is provided and valid
        case Accounts.update_user_password(user, %{"password" => password}) do
          {:ok, _user} ->
            conn
            |> put_status(:ok)
            |> json(%{message: "Password updated successfully"})

          {:error, changeset} ->
            errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
              Enum.reduce(opts, msg, fn {key, value}, acc ->
                String.replace(acc, "%{#{key}}", to_string(value))
              end)
            end)

            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: errors})
        end

      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "You must be authenticated to update the password."})
    end
  end
end
