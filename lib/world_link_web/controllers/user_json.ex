defmodule WorldLinkWeb.UserJSON do
  alias WorldLink.Identity.User

  @doc """
  Renders a list of urls.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single url.
  """
  def show(%{user: user}) do
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
