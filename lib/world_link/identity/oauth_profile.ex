defmodule WorldLink.Identity.OauthProfile do
  @moduledoc """
  Schema for OauthProfile
  """
  use WorldLink.Schema
  import Ecto
  import Ecto.Changeset
  alias WorldLink.Identity.User

  schema "oauth_profiles" do
    field :oauth_provider, Ecto.Enum, values: [:discord, :facebook, :twitter, :google]
    field :provider_uid, :string

    belongs_to :user, User
    timestamps()
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> build_assoc(:oauth_profiles)
    |> cast(attrs, [:oauth_provider, :provider_uid])
    |> validate_required([:oauth_provider, :provider_uid])
    |> validate_provider_uid()
  end

  defp validate_provider_uid(changeset) do
    changeset
    |> unsafe_validate_unique([:provider_uid, :oauth_provider], WorldLink.Repo)
    |> unique_constraint([:provider_uid, :oauth_provider])
  end
end
