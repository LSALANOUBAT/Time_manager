alias TimeManager.Repo
alias TimeManager.{User, Team, Workingtime}

# Define user parameters
admin_user_params = %{
  username: "admin_user",
  email: "admin@example.com",
  password: "securepassword",
  role: "admin",
  team_id: nil  # No team assigned
}

manager_user_params = %{
  username: "manager_user",
  email: "manager@example.com",
  password: "securepassword",
  role: "manager",
  team_id: nil
}

employee_user_params = %{
  username: "employee_user",
  email: "employee@example.com",
  password: "securepassword",
  role: "employee",
  team_id: nil
}

# Define team parameters
team_params = %{
  name: "Engineering"
}

# Define working time parameters
working_times_params_full = %{
  start: ~U[2023-10-01 09:00:00Z],
  end: ~U[2023-10-01 17:00:00Z],
  night_time: false
}

working_times_params_less = %{
  start: ~U[2023-10-02 10:00:00Z],
  end: ~U[2023-10-02 17:00:00Z],
  night_time: false
}

# Anonymous function to insert a user
insert_user = fn params, user_role ->
  changeset = User.changeset(%User{}, params)

  case Repo.insert(changeset) do
    {:ok, user} ->
      IO.puts("#{user_role} created successfully.")
      user
    {:error, changeset} ->
      IO.inspect(changeset.errors, label: "Failed to create #{user_role}")
      nil
  end
end

# Anonymous function to insert a team with manager and employee
insert_team = fn params, manager, employee ->
  # Include both manager_id and employee_id in the team params
  updated_params =
    params
    |> Map.put(:manager_id, manager.id)
    |> Map.put(:employee_id, employee.id)

  changeset = Team.changeset(%Team{}, updated_params)

  case Repo.insert(changeset) do
    {:ok, team} ->
      IO.puts("Team #{params[:name]} created successfully.")
      # Update employee to associate with the team
      employee
      |> Ecto.Changeset.change(team_id: team.id)
      |> Repo.update!()
      IO.puts("Employee assigned to team successfully.")
      team
    {:error, changeset} ->
      IO.inspect(changeset.errors, label: "Failed to create team")
      nil
  end
end

# Anonymous function to insert working times
insert_working_time = fn params, user, label ->
  changeset = Workingtime.changeset(%Workingtime{}, Map.put(params, :user_id, user.id))

  case Repo.insert(changeset) do
    {:ok, _working_time} ->
      IO.puts("#{label} created successfully.")
    {:error, changeset} ->
      IO.inspect(changeset.errors, label: "Failed to create #{label}")
  end
end

# Insert users
admin_user = insert_user.(admin_user_params, "Admin user")
manager_user = insert_user.(manager_user_params, "Manager user")
employee_user = insert_user.(employee_user_params, "Employee user")

engineering_team = insert_team.(team_params, manager_user, employee_user)

# Update manager and employee to associate with the Engineering team
if engineering_team do
  # Assign the Engineering team to both manager and employee
  [manager_user, employee_user]
  |> Enum.each(fn user ->
    user
    |> Ecto.Changeset.change(team_id: engineering_team.id)
    |> Repo.update!()
  end)

  IO.puts("Manager and Employee assigned to Engineering team successfully.")
end
# Insert working times for the employee
insert_working_time.(working_times_params_full, employee_user, "Working Time Full")
insert_working_time.(working_times_params_less, employee_user, "Working Time Less")
