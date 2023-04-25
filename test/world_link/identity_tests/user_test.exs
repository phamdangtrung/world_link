defmodule WorldLink.IdentityTests.UserTest do
  use WorldLink.DataCase
  alias WorldLink.Identity.OauthProfile
  alias Support.Factories.IdentityFactory

  alias WorldLink.Identity.User

  @tag :unit

  setup_all do
    {
      :ok,
      %{
        user_valid_attributes: IdentityFactory.build(:user_params),
        user_invalid_attributes:
          IdentityFactory.build(:user_params, %{excluded_fields: [:name, :email]})
      }
    }
  end

  describe "registration_changeset/2" do
    test "should validate all the attributes", %{
      user_valid_attributes: user_valid_attributes,
      user_invalid_attributes: user_invalid_attributes
    } do
      valid_changeset = User.registration_changeset(%User{}, user_valid_attributes)
      invalid_changeset = User.registration_changeset(%User{}, user_invalid_attributes)

      assert valid_changeset.valid? == true
      refute invalid_changeset.valid? == true
    end

    test "should validate the conflict email" do
      registered_user = IdentityFactory.build(:user) |> IdentityFactory.insert()
      conflict_user_params = IdentityFactory.build(:user_params, %{email: registered_user.email})
      changeset = User.registration_changeset(%User{}, conflict_user_params)

      assert conflict_user_params.email == changeset.changes.email
      refute changeset.valid? == true
    end
  end

  describe "oauth_registration_changeset/2" do
    test "should validate all the attributes" do
      registered_user = IdentityFactory.build(:user) |> IdentityFactory.insert()
      oauth = IdentityFactory.build(:oauth, %{user: registered_user})

      assert %OauthProfile{} = oauth
    end

    test "should validate the conflict email" do
      registered_user = IdentityFactory.build(:user) |> IdentityFactory.insert()
      conflict_user_params = IdentityFactory.build(:user_params, %{email: registered_user.email})
      changeset = User.registration_changeset(%User{}, conflict_user_params)

      assert conflict_user_params.email == changeset.changes.email
      refute changeset.valid? == true
    end
  end
end
