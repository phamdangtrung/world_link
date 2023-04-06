defmodule WorldLink.Repo.Migrations.CreateTimelines do
  use Ecto.Migration

  def change do
    create table(:timelines) do
      add :timeline_name, :string, size: 255, null: false
      add :main, :boolean, default: false
      add :world_id, references(:worlds)

      timestamps()
    end
  end
end
