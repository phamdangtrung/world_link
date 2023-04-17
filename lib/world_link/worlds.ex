defmodule WorldLink.Worlds do
  @moduledoc """
  The Worlds context.
  """

  import Ecto.Query, warn: false
  alias WorldLink.Worlds.WorldsCharacters
  alias WorldLink.Worlds.TimelinesCharacterInfo
  alias Ecto.Multi
  alias WorldLink.Repo
  alias WorldLink.Identity.User
  alias WorldLink.Worlds.{World, Timeline, Character, CharacterInfo}

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
      fn %{world: world} ->
        World.changeset_create_a_timelines(world, %{
          name: default_timeline_name,
          main: true
        })
      end
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{world: world, timeline: timeline}} -> {:ok, world, timeline}
      {:error, :world, world_changeset, _} -> {:error, :world, world_changeset}
      {:error, :timeline, timeline_changeset, _} -> {:error, :timeline, timeline_changeset}
    end
  end

  def create_a_timeline(%World{} = world, timeline_attrs) do
    Repo.transaction(fn repo ->
      World.changeset_create_a_timelines(world, timeline_attrs)
      |> repo.insert()
    end)
    |> case do
      {:ok, timeline} -> {:ok, timeline}
      {:error, message} -> {:error, message}
    end
  end

  def create_a_character(%User{} = user, character_attrs) do
    Multi.new()
    |> Multi.insert(:character, User.changeset_create_a_character(user, character_attrs))
    |> Multi.run(:bio, fn repo, %{character: character} ->
      Character.changeset_create_main_bio(character, %{main: true})
      |> repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{character: character, bio: bio}} -> {:ok, character, bio}
      {:error, :character, character_changeset, _} -> {:error, :character, character_changeset}
      {:error, :bio, bio_changeset, _} -> {:error, :bio, bio_changeset}
    end
  end

  def assign_characters_to_a_world(world_id, character_ids) when is_list(character_ids) do
    Enum.each(character_ids, &assign_a_character_to_a_world(world_id, &1))
  end

  def assign_a_character_to_a_world(world_id, character_id) do
    Multi.new()
    |> retrieve_world_and_character({world_id, character_id})
    |> Multi.insert(:assign_character_to_world, &assign_character_to_world/1)
    |> retrieve_main_bio_and_main_timeline()
    |> Multi.insert(:assign_bio_to_timeline, &assign_bio_to_timeline/1)
    |> Repo.transaction()
  end

  defp retrieve_world_and_character(multi, {world_id, character_id}) do
    multi
    |> Multi.run(:retrieve_world_and_character, fn _, _ ->
      with %World{} = world <- Repo.get(World, world_id),
           %Character{} = character <- Repo.get(Character, character_id) do
        {:ok, {world, character}}
      else
        %Ecto.NoResultsError{} -> {:error, :world_or_character_not_found}
      end
    end)
  end

  defp retrieve_main_bio_and_main_timeline(multi) do
    multi
    |> Multi.run(
      :retrieve_main_bio_and_main_timeline,
      fn _,
         %{
           assign_character_to_world: worlds_characters
         } ->
        with %Timeline{} = timeline <-
               Repo.get_by(Timeline, world_id: worlds_characters.world_id, main: true),
             %CharacterInfo{} = character_info <-
               Repo.get_by(CharacterInfo, character_id: worlds_characters.character_id, main: true) do
          {:ok, {timeline, character_info}}
        else
          %Ecto.NoResultsError{} -> {:error, :world_or_character_not_found}
        end
      end
    )
  end

  defp assign_bio_to_timeline(changes) do
    %{
      retrieve_main_bio_and_main_timeline: {timeline, bio},
      retrieve_world_and_character: {world, character}
    } = changes

    timeline
    |> Timeline.changeset_assign_a_character_info(%{
      timeline_id: timeline.id,
      character_info_id: bio.id,
      character_id: character.id,
      world_id: world.id
    })
  end

  def unassign_a_character_from_a_world(world_id, character_id) do
    Multi.new()
    |> retrieve_world_and_character({world_id, character_id})
    |> Multi.delete_all(
      :delete_associated_bio_and_timeline,
      fn %{
           retrieve_world_and_character: {world, character}
         } ->
        from(tci in TimelinesCharacterInfo,
          where: tci.world_id == ^world.id and tci.character_id == ^character.id
        )
      end
    )
    |> Repo.transaction()
  end

  def unassign_a_character_from_a_timeline(timeline_id, bio_id) do
    Multi.new()
    |> retrieve_bio_and_timeline({timeline_id, bio_id})
    |> Multi.delete(:remove_bio_from_timeline, fn %{retrieve_bio_and_timeline: timelines_bio} ->
      timelines_bio
    end)
    |> Repo.transaction()
  end

  defp assign_character_to_world(changes) do
    %{retrieve_world_and_character: {world, character}} = changes

    world
    |> World.changeset_assign_a_character(%{world_id: world.id, character_id: character.id})
  end

  defp retrieve_bio_and_timeline(multi, {timeline_id, bio_id}) do
    multi
    |> Multi.run(
      :retrieve_bio_and_timeline,
      fn _, _ ->
        Repo.get_by(TimelinesCharacterInfo, timeline_id: timeline_id, character_info_id: bio_id)
        |> case do
          %TimelinesCharacterInfo{} = timelines_bio -> {:ok, timelines_bio}
          %Ecto.NoResultsError{} -> {:error, :timeline_or_bio_not_found}
        end
      end
    )
  end

  def transfer_character(character_id, sender_id, recipient_id) do
    Multi.new()
    |> Multi.one(:ownership_verification, fn _ ->
      from(c in Character, where: c.id == ^character_id and c.user_id == ^sender_id)
    end)
    |> Multi.run(:maybe_cancel, &maybe_cancel?/2)
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
  end

  defp maybe_cancel?(_, changes) do
    %{ownership_verification: verified_character} = changes

    verified_character
    |> case do
      %Character{} = character -> {:ok, character}
      _ -> {:error, :unverified_character}
    end
  end

  def delete_character(character_id, user_id) do
    delete_time = DateTime.utc_now() |> DateTime.truncate(:second)

    Multi.new()
    |> Multi.one(
      :ownership_verification,
      fn _ ->
        from(c in Character, where: c.id == ^character_id and c.user_id == ^user_id)
      end
    )
    |> Multi.run(:maybe_cancel, &maybe_cancel?/2)
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
end
