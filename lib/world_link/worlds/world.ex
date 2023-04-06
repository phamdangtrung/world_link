defmodule WorldLink.Worlds.World do
  use WorldLink.Schema
  import Ecto
  import Ecto.Changeset
  alias WorldLink.Identity.User
  alias WorldLink.Worlds.{Timeline, Character, World, WorldsCharacters, TimelinesCharacterInfo}

  schema "worlds" do
    field :world_name, :string

    belongs_to :user, User
    has_many :timelines, Timeline
    has_many :worlds_characters, WorldsCharacters
    has_many :timelines_character_info, TimelinesCharacterInfo

    many_to_many(
      :characters,
      Character,
      join_through: "worlds_characters",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def world_changeset(assoc_changeset, world_attrs) do
    assoc_changeset
    |> cast(world_attrs, [:world_name])
    |> validate_required([:world_name])
    |> validate_length(:world_name, min: 5, max: 255)
  end

  def changeset_update_characters(%World{} = world, characters) do
    world
    |> cast(%{}, [:world_name])
    |> put_assoc(:characters, characters)
  end

  def changeset_update_timelines(%World{} = world, timelines) do
    world
    |> cast(%{}, [:timeline_name])
    |> put_assoc(:timelines, timelines)
  end

  def changeset_create_a_timelines(world, timeline_attrs) do
    world
    |> build_assoc(:timelines)
    |> Timeline.timeline_changeset(timeline_attrs)
  end

  def changeset_assign_a_character(world, worlds_characters_attrs) do
    world
    |> build_assoc(:worlds_characters)
    |> WorldsCharacters.changeset(worlds_characters_attrs)
  end
end
