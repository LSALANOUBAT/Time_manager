defmodule TimeManager.Repo.Migrations.CreateTeamMembers do
  use Ecto.Migration

  def change do
    create table(:team_members) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false  # Cascade on team deletion
      add :employee_id, references(:users, on_delete: :nilify_all), null: false  # Nullify employee_id on user deletion

      timestamps(type: :utc_datetime)
    end

    # Ensure each employee can belong to only one team at a time
    create unique_index(:team_members, [:employee_id], name: :unique_employee_team)

    # Optional index for quick lookup by team
    create index(:team_members, [:team_id])
  end
end
