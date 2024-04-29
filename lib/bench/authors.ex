defmodule Bench.Authors do
  import Ecto.Query
  alias Bench.Repo
  alias Bench.Authors.Author
  alias Bench.Filter

  def get_author!(id), do: Repo.get!(Author, id)

  def list_authors do
    Repo.all(from a in Author, order_by: [desc: a.id])
  end

  def list_authors(options) when is_map(options) do
    from(Author)
    |> Filter.paginate(options)
    |> Repo.all()
  end

  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end

  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end

  def change_author(%Author{} = author, attrs \\ %{}) do
    Author.changeset(author, attrs)
  end
end
