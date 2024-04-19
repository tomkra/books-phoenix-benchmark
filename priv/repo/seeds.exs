# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bench.Repo.insert!(%Bench.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

for _ <- 1..10 do
  author = %Bench.Authors.Author{
    name: Faker.Person.name(),
    birth: Faker.Date.date_of_birth()
  }

  Bench.Repo.insert!(author)
end
