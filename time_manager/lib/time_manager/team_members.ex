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
    |> unique_constraint(:employee_id, message: "Employee can only belong to one team")
  end
end
