defmodule WorldLink.UserTest do
  use WorldLink.DataCase

  alias Support.Factories.IdentityFactory

  describe "User context" do
    alias WorldLink.Identity.User

    test "list_user/1 returns a list of users" do
      for _ <- 1..20 do
        IdentityFactory.build(:user) 
        |> IdentityFactory.insert()
      end

      user_count_10 = WorldLink.User.list_users(%{page_size: 10})
      |> Enum.count()

      user_count_20 = WorldLink.User.list_users()
      |> Enum.count()

      assert user_count_10 == 10
      assert user_count_20 == 20
    end

    test "get_user_by_id/1 returns either a valid user or :nil" do
      user_attrs = %{
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword",
        username: "username"
      }

      user = 
        IdentityFactory.build(:user, user_attrs) 
        |> IdentityFactory.insert()

      user = WorldLink.User.get_user_by_id(user.id)
      error = WorldLink.User.get_user_by_id(Ecto.ULID.generate())

      assert %User{} = user
      assert error == nil
    end

    test "get_user_by_email/1 returns either a valid user or :nil" do
      user_attrs = %{
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword",
        username: "username"
      }

      IdentityFactory.build(:user, user_attrs) 
      |> IdentityFactory.insert()

      user = WorldLink.User.get_user_by_email("sam@doe.com")
      error = WorldLink.User.get_user_by_email("test@test.com")

      assert %User{} = user
      assert error == nil
    end
  end
end