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
        activated: true,
        activated_at: ~U[2023-02-28 09:51:00Z],
        approved: true,
        auth_token: "some auth_token",
        auth_token_expires_at: ~U[2023-02-28 09:51:00Z],
        discord_handle: "some discord_handle",
        email: "some email",
        facebook_handle: "some facebook_handle",
        google_handle: "some google_handle",
        handle: "some handle",
        joined_at: ~U[2023-02-28 09:51:00Z],
        name: "some name",
        signed_in_at: ~U[2023-02-28 09:51:00Z],
        twitter_handle: "some twitter_handle"
      })
      |> WorldLink.Identity.create_user()

    user
  end
end
