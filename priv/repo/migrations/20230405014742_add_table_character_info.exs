defmodule WorldLink.Repo.Migrations.AddTableCharacterInfo do
  use Ecto.Migration

  def change do
    create table(:character_info) do
      add :species, :string, size: 255
      add :data, :map, null: false, default: %{}
      add :main, :boolean, default: false
      add :character_id, references(:characters)

      timestamps()
    end
  end
end
