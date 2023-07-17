defmodule WorldLink.Repo.Migrations.AddDatabaseIndices do
  use Ecto.Migration

  def change do
    # users
    create(unique_index(:users, [:normalized_email],
      name: :users_normalized_email_unique_index)
    )

    create(unique_index(:users, [:normalized_username],
      name: :users_normalized_username_unique_index)
    )

    # oauth_profiles
    create(unique_index(:oauth_profiles, [:provider_uid],
      name: :oauth_profiles_provider_uid_unique_index)
    )

    create(index(:oauth_profiles, [:user_id]))

    # images
    create(index(:images, [:user_id]))

    # worlds
    create(index(:worlds, [:user_id]))

    # characters
    create(index(:characters, [:user_id]))

    # character_info
    create(index(:character_info, [:character_id]))

    # timelines
    create(index(:timelines, [:world_id]))

    # timelines_character_info
    create(index(:timelines_character_info, [:world_id]))
    create(index(:timelines_character_info, [:character_id]))
  end
end
