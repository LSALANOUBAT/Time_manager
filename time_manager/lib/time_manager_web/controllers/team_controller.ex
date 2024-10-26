defmodule TimeManagerWeb.TeamController do
  use TimeManagerWeb, :controller

  alias TimeManager.{Team, Repo, User, TeamMembers}  # Use TimeManager.Repo here
  alias TimeManagerWeb.Plugs.Admin
  import Ecto.Query



  plug Admin when action in [:create, :delete, :update_name, :assign_manager]


  # List all teams
  def all(conn, _params) do
    teams = Repo.all(Team)
    json(conn, %{teams: teams})
  end


  def create(conn, %{"team" => team_params}) do
    changeset = Team.changeset(%Team{}, team_params)

    case Repo.insert(changeset) do
      {:ok, _team} ->
        conn
        |> put_status(:created)
        |> json(%{message: "Team successfully created"})

      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: errors})
    end
  end


  # Update an existing team
  def update_name(conn, %{"id" => id, "team" => %{"name" => name}}) do
    team = Repo.get(Team, id)

    changeset = Team.changeset(team, %{name: name})

    case Repo.update(changeset) do
      {:ok, _team} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "Team name successfully updated"})

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

  def delete(conn, %{"id" => id}) do
    team = Repo.get(Team, id)
    case team do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Team not found"})
      team ->
        case Repo.delete(team) do
          {:ok, _deleted_team} ->
            conn
            |> put_status(:ok)
            |> json(%{message: "Team successfully deleted"})
          {:error, _changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{message: "Failed to delete team"})
        end
    end
  end

  # Delete a team
  def assign_manager(conn, %{"team_id" => team_id, "id" => new_manager_id}) do
    team_id = String.to_integer(team_id)
    new_manager_id = String.to_integer(new_manager_id)

    # Fetch the team by its ID
    case Repo.get(Team, team_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Team not found"})

      %Team{manager_id: current_manager_id} = team ->
        # Fetch the new manager and verify their role
        case Repo.get(User, new_manager_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{status: "error", message: "Manager not found"})

          %User{role: "manager"} = new_manager ->
            # Begin a transaction to update the manager assignment
            case Repo.transaction(fn ->
              # If there is an existing manager, remove them from team members
              if current_manager_id do
                Repo.delete_all(
                  from(tm in TeamMembers,
                    where: tm.team_id == ^team_id and tm.employee_id == ^current_manager_id
                  )
                )
              end

              # Update the team with the new manager_id
              team_changeset =
                team
                |> Ecto.Changeset.change(manager_id: new_manager.id)
                |> Ecto.Changeset.unique_constraint(:manager_id, name: "teams_manager_id_index")

              case Repo.update(team_changeset) do
                {:ok, updated_team} ->
                  # Add the new manager to team members if not already present
                  case Repo.get_by(TeamMembers, team_id: team_id, employee_id: new_manager_id) do
                    nil ->
                      %TeamMembers{}
                      |> TeamMembers.changeset(%{team_id: team_id, employee_id: new_manager_id})
                      |> Repo.insert!()

                    _existing ->
                      :ok # New manager is already a member
                  end

                  {:ok, updated_team}

                {:error, changeset} ->
                  Repo.rollback(changeset)
              end
            end) do
              {:ok, _updated_team} ->
                conn
                |> put_status(:ok)
                |> json(%{status: "success", message: "Manager successfully assigned to the team as both manager and team member"})

              {:error, changeset} ->
                errors = format_changeset_errors(changeset)

                conn
                |> put_status(:conflict)
                |> json(%{status: "error", message: "Manager has already a team", errors: errors})
            end

          _user ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", message: "User is not a manager"})
        end
    end
  end

  # Helper function for formatting errors
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

end
