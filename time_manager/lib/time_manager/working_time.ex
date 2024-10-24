defmodule TimeManager.Workingtime do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :start, :end, :night_time, :user_id]}  # Ajout de 'night_time'

  schema "workingtimes" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    field :night_time, :boolean, default: false  # Ajout du champ 'night_time'
    belongs_to :user, TimeManager.User
    timestamps(type: :utc_datetime)

  end

  def changeset(workingtime, attrs) do
    workingtime
    |> cast(attrs, [:start, :end, :night_time, :user_id])  # Ajout de 'night_time'
    |> validate_required([:start, :end, :user_id])
  end
end
