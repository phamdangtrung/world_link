defmodule WorldLink.Images.Album do
  @moduledoc """
  Album schema
  """

  alias WorldLink.Identity.User
  alias WorldLink.Images.{Album, AlbumsCharacters, AlbumsImages, Image}
  alias WorldLink.Worlds.Character
  import Ecto.Changeset
  use WorldLink.Schema

  schema "albums" do
    field(:count, :integer, default: 0)
    field(:description, :string)
    field(:nsfw, :boolean, default: false)
    field(:shared, :boolean, default: false)
    field(:title, :string)
    field(:url, :string)

    has_many(:albums_images, AlbumsImages)

    many_to_many(
      :images,
      Image,
      join_through: "albums_images",
      on_replace: :delete
    )

    has_many(:albums_characters, AlbumsCharacters)

    many_to_many(
      :characters,
      Character,
      join_through: "albums_characters",
      on_replace: :delete
    )

    belongs_to(:user, User)
    timestamps()
  end

  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: Ecto.ULID.t(),
          count: non_neg_integer(),
          description: String.t() | nil,
          nsfw: boolean(),
          shared: boolean(),
          title: String.t(),
          url: String.t(),
          user_id: Ecto.ULID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  def new_album_changeset(assoc_changeset, attrs) do
    assoc_changeset
    |> cast(attrs, [:title, :description])
    |> validate_required([:title])
    |> validate_length(:title, max: 255)
    |> validate_length(:description, max: 2000)
  end

  def album_count_changeset(%Album{} = album, attrs) do
    album
    |> cast(attrs, [:count])
    |> validate_required([:count])
  end

  def album_changeset(album, attrs) do
    album
    |> cast(attrs, [:title, :description, :nsfw, :shared, :url])
    |> validate_length(:title, max: 255)
    |> validate_length(:description, max: 2000)
  end

  def album_nsfw_changeset(album, %{nsfw: current_setting} = _attrs)
      when is_boolean(current_setting) do
    album
    |> cast(%{nsfw: !current_setting}, [:nsfw])
  end

  def album_shared_changeset(album, %{shared: current_setting} = _attrs)
      when is_boolean(current_setting) do
    album
    |> cast(%{nsfw: !current_setting}, [:shared])
  end
end
