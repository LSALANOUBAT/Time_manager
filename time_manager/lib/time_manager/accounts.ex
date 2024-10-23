defmodule TimeManager.Accounts do
  alias TimeManager.Repo
  alias TimeManager.User

  alias TimeManager.Workingtime
  import Ecto.Query
  alias Bcrypt  # Updated alias to use `Bcrypt` from `bcrypt_elixir`

  # Lister tous les utilisateurs
  def list_users() do
    Repo.all(User)
  end

  # Récupérer un utilisateur par son ID
  def get_user!(id), do: Repo.get!(User, id)

  # Créer un utilisateur avec un mot de passe haché et un rôle par défaut
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # Mettre à jour un utilisateur
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  # Supprimer un utilisateur
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  # Authentifier un utilisateur par email et mot de passe
  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    case user do
      nil ->
        {:error, "Invalid credentials"}

      %User{} = user ->
        # Updated password verification function to use `Bcrypt.verify_pass/2`
        if Bcrypt.verify_pass(password, user.hashed_password) do
          {:ok, user}
        else
          {:error, "Invalid credentials"}
        end
    end
  end

  # Promouvoir ou rétrograder un utilisateur à un rôle différent
  def change_role(%User{} = user, role) do
    user
    |> Ecto.Changeset.change(role: role)
    |> Repo.update()
  end

  # Récupérer un workingtime d'un utilisateur par son ID
  def get_workingtime!(user_id, id) do
    Repo.get_by!(Workingtime, user_id: user_id, id: id)
  end

  # Créer un nouveau workingtime pour un utilisateur
  def create_workingtime(attrs) do
    %Workingtime{}
    |> Workingtime.changeset(attrs)
    |> Repo.insert()
  end

  # Mettre à jour un workingtime
  def update_workingtime(%Workingtime{} = workingtime, attrs) do
    workingtime
    |> Workingtime.changeset(attrs)
    |> Repo.update()
  end

  # Supprimer un workingtime
  def delete_workingtime(%Workingtime{} = workingtime) do
    Repo.delete(workingtime)
  end

  # Lister les workingtimes d'un utilisateur dans un intervalle donné
  def list_workingtimes(user_id, start_time, end_time) do
    query = from w in Workingtime,
                 where: w.user_id == ^user_id and w.start >= ^start_time and w.end <= ^end_time

    Repo.all(query)
  end
end
