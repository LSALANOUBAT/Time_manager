defmodule TimeManagerWeb.Plugs.FetchTeamID do
  import Plug.Conn
  alias TimeManager.{Repo, TeamMembers}
  alias TimeManagerWeb.Auth.Guardian

  def init(_opts), do: nil

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      %TimeManager.User{id: user_id} ->
        # Get team_id from TeamMembers table
        case Repo.get_by(TeamMembers, employee_id: user_id) do
          %TeamMembers{team_id: team_id} ->
            assign(conn, :team_id, team_id)

          nil ->
            assign(conn, :team_id, nil) # No team assigned
        end

      _ ->
        conn
    end
  end
end
