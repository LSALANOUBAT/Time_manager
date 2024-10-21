defmodule TimeManager.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :hashed_password, :string, null: false  # Ajoute le champ pour le mot de passe haché
      add :role, :string, default: "employee", null: false  # Ajoute un rôle avec une valeur par défaut "employee"

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
