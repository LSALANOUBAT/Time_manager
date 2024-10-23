# priv/repo/seeds.exs
alias TimeManager.Repo
alias TimeManager.User

# Create an admin user with no team
admin_user_params = %{
  username: "admin_user",
  email: "admin@example.com",
  password: "securepassword",  # Ensure this is at least 6 characters
  role: "admin",
  team_id: nil  # No team assigned
}

# Create and insert the user
admin_user_changeset = User.changeset(%User{}, admin_user_params)

case Repo.insert(admin_user_changeset) do
  {:ok, _user} ->
    IO.puts("Admin user created successfully.")
  {:error, changeset} ->
    IO.inspect(changeset.errors, label: "Failed to create admin user")
end
