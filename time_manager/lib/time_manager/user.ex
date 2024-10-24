defmodule TimeManager.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :username, :email, :role, :team_id, :inserted_at, :updated_at]}
  @roles ~w(employee manager admin)

  schema "users" do
    field :username, :string
    field :email, :string
    field :hashed_password, :string
    field :role, :string, default: "employee"
    field :password, :string, virtual: true

    belongs_to :team, TimeManager.Team, foreign_key: :team_id  # Team association

    timestamps(type: :utc_datetime)
  end

  # Changeset for user creation (requires password)
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :role, :team_id])
    |> validate_required([:username, :email, :password])
    |> validate_length(:password, min: 6)
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(:email)
    |> assoc_constraint(:team)
    |> put_password_hash()
  end

  # Changeset for user updates (password is optional)
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :role, :team_id])
    |> validate_required([:username, :email, :role])  # Password is not required here
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(:email)
    |> assoc_constraint(:team)
    |> maybe_put_password_hash(attrs)
  end

  # Function to hash the password if provided in updates
  defp maybe_put_password_hash(changeset, %{"password" => password}) when password != "" do
    changeset
    |> validate_length(:password, min: 6)
    |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
  end

  defp maybe_put_password_hash(changeset, _attrs) do
    changeset
  end

  # Function to hash the password during creation
  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
    end
  end
end
