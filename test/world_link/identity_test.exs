defmodule WorldLink.IdentityTest do
  use WorldLink.DataCase

  alias WorldLink.Identity

  @tags [:unit, :user]

  describe "Identity functions for %User{}" do
    alias WorldLink.Identity.User

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
      invalid_attrs = %{
        activated: nil,
        activated_at: nil,
        name: 123,
        password: 123
      }

      assert {:error, %Ecto.Changeset{}} = Identity.create_user(invalid_attrs)
    end

    test "list_users/1" do
      expected =
        WorldLink.Repo.all(
          from users in User,
            select: [:id, :name, :activated, :username, :email],
            limit: 3,
            offset: 0
        )

      assert expected == Identity.list_users(%{page_size: 3, page: 1})
    end

    test "create_oauth_user/1 returns a valid user" do
      attrs = %{
        provider_uid: "some-uid",
        oauth_provider: :google,
        name: "Name Full",
        username: "samdoe",
        email: "sam@doe.com",
        avatar: nil
      }
      assert {:ok, %User{}} = Identity.create_oauth_user(attrs)
    end

    test "create_oauth_user/1 returns an error tuple" do
      attrs = %{
        provider_uid: "some-uid",
        oauth_provider: :google,
        name: "Name Full",
        username: "samdoe",
        email: "sam@doe.com",
        avatar: nil
      }

      Identity.create_oauth_user(attrs)

      oauth_attrs = %{
        provider_uid: "some-uid",
        oauth_provider: :google,
        name: "Name Full",
        username: "sam2doe",
        email: "sam2@doe.com",
        avatar: nil
      }

      assert {:error, :user, %Ecto.Changeset{}}  = Identity.create_oauth_user(attrs)
      assert {:error, :oauth_profile, %Ecto.Changeset{}}  = Identity.create_oauth_user(oauth_attrs)
    end
  end

  describe "Identity functions for %OauthProfile{}" do
    alias WorldLink.Identity.{User, OauthProfile}

    test "assign_oauth_profile/2 should return {:ok, %OauthProfile{}} with valid data" do
      valid_user_attrs = %{
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword",
        username: "username"
      }

      {:ok, %User{} = user} = Identity.create_user(valid_user_attrs)

      valid_oauth_attrs = %{
        oauth_provider: :discord,
        provider_uid: "some-uid-from-discord"
      }

      assert {:ok, %OauthProfile{}} = Identity.assign_oauth_profile(user, valid_oauth_attrs)
    end

    test "verify_user_existence/1 should return {:ok}" do
      attrs = %{
        email: "sam2@doe.com",
        provider_uid: "some-uid",
        oauth_provider: :google
      }

      assert {:ok} = Identity.verify_user_existence(attrs)
    end

    test "verify_user_existence/1 should return {:error, :user_already_exists, %User{}}" do
      attrs = %{
        email: "sam@doe.com",
        provider_uid: "some-uid",
        oauth_provider: :google
      }

      valid_user_attrs = %{
        email: "sam@doe.com",
        name: "some name",
        password: "somepassword",
        username: "username"
      } |> Identity.create_user()

      assert {:error, :user_already_exists, %User{}} = Identity.verify_user_existence(attrs)
    end
  end
end
