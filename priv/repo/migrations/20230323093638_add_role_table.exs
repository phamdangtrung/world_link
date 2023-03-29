defmodule WorldLink.Repo.Migrations.AddRoleTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role_name, :string, size: 20, null: false, default: "user"
    end
  end
end
