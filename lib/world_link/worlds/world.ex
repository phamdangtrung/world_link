defmodule WorldLink.Worlds.World do
  @moduledoc """
  World schema
  """

  use WorldLink.Schema
  import Ecto
  import Ecto.Changeset
  alias WorldLink.Identity.User
  alias WorldLink.Worlds.{Character, Timeline, TimelinesCharacterInfo, WorldsCharacters}

  schema "worlds" do
    field(:name, :string)
    field(:deleted, :boolean, default: false)
    field(:deleted_at, :utc_datetime)

    belongs_to(:user, User)
    has_many(:timelines, Timeline, where: [deleted: false])

    field(:main_timeline_id, Ecto.ULID)

    has_one(:main_timeline, Timeline,
      foreign_key: :id,
      where: [deleted: false],
      on_replace: :update
    )

    has_many(:worlds_characters, WorldsCharacters, where: [deleted: false])
    has_many(:timelines_character_info, TimelinesCharacterInfo, where: [deleted: false])

    many_to_many(
      :characters,
      Character,
      join_through: "worlds_characters",
      on_replace: :delete
    )

    timestamps()
  end

  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: Ecto.ULID.t(),
          name: String.t(),
          deleted: boolean(),
          deleted_at: DateTime.t() | nil,
          user_id: Ecto.ULID.t(),
          main_timeline_id: Ecto.ULID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def world_changeset(assoc_changeset, world_attrs) do
    assoc_changeset
    |> cast(world_attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 5, max: 255)
  end

  def changeset_create_a_timelines(world, timeline_attrs) do
    world
    |> build_assoc(:timelines)
    |> Timeline.timeline_changeset(timeline_attrs)
  end

  def changeset_update_main_timeline(world, timeline) do
    world
    |> change()
    |> put_assoc(:main_timeline, timeline)
  end

  def changeset_delete_world(world) do
    world
    |> change(%{deleted: true, deleted_at: DateTime.utc_now() |> DateTime.truncate(:second)})
  end

  def changeset_assign_a_character(world, worlds_characters_attrs) do
    world
    |> build_assoc(:worlds_characters)
    |> WorldsCharacters.changeset(worlds_characters_attrs)
  end
end
