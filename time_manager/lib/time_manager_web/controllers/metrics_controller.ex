defmodule TimeManagerWeb.MetricsController do
  use TimeManagerWeb, :controller
  import Ecto.Query
  alias TimeManager.{Repo, Workingtime, TeamMembers}
  alias TimeManagerWeb.Plugs.{Manager, FetchTeamID}

  plug Manager when action in [:overtime_ratio, :night_ratio]
  plug FetchTeamID when action in [:overtime_ratio, :night_ratio]

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
end
