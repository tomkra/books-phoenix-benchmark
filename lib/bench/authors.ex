defmodule Bench.Authors do
  alias Bench.Repo
  alias Bench.Authors.Author

  def create_author(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert()
  end
end
