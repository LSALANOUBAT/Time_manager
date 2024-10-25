alias TimeManager.Repo
alias TimeManager.User

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

# Function to insert user and handle success or error
def insert_user(params, user_role) do
  changeset = User.changeset(%User{}, params)

  case Repo.insert(changeset) do
    {:ok, _user} ->
      IO.puts("#{user_role} created successfully.")
    {:error, changeset} ->
      IO.inspect(changeset.errors, label: "Failed to create #{user_role}")
  end
end

# Insert each user with appropriate role labels
insert_user(admin_user_params, "Admin user")
insert_user(manager_user_params, "Manager user")
insert_user(employee_user_params, "Employee user")
