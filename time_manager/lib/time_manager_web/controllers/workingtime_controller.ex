defmodule TimeManagerWeb.WorkingtimeController do
  use TimeManagerWeb, :controller
  alias TimeManager.Repo
  alias TimeManager.Workingtime
  import Ecto.Query

  # Fetch working times for a user, with optional start and end time filters
  def index(conn, %{"userID" => user_id} = params) do
  end
end
