defmodule TimeManagerWeb.AdminTeamController do
  use TimeManagerWeb, :controller

  alias TimeManager.{Team, Repo, User}  # Use TimeManager.Repo here
  alias TimeManagerWeb.Plugs.Admin


  plug Admin when action in [:create, :delete, :update_name, :assign_manager]
  plug AdminOrManager when action in [:add_user]


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

  # Delete a team
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

  # Assign a manager to a team
  def assign_manager(conn, %{"team_id" => team_id, "id" => manager_id}) do
    # Convert team_id and manager_id to integers
    team_id = String.to_integer(team_id)
    manager_id = String.to_integer(manager_id)

    # Find the team by its ID
    case Repo.get(TimeManager.Team, team_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Team not found"})

      team ->
        # Check if the manager exists and has a role of "manager"
        case Repo.get(TimeManager.User, manager_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{status: "error", message: "Manager not found"})

          %TimeManager.User{role: "manager"} = manager ->
            # Attempt to update the team with the new manager_id
            team_changeset =
              team
              |> Ecto.Changeset.change(manager_id: manager.id)
              |> Ecto.Changeset.unique_constraint(:manager_id, name: "teams_manager_id_index")

            # Start a transaction to update both the team and the user's team_id
            case Repo.transaction(fn ->
              case Repo.update(team_changeset) do
                {:ok, _team} ->
                  # Add the manager to team members if not already present
                  case Repo.get_by(TimeManager.TeamMembers, team_id: team_id, employee_id: manager_id) do
                    nil ->
                      # Add manager to team members table
                      %TimeManager.TeamMembers{}
                      |> TimeManager.TeamMembers.changeset(%{team_id: team_id, employee_id: manager_id})
                      |> Repo.insert!()

                    _ ->
                      :ok  # Manager is already a member
                  end
                {:error, changeset} ->
                  Repo.rollback(changeset)
              end
            end) do
              {:ok, _} ->
                conn
                |> put_status(:ok)
                |> json(%{status: "success", message: "Manager successfully assigned to the team as both manager and team member"})

              {:error, changeset} ->
                errors = format_changeset_errors(changeset)
                conn
                |> put_status(:conflict)
                |> json(%{status: "error", message: "Manager has already a team", errors: errors})
            end

          _ ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", message: "User is not a manager"})
        end
    end
  end

  # Helper function to format changeset errors without `apply_action`
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end








  # Add a user to a team
  def add_employee(conn, %{"team_id" => team_id, "id" => employee_id}) do
    # Convert team_id and employee_id to integers
    team_id = String.to_integer(team_id)
    employee_id = String.to_integer(employee_id)

    # Find the team by its ID
    case Repo.get(Team, team_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Team not found"})

      team ->
        # Check if the employee exists
        case Repo.get(User, employee_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{status: "error", message: "Employee not found"})

          %User{role: "employee"} = employee ->
            # Start a transaction to update both the team and the user's team_id
            Repo.transaction(fn ->
              # Update the team with the new employee_id
              team_changeset = Ecto.Changeset.change(team, employee_id: employee.id)
              Repo.update!(team_changeset)

              # Update the user’s team_id field
              user_changeset = Ecto.Changeset.change(employee, team_id: team_id)
              Repo.update!(user_changeset)
            end)

            conn
            |> put_status(:ok)
            |> json(%{status: "success", message: "Employee successfully added to the team"})

          _ ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", message: "User is not an employee"})
        end
    end
  end
end
