defmodule WorldLink.Repo.Migrations.AddSoftDelete do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:deleted, :boolean, default: false, null: false)
      add(:deleted_at, :utc_datetime)
    end

    alter table(:oauth_profiles) do
      add(:deleted, :boolean, default: false, null: false)
      add(:deleted_at, :utc_datetime)
    end

    alter table(:worlds) do
      add(:deleted, :boolean, default: false, null: false)
      add(:deleted_at, :utc_datetime)
    end

    alter table(:timelines) do
      add(:deleted, :boolean, default: false, null: false)
      add(:deleted_at, :utc_datetime)
    end

    alter table(:characters) do
      add(:deleted, :boolean, default: false, null: false)
      add(:deleted_at, :utc_datetime)
    end

    alter table(:worlds_characters) do
      add(:deleted, :boolean, default: false, null: false)
      add(:deleted_at, :utc_datetime)
    end

    alter table(:character_info) do
      add(:deleted, :boolean, default: false, null: false)
      add(:deleted_at, :utc_datetime)
    end

    alter table(:timelines_character_info) do
      add(:deleted, :boolean, default: false, null: false)
      add(:deleted_at, :utc_datetime)
    end
  end
end
