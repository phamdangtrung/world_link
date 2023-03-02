defmodule WorldLink.Identity.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :activated, :boolean, default: false
    field :activated_at, :utc_datetime
    field :approved, :boolean, default: false
    field :auth_token, :string
    field :auth_token_expires_at, :utc_datetime
    field :discord_handle, :string
    field :email, :string
    field :facebook_handle, :string
    field :google_handle, :string
    field :handle, :string
    field :joined_at, :utc_datetime
    field :name, :string
    field :signed_in_at, :utc_datetime
    field :twitter_handle, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :handle, :twitter_handle, :discord_handle, :facebook_handle, :google_handle, :auth_token, :auth_token_expires_at, :joined_at, :signed_in_at, :approved, :activated, :activated_at])
    |> validate_required([:name, :email, :handle, :twitter_handle, :discord_handle, :facebook_handle, :google_handle, :auth_token, :auth_token_expires_at, :joined_at, :signed_in_at, :approved, :activated, :activated_at])
  end
end
