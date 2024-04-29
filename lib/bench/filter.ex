defmodule Bench.Filter do
  import Ecto.Query

  def paginate(query, %{page: page, per_page: per_page}) do
    offset = per_page * (page - 1)

    query
    |> limit(^per_page)
    |> offset(^offset)
  end

  def paginate(query, _filters), do: query

  def sort(query, %{sort_by: sort_by, sort_order: sort_order}) do
    order_by(query, {^sort_order, ^sort_by})
  end

  def sort(query, _filters), do: query

  def next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end
end
