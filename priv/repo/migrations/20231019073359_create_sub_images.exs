defmodule WorldLink.Repo.Migrations.CreateSubimage do
  use Ecto.Migration

  def change do
    create table(:sub_images) do
      add(:type, :string, size: 20, null: false, default: "original")
      add(:keyname, :string, size: 1024)

      add(:image_id, references(:images))
      timestamps()
    end
  end
end
