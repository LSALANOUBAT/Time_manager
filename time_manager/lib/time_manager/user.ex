defmodule TimeManager.User do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, only: [:id, :username, :email, :inserted_at, :updated_at]} # Specify fields to encode

  schema "users" do
    field :username, :string
    field :email, :string
    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
  end
end
