defmodule TimeManager.Repo.Migrations.AddHoursPerWeek do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hours_per_day, :float, default: 8.0
    end
  end
end
