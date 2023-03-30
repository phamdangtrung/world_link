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
        password: "somepassword",
        username: "some_nickanem"
      }

      invalid_attrs = %{
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword1",
        username: "some_nickanem"
      }

      {:ok, user} = Identity.create_user(valid_attrs)

      assert User.valid_password?(user, valid_attrs.password)
      refute User.valid_password?(user, invalid_attrs.password)
    end
  end
end
