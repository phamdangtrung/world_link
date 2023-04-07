# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WorldLink.Repo.insert!(%WorldLink.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

for _ <- 1..20 do
  WorldLink.Identity.create_user(%{
    name: Faker.Person.name(),
    username: Faker.Internet.user_name(),
    email: Faker.Internet.email(),
    password: Faker.Internet.user_name()
  })
end

user =
  WorldLink.Identity.create_user(%{
    name: "Son",
    username: "sonuser",
    email: "sonuser@email.com",
    password: "S@tjsf4ction"
  })
