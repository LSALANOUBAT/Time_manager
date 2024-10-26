defmodule TimeManagerWeb.MetricsController do
  use TimeManagerWeb, :controller
  import Ecto.Query
  alias TimeManager.{Repo, Workingtime, TeamMembers}
  alias TimeManagerWeb.Plugs.{Manager, FetchTeamID}
  alias TimeManagerWeb.Auth.Guardian

  plug Manager when action in [:overtime_ratio, :night_ratio, :undertime_ratio, :time_per_over_overtime]
  plug FetchTeamID when action in [:overtime_ratio, :night_ratio, :undertime_ratio, :time_per_over_overtime]

  # Private helper function to calculate overtime hours sum
  defp calculate_overtime_hours_sum(team_id, start_of_month) do
    from(w in Workingtime,
      join: tm in TeamMembers, on: w.user_id == tm.employee_id,
      where: tm.team_id == ^team_id and w.start >= ^start_of_month,
      select: sum(w.overtime_hours)
    )
    |> Repo.one() || 0.0
  end


  defp calculate_night_hours_sum(team_id, start_of_month) do
    from(w in Workingtime,
      join: tm in TeamMembers, on: w.user_id == tm.employee_id,
      where: tm.team_id == ^team_id and w.start >= ^start_of_month,
      select: sum(w.night_hours)
    )
    |> Repo.one() || 0.0
  end

  # Private helper function to calculate total hours sum
  defp calculate_total_hours_sum(team_id, start_of_month) do
    from(w in Workingtime,
      join: tm in TeamMembers, on: w.user_id == tm.employee_id,
      where: tm.team_id == ^team_id and w.start >= ^start_of_month,
      select: sum(w.hours_worked)
    )
    |> Repo.one() || 0.0
  end



  # Public action to calculate and return overtime and total ratios along with the sums
  def overtime_ratio(conn, _params) do
    # Get the team_id from the connection assigns
    team_id = conn.assigns[:team_id]

    if is_nil(team_id) do
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Manager does not have an assigned team"})
    else
      # Get the start of the current month
      start_of_month = Timex.beginning_of_month(Timex.now())

      # Calculate sums using the private helper functions
      overtime_hours_sum = calculate_overtime_hours_sum(team_id, start_of_month)
      total_hours_sum = calculate_total_hours_sum(team_id, start_of_month)

      # Calculate the ratios
      overtime_ratio = if total_hours_sum > 0, do: overtime_hours_sum / total_hours_sum, else: 0.0
      total_ratio = 1 - overtime_ratio
      total_ratio = Float.round(total_ratio, 4)
      overtime_ratio = Float.round(overtime_ratio, 4)

      # Return the sums along with calculated ratios
      conn
      |> put_status(:ok)
      |> json(%{
        overtime_hours_sum: overtime_hours_sum,
        total_hours_sum: total_hours_sum,
        overtime_ratio: overtime_ratio,
        total_ratio: total_ratio
      })
    end
  end


  def night_ratio(conn, _params) do
    # Get the team_id from the connection assigns
    team_id = conn.assigns[:team_id]

    if is_nil(team_id) do
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Manager does not have an assigned team"})
    else
      # Get the start of the current month
      start_of_month = Timex.beginning_of_month(Timex.now())

      # Calculate sums using the private helper functions
      night_hours_sum = calculate_night_hours_sum(team_id, start_of_month)
      total_hours_sum = calculate_total_hours_sum(team_id, start_of_month)

      # Calculate the ratios
      night_ratio = if total_hours_sum > 0, do: night_hours_sum / total_hours_sum, else: 0.0
      total_ratio = 1 - night_ratio
      total_ratio = Float.round(total_ratio, 4)
      night_ratio = Float.round(night_ratio, 4)

      # Return the sums along with calculated ratios
      conn
      |> put_status(:ok)
      |> json(%{
        night_hours_sum: night_hours_sum,
        total_hours_sum: total_hours_sum,
        night_ratio: night_ratio,
        total_ratio: total_ratio
      })
    end
  end

  defp count_undertime_workingtimes(team_id, start_of_month) do
    from(w in Workingtime,
      join: tm in TeamMembers, on: w.user_id == tm.employee_id,
      where: tm.team_id == ^team_id and w.start >= ^start_of_month and w.undertime == true,
      select: count(w.id)
    )
    |> Repo.one() || 0
  end

  # Helper function to count total working times for a team in the current month
  defp count_total_workingtimes(team_id, start_of_month) do
    from(w in Workingtime,
      join: tm in TeamMembers, on: w.user_id == tm.employee_id,
      where: tm.team_id == ^team_id and w.start >= ^start_of_month,
      select: count(w.id)
    )
    |> Repo.one() || 0
  end

  # Public action to return undertime and total working time counts and their ratios
  def undertime_ratio(conn, _params) do
    # Get the team_id from the connection assigns (usually set by a plug)
    team_id = conn.assigns[:team_id]

    if is_nil(team_id) do
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Manager does not have an assigned team"})
    else
      # Define the start of the current month
      start_of_month = Timex.beginning_of_month(Timex.now())

      # Calculate the undertime and total working time counts
      undertime_count = count_undertime_workingtimes(team_id, start_of_month)
      total_count = count_total_workingtimes(team_id, start_of_month)

      # Calculate the undertime and on-time ratios
      undertime_ratio = if total_count > 0, do: undertime_count / total_count, else: 0.0
      on_time_ratio = 1 - undertime_ratio

      # Return the metrics
      conn
      |> put_status(:ok)
      |> json(%{
        undertime_workingtimes: undertime_count,
        total_workingtimes: total_count,
        undertime_ratio: Float.round(undertime_ratio, 4),
        on_time_ratio: Float.round(on_time_ratio, 4)
      })
    end
  end


  def time_per_over_overtime(conn, _params) do
    # Get the team_id from the connection assigns (usually set by a plug like Manager)
    team_id = conn.assigns[:team_id]

    # Validate that a team_id is present
    if is_nil(team_id) do
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Manager does not have an assigned team"})
    else
      # Define the start of the current month
      start_of_month = Timex.beginning_of_month(Timex.now())

      # Query to count working times per day for team members since the beginning of the month
      daily_working_times =
        from(w in Workingtime,
          join: tm in TeamMembers, on: w.user_id == tm.employee_id,
          where: tm.team_id == ^team_id and w.start >= ^start_of_month,
          group_by: fragment("DATE(?)", w.start),
          select: %{date: fragment("DATE(?)", w.start), count: count(w.id)}
        )
        |> Repo.all()

      # Format the result into JSON
      conn
      |> put_status(:ok)
      |> json(%{daily_working_times: daily_working_times})
    end
  end

  def sum_user_overtime_hours(conn, _params) do
    # Extract user_id from the bearer token
    user_id = Guardian.Plug.current_resource(conn).id

    # Get the start of the current month
    start_of_month = Timex.beginning_of_month(Timex.now())

    # Calculate the sum of overtime hours for the user since the beginning of the month
    overtime_hours_sum =
      from(w in Workingtime,
        where: w.user_id == ^user_id and w.start >= ^start_of_month,
        select: sum(w.overtime_hours)
      )
      |> Repo.one() || 0.0

    # Return the result as JSON
    conn
    |> put_status(:ok)
    |> json(%{overtime_hours_sum: overtime_hours_sum})
  end

  def sum_user_night_hours(conn, _params) do
    # Extract user_id from the bearer token
    user_id = Guardian.Plug.current_resource(conn).id

    # Get the start of the current month
    start_of_month = Timex.beginning_of_month(Timex.now())

    # Calculate the sum of night hours for the user since the beginning of the month
    night_hours_sum =
      from(w in Workingtime,
        where: w.user_id == ^user_id and w.start >= ^start_of_month,
        select: sum(w.night_hours)
      )
      |> Repo.one() || 0.0

    # Return the result as JSON
    conn
    |> put_status(:ok)
    |> json(%{night_hours_sum: night_hours_sum})
  end
end
