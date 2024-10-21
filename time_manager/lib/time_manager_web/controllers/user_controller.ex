defmodule TimeManagerWeb.UserController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManagerWeb.Auth.Guardian  # Utilisation de Guardian pour JWT

  # Liste des utilisateurs
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

  # Affichage d'un utilisateur
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    json(conn, user)
  end

  # Création d'un nouvel utilisateur
  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)  # Génère un token JWT pour l'utilisateur
        conn
        |> put_status(:created)
        |> json(%{user: user, token: token})  # Renvoie l'utilisateur et le token JWT

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  # Mise à jour d'un utilisateur
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

  # Suppression d'un utilisateur
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

  # Connexion (Login)
  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)  # Génère un token JWT après connexion réussie
        conn
        |> put_status(:ok)
        |> json(%{token: token, user: user})

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: reason})
    end
  end
end
