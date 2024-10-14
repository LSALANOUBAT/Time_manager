defmodule TimeManager.Accounts do
  alias TimeManager.Repo
  alias TimeManager.User
  alias TimeManager.Clock
  alias TimeManager.Workingtime
  import Ecto.Query

  def list_users() do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)
  
def create_user(attrs) do
  %User{}
  |> User.changeset(attrs)
  |> Repo.insert()
end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def list_clocks(user_id) do
    Repo.all(from c in TimeManager.Clock, where: c.user_id == ^user_id)
  end

  def create_clock(attrs \\ %{}) do
    %TimeManager.Clock{}
    |> Clock.changeset(attrs)
    |> Repo.insert()
  end

  def get_workingtime!(user_id, id) do
    Repo.get_by!(Workingtime, user_id: user_id, id: id)
  end

  # Crée un nouveau workingtime pour un utilisateur
  def create_workingtime(attrs) do
    %Workingtime{}
    |> Workingtime.changeset(attrs)
    |> Repo.insert()
  end

  def get_workingtime!(id), do: Repo.get!(Workingtime, id)

  # Met à jour un workingtime par ID
  def update_workingtime(%Workingtime{} = workingtime, attrs) do
    workingtime
    |> Workingtime.changeset(attrs)
    |> Repo.update()
  end

  # Supprime un workingtime par ID
  def delete_workingtime(%Workingtime{} = workingtime) do
    Repo.delete(workingtime)
  end

  def list_workingtimes(user_id, start_time, end_time) do
    query = from w in Workingtime,
      where: w.user_id == ^user_id and w.start >= ^start_time and w.end <= ^end_time
    
    Repo.all(query)
  end
end
