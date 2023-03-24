defmodule WorldLink.Identity.User do
  @moduledoc false

  use WorldLink.Schema
  import Ecto.Changeset

  alias WorldLink.Identity.{User, OauthProfile}

  schema "users" do
    field :activated, :boolean, default: false
    field :activated_at, :utc_datetime
    field :email, :string
    field :name, :string
    field :nickname, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :role_name, Ecto.Enum, values: [:user, :admin]

    has_many :oauth_profiles, OauthProfile
    timestamps()
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :name, :email, :password])
    |> validate_name()
    |> validate_nickname()
    |> validate_email()
    |> validate_password()
  end

  def oauth_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :name, :email])
    |> validate_email()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_length(:name, max: 50)
  end

  defp validate_nickname(changeset) do
    changeset
    |> validate_required([:nickname])
    |> validate_format(:nickname, ~r/^[a-z0-9_-]+$/,
      message: "can only include alphnumeric characters and - or _"
    )
    |> validate_length(:nickname, min: 5, max: 50)
    |> unsafe_validate_unique(:nickname, WorldLink.Repo)
    |> unique_constraint(:nickname)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> normalize_email()
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, min: 5, max: 255)
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

  def valid_password?(%User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Argon2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Argon2.no_user_verify()
  end

  def confirm_changeset(user) do
    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    change(user, activated_at: now, activated: true)
  end
end
