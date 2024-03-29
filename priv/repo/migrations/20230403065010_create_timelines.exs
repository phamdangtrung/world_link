defmodule WorldLink.Repo.Migrations.CreateTimelines do
  use Ecto.Migration

  def change do
    create table(:timelines) do
      add(:name, :string, size: 255, null: false)
      add(:world_id, references(:worlds))

      timestamps()
    end
  end
end
