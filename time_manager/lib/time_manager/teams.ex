defmodule TimeManager.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    belongs_to :manager, TimeManager.User, foreign_key: :manager_id  # Reference to the manager
    belongs_to :employee, TimeManager.User, foreign_key: :employee_id  # Reference to an employee

    has_many :users, TimeManager.User, foreign_key: :team_id  # One-to-many relationship with users

    timestamps(type: :utc_datetime)
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :manager_id, :employee_id])  # Include employee_id in the changeset
    |> validate_required([:name])
    |> foreign_key_constraint(:manager_id)
    |> foreign_key_constraint(:employee_id)  # Validate that the employee_id is a valid reference
  end
end
