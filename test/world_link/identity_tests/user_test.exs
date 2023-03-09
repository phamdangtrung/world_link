defmodule WorldLink.IdentityTests.UserTest do
  use WorldLink.DataCase

  alias WorldLink.Identity.User

  @tag :unit
  describe "users" do
    alias WorldLink.Identity

    test "valid_password?/2 returns true or false according to password" do
      valid_attrs = %{
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword"
      }
      invalid_attrs = %{
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword1"
      }
      {:ok, user} = Identity.create_user(valid_attrs)

      assert User.valid_password?(user, valid_attrs.password)
      refute User.valid_password?(user, invalid_attrs.password)
    end
  end
end
