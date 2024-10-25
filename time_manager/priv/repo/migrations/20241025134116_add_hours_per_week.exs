defmodule TimeManager.Repo.Migrations.AddHoursPerWeek do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hours_per_day, :integer, default: 8
    end
  end
end
