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

    belongs_to :team, TimeManager.Team, foreign_key: :team_id  # Remove :on_delete from here

    timestamps(type: :utc_datetime)
  end

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

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
    end
  end
end
