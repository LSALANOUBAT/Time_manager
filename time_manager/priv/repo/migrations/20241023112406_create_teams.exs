defmodule TimeManager.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false  # Team name, cannot be null

      timestamps(type: :utc_datetime)
    end

    create unique_index(:teams, [:name])  # Ensure team names are unique
  end
end
