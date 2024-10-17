defmodule TimeManagerWeb.UserController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts

  def index(conn, params) do
    users = 
      case params do
        %{"email" => email, "username" => username} ->
          Accounts.list_users()
          |> Enum.filter(fn u -> u.email == email and u.username == username end)

        %{"email" => email} ->
          Accounts.list_users()
          |> Enum.filter(fn u -> u.email == email end)

        %{"username" => username} ->
          Accounts.list_users()
          |> Enum.filter(fn u -> u.username == username end)

        _ ->
          Accounts.list_users()
      end

    json(conn, users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    json(conn, user)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} -> 
        conn 
        |> put_status(:created) 
        |> json(user)

      {:error, changeset} -> 
        conn 
        |> put_status(:unprocessable_entity) 
        |> json(%{errors: changeset})
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} -> 
        json(conn, user)

      {:error, changeset} -> 
        conn 
        |> put_status(:unprocessable_entity) 
        |> json(%{errors: changeset})
    end
  end

  def delete(conn, %{"id" => id}) do
    try do
      user = Accounts.get_user!(id)
      Accounts.delete_user(user)

      conn
      |> put_status(:ok)
      |> json(%{message: "User successfully deleted"})
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      _error ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to delete user"})
    end
  end
end
