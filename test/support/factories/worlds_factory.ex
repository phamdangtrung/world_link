defmodule Support.Factories.WorldsFactory do
  use ExMachina.Ecto, repo: WorldLink.Repo
  alias WorldLink.Worlds.CharacterInfo

  alias WorldLink.Worlds.{
    Character,
    CharacterInfo,
    Timeline,
    TimelinesCharacterInfo,
    World,
    WorldsCharacters
  }

  def world_factory(attrs) do
    %World{
      name: Faker.Nato.callsign()
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def world_params_factory(attrs) do
    %{name: Faker.Nato.callsign()}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def timeline_factory(attrs) do
    %Timeline{
      name: Faker.Nato.callsign()
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def timeline_params_factory(attrs) do
    %{name: Faker.Nato.callsign(), main: false}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def set_timeline_as_main(timeline) do
    %{timeline | main: true}
  end

  def character_factory(attrs) do
    %Character{
      name: Faker.Nato.callsign()
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def character_params_factory(attrs) do
    %{name: Faker.Nato.callsign()}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def character_info_factory(attrs) do
    %CharacterInfo{
      species: Faker.Team.creature(),
      data: %{},
      main: false
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def character_info_params_factory(attrs) do
    %{species: Faker.Team.creature(), data: %{}, main: false}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def worlds_characters_factory(attrs) do
    %WorldsCharacters{}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def timelines_character_info_factory(attrs) do
    %TimelinesCharacterInfo{}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end
end
