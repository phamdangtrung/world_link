defmodule WorldLink.Repo.Migrations.AddTableWorldsCharacters do
  use Ecto.Migration

  def change do
    create table(:worlds_characters, primary_key: false) do
      add(:world_id, references(:worlds, on_delete: :delete_all), primary_key: true)
      add(:character_id, references(:characters, on_delete: :delete_all), primary_key: true)
    end

    create(index(:worlds_characters, [:world_id]))
    create(index(:worlds_characters, [:character_id]))

    create(
      unique_index(:worlds_characters, [:world_id, :character_id],
        name: :world_id_character_id_unique_index
      )
    )
  end
end
