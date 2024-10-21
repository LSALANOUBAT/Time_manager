defmodule TimeManager.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :username, :email, :role, :inserted_at, :updated_at]} # Specify fields to encode

  schema "users" do
    field :username, :string
    field :email, :string
    field :hashed_password, :string  # Field for the hashed password
    field :role, :string, default: "employee"  # Role with default value

    # Virtual field for the password (not stored in the database)
    field :password, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  # Changeset for creating a user
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :role])  # Cast virtual password here
    |> validate_required([:username, :email, :password])  # Password is required for user creation
    |> validate_length(:password, min: 6)  # Ensure the password is at least 6 characters long
    |> unique_constraint(:email)  # Ensure the email is unique
    |> put_password_hash()  # Hash the password and store in hashed_password
  end

  # Function to hash the password and store it in hashed_password
  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset  # If no password change, do nothing
      password -> put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
    end
  end
end
