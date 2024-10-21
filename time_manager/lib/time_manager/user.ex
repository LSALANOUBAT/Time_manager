defmodule TimeManager.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :username, :email, :role, :inserted_at, :updated_at]} # Specify fields to encode

  schema "users" do
    field :username, :string
    field :email, :string
    field :hashed_password, :string  # Ajoute un champ pour le mot de passe haché
    field :role, :string, default: "employee"  # Ajoute un champ pour le rôle, par défaut "employee"

    timestamps(type: :utc_datetime)
  end

  # Changeset pour la création d'utilisateur
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :hashed_password, :role])
    |> validate_required([:username, :email, :hashed_password])  # Le mot de passe est requis
    |> unique_constraint(:email)  # Assure que l'email est unique
  end

  # Fonction pour hacher le mot de passe
  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :hashed_password, Bcrypt.hashpwsalt(password))
    end
  end
end
