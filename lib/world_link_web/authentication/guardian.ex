defmodule WorldLinkWeb.Authentication.Guardian do
  @moduledoc """
  Implementation module for Guardian
  """
  use Guardian, otp_app: :world_link
  alias WorldLink.User

  @refresh_token_ttl_in_days 30
  @access_token_ttl_in_hours 24

  def subject_for_token(%{id: id}, _claim) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _), do: {:error, :reason_for_error}

  def resource_from_claims(%{"sub" => id}) do
    case User.get_user_by_id(id) do
      %Ecto.NoResultsError{} -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims), do: {:error, :no_subject_provided}

  def verify_access_token(token) do
    decode_and_verify(
      token,
      %{
        typ: "access"
      },
      verify_issuer: true
    )
  end

  def verify_refresh_token(token) do
    decode_and_verify(
      token,
      %{
        typ: "refresh"
      },
      verify_issuer: true
    )
  end

  def create_token(user) do
    {:ok, tokens: %{access: create_access_token(user), refresh: create_refresh_token(user)}}
  end

  defp create_access_token(user) do
    {:ok, access_token, _claims} =
      encode_and_sign(user, %{role: user.role_name},
        ttl: {@access_token_ttl_in_hours, :hour},
        token_type: "access",
        verify_issuer: true,
        auth_time: true
      )

    access_token
  end

  defp create_refresh_token(user) do
    {:ok, refresh_token, _claims} =
      encode_and_sign(user, %{},
        ttl: {@refresh_token_ttl_in_days, :day},
        token_type: "refresh",
        verify_issuer: true,
        auth_time: true
      )

    refresh_token
  end

  def re_authenticate(refresh_token) do
    case(verify_refresh_token(refresh_token)) do
      {:ok, claims} ->
        {:ok, resource} = resource_from_claims(claims)
        create_token(resource)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
