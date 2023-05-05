defmodule WorldLink.Worlds.Character do
  use WorldLink.Schema
  import Ecto.Changeset
  import Ecto
  alias WorldLink.Worlds.{World, CharacterInfo, WorldsCharacters, TimelinesCharacterInfo}
  alias WorldLink.Identity.User

  schema "characters" do
    field(:name, :string)
    field(:deleted, :boolean, default: false)
    field(:deleted_at, :utc_datetime)

    belongs_to(:user, User)
    has_many(:bio, CharacterInfo, where: [deleted: false])
    has_many(:worlds_characters, WorldsCharacters, where: [deleted: false])
    has_many(:timelines_character_info, TimelinesCharacterInfo, where: [deleted: false])

    many_to_many(
      :worlds,
      World,
      join_through: "worlds_characters",
      on_replace: :delete
    )

    timestamps()
  end

  def character_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 5, max: 255)
  end

  def changeset_create_bio(character, bio_attrs) do
    character
    |> build_assoc(:bio)
    |> CharacterInfo.changeset(bio_attrs)
  end

  def changeset_update_ownership(character, character_id_attr) do
    character
    |> cast(character_id_attr, [:user_id])
  end

  def changeset_delete_character(character, deletion_time) do
    character
    |> change(%{deleted: true, deleted_at: deletion_time})
  end
end
