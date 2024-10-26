defmodule TimeManager.Repo.Migrations.CreateWorkingtimes do
  use Ecto.Migration

  def change do
    create table(:workingtimes) do
      add :start, :utc_datetime, null: false
      add :end, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all)
      add :hours_worked, :float
      add :overtime, :boolean, default: false
      add :night_time, :boolean, default: false
      add :overtime_hours, :float
      add :night_hours, :float
      add :undertime, :boolean, default: false
      timestamps(type: :utc_datetime)

    end

    create index(:workingtimes, [:user_id])
  end
end
