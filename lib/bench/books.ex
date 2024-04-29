defmodule Bench.Books do
  import Ecto.Query
  alias Bench.Repo
  alias Bench.Books.Book
  alias Bench.Filter

  def get_book!(id), do: Repo.get!(Book, id)

  def list_books do
    Repo.all(from b in Book, order_by: [desc: b.id])
  end

  def list_books_with_author do
    list_books()
    |> Repo.preload(:author)
  end

  def list_books_with_author(options) when is_map(options) do
    from(Book)
    |> Filter.paginate(options)
    |> Repo.all()
    |> Repo.preload(:author)
  end

  def create_book(author, attrs \\ %{}) do
    %Book{author: author}
    |> Book.changeset(attrs)
    |> Repo.insert!()
  end

  def delete_author(%Book{} = book) do
    Repo.delete(book)
  end

  def change_author(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end
end
