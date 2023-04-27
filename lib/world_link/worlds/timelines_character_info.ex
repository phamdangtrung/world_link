defmodule WorldLink.Worlds.TimelinesCharacterInfo do
  use WorldLink.Schema
  import Ecto.Changeset
  alias WorldLink.Worlds.{Character, World, Timeline, CharacterInfo}

  @primary_key false
  @required_fields [:timeline_id, :character_info_id, :character_id, :world_id]
  schema "timelines_character_info" do
    field(:deleted, :boolean, default: false)
    field(:deleted_at, :utc_datetime)

    belongs_to(:timeline, Timeline, primary_key: true)
    belongs_to(:character_info, CharacterInfo, primary_key: true)
    belongs_to(:character, Character)
    belongs_to(:world, World)
  end

  def changeset(assoc_changeset, attrs) do
    assoc_changeset
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unsafe_validate_unique([:timeline_id, :character_info_id], WorldLink.Repo)
    |> unique_constraint([:timeline_id, :character_info_id])
  end

  def changeset_delete_timelines_character_info(timelines_character_info) do
    timelines_character_info
    |> change(%{deleted: true, deleted_at: DateTime.utc_now() |> DateTime.truncate(:second)})
  end
end
