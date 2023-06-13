defmodule WorldLink.Repo.Migrations.CreateOauthProfiles do
  use Ecto.Migration

  def change do
    create table(:oauth_profiles) do
      add(:oauth_provider, :string, size: 20, null: false)
      add(:provider_uid, :string, size: 100, null: false)
      add(:user_id, references(:users))

      timestamps()
    end
  end
end
