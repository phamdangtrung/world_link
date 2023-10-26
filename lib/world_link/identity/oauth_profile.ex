defmodule WorldLink.Identity.OauthProfile do
  @moduledoc """
  Schema for OauthProfile
  """
  use WorldLink.Schema
  import Ecto
  import Ecto.Changeset
  alias WorldLink.Identity.User

  @supported_providers [:discord, :facebook, :twitter, :google]

  schema "oauth_profiles" do
    field(:oauth_provider, Ecto.Enum, values: @supported_providers)
    field(:provider_uid, :string)
    field(:deleted, :boolean, default: false)
    field(:deleted_at, :utc_datetime)

    belongs_to(:user, User)
    timestamps()
  end

  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          oauth_provider: atom(),
          provider_uid: String.t(),
          deleted: boolean(),
          deleted_at: DateTime.t() | nil,
          user_id: Ecto.ULID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  def supported_providers, do: @supported_providers

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
