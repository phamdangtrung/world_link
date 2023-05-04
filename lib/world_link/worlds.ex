defmodule WorldLink.Worlds do
  @moduledoc """
  API for interacting with Worlds context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias WorldLink.Identity.User
  alias WorldLink.Repo

  alias WorldLink.Worlds.{
    Character,
    CharacterInfo,
    Timeline,
    TimelinesCharacterInfo,
    World,
    WorldsCharacters
  }

  @doc """
  Creates a new world for a given user.

  ## Examples

      iex> create_a_world(user, %{name: "a whole new world"})
      {:ok, %World{}}

      iex> create_a_world(user, %{name: "a wo"})
      {:error, :create_a_world, %Ecto.Changeset{}}

      iex> create_a_world(nil, %{name: "a whole new world"})
      {:error, :invalid_params}

  """
  def create_a_world(%User{} = user, %{} = world_attrs) do
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
       %{
         create_a_world: _new_world,
         create_main_timeline: _timeline,
         update_main_timeline: world
       }} ->
        {:ok, world}

      {:error, :create_a_world, world_changeset, _} ->
        {:error, :create_a_world, world_changeset}
    end
  end

  def create_a_world(_, _), do: {:error, :invalid_params}

  @doc """
  Creates a new timeline for a world.

  ## Examples

      iex> create_a_timeline(world, %{name: "a whole new timeline"})
      {:ok, %Timeline{}}

      iex> create_a_timeline(world, %{name: "a wo"})
      {:error, %Ecto.Changeset{}}

      iex> create_a_timeline(nil, nil)
      {:error, :invalid_params}

  """
  def create_a_timeline(%World{} = world, %{} = timeline_attrs) do
    {_, {status, result}} =
      Repo.transaction(fn repo ->
        World.changeset_create_a_timelines(world, timeline_attrs)
        |> repo.insert()
      end)

    {status, result}
  end

  def create_a_timeline(_, _), do: {:error, :invalid_params}

  @doc """
  Creates a new character for a user.

  ## Examples

      iex> create_a_character(user, %{name: "a whole new character"})
      {:ok, %{character: %Character{}, bio: %CharacterInfo{}}}

      iex> create_a_character(user, %{name: "a wo"})
      {:error, :character, %Ecto.Changeset{}}

      iex> create_a_character(nil, nil)
      {:error, :invalid_params}

  """
  def create_a_character(%User{} = user, %{} = character_attrs) do
    Multi.new()
    |> Multi.insert(:character, User.changeset_create_a_character(user, character_attrs))
    |> Multi.insert(:bio, fn %{character: character} ->
      Character.changeset_create_bio(character, %{})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{character: character, bio: bio}} -> {:ok, %{character: character, bio: bio}}
      {:error, :character, character_changeset, _} -> {:error, :character, character_changeset}
    end
  end

  def create_a_character(_, _), do: {:error, :invalid_params}

  @doc """
  Creates a new bio for a character.

  ## Examples

      iex> create_a_character_bio(character, %{species: "human", data: %{height: 150cm}})
      {:ok, %CharacterInfo{}}

      iex> create_a_character_bio(character, %{species: "aw"})
      {:error, %Ecto.Changeset{}}

      iex> create_a_character_bio(nil, %{species: "aw"})
      {:error, :invalid_params}

  """
  def create_a_character_bio(%Character{} = character, %{} = character_info_attrs) do
    {_, {status, result}} =
      Repo.transaction(fn repo ->
        Character.changeset_create_bio(character, character_info_attrs)
        |> repo.insert()
      end)

    {status, result}
  end

  def create_a_character_bio(_, _), do: {:error, :invalid_params}

  @doc """
  Assigns a list of characters to a world.

  ## Examples

      iex> assign_characters_to_a_world(world, [character_a, character_b])
      [list]

      iex> assign_characters_to_a_world(world, [])
      {:error, :empty_list}

      iex> assign_characters_to_a_world(world, nil)
      {:error, :invalid_params}

  """
  def assign_characters_to_a_world(%World{}, []), do: {:error, :empty_list}

  def assign_characters_to_a_world(%World{} = world, characters) when is_list(characters) do
    Enum.map(characters, &assign_a_character_to_a_world(world, &1))
  end

  def assign_characters_to_a_world(_, _), do: {:error, :invalid_params}

  @doc """
  Assigns a character to a world.

  ## Examples

      iex> assign_a_character_to_a_world(world, character)
      {:ok, %WorldsCharacters{}}

      iex> assign_a_character_to_a_world(world, character)
      {:error, %Ecto.Changeset{}}

      iex> assign_a_character_to_a_world(world, [])
      {:error, :invalid_params}

  """
  def assign_a_character_to_a_world(%World{} = world, %Character{} = character) do
    {_, {status, result}} =
      Repo.transaction(fn repo ->
        repo.insert(
          world
          |> World.changeset_assign_a_character(%{world_id: world.id, character_id: character.id})
        )
      end)

    {status, result}
  end

  def assign_a_character_to_a_world(_, _), do: {:error, :invalid_params}

  @doc """
  Assigns a character info to a timeline.

  ## Examples

      iex> assign_a_character_info_to_a_timeline(timeline, character_info)
      {:ok, %TimelinesCharacterInfo{}}

      iex> assign_a_character_info_to_a_timeline(timeline, character_info)
      {:error, %Ecto.Changeset{}}

      iex> assign_a_character_info_to_a_timeline(nil, character_info)
      {:error, :invalid_params}

  """
  def assign_a_character_info_to_a_timeline(
        %Timeline{} = timeline,
        %CharacterInfo{} = character_info
      ) do
    timeline = timeline |> Repo.preload(:world)
    character_info = character_info |> Repo.preload(:character)

    {_, {status, result}} =
      Repo.transaction(fn repo ->
        repo.insert(
          timeline
          |> Timeline.changeset_assign_a_character_info(%{
            timeline_id: timeline.id,
            character_info_id: character_info.id,
            character_id: character_info.character.id,
            world_id: timeline.world.id
          })
        )
      end)

    {status, result}
  end

  def assign_a_character_info_to_a_timeline(_, _), do: {:error, :invalid_params}

  @doc """
  Updates the main timeline of a world.

  ## Examples

      iex> update_main_timeline(world, timeline)
      {:ok, %World{}}

      iex> update_main_timeline(world, timeline)
      {:error, reason, %Ecto.Changeset{}}

      iex> update_main_timeline(world, nil)
      {:error, :invalid_params}

  """
  def update_main_timeline(%World{} = world, %Timeline{} = timeline) do
    Multi.new()
    |> Multi.update(
      :remove_current_main_timeline,
      world
      |> Ecto.Changeset.change(main_timeline_id: nil)
    )
    |> Multi.update(
      :update_main_timeline,
      world
      |> Repo.preload(:main_timeline)
      |> World.changeset_update_main_timeline(timeline)
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{remove_current_main_timeline: _, update_main_timeline: world}} ->
        {:ok, world}

      {:error, :remove_current_main_timeline, remove_current_main_timeline, _} ->
        {:error, :remove_current_main_timeline, remove_current_main_timeline}

      {:error, :update_main_timeline, update_main_timeline, _} ->
        {:error, :update_main_timeline, update_main_timeline}
    end
  end

  def update_main_timeline(_, _), do: {:error, :invalid_params}

  @doc """
  Updates attributes of a world.

  ## Examples

      iex> update_a_world(world, %{name: "a whole new world update"})
      {:ok, %World{}}

      iex> update_a_world(world, %{name: "aw"})
      {:error, %Ecto.Changeset{}}

      iex> update_a_world(world, nil)
      {:error, :invalid_params}

  """
  def update_a_world(%World{} = world, %{} = new_world_attrs) do
    {_, {status, result}} =
      Repo.transaction(fn repo ->
        world
        |> World.world_changeset(new_world_attrs)
        |> repo.update()
      end)

    {status, result}
  end

  def update_a_world(_, _), do: {:error, :invalid_params}

  @doc """
  Updates attributes of a character.

  ## Examples

      iex> update_a_character(character, %{name: "a whole new character"})
      {:ok, %Character{}}

      iex> update_a_character(character, %{name: "aw"})
      {:error, %Ecto.Changeset{}}

      iex> update_a_character(character, %{name: "aw"})
      {:error, :invalid_params}

  """
  def update_a_character(%Character{} = character, %{} = new_character_attrs) do
    {_, {status, result}} =
      Repo.transaction(fn repo ->
        character
        |> Character.character_changeset(new_character_attrs)
        |> repo.update()
      end)

    {status, result}
  end

  def update_a_character(_, _), do: {:error, :invalid_params}

  @doc """
  Updates attributes of a character info.

  ## Examples

      iex> update_a_character_info(character_info, %{species: "a whole new species"})
      {:ok, %CharacterInfo{}}

      iex> update_a_character_info(character_info, %{species: "aw"})
      {:error, %Ecto.Changeset{}}

      iex> update_a_character_info(nil, %{species: "aw"})
      {:error, :invalid_params}

  """
  def update_a_character_info(%CharacterInfo{} = character_info, %{} = new_character_info_attrs) do
    {_, {status, result}} =
      Repo.transaction(fn repo ->
        character_info
        |> CharacterInfo.changeset(new_character_info_attrs)
        |> repo.update()
      end)

    {status, result}
  end

  def update_a_character_info(_, _), do: {:error, :invalid_params}

  @doc """
  Updates attributes of a timeline.

  ## Examples

      iex> update_a_timeline(timeline, %{name: "a whole new timeline"})
      {:ok, %Timeline{}}

      iex> update_a_timeline(timeline, %{name: "aw"})
      {:error, %Ecto.Changeset{}}

      iex> update_a_timeline(timeline, nil)
      {:error, :invalid_params}

  """
  def update_a_timeline(%Timeline{} = timeline, %{} = new_timeline_attrs) do
    {_, {status, result}} =
      Repo.transaction(fn repo ->
        timeline
        |> Timeline.timeline_changeset(new_timeline_attrs)
        |> repo.update()
      end)

    {status, result}
  end

  def update_a_timeline(_, _), do: {:error, :invalid_params}

  @doc """
  Marks a world and its associated timelines as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> delete_a_world(world)
      :ok

      iex> delete_a_world(world)
      {:error, reason, %Ecto.Changeset{}}

      iex> delete_a_world(nil)
      {:error, :invalid_params}

  """
  def delete_a_world(%World{} = world) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :delete_associated_timelines_character_info,
      from(tci in TimelinesCharacterInfo,
        where: tci.world_id == ^world.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
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
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
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
         delete_associated_timelines_character_info: _delete_associated_timelines_character_info,
         delete_associated_timelines: _delete_associated_timelines,
         delete_associated_worlds_characters: _delete_associated_worlds_characters,
         delete_world: _delete_world
       }} ->
        :ok

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

  def delete_a_world(_), do: {:error, :invalid_params}

  @doc """
  Marks a timeline and its associated character info as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> delete_a_timeline(timeline)
      :ok

      iex> delete_a_timeline(timeline)
      {:error, reason, %Ecto.Changeset{}}

      iex> delete_a_timeline(nil)
      {:error, :invalid_params}

  """
  def delete_a_timeline(%Timeline{} = timeline) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :delete_associated_timelines_character_info,
      from(tci in TimelinesCharacterInfo,
        where: tci.timeline_id == ^timeline.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
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
         delete_associated_timelines_character_info: _delete_associated_timelines_character_info,
         delete_timeline: _delete_associated_timelines
       }} ->
        :ok

      {:error, :delete_associated_timelines_character_info,
       delete_associated_timelines_character_info, _} ->
        {:error, :delete_associated_timelines_character_info,
         delete_associated_timelines_character_info}

      {:error, :delete_timeline, delete_timeline, _} ->
        {:error, :delete_timeline, delete_timeline}
    end
  end

  def delete_a_timeline(_), do: {:error, :invalid_params}

  @doc """
  Marks a character and its character info as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> delete_a_character(character)
      :ok

      iex> delete_a_character(character)
      {:error, reason, %Ecto.Changeset{}}

      iex> delete_a_character(nil)
      {:error, :invalid_params}

  """
  def delete_a_character(%Character{} = character) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :delete_associated_timelines_character_info,
      from(tci in TimelinesCharacterInfo,
        where: tci.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
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
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update(
      :delete_character,
      Character.changeset_delete_character(character, deletion_time)
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         delete_associated_timelines_character_info: _delete_associated_timelines_character_info,
         delete_associated_character_info: _delete_associated_character_info,
         delete_associated_worlds_characters: _delete_associated_worlds_characters,
         delete_character: _delete_character
       }} ->
        :ok

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

  def delete_a_character(_), do: {:error, :invalid_params}

  @doc """
  Unassigns a character from a world and marks its associations as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> unassign_a_character_from_a_world(world, character)
      :ok

      iex> unassign_a_character_from_a_world(world, character)
      {:error, reason, %Ecto.Changeset{}}

      iex> unassign_a_character_from_a_world(world, nil)
      {:error, :invalid_params}

  """
  def unassign_a_character_from_a_world(%World{} = world, %Character{} = character) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :delete_associated_timelines_character_info,
      from(tci in TimelinesCharacterInfo,
        where: tci.character_id == ^character.id and tci.world_id == ^world.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update(
      :delete_associated_worlds_characters,
      fn _ ->
        Repo.get_by(WorldsCharacters, world_id: world.id, character_id: character.id)
        |> WorldsCharacters.changeset_delete_worlds_characters()
      end,
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         delete_associated_timelines_character_info: _delete_associated_timelines_character_info,
         delete_associated_worlds_characters: delete_associated_worlds_characters
       }} ->
        {:ok, delete_associated_worlds_characters}

      {:error, :delete_associated_timelines_character_info,
       delete_associated_timelines_character_info, _} ->
        {:error, :delete_associated_timelines_character_info,
         delete_associated_timelines_character_info}

      {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters, _} ->
        {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters}
    end
  end

  def unassign_a_character_from_a_world(_, _), do: {:error, :invalid_params}

  @doc """
  Unassigns a character from a timeline and marks its associations as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> unassign_a_character_from_a_timeline(world, character)
      :ok

      iex> unassign_a_character_from_a_timeline(world, character)
      {:error, %Ecto.Changeset{}}

      iex> unassign_a_character_from_a_timeline(world, nil)
      {:error, :invalid_params}

  """
  def unassign_a_character_from_a_timeline(
        %Timeline{} = timeline,
        %CharacterInfo{} = character_info
      ) do
    {_, {status, result}} =
      Repo.transaction(fn repo ->
        repo.get_by(TimelinesCharacterInfo,
          timeline_id: timeline.id,
          character_info_id: character_info.id
        )
        |> TimelinesCharacterInfo.changeset_delete_timelines_character_info()
        |> repo.update()
      end)

    {status, result}
  end

  def unassign_a_character_from_a_timeline(_, _), do: {:error, :invalid_params}

  @doc """
  Transfers a character to another user.

  ## Examples

      iex> transfer_character(character, recipient)
      :ok

      iex> transfer_character(character, recipient)
      {:error, reason, %Ecto.Changeset{}}

      iex> transfer_character(character, nil)
      {:error, :invalid_params}

  """
  def transfer_character(%Character{} = character, %User{} = recipient) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :unassign_character_from_all_timelines,
      from(tci in TimelinesCharacterInfo,
        where: tci.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update_all(
      :unassign_character_from_all_worlds,
      from(wc in WorldsCharacters,
        where: wc.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update(
      :transfer_character,
      Character.changeset_update_ownership(character, %{user_id: recipient.id})
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         unassign_character_from_all_timelines: _unassign_character_from_all_timelines,
         unassign_character_from_all_worlds: _unassign_character_from_all_worlds,
         transfer_character: _transfer_character
       }} ->
        :ok

      {:error, :unassign_character_from_all_timelines, unassign_character_from_all_timelines, _} ->
        {:error, :unassign_character_from_all_timelines, unassign_character_from_all_timelines}

      {:error, :unassign_character_from_all_worlds, unassign_character_from_all_worlds, _} ->
        {:error, :unassign_character_from_all_worlds, unassign_character_from_all_worlds}

      {:error, :transfer_character, transfer_character, _} ->
        {:error, :transfer_character, transfer_character}
    end
  end

  def transfer_character(_, _), do: {:error, :invalid_params}

  @doc """
  Marks a character and its associations as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> delete_character(character)
      :ok

      iex> delete_character(character)
      {:error, reason, %Ecto.Changeset{}}

      iex> delete_character(nil)
      {:error, :invalid_params}

  """
  def delete_character(%Character{} = character) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :unassign_character_from_all_timelines,
      from(tci in TimelinesCharacterInfo,
        where: tci.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update_all(
      :unassign_character_from_all_worlds,
      from(wc in WorldsCharacters,
        where: wc.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update(
      :delete_character,
      Character.changeset_delete_character(character, deletion_time)
    )
    |> Repo.transaction()
    |> case do
      {:ok,
       %{
         unassign_character_from_all_timelines: _unassign_character_from_all_timelines,
         unassign_character_from_all_worlds: _unassign_character_from_all_worlds,
         delete_character: _delete_character
       }} ->
        :ok

      {:error, :unassign_character_from_all_timelines, unassign_character_from_all_timelines, _} ->
        {:error, :unassign_character_from_all_timelines, unassign_character_from_all_timelines}

      {:error, :unassign_character_from_all_worlds, unassign_character_from_all_worlds, _} ->
        {:error, :unassign_character_from_all_worlds, unassign_character_from_all_worlds}

      {:error, :delete_character, delete_character, _} ->
        {:error, :delete_character, delete_character}
    end
  end

  def delete_character(_), do: {:error, :invalid_params}

  defp deletion_time do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
