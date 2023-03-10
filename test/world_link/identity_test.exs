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
      auth_token: nil,
      auth_token_expires_at: nil,
      email: "some email",
      handle: nil,
      name: nil,
      provider_uid: nil,
      uuid: nil,
      password: nil,
      oauth_provider: nil
    }

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword"
      }

      assert {:ok, %User{} = user} = Identity.create_user(valid_attrs)
      assert user.email == "sam@doe.com"
      assert user.name == "some name"
      assert user.uuid
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_user(@invalid_attrs)
    end
  end
end
