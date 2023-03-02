defmodule WorldLink.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :handle, :string
      add :auth_token, :string
      add :auth_token_expires_at, :utc_datetime
      add :activated, :boolean, default: false, null: false
      add :activated_at, :utc_datetime
      add :provider_uid, :string
      add :uuid, :string
      add :oauth_provider, :string
      add :hashed_password, :string

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:provider_uid, :oauth_provider])
  end
end
