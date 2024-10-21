defmodule TimeManagerWeb.Auth.Guardian do
  use Guardian, otp_app: :time_manager

  alias TimeManager.Accounts

  # Cette fonction renvoie le sujet du token (souvent l'ID de l'utilisateur)
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  # Cette fonction vérifie si l'utilisateur existe à partir de l'ID extrait du token
  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user!(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
