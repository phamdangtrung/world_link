defmodule WorldLink.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add(:name, :string, size: 255, null: false)
      add(:user_id, references(:users))

      timestamps()
    end
  end
end
