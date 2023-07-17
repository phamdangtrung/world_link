defmodule WorldLink.Images.AlbumsCharacters do
  @moduledoc """
  AlbumsCharacters schema
  """

  alias WorldLink.Images.Album
  alias WorldLink.Worlds.Character
  import Ecto.Changeset
  use WorldLink.Schema

  @primary_key false
  @required_fields [:album_id, :character_id]

  schema "albums_characters" do
    belongs_to(:album, Album, primary_key: true)
    belongs_to(:character, Character, primary_key: true)
  end

  def changeset(assoc_changeset, attrs) do
    assoc_changeset
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unsafe_validate_unique([:album_id, :character_id], WorldLink.Repo)
    |> unique_constraint([:album_id, :character_id])
  end
end
