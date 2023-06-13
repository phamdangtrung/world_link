defmodule WorldLink.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add(:artist, :string, size: 50)
      add(:artist_contact, :string, size: 255)
      add(:commission, :boolean, default: false, null: false)
      add(:commissioner, :string, size: 50)
      add(:commissioner_contact, :string, size: 255)
      add(:content_type, :string, size: 255)
      add(:date, :utc_datetime)
      add(:description, :string, size: 2000)
      add(:exif, :map, default: %{})
      add(:file_name, :string, size: 255)
      add(:file_size, :integer)
      add(:gore, :boolean, default: false, null: false)
      add(:key, :string, size: 40)
      add(:nsfw, :boolean, default: false, null: false)
      add(:sensitive, :boolean, default: false, null: false)
      add(:title, :string)
      add(:url, :string)

      add(:user_id, references(:users))
      timestamps()
    end
  end
end
