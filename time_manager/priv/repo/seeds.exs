alias TimeManager.Repo
alias TimeManager.{User, Team, TeamMembers, Workingtime}

admin_user_params = %{
  username: "James_Gordon",
  email: "gordon@gothampd.com",
  password: "securepassword",
  role: "admin",
}

manager_user_params = %{
  username: "Harvey_Bullock",
  email: "bullock@gothampd.com",
  password: "detectivework",
  role: "manager",
}

employee1_user_params = %{
  username: "Renee_Montoya",
  email: "montoya@gothampd.com",
  password: "gothamstrong",
  role: "employee",
}

employee2_user_params = %{
  username: "Crispus_Allen",
  email: "allen@gothampd.com",
  password: "justice4gotham",
  role: "employee",
}

# Define team parameters
team_params = %{
  name: "Gotham Police Department"
}

# Helper functions to insert users and teams
insert_user = fn params, role ->
  changeset = User.changeset(%User{}, params)
  case Repo.insert(changeset) do
    {:ok, user} ->
      IO.puts("#{role} #{user.username} created successfully.")
      user
    {:error, changeset} ->
      IO.inspect(changeset.errors, label: "Failed to create #{role}")
      nil
  end
end

admin_user = insert_user.(admin_user_params, "Admin")
manager_user = insert_user.(manager_user_params, "Manager")
employee1_user = insert_user.(employee1_user_params, "Employee 1")
employee2_user = insert_user.(employee2_user_params, "Employee 2")

# Insert team and assign the manager
team_changeset = Team.changeset(%Team{}, Map.put(team_params, :manager_id, manager_user.id))
gotham_pd_team = Repo.insert!(team_changeset)
IO.puts("Team #{gotham_pd_team.name} created successfully.")

# Add the manager and employees to team members
all_team_members = [manager_user, employee1_user, employee2_user]

for member <- all_team_members do
  team_member_changeset = %TeamMembers{team_id: gotham_pd_team.id, employee_id: member.id}
  case Repo.insert(team_member_changeset) do
    {:ok, _team_member} ->
      IO.puts("#{member.username} assigned to team #{gotham_pd_team.name} successfully.")
    {:error, changeset} ->
      IO.inspect(changeset.errors, label: "Failed to assign #{member.username} to team")
  end
end

# Define working times
working_times_params = [
  %{start: ~U[2023-10-01 14:00:00Z], end: ~U[2023-10-01 23:00:00Z], user_id: employee1_user.id},
  %{start: ~U[2023-10-02 09:00:00Z], end: ~U[2023-10-02 17:00:00Z], user_id: employee2_user.id}
]

# Helper function to insert working times
insert_working_time = fn params, label ->
  changeset = Workingtime.changeset(%Workingtime{}, params)
  case Repo.insert(changeset) do
    {:ok, _working_time} ->
      IO.puts("Working time for #{label} created successfully.")
    {:error, changeset} ->
      IO.inspect(changeset.errors, label: "Failed to create working time for #{label}")
  end
end

Enum.each(working_times_params, fn params ->
  user = Enum.find([employee1_user, employee2_user], fn user -> user.id == params.user_id end)
  insert_working_time.(params, user.username)
end)
