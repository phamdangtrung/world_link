defmodule WorldLink.Images.AlbumsImages do
  @moduledoc """
  AlbumsImages schema
  """

  alias WorldLink.Images.{Album, Image}
  import Ecto.Changeset
  use WorldLink.Schema

  @primary_key false
  @required_fields [:album_id, :image_id]

  schema "albums_images" do
    belongs_to(:album, Album, primary_key: true)
    belongs_to(:image, Image, primary_key: true)
  end

  def changeset(assoc_changeset, attrs) do
    assoc_changeset
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unsafe_validate_unique([:album_id, :image_id], WorldLink.Repo)
    |> unique_constraint([:album_id, :image_id])
  end
end
