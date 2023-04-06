defmodule WorldLink.Worlds do
  @moduledoc """
  The Worlds context.
  """

  import Ecto.Query, warn: false
  alias WorldLink.Worlds.TimelinesCharacterInfo
  alias Ecto.Multi
  alias WorldLink.Repo
  alias WorldLink.Identity.User
  alias WorldLink.Worlds.{World, Timeline, Character, CharacterInfo}

  def create_a_world(%User{} = user, world_attrs) do
    default_timeline_name = "Main Timeline"

    Multi.new()
    |> Multi.insert(:world, User.changeset_create_a_world(user, world_attrs))
    |> Multi.run(:timeline, fn repo, %{world: world} ->
      World.changeset_create_a_timelines(world, %{
        timeline_name: default_timeline_name,
        main: true
      })
      |> repo.insert()
    end)
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

  @doc """
  An alternative to:
  def assign_a_character_to_a_world(world_id, character_id) do
    retrieve_world_and_character = fn repo, _ ->
      with %World{} = world <- repo.get(World, world_id),
           %Character{} = character <- repo.get(Character, character_id) do
        {:ok, {world, character}}
      else
        %Ecto.NoResultsError{} -> {:error, :world_or_character_not_found}
      end
    end

    assign_character_to_world = fn repo, %{retrieve_world_and_character: {world, character}} ->
      world
      |> World.changeset_assign_a_character(%{world_id: world.id, character_id: character.id})
      |> repo.insert()
    end

    retrieve_main_bio_and_main_timeline = fn repo, %{assign_character_to_world: %WorldsCharacters{} = worlds_characters} ->
      with %Timeline{} = timeline <-
             repo.get_by(Timeline, world_id: worlds_characters.world_id, main: true),
           %CharacterInfo{} = bio <-
             repo.get_by(CharacterInfo, character_id: worlds_characters.character_id, main: true) do
        {:ok, {timeline, bio}}
      else
        %Ecto.NoResultsError{} -> {:error, :timeline_or_bio_not_found}
      end
    end

    assign_bio_to_timeline = fn repo, %{retrieve_main_bio_and_main_timeline: {timeline, bio}} ->
      timeline
      |> Timeline.changeset_assign_a_character_info(%{
        timeline_id: timeline.id,
        character_info_id: bio.id
      })
      |> repo.insert()
    end

    batch =
      Multi.new()
      |> Multi.run(:retrieve_world_and_character, retrieve_world_and_character)
      |> Multi.run(:assign_character_to_world, assign_character_to_world)
      |> Multi.run(:retrieve_main_bio_and_main_timeline, retrieve_main_bio_and_main_timeline)
      |> Multi.run(:assign_bio_to_timeline, assign_bio_to_timeline)

    batch |> Repo.transaction()
  end
  """

  def assign_a_character_to_a_world(world_id, character_id) do
    Multi.new()
    |> retrieve_world_and_character({world_id, character_id})
    |> Multi.insert(:assign_character_to_world, &assign_character_to_world/1)
    |> retrieve_main_bio_and_main_timeline()
    |> Multi.insert(:assign_bio_to_timeline, &assign_bio_to_timeline/1)
    |> Repo.transaction()
  end

  def unassign_a_character_from_a_timeline(timeline_id, bio_id) do
    Multi.new()
    |> retrieve_bio_and_timeline({timeline_id, bio_id})
    |> Multi.delete(:remove_bio_from_timeline, fn %{retrieve_bio_and_timeline: timelines_bio} ->
      timelines_bio |> IO.inspect()
    end)
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

  def own?(user, resource) do
    user.id == resource.user_id
  end
end
