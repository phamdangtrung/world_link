defmodule WorldLink.Repo.Migrations.CreateImageUrls do
  use Ecto.Migration

  def change do
    create table(:image_urls) do
      add(:type, :string, size: 20, null: false, default: "original")
      add(:s3_url, :string, size: 1600)
      add(:url, :string, size: 1600)

      add(:image_id, references(:images))
      timestamps()
    end
  end
end
