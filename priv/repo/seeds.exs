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
  WorldLink.Repo.insert!(%WorldLink.Identity.User{
    name: Faker.Person.name(),
    nickname: Faker.Internet.user_name(),
    email: Faker.Internet.email(),
    password: Faker.Internet.user_name()
  })
end
