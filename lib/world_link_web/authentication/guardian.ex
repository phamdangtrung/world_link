defmodule WorldLinkWeb.Authentication.Guardian do
  use Guardian, otp_app: :world_link
  alias WorldLink.Identity

  def subject_for_token(%{id: id}, _claim) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _), do: {:error, :reason_for_error}

  # def build_claims(claims, _, _) do
  #   {:ok, claims} = build_claims(%{role: "admin"}, nil, nil)
  #   {:ok, claims}
  # end

  def resource_from_claims(%{"sub" => id}) do
    case Identity.get_user!(id) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims), do: {:error, :no_subject_provided}

  def authenticate(email, password) do
    case Identity.get_user_by_email(email) do
      nil -> {:error, :not_found}
      user ->
        Identity.verify_password(user, password)
        |> case do
          true -> create_token(user)
          false -> {:error, :unauthorized}
        end
    end
  end

  defp create_token(user) do
    {:ok, token, _claims} = encode_and_sign(user)
    {:ok, user, token}
  end
end
