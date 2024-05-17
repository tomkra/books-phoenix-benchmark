defmodule BenchWeb.BooksLive do
  use BenchWeb, :live_view
  alias Bench.Books
  alias Bench.Filter
  import BenchWeb.Components.Pagination

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :books_count, Books.books_count())}
  end

  def handle_params(params, _uri, socket) do
    filter_params = params["filters"] || %{}

    page = Filter.param_to_integer(filter_params["page"], 1)
    per_page = Filter.param_to_integer(filter_params["per_page"], 20)

    filters = %{
      page: page,
      per_page: per_page,
      sort_by: Filter.valid_sort_by(filter_params),
      sort_order: Filter.valid_sort_order(filter_params)
    }

    socket =
      socket
      |> assign(:filters, filters)
      |> stream(:books, Books.list_books_with_author(filters), reset: true)
      |> assign(:form, nil)

    {:noreply, socket}
  end

  def book(assigns) do
    ~H"""
    <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @book.id %>
      </td>

      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @book.title %>
      </td>

      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @book.isbn %>
      </td>

      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @book.year_published %>
      </td>

      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @book.price %>
      </td>

      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @book.author.name %>
      </td>

      <td class="flex items-center px-6 py-4">
        <button
          title={gettext("Edit")}
          class="font-medium text-blue-600 dark:text-blue-500 hover:underline ms-3"
        >
          <.icon name="hero-pencil-square" />
        </button>

        <button
          title={gettext("Edit")}
          class="font-medium text-red-600 dark:text-red-500 hover:underline ms-3"
        >
          <.icon name="hero-trash" />
        </button>
      </td>
    </tr>
    """
  end

  def sort_link(assigns) do
    params = %{
      filters: %{
        assigns.filters
        | sort_by: assigns.sort_by,
          sort_order: Filter.next_sort_order(assigns.filters.sort_order)
      }
    }

    assigns = assign(assigns, params: params)

    ~H"""
    <.sort_link_shared path={~p"/books?#{@params}"} filters={@filters} sort_by={@sort_by}>
      <%= render_slot(@inner_block) %>
    </.sort_link_shared>
    """
  end
end
