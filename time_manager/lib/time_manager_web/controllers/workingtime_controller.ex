defmodule TimeManagerWeb.WorkingtimeController do
  use TimeManagerWeb, :controller
  alias TimeManager.Repo
  alias TimeManager.Workingtime
  import Ecto.Query

  # Fetch working times for a user, with optional start and end time filters
  def index(conn, %{"userID" => user_id} = params) do
    # Handle optional start and end parameters
    start_time = Map.get(params, "start")
    end_time = Map.get(params, "end")

    # Build the query for working times
    query =
      from wt in Workingtime,
           where: wt.user_id == ^user_id,
           order_by: [asc: wt.start]

    # Filter by start and end time if provided
    query =
      if start_time && end_time do
        with {:ok, start_dt} <- DateTime.from_iso8601(start_time),
             {:ok, end_dt} <- DateTime.from_iso8601(end_time) do
          from wt in query,
               where: wt.start >= ^start_dt and wt.end <= ^end_dt
        else
          _ -> query
        end
      else
        query
      end

    # Fetch the working times from the database
    workingtimes = Repo.all(query)
    json(conn, workingtimes)
  end

  # Fetch a specific working time entry
  def show(conn, %{"userID" => user_id, "id" => id}) do
    case Repo.get_by(Workingtime, user_id: user_id, id: id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found"})

      workingtime ->
        json(conn, workingtime)
    end
  end

  # Create a new working time for a user
  def create(conn, %{"userID" => user_id, "workingtime" => workingtime_params}) do
    changeset_params = Map.put(workingtime_params, "user_id", user_id)

    case Workingtime.changeset(%Workingtime{}, changeset_params) |> Repo.insert() do
      {:ok, workingtime} ->
        conn
        |> put_status(:created)
        |> json(workingtime)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end

  # Update an existing working time
  def update(conn, %{"id" => id, "workingtime" => workingtime_params}) do
    case Repo.get(Workingtime, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found"})

      workingtime ->
        case Workingtime.changeset(workingtime, workingtime_params) |> Repo.update() do
          {:ok, updated_workingtime} ->
            json(conn, updated_workingtime)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
        end
    end
  end

  # Delete a working time entry
  def delete(conn, %{"id" => id}) do
    case Repo.get(Workingtime, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Working time not found"})

      workingtime ->
        case Repo.delete(workingtime) do
          {:ok, _} ->
            send_resp(conn, :ok, "Working time deleted successfully")

          {:error, _reason} ->
            send_resp(conn, :internal_server_error, "Error deleting working time")
        end
    end
  end

  # Helper function to translate changeset errors
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
