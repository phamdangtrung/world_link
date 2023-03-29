defmodule WorldLink.IdentityTest do
  use WorldLink.DataCase

  alias WorldLink.Identity

  @tag :integration
  describe "users" do
    alias WorldLink.Identity.User

    import WorldLink.IdentityFixtures

    @invalid_attrs %{
      activated: nil,
      activated_at: nil,
      email: "some email",
      name: nil,
      password: nil
    }

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword",
        username: "username"
      }

      assert {:ok, %User{} = user} = Identity.create_user(valid_attrs)
      assert user.email == "sam@doe.com"
      assert user.name == "some name"
      assert user.username == "username"
      assert user.id
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_user(@invalid_attrs)
    end
  end

  describe "oauth_profiles" do
    alias WorldLink.Identity.OauthProfile

    import WorldLink.IdentityFixtures

    @invalid_attrs %{oauth_provider: nil}
  end
end
