defmodule TimeManager.TeamMembers do
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_members" do
    belongs_to :team, TimeManager.Team, foreign_key: :team_id
    belongs_to :user, TimeManager.User, foreign_key: :employee_id

    timestamps(type: :utc_datetime)
  end

  def changeset(team_employee, attrs) do
    team_employee
    |> cast(attrs, [:team_id, :employee_id])
    |> validate_required([:team_id, :employee_id])
    |> unique_constraint(:employee_id, name: :unique_employee_team, message: "Employee is already assigned to another team")
    |> unique_constraint(:employee_id, name: :team_members_employee_id_index, message: "Employee is already assigned to another team")
  end
end
