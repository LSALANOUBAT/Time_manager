defmodule TimeManagerWeb.TeamMembersController do
  use TimeManagerWeb, :controller
  import Ecto.Query, only: [from: 2]
  alias TimeManager.{Team, Repo, User, TeamMembers}
  alias TimeManagerWeb.Plugs.AdminOrManager

  plug AdminOrManager when action in [:add_employee, :delete_team_member]

  def add_employee(conn, %{"team_id" => team_id, "id" => employee_id}) do
    team_id = String.to_integer(team_id)
    employee_id = String.to_integer(employee_id)

    case Repo.get(TimeManager.User, employee_id) do
      %TimeManager.User{role: "employee"} = employee ->
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

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end




  def delete_team_member(conn, %{"team_id" => team_id, "id" => employee_id}) do
    team_id = String.to_integer(team_id)
    employee_id = String.to_integer(employee_id)

    # Check if the employee is a member of the given team
    case Repo.get_by(TeamMembers, team_id: team_id, employee_id: employee_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Team member not found in the specified team"})

      %TeamMembers{} = team_member ->
        # Retrieve the user's role to ensure only employees can be deleted
        case Repo.get(TimeManager.User, employee_id) do
          %TimeManager.User{role: "employee"} ->
            Repo.delete!(team_member)
            conn
            |> put_status(:ok)
            |> json(%{status: "success", message: "Team member successfully deleted"})

          %TimeManager.User{role: "manager"} ->
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


  def get_team_members(conn, %{"team_id" => team_id}) do
    team_id = String.to_integer(team_id)

    case Repo.get(TimeManager.Team, team_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Team not found"})

      team ->
        members =
          Repo.all(
            from tm in TimeManager.TeamMembers,
            where: tm.team_id == ^team_id,
            join: user in assoc(tm, :user),
            select: %{id: user.id, username: user.username, email: user.email, role: user.role}
          )

        conn
        |> put_status(:ok)
        |> json(%{status: "success", team: team.name, members: members})
    end
  end




end
