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
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword"
      })
      # |> WorldLink.Identity.create_user()

    user
  end

  @doc """
  Generate a oauth_profile.
  """
  # def oauth_profile_fixture(attrs \\ %{}) do
  #   {:ok, oauth_profile} =
  #     attrs
  #     |> Enum.into(%{
  #       oauth_provider: "some oauth_provider"
  #     })
  #     |> WorldLink.Identity.create_oauth_profile()

  #   oauth_profile
  # end
end
