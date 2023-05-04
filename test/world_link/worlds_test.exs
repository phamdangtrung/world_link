defmodule WorldLink.WorldsTest do
  use WorldLink.DataCase

  alias Support.Factories.{IdentityFactory, WorldsFactory}
  alias WorldLink.Worlds

  alias WorldLink.Worlds.{
    Character,
    CharacterInfo,
    Timeline,
    TimelinesCharacterInfo,
    World,
    WorldsCharacters
  }

  describe "create_a_world/2" do
    test "should successfully create a world and return the world" do
      regular_user = IdentityFactory.build(:user) |> IdentityFactory.insert()
      world_params = WorldsFactory.build(:world_params)

      {status, result} = Worlds.create_a_world(regular_user, world_params)

      assert status == :ok
      assert(%World{} = result)
      assert result.name == world_params.name
      assert result.main_timeline
      assert %Timeline{} = result.main_timeline
      assert result.main_timeline.name == "Main Timeline"
    end

    test "should return {:error, %Changeset{}} when fails to validate" do
      regular_user = IdentityFactory.build(:user) |> IdentityFactory.insert()
      world_params = WorldsFactory.build(:world_params, %{name: "smol"})

      {status, reason, result} = Worlds.create_a_world(regular_user, world_params)

      assert status == :error
      assert reason == :create_a_world
      assert %Ecto.Changeset{} = result
    end

    test "should return {:error, :invalid_params} when given invalid parameters a" do
      world_params = WorldsFactory.build(:world_params)

      {status, result} = Worlds.create_a_world(nil, world_params)

      assert status == :error
      assert result == :invalid_params
    end

    test "should return {:error, :invalid_params} when given invalid parameters b" do
      regular_world = WorldsFactory.build(:world) |> WorldsFactory.insert()

      {status, result} = Worlds.create_a_timeline(regular_world, nil)

      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "create_a_timeline/2" do
    test "should successfully create a timeline and return the timeline" do
      regular_world = WorldsFactory.build(:world) |> WorldsFactory.insert()
      timeline_params = WorldsFactory.build(:timeline_params)

      {status, result} = Worlds.create_a_timeline(regular_world, timeline_params)

      assert status == :ok
      assert %Timeline{} = result
      assert result.name == timeline_params.name
    end

    test "should return {:error, %Changeset{}} when fails to validate" do
      regular_world = WorldsFactory.build(:world) |> WorldsFactory.insert()
      timeline_params = WorldsFactory.build(:timeline_params, %{name: "aso"})

      {status, result} = Worlds.create_a_timeline(regular_world, timeline_params)

      assert status == :error
      assert %Ecto.Changeset{} = result
    end

    test "should return {:error, :invalid_params} when given invalid parameters a" do
      timeline_params = WorldsFactory.build(:timeline_params, %{name: "aso"})

      {status, result} = Worlds.create_a_timeline(nil, timeline_params)

      assert status == :error
      assert result == :invalid_params
    end

    test "should return {:error, :invalid_params} when given invalid parameters b" do
      regular_world = WorldsFactory.build(:world) |> WorldsFactory.insert()

      {status, result} = Worlds.create_a_timeline(regular_world, nil)

      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "create_a_character/2" do
    test "should successfully create a character and return the character with its default bio" do
      regular_user = IdentityFactory.build(:user) |> IdentityFactory.insert()
      character_attrs = WorldsFactory.build(:character_params)

      {status, result} = Worlds.create_a_character(regular_user, character_attrs)
      assert is_map(result)
      assert status == :ok
      assert result.character
      assert result.bio
      assert %Character{} = result.character
      assert %CharacterInfo{} = result.bio
      assert result.character.name == character_attrs.name
      assert result.bio.species == "unspecified"
    end

    test "should return {:error, reason, %Ecto.Changeset{}} when fails to validate" do
      regular_user = IdentityFactory.build(:user) |> IdentityFactory.insert()
      character_attrs = WorldsFactory.build(:character_params, %{name: "awo"})

      {status, reason, result} = Worlds.create_a_character(regular_user, character_attrs)
      assert status == :error
      assert reason == :character
      assert %Ecto.Changeset{} = result
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      regular_user = IdentityFactory.build(:user) |> IdentityFactory.insert()

      {status, result} = Worlds.create_a_character(regular_user, nil)
      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "create_a_character_bio/2" do
    test "should successfully create a character bio and return the character bio" do
      regular_user = IdentityFactory.build(:user)
      character = WorldsFactory.build(:character, user: regular_user) |> WorldsFactory.insert()
      character_info_attrs = WorldsFactory.build(:character_info_params)

      {status, result} = Worlds.create_a_character_bio(character, character_info_attrs)

      assert status == :ok
      assert %CharacterInfo{} = result
      assert result.species == character_info_attrs.species
      assert result.data == character_info_attrs.data
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      {status, result} = Worlds.create_a_character_bio(nil, nil)

      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "assign_characters_to_a_world/2" do
    test "should successfully assign all given characters to a world" do
      regular_user = IdentityFactory.build(:user)
      character_a = WorldsFactory.build(:character, user: regular_user) |> WorldsFactory.insert()
      character_b = WorldsFactory.build(:character, user: regular_user) |> WorldsFactory.insert()
      world = WorldsFactory.build(:world, user: regular_user) |> WorldsFactory.insert()

      result = Worlds.assign_characters_to_a_world(world, [character_a, character_b])
      assert is_list(result)
    end

    test "should return {:error, :empty_list} when given a list with no item" do
      regular_user = IdentityFactory.build(:user)
      world = WorldsFactory.build(:world, user: regular_user) |> WorldsFactory.insert()

      {status, result} = Worlds.assign_characters_to_a_world(world, [])
      assert status == :error
      assert result == :empty_list
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      {status, result} = Worlds.assign_characters_to_a_world(nil, [])
      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "assign_a_character_to_a_world/2" do
    test "should successfully assign a given character to a world" do
      regular_user = IdentityFactory.build(:user)
      character = WorldsFactory.build(:character, user: regular_user) |> WorldsFactory.insert()
      world = WorldsFactory.build(:world, user: regular_user) |> WorldsFactory.insert()

      {status, result} = Worlds.assign_a_character_to_a_world(world, character)
      assert status == :ok
      assert %WorldsCharacters{} = result
    end

    test "should return {:error, %Ecto.Changeset{}} when re-assign a character" do
      regular_user = IdentityFactory.build(:user)
      character = WorldsFactory.build(:character, user: regular_user) |> WorldsFactory.insert()
      world = WorldsFactory.build(:world, user: regular_user) |> WorldsFactory.insert()

      Worlds.assign_a_character_to_a_world(world, character)
      {status, result} = Worlds.assign_a_character_to_a_world(world, character)
      assert status == :error
      assert %Ecto.Changeset{} = result
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      {status, result} = Worlds.assign_a_character_to_a_world(nil, nil)
      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "assign_a_character_info_to_a_timeline/2" do
    test "should successfully assign a given character info to a timeline and return the relationship" do
      regular_user = IdentityFactory.build(:user) |> IdentityFactory.insert()
      character = WorldsFactory.build(:character, user: regular_user) |> WorldsFactory.insert()

      character_info =
        WorldsFactory.build(:character_info, character: character) |> WorldsFactory.insert()

      world = WorldsFactory.build(:world, user: regular_user) |> WorldsFactory.insert()
      timeline = WorldsFactory.build(:timeline, world: world) |> WorldsFactory.insert()

      {status, result} = Worlds.assign_a_character_info_to_a_timeline(timeline, character_info)
      assert status == :ok
      assert %TimelinesCharacterInfo{} = result
    end

    test "should return {:error, %Ecto.Changeset{}} when re-assign a character info to a timeline" do
      regular_user = IdentityFactory.build(:user) |> IdentityFactory.insert()
      character = WorldsFactory.build(:character, user: regular_user) |> WorldsFactory.insert()

      character_info =
        WorldsFactory.build(:character_info, character: character) |> WorldsFactory.insert()

      world = WorldsFactory.build(:world, user: regular_user) |> WorldsFactory.insert()
      timeline = WorldsFactory.build(:timeline, world: world) |> WorldsFactory.insert()

      Worlds.assign_a_character_info_to_a_timeline(timeline, character_info)
      {status, result} = Worlds.assign_a_character_info_to_a_timeline(timeline, character_info)
      assert status == :error
      assert %Ecto.Changeset{} = result
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      world = WorldsFactory.build(:world)
      timeline = WorldsFactory.build(:timeline, world: world)

      {status, result} = Worlds.assign_a_character_info_to_a_timeline(timeline, nil)
      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "update_main_timeline/2" do
    test "should successfully update a world's main_timeline" do
      world = WorldsFactory.build(:world) |> WorldsFactory.insert()
      new_timeline = WorldsFactory.build(:timeline, world: world) |> WorldsFactory.insert()

      {status, result} = Worlds.update_main_timeline(world, new_timeline)
      assert status == :ok
      assert %World{} = result
      assert result.main_timeline.name == new_timeline.name
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      world = WorldsFactory.build(:world)

      {status, result} = Worlds.update_main_timeline(world, nil)
      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "update_a_world/2" do
    test "should successfully update a world's attributes" do
      world = WorldsFactory.build(:world) |> WorldsFactory.insert()
      new_world_attrs = WorldsFactory.build(:world_params)

      {status, result} = Worlds.update_a_world(world, new_world_attrs)
      assert status == :ok
      assert %World{} = result
      assert result.name == new_world_attrs.name
    end

    test "should return {:error, %Ecto.Changeset{}} when fails to validate" do
      world = WorldsFactory.build(:world) |> WorldsFactory.insert()
      new_world_attrs = WorldsFactory.build(:world_params, %{name: "aw"})

      {status, result} = Worlds.update_a_world(world, new_world_attrs)
      assert status == :error
      assert %Ecto.Changeset{} = result
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      world = WorldsFactory.build(:world)

      {status, result} = Worlds.update_a_world(world, nil)
      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "update_a_character/2" do
    test "should successfully update a world's attributes" do
      character = WorldsFactory.build(:character) |> WorldsFactory.insert()
      new_character_attrs = WorldsFactory.build(:character_params)

      {status, result} = Worlds.update_a_character(character, new_character_attrs)
      assert status == :ok
      assert %Character{} = result
      assert result.name == new_character_attrs.name
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      character = WorldsFactory.build(:character) |> WorldsFactory.insert()

      {status, result} = Worlds.update_a_character(character, nil)
      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "update_a_character_info/2" do
    test "should successfully update a world's attributes" do
      character_info = WorldsFactory.build(:character_info) |> WorldsFactory.insert()
      new_character_info_attrs = WorldsFactory.build(:character_info_params)

      {status, result} = Worlds.update_a_character_info(character_info, new_character_info_attrs)
      assert status == :ok
      assert %CharacterInfo{} = result
      assert result.species == new_character_info_attrs.species
      assert result.data == new_character_info_attrs.data
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      character_info = WorldsFactory.build(:character_info) |> WorldsFactory.insert()

      {status, result} = Worlds.update_a_character_info(character_info, nil)
      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "update_a_timeline/2" do
    test "should successfully update a world's attributes" do
      timeline = WorldsFactory.build(:timeline) |> WorldsFactory.insert()
      new_timeline_attrs = WorldsFactory.build(:timeline_params)

      {status, result} = Worlds.update_a_timeline(timeline, new_timeline_attrs)
      assert status == :ok
      assert %Timeline{} = result
      assert result.name == new_timeline_attrs.name
    end

    test "should return {:error, %Ecto.Changeset{}} when fails to validate" do
      timeline = WorldsFactory.build(:timeline) |> WorldsFactory.insert()
      new_timeline_attrs = WorldsFactory.build(:timeline_params, %{name: "awo"})

      {status, result} = Worlds.update_a_timeline(timeline, new_timeline_attrs)
      assert status == :error
      assert %Ecto.Changeset{} = result
    end

    test "should return {:error, :invalid_params} when given invalid parameters" do
      timeline = WorldsFactory.build(:timeline) |> WorldsFactory.insert()

      {status, result} = Worlds.update_a_timeline(timeline, nil)
      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "delete_a_world/1" do
    test "should successfully delete a world and return :ok" do
      world = WorldsFactory.build(:world) |> WorldsFactory.insert()

      result = Worlds.delete_a_world(world)
      refreshed_world = Repo.get(World, world.id)
      assert result == :ok
      assert refreshed_world
      assert refreshed_world.deleted == true
      assert refreshed_world.deleted_at
    end

    test "should return {:error, :invalid_params}" do
      {status, result} = Worlds.delete_a_world(nil)

      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "delete_a_timeline/1" do
    test "should successfully delete a timeline and return :ok" do
      timeline = WorldsFactory.build(:timeline) |> WorldsFactory.insert()

      result = Worlds.delete_a_timeline(timeline)
      refreshed_timeline = Repo.get(Timeline, timeline.id)
      assert result == :ok
      assert refreshed_timeline
      assert refreshed_timeline.deleted == true
      assert refreshed_timeline.deleted_at
    end

    test "should return {:error, :invalid_params}" do
      {status, result} = Worlds.delete_a_timeline(nil)

      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "delete_a_character/1" do
    test "should successfully delete a character and return :ok" do
      character = WorldsFactory.build(:character) |> WorldsFactory.insert()

      result = Worlds.delete_a_character(character)
      refreshed_character = Repo.get(Character, character.id)
      assert result == :ok
      assert refreshed_character
      assert refreshed_character.deleted == true
      assert refreshed_character.deleted_at
    end

    test "should return {:error, :invalid_params}" do
      {status, result} = Worlds.delete_a_character(nil)

      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "unassign_a_character_from_a_world/2" do
    test "should successfully delete related worlds_characters record and return :ok" do
      character = WorldsFactory.build(:character) |> WorldsFactory.insert()
      world = WorldsFactory.build(:world) |> WorldsFactory.insert()
      Worlds.assign_a_character_to_a_world(world, character)

      {status, result} = Worlds.unassign_a_character_from_a_world(world, character)

      assert status == :ok
      assert result
      assert %WorldsCharacters{} = result
      assert result.deleted_at
      assert result.deleted == true
    end

    test "should return {:error, :invalid_params}" do
      {status, result} = Worlds.unassign_a_character_from_a_world(nil, nil)

      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "unassign_a_character_from_a_timeline/2" do
    test "should successfully delete related timelines_character_info record and return {:ok, %TimelinesCharacterInfo{}}" do
      character = WorldsFactory.build(:character) |> WorldsFactory.insert()

      character_info =
        WorldsFactory.build(:character_info, character: character) |> WorldsFactory.insert()

      world = WorldsFactory.build(:world) |> WorldsFactory.insert()
      timeline = WorldsFactory.build(:timeline, world: world) |> WorldsFactory.insert()
      Worlds.assign_a_character_info_to_a_timeline(timeline, character_info)

      {status, result} = Worlds.unassign_a_character_from_a_timeline(timeline, character_info)

      assert status == :ok
      assert %TimelinesCharacterInfo{} = result
      assert result
      assert result.deleted_at
      assert result.deleted == true
    end

    test "should return {:error, :invalid_params}" do
      {status, result} = Worlds.unassign_a_character_from_a_timeline(nil, nil)

      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "transfer_character/2" do
    test "should successfully transfer character to recipient and return :ok" do
      user_a = IdentityFactory.build(:user) |> IdentityFactory.insert()
      user_b = IdentityFactory.build(:user) |> IdentityFactory.insert()
      character = WorldsFactory.build(:character, user: user_a) |> WorldsFactory.insert()

      result = Worlds.transfer_character(character, user_b)
      refreshed_character = Repo.get(Character, character.id) |> Repo.preload(:user)

      assert result == :ok
      refute refreshed_character.user.id == character.user.id
      assert refreshed_character.user.id == user_b.id
    end

    test "should return {:error, :invalid_params}" do
      {status, result} = Worlds.transfer_character(nil, nil)

      assert status == :error
      assert result == :invalid_params
    end
  end

  describe "delete_character/1" do
    test "should successfully transfer character to recipient and return :ok" do
      character = WorldsFactory.build(:character) |> WorldsFactory.insert()

      result = Worlds.delete_character(character)
      refreshed_character = Repo.get(Character, character.id)

      assert result == :ok
      assert refreshed_character
      assert refreshed_character.deleted_at
      assert refreshed_character.deleted == true
    end

    test "should return {:error, :invalid_params}" do
      {status, result} = Worlds.delete_character(nil)

      assert status == :error
      assert result == :invalid_params
    end
  end
end
