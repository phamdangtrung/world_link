defmodule WorldLink.Images.Album do
  @moduledoc """
  Album schema
  """

  alias WorldLink.Identity.User
  alias WorldLink.Images.{AlbumsCharacters, AlbumsImages, Image}
  alias WorldLink.Worlds.Character
  use WorldLink.Schema

  schema "albums" do
    field(:count, :integer)
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
end
