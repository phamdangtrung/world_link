defmodule WorldLink.Worlds.WorldsCharacters do
  @moduledoc """
  WorldsCharacters schema
  """
  use WorldLink.Schema
  import Ecto.Changeset
  alias WorldLink.Worlds.{Character, World}

  @primary_key false
  @required_fields [:world_id, :character_id]
  schema "worlds_characters" do
    field(:deleted, :boolean, default: false)
    field(:deleted_at, :utc_datetime)

    belongs_to(:character, Character, primary_key: true)
    belongs_to(:world, World, primary_key: true)
  end

  def changeset(assoc_changeset, attrs) do
    assoc_changeset
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unsafe_validate_unique(@required_fields, WorldLink.Repo)
    |> unique_constraint(@required_fields)
  end

  def changeset_delete_worlds_characters(worlds_characters) do
    worlds_characters
    |> change(%{deleted: true, deleted_at: DateTime.utc_now() |> DateTime.truncate(:second)})
  end
end
