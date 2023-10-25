defmodule WorldLink.Images.Image do
  @moduledoc """
  Image schema
  """
  alias WorldLink.Identity.User
  alias WorldLink.Images.{Album, AlbumsImages, SubImage}
  import Ecto
  import Ecto.Changeset
  use WorldLink.Schema

  schema "images" do
    field(:artist, :string)
    field(:artist_contact, :string)
    field(:commission, :boolean, default: false)
    field(:commissioner, :string)
    field(:commissioner_contact, :string)
    field(:content_length, :integer)
    field(:content_type, :string)
    field(:date, :utc_datetime)
    field(:description, :string)
    field(:exif, :map, default: %{})
    field(:original_filename, :string)
    field(:gore, :boolean, default: false)
    field(:nsfw, :boolean, default: false)
    field(:sensitive, :boolean, default: false)
    field(:shared, :boolean, default: false)
    field(:title, :string)
    field(:url, :string)

    has_many(:albums_images, AlbumsImages)
    has_many(:sub_images, SubImage)

    many_to_many(
      :albums,
      Album,
      join_through: "albums_images",
      on_replace: :delete
    )

    belongs_to(:user, User)
    timestamps()
  end

  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: Ecto.ULID.t(),
          artist: String.t() | nil,
          artist_contact: String.t() | nil,
          commission: boolean(),
          commissioner: String.t() | nil,
          commissioner_contact: String.t() | nil,
          content_length: non_neg_integer(),
          content_type: String.t(),
          date: DateTime.t(),
          description: String.t(),
          exif: %{} | map(),
          original_filename: String.t(),
          gore: boolean(),
          nsfw: boolean(),
          sensitive: boolean(),
          shared: boolean(),
          title: String.t(),
          url: String.t(),
          user_id: Ecto.ULID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  def changeset(assoc_changeset, attrs) do
    assoc_changeset
    |> cast(attrs, [
      :artist,
      :artist_contact,
      :commission,
      :commissioner,
      :commissioner_contact,
      :content_length,
      :content_type,
      :date,
      :description,
      :exif,
      :original_filename,
      :gore,
      :nsfw,
      :sensitive,
      :title,
      :url
    ])
    |> validate_required([
      :original_filename,
      :content_length,
      :content_type,
      :exif,
      :title
    ])
  end

  def changeset_add_original_image_url(image, image_url_attrs) do
    image
    |> build_assoc(:image_urls)
    |> SubImage.original_image_changeset(image_url_attrs)
  end
end
