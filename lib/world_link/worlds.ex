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
    end
  end

  def create_a_world(_, _), do: {:error, :invalid_params}

  @doc """
  Creates a new timeline for a world.

  ## Examples

      iex> create_a_timeline(world, %{name: "a whole new timeline"})
      {:ok, %Timeline{}}

      iex> create_a_timeline(user, %{name: "a wo"})
      {:error, %Ecto.Changeset{}}

  """
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

  @doc """
  Creates a new character for a user.

  ## Examples

      iex> create_a_character(user, %{name: "a whole new character"})
      {:ok, %{character: %Character{}, bio: %CharacterInfo{}}}

      iex> create_a_character(user, %{name: "a wo"})
      {:error, :character, %Ecto.Changeset{}}

  """
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
    end
  end

  @doc """
  Creates a new bio for a character.

  ## Examples

      iex> create_a_character_bio(user, %{species: "human", data: %{height: 150cm}})
      {:ok, %CharacterInfo{}}

      iex> create_a_character_bio(user, %{species: "aw"})
      {:error, %Ecto.Changeset{}}

  """
  def create_a_character_bio(%User{} = user, character_info_attrs) do
    Repo.transaction(fn repo ->
      Character.changeset_create_bio(user, character_info_attrs)
      |> repo.insert()
    end)
    |> case do
      {:ok, character_info} -> {:ok, character_info}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Assigns a list of characters to a world.

  ## Examples

      iex> assign_characters_to_a_world(user, [character_a, character_b])
      {:ok, [list]}

      iex> assign_characters_to_a_world(user, [])
      {:error, :empty_list}

  """
  def assign_characters_to_a_world(world, characters) when is_list(characters) do
    {:ok, Enum.map(characters, &assign_a_character_to_a_world(world, &1))}
  end

  def assign_characters_to_a_world(_world, []), do: {:error, :empty_list}

  @doc """
  Assigns a character to a world.

  ## Examples

      iex> assign_a_character_to_a_world(world, character)
      {:ok, %WorldsCharacters{}}

      iex> assign_a_character_to_a_world(user, [])
      {:error, %Ecto.Changeset{}}

  """
  def assign_a_character_to_a_world(world, character) do
    Repo.transaction(fn repo ->
      repo.insert(
        world
        |> World.changeset_assign_a_character(%{world_id: world.id, character_id: character.id})
      )
    end)
    |> case do
      {:ok, world_character} -> {:ok, world_character}
      {:error, message} -> {:error, message}
      result -> {:error, result}
    end
  end

  @doc """
  Assigns a character info to a timeline.

  ## Examples

      iex> assign_a_character_info_to_a_timeline(timeline, character_info)
      {:ok, %TimelinesCharacterInfo{}}

      iex> assign_a_character_info_to_a_timeline(timeline, character_info)
      {:error, %Ecto.Changeset{}}

  """
  def assign_a_character_info_to_a_timeline(timeline, character_info) do
    timeline = timeline |> Repo.preload(:world)
    character_info = character_info |> Repo.preload(:character)

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
    |> case do
      {:ok, timelines_character_info} -> {:ok, timelines_character_info}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Updates the main timeline of a world.

  ## Examples

      iex> update_main_timeline(timeline, character_info)
      {:ok, %World{}}

      iex> update_main_timeline(timeline, character_info)
      {:error, %Ecto.Changeset{}}

  """
  def update_main_timeline(world, timeline) do
    Repo.transaction(fn repo ->
      world
      |> preload(:main_timeline)
      |> World.changeset_update_main_timeline(timeline)
      |> repo.update()
    end)
    |> case do
      {:ok, world} -> {:ok, world}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates attributes of a world.

  ## Examples

      iex> update_a_world(world, %{name: "a whole new world update"})
      {:ok, %World{}}

      iex> update_a_world(world, %{name: "aw"})
      {:error, %Ecto.Changeset{}}

  """
  def update_a_world(world, new_world_attrs) do
    Repo.transaction(fn repo ->
      world
      |> World.world_changeset(new_world_attrs)
      |> repo.update()
    end)
    |> case do
      {:ok, updated_world} -> {:ok, updated_world}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates attributes of a character.

  ## Examples

      iex> update_a_character(character, %{name: "a whole new character"})
      {:ok, %Character{}}

      iex> update_a_character(character, %{name: "aw"})
      {:error, %Ecto.Changeset{}}

  """
  def update_a_character(character, new_character_attrs) do
    Repo.transaction(fn repo ->
      character
      |> Character.character_changeset(new_character_attrs)
      |> repo.update()
    end)
    |> case do
      {:ok, updated_character} -> {:ok, updated_character}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates attributes of a character info.

  ## Examples

      iex> update_a_character_info(character_info, %{species: "a whole new species"})
      {:ok, %CharacterInfo{}}

      iex> update_a_character_info(character_info, %{species: "aw"})
      {:error, %Ecto.Changeset{}}

  """
  def update_a_character_info(character_info, new_character_info_attrs) do
    Repo.transaction(fn repo ->
      character_info
      |> CharacterInfo.changeset(new_character_info_attrs)
      |> repo.update()
    end)
    |> case do
      {:ok, updated_character_info} -> {:ok, updated_character_info}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates attributes of a timeline.

  ## Examples

      iex> update_a_timeline(timeline, %{name: "a whole new timeline"})
      {:ok, %Timeline{}}

      iex> update_a_timeline(timeline, %{name: "aw"})
      {:error, %Ecto.Changeset{}}

  """
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

  @doc """
  Marks a world and its associated timelines as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> delete_a_world(world)
      :ok

      iex> delete_a_world(world)
      {:error, reason, %Ecto.Changeset{}}

  """
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

  @doc """
  Marks a timeline and its associated character info as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> delete_a_timeline(timeline)
      :ok

      iex> delete_a_timeline(timeline)
      {:error, reason, %Ecto.Changeset{}}

  """
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

  @doc """
  Marks a character and its character info as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> delete_a_character(character)
      :ok

      iex> delete_a_character(character)
      {:error, reason, %Ecto.Changeset{}}

  """
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

  @doc """
  Unassigns a character from a world and marks its associations as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> unassign_a_character_from_a_world(world, character)
      :ok

      iex> unassign_a_character_from_a_world(world, character)
      {:error, reason, %Ecto.Changeset{}}

  """
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
    |> Multi.update_all(
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
        :ok

      {:error, :delete_associated_timelines_character_info,
       delete_associated_timelines_character_info, _} ->
        {:error, :delete_associated_timelines_character_info,
         delete_associated_timelines_character_info}

      {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters, _} ->
        {:error, :delete_associated_worlds_characters, delete_associated_worlds_characters}
    end
  end

  @doc """
  Unassigns a character from a timeline and marks its associations as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> unassign_a_character_from_a_timeline(world, character)
      :ok

      iex> unassign_a_character_from_a_timeline(world, character)
      {:error, %Ecto.Changeset{}}

  """
  def unassign_a_character_from_a_timeline(timeline, character_info) do
    deletion_time = deletion_time()

    Repo.transaction(fn repo ->
      repo.update(
        from(tci in TimelinesCharacterInfo,
          where: tci.timeline_id == ^timeline.id and tci.character_info_id == ^character_info.id,
          update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
        )
      )
    end)
    |> case do
      {:ok, timelines_character_info} -> {:ok, timelines_character_info}
      {:error, timelines_character_info_changeset} -> {:error, timelines_character_info_changeset}
    end
  end

  @doc """
  Transfers a character to another user.

  ## Examples

      iex> transfer_character(character, recipient)
      :ok

      iex> transfer_character(character, recipient)
      {:error, reason, %Ecto.Changeset{}}

  """
  def transfer_character(character, recipient) do
    deletion_time = deletion_time()

    Multi.new()
    |> Multi.update_all(
      :unassign_character_from_all_timelines,
      from(tci in TimelinesCharacterInfo,
        where: tci.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
      ),
      []
    )
    |> Multi.update_all(
      :unassign_character_from_all_worlds,
      from(wc in WorldsCharacters,
        where: wc.character_id == ^character.id,
        update: [set: [deleted: true, deleted_at: ^deletion_time, updated_at: ^deletion_time]]
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

  @doc """
  Marks a character and its associations as deleted and updates [:deleted_at, :updated_at].

  ## Examples

      iex> delete_character(character)
      :ok

      iex> delete_character(character)
      {:error, reason, %Ecto.Changeset{}}

  """
  def delete_character(character) do
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

  defp deletion_time do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
