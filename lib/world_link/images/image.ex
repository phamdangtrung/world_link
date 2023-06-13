defmodule WorldLink.Images.Image do
  @moduledoc """
  Image schema
  """
  alias WorldLink.Identity.User
  use WorldLink.Schema
  import Ecto.Changeset

  schema "images" do
    field(:artist, :string)
    field(:artist_contact, :string)
    field(:commission, :boolean, default: false)
    field(:commissioner, :string)
    field(:commissioner_contact, :string)
    field(:content_type, :string)
    field(:date, :utc_datetime)
    field(:description, :string)
    field(:exif, :map, default: %{})
    field(:file_name, :string)
    field(:file_size, :integer)
    field(:gore, :boolean, default: false)
    field(:key, :string)
    field(:nsfw, :boolean, default: false)
    field(:sensitive, :boolean, default: false)
    field(:title, :string)

    belongs_to(:user, User)
    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [
      :artist,
      :artist_contact,
      :commission,
      :commissioner,
      :commissioner_contact,
      :content_type,
      :date,
      :description,
      :exif,
      :file_name,
      :file_size,
      :gore,
      :key,
      :nsfw,
      :sensitive,
      :title
    ])
    |> validate_required([
      :key,
      :file_name,
      :file_size,
      :content_type,
      :exif,
      :title
    ])
  end
end
