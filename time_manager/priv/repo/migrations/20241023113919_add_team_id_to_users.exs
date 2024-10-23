defmodule TimeManager.Repo.Migrations.AddTeamIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :team_id, references(:teams, on_delete: :nilify_all)  # Add foreign key for team
    end

    create index(:users, [:team_id])  # Index for faster queries on team_id
  end
end
