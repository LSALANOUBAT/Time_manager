defmodule TimeManagerWeb.WorkingtimeController do
  use TimeManagerWeb, :controller
  alias TimeManager.Repo  
  alias TimeManager.Accounts
  alias TimeManager.Workingtime
  import Ecto.Query

  def index(conn, %{"userID" => user_id, "start" => start_time, "end" => end_time}) do
    {:ok, start_time} = DateTime.from_iso8601(start_time)
    {:ok, end_time} = DateTime.from_iso8601(end_time)
    
    workingtimes = Accounts.list_workingtimes(user_id, start_time, end_time)
    json(conn, workingtimes)
  end

  def show(conn, %{"userID" => user_id, "id" => id}) do
    workingtime = Accounts.get_workingtime!(user_id, id)
    json(conn, workingtime)
  end

  def create(conn, %{"userID" => user_id, "workingtime" => workingtime_params}) do
    changeset_params = Map.put(workingtime_params, "user_id", user_id)
    
    case Accounts.create_workingtime(changeset_params) do
      {:ok, workingtime} ->
        workingtime = Repo.preload(workingtime, :user)
        conn
        |> put_status(:created)
        |> json(%{
            id: workingtime.id,
            start: workingtime.start,
            end: workingtime.end,
            user_id: workingtime.user_id,
            inserted_at: workingtime.inserted_at,
            updated_at: workingtime.updated_at
        })

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  def update(conn, %{"id" => id, "workingtime" => workingtime_params}) do
    workingtime = Accounts.get_workingtime!(id)

    case Accounts.update_workingtime(workingtime, workingtime_params) do
      {:ok, workingtime} ->
        conn
        |> put_status(:ok)
        |> json(%{
          id: workingtime.id,
          start: workingtime.start,
          end: workingtime.end,
          user_id: workingtime.user_id,
          inserted_at: workingtime.inserted_at,
          updated_at: workingtime.updated_at
        })

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end

  def delete(conn, %{"id" => id}) do
    workingtime = Accounts.get_workingtime!(id)

    case Accounts.delete_workingtime(workingtime) do
      {:ok, _} -> 
        send_resp(conn, :ok, "Working time deleted successfully")
      
      {:error, _reason} -> 
        send_resp(conn, :internal_server_error, "Error deleting working time")
    end
  end
end
