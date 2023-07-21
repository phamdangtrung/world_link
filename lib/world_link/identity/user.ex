defmodule WorldLink.Identity.User do
  @moduledoc """
  Schema for User
  """

  use WorldLink.Schema
  import Ecto.Changeset
  import Ecto

  alias WorldLink.Identity.{OauthProfile, User}
  alias WorldLink.Images.{Album, Image}
  alias WorldLink.Worlds.{Character, World}

  @required_fields [:email, :name, :username, :password]

  schema "users" do
    field(:activated, :boolean, default: false)
    field(:activated_at, :utc_datetime)
    field(:email, :string)
    field(:normalized_email, :string)
    field(:name, :string)
    field(:username, :string)
    field(:normalized_username, :string)
    field(:password, :string, virtual: true, redact: true)
    field(:hashed_password, :string, redact: true)
    field(:role_name, Ecto.Enum, values: [:user, :admin])
    field(:settings, :map, default: %{})
    field(:deleted, :boolean, default: false)
    field(:deleted_at, :utc_datetime)

    has_many(:oauth_profiles, OauthProfile, where: [deleted: false])
    has_many(:worlds, World, where: [deleted: false])
    has_many(:characters, Character, where: [deleted: false])
    has_many(:images, Image)
    has_many(:albums, Album)
    timestamps()
  end

  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: Ecto.ULID.t(),
          activated: boolean(),
          activated_at: DateTime.t() | nil,
          email: String.t(),
          normalized_email: String.t(),
          name: String.t(),
          username: String.t(),
          normalized_username: String.t(),
          password: String.t(),
          hashed_password: String.t(),
          role_name: atom(),
          settings: map(),
          deleted: boolean(),
          deleted_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_name()
    |> validate_username()
    |> validate_email()
    |> validate_password()
  end

  def oauth_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :name, :email])
    |> validate_name()
    |> validate_username()
    |> validate_email()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required(:name)
    |> validate_length(:name, max: 50)
  end

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username])
    |> normalize(:username)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_-]+$/,
      message: "can only include alphanumeric characters and - or _"
    )
    |> validate_length(:username, min: 5, max: 50)
    |> unsafe_validate_unique(:username, WorldLink.Repo)
    |> unique_constraint(:username)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> normalize(:email)
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

  defp normalize(changeset, field) when is_atom(field) do
    field_value = get_change(changeset, field)

    normalize_field(changeset, field, field_value)
  end

  defp normalize_field(changeset, field, field_value) when not is_nil(field_value) do
    normalized_value = field_value |> String.downcase()
    [normalized_field] = ~w(normalized_#{field})a

    changeset
    |> put_change(normalized_field, normalized_value)
  end

  defp normalize_field(changeset, field, _) do
    [normalized_field] = ~w(normalized_#{field})a

    changeset
    |> add_error(normalized_field, "is invalid")
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

  def changeset_create_a_world(user, world_attrs) do
    user
    |> build_assoc(:worlds)
    |> World.world_changeset(world_attrs)
  end

  def changeset_create_a_character(user, character_attrs) do
    user
    |> build_assoc(:characters)
    |> Character.character_changeset(character_attrs)
  end

  def changeset_upload_image(user, image) when not is_list(image) do
    user
    |> build_assoc(:images)
    |> Image.changeset(image)
  end
end
