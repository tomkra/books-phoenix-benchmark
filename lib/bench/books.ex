defmodule Bench.Books do
  import Ecto.Query
  alias Bench.Repo
  alias Bench.Books.Book
  alias Bench.Filter

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Bench.PubSub, @topic)
  end

  def broadcast({:ok, book}, tag) do
    Phoenix.PubSub.broadcast(Bench.PubSub, @topic, {tag, book})

    {:ok, book}
  end

  def broadcast({:error, _changeset} = error, _tag), do: error

  def get_book!(id), do: Repo.get!(Book, id)

  def list_books do
    Repo.all(from b in Book, order_by: [desc: b.id])
  end

  def list_books_with_author do
    list_books()
    |> Repo.preload(:author)
  end

  def list_books_with_author(filters) when is_map(filters) do
    from(Book)
    |> filter_by_title(filters)
    |> filter_by_author(filters)
    |> Filter.paginate(filters)
    |> Filter.sort(filters)
    |> Repo.all()
    |> Repo.preload(:author)
  end

  defp filter_by_title(query, %{title: nil}), do: query
  defp filter_by_title(query, %{title: ""}), do: query

  defp filter_by_title(query, %{title: title}) do
    from(b in query, where: ilike(b.title, ^"%#{title}%"))
  end

  defp filter_by_author(query, %{author_id: nil}), do: query
  defp filter_by_author(query, %{author_id: ""}), do: query

  defp filter_by_author(query, %{author_id: author_id}) do
    IO.puts("author_id: #{author_id}")
    from(a in query, where: a.author_id == ^author_id)
  end

  defp filter_by_author(query, _), do: query

  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:book_created)
  end

  def update_book(%Book{} = book, attrs \\ %{}) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
    |> broadcast(:book_updated)
  end

  def delete_book(%Book{} = book) do
    book
    |> Repo.delete()
    |> broadcast(:book_deleted)
  end

  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  def books_count do
    Repo.aggregate(Book, :count, :id)
  end
end
