defmodule Bench.Filter do
  import Ecto.Query

  def paginate(query, %{page: page, per_page: per_page}) do
    offset = per_page * (page - 1)

    query
    |> limit(^per_page)
    |> offset(^offset)
  end

  def paginate(query, _options), do: query
end
