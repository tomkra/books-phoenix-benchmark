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

alias Bench.Repo

for _ <- 1..100 do
  author = %Bench.Authors.Author{
    name: Faker.Person.name(),
    birth: Faker.Date.date_of_birth()
  }

  Repo.insert!(author)

  for _ <- 1..Enum.random(5..10) do
    book = %Bench.Books.Book{
      title: "#{Faker.Lorem.word()} #{SecureRandom.hex(2)}",
      year_published: Faker.Date.date_of_birth().year(),
      isbn: Faker.Code.isbn(),
      price: Faker.Commerce.price()
    }

    Ecto.build_assoc(author, :books, book) |> Repo.insert!()
  end
end
