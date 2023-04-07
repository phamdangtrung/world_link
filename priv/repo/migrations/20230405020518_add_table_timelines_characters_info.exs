defmodule WorldLink.Repo.Migrations.AddTableTimelinesCharacterInfo do
  use Ecto.Migration

  def change do
    create table(:timelines_character_info, primary_key: false) do
      add(:timeline_id, references(:timelines, on_delete: :delete_all), primary_key: true)

      add(:character_info_id, references(:character_info, on_delete: :delete_all),
        primary_key: true
      )

      add(:character_id, references(:characters, on_delete: :delete_all))
      add(:world_id, references(:worlds, on_delete: :delete_all))
    end

    create index(:timelines_character_info, [:timeline_id])
    create index(:timelines_character_info, [:character_info_id])

    create unique_index(:timelines_character_info, [:timeline_id, :character_info_id],
             name: :timeline_idcharacter_info_id_unique_index
           )
  end
end
