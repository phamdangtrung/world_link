defmodule WorldLink.Worlds.TimelinesCharacterInfo do
  use WorldLink.Schema
  import Ecto.Changeset
  alias WorldLink.Worlds.{Character, World, Timeline, CharacterInfo}

  @primary_key false
  @required_fields [:timeline_id, :character_info_id, :character_id, :world_id]
  schema "timelines_character_info" do
    belongs_to :timeline, Timeline, primary_key: true
    belongs_to :character_info, CharacterInfo, primary_key: true
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
