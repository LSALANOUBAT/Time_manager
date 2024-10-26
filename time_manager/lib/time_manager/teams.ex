defmodule TimeManager.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :manager_id, :inserted_at, :updated_at]}
  schema "teams" do
    field :name, :string

    # Reference to the manager with a unique constraint to ensure only one team per manager
    belongs_to :user, TimeManager.User, foreign_key: :manager_id

    # Define one-to-many relationship for employees via the join table "team_employees"
    has_many :team_employees, TimeManager.TeamMembers
    has_many :employees, through: [:team_employees, :employee]

    timestamps(type: :utc_datetime)
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :manager_id])
    |> validate_required([:name])
    |> unique_constraint(:name, message: "Team name must be unique")
    |> unique_constraint(:manager_id, message: "Team can only manage one team")
  end
end
