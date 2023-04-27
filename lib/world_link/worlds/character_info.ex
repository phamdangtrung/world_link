defmodule WorldLink.Worlds.CharacterInfo do
  use WorldLink.Schema
  import Ecto.Changeset
  alias WorldLink.Worlds.{Character, Timeline, TimelinesCharacterInfo}

  @required_fields [:species, :data]
  schema "character_info" do
    field(:species, :string, default: "unspecified")
    field(:data, :map, default: %{})
    field(:deleted, :boolean, default: false)
    field(:deleted_at, :utc_datetime)

    belongs_to(:character, Character)
    has_many(:timelines_character_info, TimelinesCharacterInfo, where: [deleted: false])

    many_to_many(
      :timelines,
      Timeline,
      join_through: "timelines_character_info",
      on_replace: :delete
    )

    timestamps()
  end

  def changeset(assoc_changeset, bio_attrs) do
    assoc_changeset
    |> cast(bio_attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:species, min: 3, max: 255)
  end

  def changeset_delete_character_info(character_info, deletion_time) do
    character_info
    |> change(%{deleted: true, deleted_at: deletion_time})
  end
end
