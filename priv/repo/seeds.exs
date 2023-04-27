alias WorldLink.{Identity, Worlds}

{:ok, user} =
  Identity.create_user(%{
    name: "SonUser",
    username: "sonuser",
    email: "sonuser@email.com",
    password: "S@tjsf4ction"
  })

{:ok, admin} =
  WorldLink.Repo.insert(%Identity.User{
    name: "Son",
    normalized_username: "sonadmin",
    username: "sonadmin",
    email: "sonadmin@email.com",
    normalized_email: "sonadmin@email.com",
    password: "S@tjsf4ction",
    role_name: :admin
  })

{:ok, world_a} = Worlds.create_a_world(user, %{name: Faker.Internet.slug()})
{:ok, world_b} = Worlds.create_a_world(user, %{name: Faker.Internet.slug()})

{:ok, timeline} = Worlds.create_a_timeline(world_a, %{name: Faker.Internet.slug()})

{:ok, %{character: character_a, bio: bio_a}} =
  Worlds.create_a_character(user, %{name: "Rayven Wolhart"})

{:ok, %{character: character_b, bio: bio_b}} =
  Worlds.create_a_character(user, %{name: "Nerya Wolhart"})

Worlds.assign_characters_to_a_world(world_a, [character_a, character_b])

main_timeline = world_a.main_timeline

{:ok, tci_a} = Worlds.assign_a_character_info_to_a_timeline(main_timeline, bio_a)
{:ok, tci_b} = Worlds.assign_a_character_info_to_a_timeline(main_timeline, bio_b)
