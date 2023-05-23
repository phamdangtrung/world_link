defmodule WorldLinkWeb.AuthJSON do
  alias WorldLink.Identity.User

  @doc """
  Renders a pair of jwt token after user successfully authenticates.
  """
  def token(%{tokens: jwt_tokens}) do
    %{data: %{access: jwt_tokens.access, refresh: jwt_tokens.refresh}}
  end

  @doc """
  Renders user.
  """
  def user(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      username: user.normalized_username,
      email: user.normalized_email,
      activated: user.activated,
      activated_at: user.activated_at,
      role_name: user.role_name
    }
  end
end
