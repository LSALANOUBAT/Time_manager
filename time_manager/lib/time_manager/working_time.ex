defmodule TimeManager.Workingtime do
  use Ecto.Schema
  import Ecto.Changeset
  alias TimeManager.Repo
  import Ecto.Query

  @derive {Jason.Encoder, only: [:id, :start, :end, :night_time, :user_id, :hours_worked, :overtime, :overtime_hours, :night_hours]}

  schema "workingtimes" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    field :night_time, :boolean, default: false
    field :hours_worked, :float
    field :overtime, :boolean, default: false
    field :overtime_hours, :float
    field :night_hours, :float

    belongs_to :user, TimeManager.User
    timestamps(type: :utc_datetime)
  end

  def changeset(workingtime, attrs) do
    workingtime
    |> cast(attrs, [:start, :end, :user_id])
    |> validate_required([:start, :user_id])
    |> calculate_hours_worked()
    |> calculate_night_time()
    |> validate_min_gap()
    |> calculate_overtime_hours()
    |> calculate_night_hours()
  end

  # Calculate hours worked and set overtime
  defp calculate_hours_worked(changeset) do
    case {get_field(changeset, :start), get_field(changeset, :end)} do
      {start, end_time} when not is_nil(start) and not is_nil(end_time) ->
        hours = DateTime.diff(end_time, start) / 3600
        changeset = put_change(changeset, :hours_worked, hours)

        if hours > get_user_hours_per_day(changeset) do
          put_change(changeset, :overtime, true)
        else
          put_change(changeset, :overtime, false)
        end

      _ ->
        changeset
        |> put_change(:hours_worked, nil)
        |> put_change(:overtime, false)
    end
  end

  # Set night_time to true if start or end is after 9 PM
  defp calculate_night_time(changeset) do
    case {get_field(changeset, :start), get_field(changeset, :end)} do
      {start, end_time} when not is_nil(start) or not is_nil(end_time) ->
        if time_is_after_nine_pm?(start) or time_is_after_nine_pm?(end_time) do
          put_change(changeset, :night_time, true)
        else
          put_change(changeset, :night_time, false)
        end

      _ ->
        put_change(changeset, :night_time, false)
    end
  end

  # Helper to check if DateTime is after 9 PM
  defp time_is_after_nine_pm?(datetime) do
    case datetime do
      %DateTime{} -> DateTime.to_time(datetime).hour >= 22
      _ -> false
    end
  end

  # Get user's hours per day
  defp get_user_hours_per_day(changeset) do
    user_id = get_field(changeset, :user_id)

    case Repo.get(TimeManager.User, user_id) do
      %TimeManager.User{hours_per_day: hours_per_day} -> hours_per_day
      _ -> 8
    end
  end

  # Validate minimum gap of 16 hours between shifts
  defp validate_min_gap(changeset) do
    user_id = get_field(changeset, :user_id)
    start_time = get_field(changeset, :start)

    if user_id && start_time do
      last_workingtime =
        Repo.one(
          from(w in __MODULE__,
            where: w.user_id == ^user_id,
            order_by: [desc: w.end],
            limit: 1
          )
        )

      if last_workingtime && DateTime.diff(start_time, last_workingtime.end) < 16 * 3600 do
        add_error(changeset, :start, "must be at least 16 hours after the previous shift end")
      else
        changeset
      end
    else
      changeset
    end
  end

  # Calculate overtime hours based on hours worked
  defp calculate_overtime_hours(changeset) do
    hours_worked = get_field(changeset, :hours_worked) || 0
    user_hours_per_day = get_user_hours_per_day(changeset)

    overtime_hours =
      if get_field(changeset, :overtime) do
        hours_worked - user_hours_per_day
      else
        0.0
      end

    put_change(changeset, :overtime_hours, overtime_hours)
  end

  # Calculate night hours based on night_time flag
  defp calculate_night_hours(changeset) do
    case get_field(changeset, :night_time) do
      true ->
        {start, end_time} = {get_field(changeset, :start), get_field(changeset, :end)}

        night_hours =
          cond do
            is_nil(start) or is_nil(end_time) -> 0.0
            time_is_after_nine_pm?(start) && time_is_after_nine_pm?(end_time) ->
              DateTime.diff(end_time, start) / 3600
            time_is_after_nine_pm?(start) ->
              DateTime.diff(DateTime.add(start, 3600 * 22 - DateTime.to_time(start).hour * 3600, :second), start) / 3600
            time_is_after_nine_pm?(end_time) ->
              DateTime.diff(end_time, DateTime.add(end_time, -(DateTime.to_time(end_time).hour - 22) * 3600, :second)) / 3600
            true ->
              0.0
          end

        put_change(changeset, :night_hours, night_hours)

      _ ->
        put_change(changeset, :night_hours, 0.0)
    end
  end
end
