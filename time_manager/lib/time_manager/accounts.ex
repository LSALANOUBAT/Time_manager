defmodule TimeManager.Accounts do
  alias TimeManager.Repo
  alias TimeManager.User   # Correct path to the User schema
  alias TimeManager.Workingtime   # Correct path to the Workingtime schema
  import Ecto.Query
  alias Bcrypt  # Updated alias to use `Bcrypt` from `bcrypt_elixir`

  # List all users
  def list_users() do
    Repo.all(User)
  end

  # Get a user by ID
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id) do
    Repo.get(User, id)
  end

  # Create a user with a hashed password and default role
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # Update a user
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end


  # Delete a user
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  # Authenticate a user by email and password
  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    case user do
      nil ->
        {:error, "Invalid credentials"}

      %User{} = user ->
        if Bcrypt.verify_pass(password, user.hashed_password) do
          {:ok, user}
        else
          {:error, "Invalid credentials"}
        end
    end
  end

  # Promote or demote a user to a different role
  def change_role(%User{} = user, role) do
    user
    |> Ecto.Changeset.change(role: role)
    |> Repo.update()
  end

  # Get a workingtime of a user by their ID
  def get_workingtime!(user_id, id) do
    Repo.get_by!(Workingtime, user_id: user_id, id: id)
  end

  # Create a new workingtime for a user
  def create_workingtime(attrs) do
    %Workingtime{}
    |> Workingtime.changeset(attrs)
    |> Repo.insert()
  end

  # Update a workingtime
  def update_workingtime(%Workingtime{} = workingtime, attrs) do
    workingtime
    |> Workingtime.changeset(attrs)
    |> Repo.update()
  end

  # Delete a workingtime
  def delete_workingtime(%Workingtime{} = workingtime) do
    Repo.delete(workingtime)
  end

    # Function to update only the password
  def update_user_password(%User{} = user, %{"password" => password}) do
    user
    |> User.password_changeset(%{"password" => password})
    |> Repo.update()
  end

  # List workingtimes for a user within a given time range
  def list_workingtimes(user_id, start_time, end_time) do
    query = from w in Workingtime,
                 where: w.user_id == ^user_id and w.start >= ^start_time and w.end <= ^end_time

    Repo.all(query)  # This line was missing, it executes the query and fetches the result
  end
end
