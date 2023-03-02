defmodule WorldLink.Identity.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :activated, :boolean, default: false
    field :activated_at, :utc_datetime
    field :auth_token, :string
    field :auth_token_expires_at, :utc_datetime
    field :email, :string
    field :handle, :string
    field :name, :string
    field :provider_uid, :string
    field :uuid, :string
    field :oauth_provider, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :handle,
      :twitter_handle,
      :discord_handle,
      :facebook_handle,
      :google_handle,
      :auth_token,
      :auth_token_expires_at,
      :joined_at,
      :signed_in_at,
      :approved,
      :activated,
      :activated_at
    ])
    |> validate_required([
      :name,
      :email,
      :handle,
      :twitter_handle,
      :discord_handle,
      :facebook_handle,
      :google_handle,
      :auth_token,
      :auth_token_expires_at,
      :joined_at,
      :signed_in_at,
      :approved,
      :activated,
      :activated_at
    ])
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [])
    |> validate_email()
    |> validate_password()
  end

  def oauth_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_email()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> normalize_email()
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, min: 5, max: 160)
    |> unsafe_validate_unique(:email, WorldLink.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 10, max: 72)
    |> hash_password()
  end

  defp hash_password(changeset) do
    if changeset.valid? do
      password = get_change(changeset, :password)

      changeset
      |> put_change(:hashed_password, Argon2.hash_pwd_salt(password, salt_len: 32))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp normalize_email(changeset) do
    email = get_change(changeset, :email)

    changeset
    |> put_change(:email, String.downcase(email))
  end
end
