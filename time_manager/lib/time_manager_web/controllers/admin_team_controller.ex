defmodule TimeManagerWeb.AdminTeamController do
  use TimeManagerWeb, :controller
  alias TimeManager.{Team, User, Repo}

  plug TimeManagerWeb.Plugs.Admin  # Ensure only admins can access these actions

  # List all teams
  def index(conn, _params) do
    teams = Repo.all(Team)
    render(conn, "index.json", teams: teams)
  end

  # Create a new team
  def create(conn, %{"team" => team_params}) do
    changeset = Team.changeset(%Team{}, team_params)

    case Repo.insert(changeset) do
      {:ok, team} ->
        conn
        |> put_status(:created)
        |> render("show.json", team: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TimeManagerWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  # Update an existing team
  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Repo.get!(Team, id)
    changeset = Team.changeset(team, team_params)

    case Repo.update(changeset) do
      {:ok, team} ->
        render(conn, "show.json", team: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TimeManagerWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  # Delete a team
  def delete(conn, %{"id" => id}) do
    team = Repo.get!(Team, id)

    with {:ok, %Team{}} <- Repo.delete(team) do
      send_resp(conn, :no_content, "")
    end
  end

  def assign_manager(conn, %{"team_id" => team_id, "id" => manager_id}) do
    team = Repo.get!(Team, team_id)
    manager = Repo.get!(User, manager_id)

    if manager.role == "manager" do
      changeset = Team.changeset(team, %{manager_id: manager_id})

      case Repo.update(changeset) do
        {:ok, team} ->
          render(conn, "show.json", team: team)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(TimeManagerWeb.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{error: "User is not a manager"})
    end
  end

  def add_user(conn, %{"team_id" => team_id, "id" => user_id}) do
    team = Repo.get!(Team, team_id)
    user = Repo.get!(User, user_id)

    changeset = User.changeset(user, %{team_id: team_id})

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(TimeManagerWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
