defmodule TimeManagerWeb.AuthController do
  use TimeManagerWeb, :controller

  alias TimeManager.Accounts
  alias TimeManagerWeb.Auth.Guardian

  def sign_in(conn, %{"email" => email, "password" => password}) do
  end
end
