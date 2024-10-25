defmodule TimeManager.Repo.Migrations.AddManagerIdToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :manager_id, references(:users, on_delete: :nilify_all)  # Foreign key for manager
    end

    # Ensure each manager can only manage one team
    create unique_index(:teams, [:manager_id])
  end
end
