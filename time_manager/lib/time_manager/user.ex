defmodule TimeManager.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :username, :email, :role, :inserted_at, :updated_at]}
  @roles ~w(employee manager admin)

  schema "users" do
    field :username, :string
    field :email, :string
    field :hashed_password, :string
    field :role, :string, default: "employee"
    field :hours_per_day, :float, default: 8.0
    field :password, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  # Changeset for user creation (requires password)
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :role])
    |> validate_required([:username, :email, :password])
    |> validate_length(:password, min: 6)
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  # Changeset for user updates (password is optional)
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :role])
    |> validate_required([:username, :email, :role])
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(:email)
    |> maybe_put_password_hash(attrs)
  end

  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
    |> put_password_hash()
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
