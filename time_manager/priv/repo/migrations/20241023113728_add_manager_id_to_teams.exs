defmodule TimeManager.Repo.Migrations.AddManagerAndEmployeeIdToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :manager_id, references(:users, on_delete: :nilify_all)  # Foreign key for manager
      add :employee_id, references(:users, on_delete: :nilify_all)  # Foreign key for employee
    end

    create unique_index(:teams, [:manager_id])  # Ensure each manager can manage only one team
    create index(:teams, [:employee_id])  # Index for employee_id for better query performance
  end
end
