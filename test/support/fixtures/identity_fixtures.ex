defmodule WorldLink.IdentityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WorldLink.Identity` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        id: 1,
        activated: true,
        activated_at: ~U[2023-02-28 09:51:00Z] |> DateTime.truncate(:second),
        approved: true,
        auth_token: "some auth_token",
        auth_token_expires_at: ~U[2023-02-28 09:51:00Z],
        email: "sam@doe.com",
        handle: "some handle",
        name: "some name",
        uuid: "uuid",
        oauth_provider: "google",
        provider_uuid: "provider-uuid",
        password: "somepassword"
      })
      |> WorldLink.Identity.create_user()

    user
  end
end
