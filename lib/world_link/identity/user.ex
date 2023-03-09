defmodule WorldLink.Identity.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias WorldLink.Identity.User

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
    field :oauth_provider, Ecto.Enum, values: [:discord, :facebook, :twitter, :google]
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true

    timestamps()
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_email()
    |> validate_password()
    |> assign_uuid()
  end

  def oauth_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :provider_uid, :oauth_provider])
    |> validate_email()
    |> validate_provider_uid()
    |> assign_uuid()
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

  defp assign_uuid(changeset) when changeset.valid? == true do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end

  defp assign_uuid(changeset), do: changeset

  defp validate_provider_uid(changeset) do
    changeset
    |> unsafe_validate_unique([:provider_uid, :oauth_provider], WorldLink.Repo)
    |> unique_constraint([:provider_uid, :oauth_provider])
  end

  def valid_password?(%User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Argon2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Argon2.no_user_verify()
    false
  end

  def confirm_changeset(user) do
    now = DateTime.utc_now()
    |> DateTime.truncate(:second)

    change(user, [activated_at: now, activated: true])
  end
end
