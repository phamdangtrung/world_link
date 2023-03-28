defmodule WorldLink.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, size: 50, null: false
      add :username, :string, size: 50, null: false
      add :email, :string, size: 255, null: false
      add :activated, :boolean, default: false, null: false
      add :activated_at, :utc_datetime
      add :hashed_password, :string, size: 200

      timestamps()
    end
  end
end
