defmodule TimeManagerWeb.UserController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManagerWeb.Auth.Guardian


  alias TimeManagerWeb.Plugs.Admin
  alias TimeManagerWeb.Plugs.AdminOrManager
  plug Admin when action in [:create]
  plug Admin when action in [:delete]
  plug Admin when action in [:update]
  plug Admin when action in [:list_managers]
  plug Admin when action in [:unasign_managers]
  plug AdminOrManager when action in [:list_unassigned_employees]

  # List all users
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

  def list_unassigned_employees(conn, _params) do
    unassigned_employees = Accounts.list_unassigned_employees()
    json(conn, unassigned_employees)
  end

  def unasign_managers(conn, _params) do
    unassigned_managers = Accounts.list_unassigned_managers()
    json(conn, unassigned_managers)
  end

  def list_managers(conn, _params) do
    managers = Accounts.list_users()
               |> Enum.filter(fn user -> user.role == "manager" end)

    json(conn, managers)
  end

  # Show a single user by ID
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    json(conn, user)
  end

  # Show a single user by ID
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    json(conn, user)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_status(:created)
        |> json(%{message: "User has been created"})

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
  end


  # Update an existing user
  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        user_data = Map.take(user, [:id, :username, :email, :role])

        conn
        |> put_status(:ok)
        |> json(user_data)

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
  end



  # Delete a user
  def delete(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        case Accounts.delete_user(user) do
          {:ok, _} ->
            conn
            |> put_status(:ok)
            |> json(%{message: "User successfully deleted"})

          {:error, _} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to delete user"})
        end
    end
  end

  # User login (sign in)
  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        # Exclude sensitive data from the response
        user_data = Map.take(user, [:id, :username, :email, :role])

        conn
        |> put_status(:ok)
        |> json(%{token: token, user: user_data})

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: reason})
    end
  end
end
