defmodule TimeManagerWeb.ClockController do
  use TimeManagerWeb, :controller
  alias TimeManager.Accounts
  alias TimeManager.Repo


  def index(conn, %{"user_id" => user_id}) do
    clocks = Accounts.list_clocks(user_id) |> Repo.preload(:user)
    
    result = Enum.map(clocks, fn clock ->
      %{
        id: clock.id,
        time: clock.time,
        status: clock.status,
        user_id: clock.user_id,
        inserted_at: clock.inserted_at,
        updated_at: clock.updated_at
      }
    end)
    
    json(conn, result)
  end

  def create(conn, %{"user_id" => user_id, "clock" => clock_params}) do
    changeset = Map.put(clock_params, "user_id", user_id)
    
    case Accounts.create_clock(changeset) do
      {:ok, clock} ->
        # Preload and encode manually
        clock = Repo.preload(clock, :user)
        conn
        |> put_status(:created)
        |> json(%{
            id: clock.id,
            time: clock.time,
            status: clock.status,
            user_id: clock.user_id,
            user: %{
              id: clock.user.id,
              username: clock.user.username,
              email: clock.user.email
            },
            inserted_at: clock.inserted_at,
            updated_at: clock.updated_at
        })
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(changeset)
    end
  end
end
