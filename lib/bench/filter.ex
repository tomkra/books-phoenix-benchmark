defmodule Bench.Filter do
  import Ecto.Query

  def paginate(query, %{page: page, per_page: per_page}) do
    offset = max(per_page * (page - 1), 0)

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

  def valid_sort_order(%{"sort_order" => sort_order}) when sort_order in ~w(asc desc) do
    String.to_atom(sort_order)
  end

  def valid_sort_order(_params), do: :desc

  def param_to_integer(nil, default), do: default

  def param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end
end
