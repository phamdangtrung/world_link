defmodule WorldLink.Repo.Migrations.AddMainTimeline do
  use Ecto.Migration

  def change do
    alter table(:worlds) do
      add :main_timeline_id, references(:timelines)
    end
  end
end
