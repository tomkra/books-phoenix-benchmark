defmodule BenchWeb.Components.Pagination do
  use BenchWeb, :html

  attr(:path, :string, required: true)
  attr(:page, :integer, default: 1)
  attr(:total_count, :integer, required: true)
  attr(:filters, :map, required: true)

  def pagination(assigns) do
    ~H"""
    <nav aria-label="Page navigation">
      <ul class="inline-flex -space-x-px text-base h-10">
        <li>
          <.link
            :if={@page > 1}
            patch={~p"/#{@path}?#{%{filters: %{@filters | page: @page - 1}}}"}
            class={pagination_link_class(false, true, false)}
          >
            Previous
          </.link>
        </li>
        <li
          :for={{page, active} <- pagination_pages(@filters, @total_count)}
          page={page}
          active={active}
        >
          <.link
            patch={~p"/#{@path}?#{%{filters: %{@filters | page: page}}}"}
            class={
              pagination_link_class(
                active,
                @page == 1 && @page == page,
                @page == page && pagination_page_count(@filters, @total_count) == page
              )
            }
          >
            <%= page %>
          </.link>
        </li>
        <li>
          <.link
            :if={pagination_more_pages?(@filters, @total_count)}
            patch={~p"/#{@path}?#{%{filters: %{@filters | page: @page + 1}}}"}
            class="flex items-center justify-center px-4 h-10 leading-tight text-gray-500 bg-white border border-gray-300 rounded-e-lg hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
          >
            Next
          </.link>
        </li>
      </ul>
    </nav>
    """
  end

  defp pagination_more_pages?(filters, authors_count) do
    authors_count > filters.page * filters.per_page
  end

  defp pagination_pages(filters, authors_count) do
    for page <- (filters.page - 2)..(filters.page + 2), page > 0 do
      if page <= pagination_page_count(filters, authors_count) do
        current_page? = page == filters.page
        {page, current_page?}
      end
    end
  end

  defp pagination_page_count(filters, authors_count) do
    ceil(authors_count / filters.per_page)
  end

  defp pagination_link_class(active, first_page?, last_page?) do
    klass =
      if active do
        "flex items-center justify-center px-4 h-10 text-blue-600 border border-gray-300 bg-blue-50 hover:bg-blue-100 hover:text-blue-700 dark:border-gray-700 dark:bg-gray-700 dark:text-white"
      else
        "flex items-center justify-center px-4 h-10 leading-tight text-gray-500 bg-white border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
      end

    klass = if first_page?, do: "#{klass} rounded-l-lg", else: klass
    klass = if last_page?, do: "#{klass} rounded-r-lg", else: klass
    klass
  end
end
