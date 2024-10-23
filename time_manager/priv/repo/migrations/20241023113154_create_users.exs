defmodule TimeManager.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :role, :string, default: "employee", null: false  # Role with default "employee"

      timestamps(type: :utc_datetime)  # Automatically adds inserted_at and updated_at
    end

    create unique_index(:users, [:email])  # Ensure email is unique
  end
end
