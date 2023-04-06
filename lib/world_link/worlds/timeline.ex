defmodule WorldLink.Worlds.Timeline do
  use WorldLink.Schema
  import Ecto.Changeset
  import Ecto
  alias WorldLink.Worlds.{World, CharacterInfo, TimelinesCharacterInfo}

  @required_fields [:timeline_name, :main]
  schema "timelines" do
    field :timeline_name, :string
    field :main, :boolean, default: false

    belongs_to :world, World
    has_many :timelines_character_info, TimelinesCharacterInfo

    many_to_many(
      :character_info,
      CharacterInfo,
      join_through: "timelines_character_info",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def timeline_changeset(timeline, attrs) do
    timeline
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:timeline_name, min: 5, max: 255)
  end

  def changeset_assign_a_character_info(timeline, timeline_character_info_attrs) do
    timeline
    |> build_assoc(:timelines_character_info)
    |> TimelinesCharacterInfo.changeset(timeline_character_info_attrs)
  end
end
