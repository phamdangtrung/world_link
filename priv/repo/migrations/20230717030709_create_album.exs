defmodule WorldLink.Repo.Migrations.CreateAlbum do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add(:count, :integer, default: 0)
      add(:description, :string, size: 2000)
      add(:nsfw, :boolean, default: false, null: false)
      add(:shared, :boolean, default: false, null: false)
      add(:title, :string, size: 255)
      add(:url, :string)

      add(:user_id, references(:users))
      timestamps()
    end
  end
end
