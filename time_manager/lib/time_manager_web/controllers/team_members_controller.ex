defmodule TimeManagerWeb.TeamMembersController do
  use TimeManagerWeb, :controller
  import Ecto.Query, only: [from: 2]
  alias TimeManager.{Repo, User, TeamMembers}
  alias TimeManagerWeb.Plugs.{AdminOrManager, FetchTeamID}

  # Ensure Admin or Manager role for specific actions
  plug AdminOrManager when action in [:add_employee, :delete_team_member, :get_team_members]
  plug FetchTeamID when action in [:add_employee, :delete_team_member, :get_team_members]

  # Add employee to the team
  def add_employee(conn, %{"id" => employee_id}) do
    team_id = conn.assigns[:team_id]
    employee_id = String.to_integer(employee_id)

    case Repo.get(User, employee_id) do
      %User{role: "employee"} = employee ->
        changeset = TeamMembers.changeset(%TeamMembers{}, %{team_id: team_id, employee_id: employee.id})

        case Repo.insert(changeset) do
          {:ok, _team_member} ->
            conn
            |> put_status(:created)
            |> json(%{message: "Team member successfully added"})

          {:error, %Ecto.Changeset{errors: [employee_id: {"Employee is already assigned to another team", _}]}} ->
            conn
            |> put_status(:conflict)
            |> json(%{status: "error", message: "This employee is already assigned to another team"})

          {:error, changeset} ->
            errors = format_changeset_errors(changeset)
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", errors: errors})
        end

      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "Only employees can be added to the team"})
    end
  end

  # Helper function to format errors in a readable format
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  # Delete a team member
  def delete_team_member(conn, %{"id" => employee_id}) do
    team_id = conn.assigns[:team_id]
    employee_id = String.to_integer(employee_id)

    # Check if the employee is a member of the given team
    case Repo.get_by(TeamMembers, team_id: team_id, employee_id: employee_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Team member not found in the specified team"})

      %TeamMembers{} = team_member ->
        # Retrieve the user's role to ensure only employees can be deleted
        case Repo.get(User, employee_id) do
          %User{role: "employee"} ->
            Repo.delete!(team_member)
            conn
            |> put_status(:ok)
            |> json(%{status: "success", message: "Team member successfully deleted"})

          %User{role: "manager"} ->
            conn
            |> put_status(:forbidden)
            |> json(%{status: "error", message: "Cannot delete a manager from the team, delete the team instead"})

          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{status: "error", message: "User not found"})
        end
    end
  end

  # Get all members of a team
  def get_team_members_token(conn, _params) do
    team_id = conn.assigns[:team_id]

    case Repo.get(TimeManager.Team, team_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Team not found"})

      team ->
        members =
          Repo.all(
            from tm in TeamMembers,
            where: tm.team_id == ^team_id,
            join: user in assoc(tm, :user),
            select: %{id: user.id, username: user.username, email: user.email, role: user.role}
          )

        conn
        |> put_status(:ok)
        |> json(%{status: "success", team: team.name, members: members})
    end
  end

  def get_team_members_id(conn, %{"team_id" => team_id}) do
    case Repo.get(TimeManager.Team, team_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Team not found"})

      team ->
        members =
          Repo.all(
            from tm in TeamMembers,
            where: tm.team_id == ^team_id,
            join: user in assoc(tm, :user),
            select: %{id: user.id, username: user.username, email: user.email, role: user.role}
          )

        conn
        |> put_status(:ok)
        |> json(%{status: "success", team: team.name, members: members})
    end
  end
  def add_employee_admin(conn, %{"id" => employee_id, "team_id" => team_id}) do
    team_id = String.to_integer(team_id)
    employee_id = String.to_integer(employee_id)

    case Repo.get(User, employee_id) do
      %User{role: "employee"} = employee ->
        changeset = TeamMembers.changeset(%TeamMembers{}, %{team_id: team_id, employee_id: employee.id})

        case Repo.insert(changeset) do
          {:ok, _team_member} ->
            conn
            |> put_status(:created)
            |> json(%{message: "Team member successfully added"})

          {:error, %Ecto.Changeset{errors: [employee_id: {"Employee is already assigned to another team", _}]}} ->
            conn
            |> put_status(:conflict)
            |> json(%{status: "error", message: "This employee is already assigned to another team"})

          {:error, changeset} ->
            errors = format_changeset_errors(changeset)
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", errors: errors})
        end

      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "Only employees can be added to the team"})
    end
  end


end
