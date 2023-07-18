defmodule WorldLink.Repo.Migrations.CreateAlbumsImages do
  use Ecto.Migration

  def change do
    create table(:albums_images, primary_key: false) do
      add(:album_id, references(:albums, on_delete: :delete_all), primary_key: true)
      add(:image_id, references(:images, on_delete: :delete_all), primary_key: true)
    end

    create(index(:albums_images, [:album_id]))
    create(index(:albums_images, [:image_id]))

    create(
      unique_index(:albums_images, [:album_id, :image_id], name: :album_id_image_id_unique_index)
    )
  end
end
