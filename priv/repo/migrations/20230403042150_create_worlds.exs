defmodule WorldLink.Repo.Migrations.CreateWorlds do
  use Ecto.Migration

  def change do
    create table(:worlds) do
      add :name, :string, size: 255, null: false
      add :user_id, references(:users)

      timestamps()
    end
  end
end
