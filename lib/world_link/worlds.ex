defmodule WorldLink.Worlds do
  @moduledoc """
  The Worlds context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias WorldLink.Repo
  alias WorldLink.Identity.User

  alias WorldLink.Worlds.{
    Character,
    CharacterInfo,
    Timeline,
    TimelinesCharacterInfo,
    World,
    WorldsCharacters
  }

  def create_a_world(%User{} = user, world_attrs) do
    default_timeline_name = "Main Timeline"

    Multi.new()
    |> Multi.insert(
      :create_a_world,
      User.changeset_create_a_world(
        user,
        world_attrs
      )
    )
    |> Multi.insert(
      :create_main_timeline,
      fn %{create_a_world: world} ->
        World.changeset_create_a_timelines(world, %{
          name: default_timeline_name
        })
      end
    )
    |> Multi.update(
      :update_main_timeline,
      fn %{create_a_world: world, create_main_timeline: timeline} ->
        world
        |> Repo.preload(:main_timeline)
        |> World.changeset_update_main_timeline(timeline)
      end
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{create_a_world: _new_world, create_main_timeline: _timeline, update_main_timeline: world}} ->
        {:ok, world}

      {:error, :create_a_world, world_changeset, _} ->
        {:error, :create_a_world, world_changeset}

      {:error, :create_main_timeline, timeline_changeset, _} ->
        {:error, :create_main_timeline, timeline_changeset}

      {:error, :update_main_timeline, update_main_timeline_changeset, _} ->
        {:error, :update_main_timeline, update_main_timeline_changeset}
    end
  end

  def create_a_timeline(%World{} = world, timeline_attrs) do
    Repo.transaction(fn repo ->
      World.changeset_create_a_timelines(world, timeline_attrs)
      |> repo.insert!()
    end)
    |> case do
      {:ok, timeline} -> {:ok, timeline}
      {:error, message} -> {:error, message}
    end
  end

  def create_a_character(%User{} = user, character_attrs) do
    Multi.new()
    |> Multi.insert(:character, User.changeset_create_a_character(user, character_attrs))
    |> Multi.insert(:bio, fn %{character: character} ->
      Character.changeset_create_bio(character, %{})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{character: character, bio: bio}} -> {:ok, %{character: character, bio: bio}}
      {:error, :character, character_changeset, _} -> {:error, :character, character_changeset}
      {:error, :bio, bio_changeset, _} -> {:error, :bio, bio_changeset}
    end
  end

  def create_a_character_bio(%User{} = user, character_info_attrs) do
    Repo.transaction(fn repo ->
      Character.changeset_create_bio(user, character_info_attrs)
      |> repo.insert!()
    end)
    |> case do
      {:ok, character_info} -> {:ok, character_info}
      {:error, message} -> {:error, message}
    end
  end

  def assign_characters_to_a_world(world, characters) when is_list(characters) do
    Enum.each(characters, &assign_a_character_to_a_world(world, &1))
  end

  def assign_a_character_to_a_world(world, character) do
    Repo.transaction(fn repo ->
      repo.insert!(
        world
        |> World.changeset_assign_a_character(%{world_id: world.id, character_id: character.id})
      )
    end)
    |> case do
      {:ok, world_character} -> {:ok, world_character}
      {:error, message} -> {:error, message}
    end
  end

  def assign_a_character_info_to_a_timeline(timeline, character_info) do
    timeline = timeline |> Repo.preload(:world)
    character_info = character_info |> Repo.preload(:character)

    Repo.transaction(fn repo ->
      repo.insert!(
        timeline
        |> Timeline.changeset_assign_a_character_info(%{
          timeline_id: timeline.id,
          character_info_id: character_info.id,
          character_id: character_info.character.id,
          world_id: timeline.world.id
        })
      )
    end)
    |> case do
      {:ok, timelines_character_info} -> {:ok, timelines_character_info}
      {:error, message} -> {:error, message}
    end
  end

  def update_main_timeline(world, timeline) do
    Repo.transaction(fn repo ->
      world
      |> preload(:main_timeline)
      |> World.changeset_update_main_timeline(timeline)
      |> repo.update!()
    end)
    |> case do
      {:ok, world} -> {:ok, world}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_a_world(world, new_world_attrs) do
    Repo.transaction(fn repo ->
      world
      |> World.world_changeset(new_world_attrs)
      |> repo.update!()
    end)
    |> case do
      {:ok, updated_world} -> {:ok, updated_world}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_a_character(character, new_character_attrs) do
    Repo.transaction(fn repo ->
      character
      |> Character.character_changeset(new_character_attrs)
      |> repo.update!()
    end)
    |> case do
      {:ok, updated_character} -> {:ok, updated_character}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_a_character_info(character_info, new_character_info_attrs) do
    Repo.transaction(fn repo ->
      character_info
      |> CharacterInfo.changeset(new_character_info_attrs)
      |> repo.update!()
    end)
    |> case do
      {:ok, updated_character_info} -> {:ok, updated_character_info}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_a_timeline(timeline, new_timeline_attrs) do
    Repo.transaction(fn repo ->
      timeline
      |> Timeline.timeline_changeset(new_timeline_attrs)
      |> repo.update()
    end)
    |> case do
      {:ok, updated_timeline} -> {:ok, updated_timeline}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_a_world(world) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :delete_associated_timelines_character_info,
      from(tci in TimelinesCharacterInfo,
        where: tci.world_id == ^world.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update_all(
      :delete_associated_timelines,
      from(t in Timeline,
        where: t.world_id == ^world.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update_all(
      :delete_associated_worlds_characters,
      from(wc in WorldsCharacters,
        where: wc.world_id == ^world.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update(
      :delete_world,
      World.changeset_delete_world(world)
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         delete_associated_timelines_character_info: delete_associated_timelines_character_info,
         delete_associated_timelines: delete_associated_timelines,
         delete_associated_worlds_characters: delete_associated_worlds_characters,
         delete_world: delete_world
       }} ->
        {:ok,
         %{
           delete_associated_timelines_character_info: delete_associated_timelines_character_info,
           delete_associated_timelines: delete_associated_timelines,
           delete_associated_worlds_characters: delete_associated_worlds_characters,
           delete_world: delete_world
         }}

      {:error, :delete_associated_timelines_character_info,
       delete_associated_timelines_character_info, _} ->
        {:error, :delete_associated_timelines_character_info,
         delete_associated_timelines_character_info}

      {:error, :delete_associated_timelines, delete_associated_timelines, _} ->
        {:error, :delete_associated_timelines, delete_associated_timelines}

      {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters, _} ->
        {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters}

      {:error, :delete_world, delete_world, _} ->
        {:error, :delete_world, delete_world}
    end
  end

  def delete_a_timeline(timeline) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :delete_associated_timelines_character_info,
      from(tci in TimelinesCharacterInfo,
        where: tci.timeline_id == ^timeline.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update(
      :delete_timeline,
      Timeline.changeset_delete_timeline(timeline)
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         delete_associated_timelines_character_info: delete_associated_timelines_character_info,
         delete_timeline: delete_associated_timelines
       }} ->
        {:ok,
         %{
           delete_associated_timelines_character_info: delete_associated_timelines_character_info,
           delete_timeline: delete_associated_timelines
         }}

      {:error, :delete_associated_timelines_character_info,
       delete_associated_timelines_character_info, _} ->
        {:error, :delete_associated_timelines_character_info,
         delete_associated_timelines_character_info}

      {:error, :delete_timeline, delete_timeline, _} ->
        {:error, :delete_timeline, delete_timeline}
    end
  end

  def delete_a_character(character) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :delete_associated_timelines_character_info,
      from(tci in TimelinesCharacterInfo,
        where: tci.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update_all(
      :delete_associated_character_info,
      from(ci in CharacterInfo,
        where: ci.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update_all(
      :delete_associated_worlds_characters,
      from(wc in WorldsCharacters,
        where: wc.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update(
      :delete_character,
      Character.changeset_delete_character(character)
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         delete_associated_timelines_character_info: delete_associated_timelines_character_info,
         delete_associated_character_info: delete_associated_character_info,
         delete_associated_worlds_characters: delete_associated_worlds_characters,
         delete_character: delete_character
       }} ->
        {:ok,
         %{
           delete_associated_timelines_character_info: delete_associated_timelines_character_info,
           delete_associated_character_info: delete_associated_character_info,
           delete_associated_worlds_characters: delete_associated_worlds_characters,
           delete_character: delete_character
         }}

      {:error, :delete_associated_timelines_character_info,
       delete_associated_timelines_character_info, _} ->
        {:error, :delete_associated_timelines_character_info,
         delete_associated_timelines_character_info}

      {:error, :delete_associated_character_info, delete_associated_character_info, _} ->
        {:error, :delete_associated_character_info, delete_associated_character_info}

      {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters, _} ->
        {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters}

      {:error, :delete_timeline, delete_character, _} ->
        {:error, :delete_timeline, delete_character}
    end
  end

  def unassign_a_character_from_a_world(world, character) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :delete_associated_timelines_character_info,
      from(tci in TimelinesCharacterInfo,
        where: tci.character_id == ^character.id and tci.world_id == ^world.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update(
      :delete_associated_worlds_characters,
      from(wc in WorldsCharacters,
        where: wc.character_id == ^character.id and wc.world_id == ^world.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         delete_associated_timelines_character_info: _delete_associated_timelines_character_info,
         delete_associated_worlds_characters: _delete_associated_worlds_characters
       }} ->
        {:ok, :character_unassigned_from_world}

      {:error, :delete_associated_timelines_character_info,
       delete_associated_timelines_character_info, _} ->
        {:error, :delete_associated_timelines_character_info,
         delete_associated_timelines_character_info}

      {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters, _} ->
        {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters}
    end
  end

  def unassign_a_character_from_a_timeline(timeline, character_info) do
    deletion_time = deletion_time()

    Repo.update(
      from(tci in TimelinesCharacterInfo,
        where: tci.timeline_id == ^timeline.id and tci.character_info_id == ^character_info.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      )
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         retrieve_bio_and_timeline: _retrieve_bio_and_timeline,
         remove_bio_from_timeline: _remove_bio_from_timeline
       }} ->
        {:ok, :character_unassigned_from_timeline}

      {:error, :retrieve_bio_and_timeline, retrieve_bio_and_timeline, _} ->
        {:error, :retrieve_bio_and_timeline, retrieve_bio_and_timeline}

      {:error, :remove_bio_from_timeline, remove_bio_from_timeline, _} ->
        {:error, :remove_bio_from_timeline, remove_bio_from_timeline}
    end
  end

  def transfer_character(character_id, sender_id, recipient_id) do
    Multi.new()
    |> Multi.one(:ownership_verification, fn _ ->
      from(c in Character, where: c.id == ^character_id and c.user_id == ^sender_id)
    end)
    |> Multi.delete_all(:unassign_character_from_all_timelines, fn _ ->
      from(tci in TimelinesCharacterInfo, where: tci.character_id == ^character_id)
    end)
    |> Multi.delete_all(:unassign_character_from_all_worlds, fn _ ->
      from(wc in WorldsCharacters, where: wc.character_id == ^character_id)
    end)
    |> Multi.update(:transfer_character, fn %{ownership_verification: verified_character} ->
      Character.changeset_update_ownership(verified_character, %{user_id: recipient_id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         ownership_verification: _ownership_verification,
         unassign_character_from_all_timelines: _unassign_character_from_all_timelines,
         unassign_character_from_all_worlds: _unassign_character_from_all_worlds,
         transfer_character: _transfer_character
       }} ->
        {:ok, :character_transfered}

      {:error, :ownership_verification, _ownership_verification, _} ->
        {:error, :ownership_verification}

      {:error, :unassign_character_from_all_timelines, _unassign_character_from_all_timelines, _} ->
        {:error, :unassign_character_from_all_timelines}

      {:error, :unassign_character_from_all_worlds, _unassign_character_from_all_worlds, _} ->
        {:error, :unassign_character_from_all_worlds}

      {:error, :transfer_character, _transfer_character, _} ->
        {:error, :transfer_character}
    end
  end

  def delete_character(character_id, user_id) do
    delete_time = deletion_time()

    Multi.new()
    |> Multi.one(
      :ownership_verification,
      fn _ ->
        from(c in Character, where: c.id == ^character_id and c.user_id == ^user_id)
      end
    )
    |> Multi.update_all(
      :unassign_character_from_all_timelines,
      fn _ ->
        from(tci in TimelinesCharacterInfo,
          where: tci.character_id == ^character_id,
          update: [set: [deleted: true, deleted_at: ^delete_time]]
        )
      end,
      []
    )
    |> Multi.update_all(
      :unassign_character_from_all_worlds,
      fn _ ->
        from(wc in WorldsCharacters,
          where: wc.character_id == ^character_id,
          update: [set: [deleted: true, deleted_at: ^delete_time]]
        )
      end,
      []
    )
    |> Multi.update(:delete_character, fn %{ownership_verification: verified_character} ->
      Character.changeset_delete_character(verified_character)
    end)
    |> Repo.transaction()
  end

  defp deletion_time do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
