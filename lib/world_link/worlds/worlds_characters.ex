defmodule WorldLink.Worlds.WorldsCharacters do
  use WorldLink.Schema
  import Ecto.Changeset
  alias WorldLink.Worlds.{World, Character}

  @primary_key false
  @required_fields [:world_id, :character_id]
  schema "worlds_characters" do
    field :deleted, :boolean, default: false
    field :deleted_at, :utc_datetime

    belongs_to :character, Character
    belongs_to :world, World
  end

  def changeset(assoc_changeset, attrs) do
    assoc_changeset
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unsafe_validate_unique(@required_fields, WorldLink.Repo)
    |> unique_constraint(@required_fields)
  end
end
