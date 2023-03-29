defmodule WorldLink.IdentityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WorldLink.Identity` context.
  """
  alias WorldLink.Identity

  @doc """
  Generate a user.
  """
  def user_with_google_oauth_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        id: 1,
        activated: true,
        activated_at: ~U[2023-02-28 09:51:00Z] |> DateTime.truncate(:second),
        approved: true,
        email: "sam@doe.com",
        username: "samdoe",
        name: "some name",
        password: "somepassword"
      })
      |> Identity.create_user()

    oauth_attrs = %{
      oauth_provider: :google,
      provider_uid: "some-uuid-from-provider"
    }

    {:ok, complete_user} =
      user
      |> Identity.assign_oauth_profile(oauth_attrs)

    {:ok, complete_user}
  end
end
