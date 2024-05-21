defmodule Bench.Authors do
  import Ecto.Query
  alias Bench.Repo
  alias Bench.Authors.Author
  alias Bench.Filter

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Bench.PubSub, @topic)
  end

  def broadcast({:ok, author}, tag) do
    Phoenix.PubSub.broadcast(Bench.PubSub, @topic, {tag, author})

    {:ok, author}
  end

  def broadcast({:error, _changeset} = error, _tag), do: error

  def get_author!(id), do: Repo.get!(Author, id)

  def list_authors do
    Repo.all(from a in Author, order_by: [desc: a.id])
  end

  def list_authors(filter) when is_map(filter) do
    from(a in Author)
    |> filter_by_name(filter)
    |> Filter.paginate(filter)
    |> Filter.sort(filter)
    |> Repo.all()
  end

  defp filter_by_name(query, %{name: name}) do
    from(a in query, where: ilike(a.name, ^"%#{name}%"))
  end

  defp filter_by_name(query, _), do: query

  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:author_created)
  end

  def update_author(%Author{} = author, attrs \\ %{}) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
    |> broadcast(:author_updated)
  end

  def delete_author(%Author{} = author) do
    author
    |> Repo.delete()
    |> broadcast(:author_deleted)
  end

  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end

  def authors_count do
    Repo.aggregate(Author, :count, :id)
  end
end
