defmodule BenchWeb.BooksLive do
  use BenchWeb, :live_view
  alias Bench.Books

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [books: Books.list_books_with_author()]}
  end

  def handle_params(_params, _uri, socket) do
    page = 1
    per_page = 20

    filters = %{
      page: page,
      per_page: per_page
    }

    socket = assign(socket, filters: filters, books: Books.list_books_with_author(filters))

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
end
