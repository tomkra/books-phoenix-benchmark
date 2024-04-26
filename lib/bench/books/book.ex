defmodule Bench.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bench.Authors.Author

  schema "books" do
    field :title, :string
    field :available, :boolean, default: false
    field :year_published, :integer
    field :isbn, :string
    field :price, :decimal
    belongs_to :author, Author

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :year_published, :isbn, :price, :available])
    |> validate_required([:title, :isbn])
    |> validate_length(:title, max: 255)
    |> validate_number(:year_published, greater_than_or_equal_to: 0)
    # |> validate_format(:year_published, ~r/^\d+$/)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> unsafe_validate_unique([:title, :author_id], Bench.Repo)
    # |> unique_constraint([:title, :author_id])
    |> cast_assoc(:author, with: &Author.changeset/2)
  end
end
