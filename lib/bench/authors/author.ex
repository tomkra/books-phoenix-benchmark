defmodule Bench.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bench.Books.Book

  schema "authors" do
    field :name, :string
    field :birth, :date
    field :death, :date
    field :books_count, :integer
    has_many :books, Book

    timestamps(type: :utc_datetime)
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(map) do
      "#{map.id} #{map.name}"
    end
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :birth, :death])
    |> validate_required([:name, :birth])
    |> validate_length(:name, max: 255)
    |> validate_date_before_current_date([:birth, :death])
    |> validate_birth_before_death
  end

  defp validate_birth_before_death(changeset) do
    birth = get_field(changeset, :birth)
    death = get_field(changeset, :death)

    case {birth, death} do
      {nil, _} ->
        changeset

      {_, nil} ->
        changeset

      {b, d} when b >= d ->
        add_error(changeset, :death, "can't be before birth")

      _ ->
        changeset
    end
  end

  defp validate_date_before_current_date(changeset, fields) do
    date = Date.utc_today()

    Enum.reduce(fields, changeset, fn field, changeset ->
      value = get_field(changeset, field)

      cond do
        is_nil(value) ->
          changeset

        Date.compare(value, date) == :gt ->
          add_error(changeset, field, "can't be in the future")

        true ->
          changeset
      end
    end)
  end
end
