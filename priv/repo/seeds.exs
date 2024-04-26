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

alias Bench.{Repo, Authors, Books, Authors.Author, Books.Book}
import Ecto.Query

for _ <- 1..100 do
  author = %{
    name: Faker.Person.name(),
    birth: Faker.Date.date_of_birth(100..1000)
  }

  {:ok, author} = Authors.create_author(author)

  for _ <- 1..Enum.random(5..50) do
    book = %{
      title: "#{Faker.Lorem.word()} #{SecureRandom.hex(2)}",
      year_published: Faker.Date.date_of_birth(100..1000).year(),
      isbn: Faker.Code.isbn(),
      price: Faker.Commerce.price()
    }

    Books.create_book(author, book)
  end
end

Repo.all(Author)
|> Enum.each(fn author ->
  books_count =
    Book
    |> where([b], b.author_id == ^author.id)
    |> Repo.aggregate(:count)

  author
  |> Ecto.Changeset.cast(%{books_count: books_count}, [:books_count])
  |> Repo.update()
end)
