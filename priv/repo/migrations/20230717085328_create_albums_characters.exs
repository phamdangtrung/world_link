defmodule WorldLink.Repo.Migrations.CreateAlbumsCharacters do
  use Ecto.Migration

  def change do
    create table(:albums_characters, primary_key: false) do
      add(:album_id, references(:albums, on_delete: :delete_all), primary_key: true)
      add(:character_id, references(:characters, on_delete: :delete_all), primary_key: true)
    end

    create(index(:albums_characters, [:album_id]))
    create(index(:albums_characters, [:character_id]))

    create(
      unique_index(:albums_characters, [:album_id, :character_id],
        name: :album_id_character_id_unique_index
      )
    )
  end
end
