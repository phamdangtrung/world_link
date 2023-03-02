defmodule WorldLink.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :handle, :string
      add :twitter_handle, :string
      add :discord_handle, :string
      add :facebook_handle, :string
      add :google_handle, :string
      add :auth_token, :string
      add :auth_token_expires_at, :utc_datetime
      add :joined_at, :utc_datetime
      add :signed_in_at, :utc_datetime
      add :approved, :boolean, default: false, null: false
      add :activated, :boolean, default: false, null: false
      add :activated_at, :utc_datetime

      timestamps()
    end
  end
end
