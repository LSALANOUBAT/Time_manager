alias TimeManager.Repo
alias TimeManager.{User, Team, TeamMembers, Workingtime}
import Ecto.Query
import DateTime

# Define user parameters for each role
admin_user_params = %{username: "James_Gordon", email: "gordon@gothampd.com", password: "securepassword", role: "admin"}
manager_user_params = %{username: "Harvey_Bullock", email: "bullock@gothampd.com", password: "detectivework", role: "manager"}
employee1_user_params = %{username: "Renee_Montoya", email: "montoya@gothampd.com", password: "gothamstrong", role: "employee"}
employee2_user_params = %{username: "Crispus_Allen", email: "allen@gothampd.com", password: "justice4gotham", role: "employee"}

# Define team parameters
team_params = %{name: "Gotham Police Department"}

# Helper function to insert users
insert_user = fn params, role ->
  changeset = User.changeset(%User{}, params)
  case Repo.insert(changeset) do
    {:ok, user} -> IO.puts("#{role} #{user.username} created successfully."); user
    {:error, changeset} -> IO.inspect(changeset.errors, label: "Failed to create #{role}"); nil
  end
end

# Create users and store their references
admin_user = insert_user.(admin_user_params, "Admin")
manager_user = insert_user.(manager_user_params, "Manager")
employee1_user = insert_user.(employee1_user_params, "Employee 1")
employee2_user = insert_user.(employee2_user_params, "Employee 2")

# Insert team and assign the manager
team_changeset = Team.changeset(%Team{}, Map.put(team_params, :manager_id, manager_user.id))
gotham_pd_team = Repo.insert!(team_changeset)
IO.puts("Team #{gotham_pd_team.name} created successfully.")

# Add manager and employees to team members
all_team_members = [manager_user, employee1_user, employee2_user]

for member <- all_team_members do
  team_member_changeset = %TeamMembers{team_id: gotham_pd_team.id, employee_id: member.id}
  case Repo.insert(team_member_changeset) do
    {:ok, _team_member} -> IO.puts("#{member.username} assigned to team #{gotham_pd_team.name} successfully.")
    {:error, changeset} -> IO.inspect(changeset.errors, label: "Failed to assign #{member.username} to team")
  end
end

# Define working time generator function for each user over the past month
generate_working_times = fn user_id ->
  start_date = DateTime.utc_now() |> DateTime.add(-30 * 24 * 3600, :second)  # 30 days ago
  Enum.each(0..29, fn day_offset ->
    # Calculate start time for each workday
    start_time = start_date |> DateTime.add(day_offset * 24 * 3600, :second) |> DateTime.add(9 * 3600, :second)
    # Randomly select a duration between 6 to 10 hours (in seconds)
    work_duration = Enum.random(6..10) * 3600
    end_time = DateTime.add(start_time, work_duration, :second)

    # Format start and end times as ISO 8601 strings
    start_iso = DateTime.to_iso8601(start_time)
    end_iso = DateTime.to_iso8601(end_time)

    working_time_changeset = Workingtime.changeset(%Workingtime{}, %{start: start_iso, end: end_iso, user_id: user_id})
    case Repo.insert(working_time_changeset) do
      {:ok, _working_time} -> IO.puts("Working time for user #{user_id} on day #{day_offset} created.")
      {:error, changeset} -> IO.inspect(changeset.errors, label: "Failed to create working time for user #{user_id}")
    end
  end)
end

# Generate working times for the manager and employees
Enum.each([manager_user, employee1_user, employee2_user], fn user ->
  generate_working_times.(user.id)
end)
