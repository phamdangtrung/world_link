defmodule WorldLink.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add(:artist, :string, size: 50)
      add(:artist_contact, :string, size: 255)
      add(:commission, :boolean, default: false, null: false)
      add(:commissioner, :string, size: 50)
      add(:commissioner_contact, :string, size: 255)
      add(:content_length, :integer)
      add(:content_type, :string, size: 255)
      add(:date, :utc_datetime)
      add(:description, :string, size: 2000)
      add(:exif, :map, default: %{})
      add(:original_filename, :string, size: 255)
      add(:gore, :boolean, default: false, null: false)
      add(:nsfw, :boolean, default: false, null: false)
      add(:sensitive, :boolean, default: false, null: false)
      add(:shared, :boolean, default: false, null: false)
      add(:title, :string, size: 255)
      add(:url, :string, size: 1600)

      add(:user_id, references(:users))
      timestamps()
    end
  end
end
