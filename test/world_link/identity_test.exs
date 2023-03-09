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

    # test "list_users/0 returns all users" do
    #   user = user_fixture()
    #   assert Identity.list_users() == [user]
    # end

    # test "get_user!/1 returns the user with given id" do
    #   user = user_fixture()
    #   assert Identity.get_user!(user.id) == user
    # end

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

    # test "update_user/2 with valid data updates the user" do
    #   user = user_fixture()

    #   update_attrs = %{
    #     activated: false,
    #     activated_at: ~U[2023-03-01 09:51:00Z],
    #     approved: false,
    #     auth_token: "some updated auth_token",
    #     auth_token_expires_at: ~U[2023-03-01 09:51:00Z],
    #     discord_handle: "some updated discord_handle",
    #     email: "some updated email",
    #     facebook_handle: "some updated facebook_handle",
    #     google_handle: "some updated google_handle",
    #     handle: "some updated handle",
    #     joined_at: ~U[2023-03-01 09:51:00Z],
    #     name: "some updated name",
    #     signed_in_at: ~U[2023-03-01 09:51:00Z],
    #     twitter_handle: "some updated twitter_handle"
    #   }

    #   assert {:ok, %User{} = user} = Identity.update_user(user, update_attrs)
    #   assert user.activated == false
    #   assert user.activated_at == ~U[2023-03-01 09:51:00Z]
    #   assert user.approved == false
    #   assert user.auth_token == "some updated auth_token"
    #   assert user.auth_token_expires_at == ~U[2023-03-01 09:51:00Z]
    #   assert user.discord_handle == "some updated discord_handle"
    #   assert user.email == "some updated email"
    #   assert user.facebook_handle == "some updated facebook_handle"
    #   assert user.google_handle == "some updated google_handle"
    #   assert user.handle == "some updated handle"
    #   assert user.joined_at == ~U[2023-03-01 09:51:00Z]
    #   assert user.name == "some updated name"
    #   assert user.signed_in_at == ~U[2023-03-01 09:51:00Z]
    #   assert user.twitter_handle == "some updated twitter_handle"
    # end

    # test "update_user/2 with invalid data returns error changeset" do
    #   user = user_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Identity.update_user(user, @invalid_attrs)
    #   assert user == Identity.get_user!(user.id)
    # end

    # test "delete_user/1 deletes the user" do
    #   user = user_fixture()
    #   assert {:ok, %User{}} = Identity.delete_user(user)
    #   assert_raise Ecto.NoResultsError, fn -> Identity.get_user!(user.id) end
    # end

    # test "change_user/1 returns a user changeset" do
    #   user = user_fixture()
    #   assert %Ecto.Changeset{} = Identity.change_user(user)
    # end
  end
end
