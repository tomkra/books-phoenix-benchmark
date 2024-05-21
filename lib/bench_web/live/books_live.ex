defmodule BenchWeb.BooksLive do
  use BenchWeb, :live_view
  alias Bench.{Books, Filter}
  alias Bench.Books.Book
  import BenchWeb.Components.Pagination
  alias Bench.Repo

  def mount(_params, _session, socket) do
    if connected?(socket), do: Books.subscribe()

    authors = Bench.Authors.list_authors(%{sort_by: :name, sort_order: :asc})

    socket =
      assign(socket,
        authors_options: [{"Select author", ""} | Enum.map(authors, &{&1.name, &1.id})]
      )

    {:ok, assign(socket, :books_count, Books.books_count())}
  end

  def handle_params(params, _uri, socket) do
    filter_params = params["filters"] || %{}

    page = Filter.param_to_integer(filter_params["page"], 1)
    per_page = Filter.param_to_integer(filter_params["per_page"], 20)

    filters = %{
      page: page,
      per_page: per_page,
      sort_by: valid_sort_by(filter_params),
      sort_order: Filter.valid_sort_order(filter_params),
      title: filter_params["title"] || "",
      author_id: filter_params["author_id"] || ""
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
    <tr
      id={@id}
      class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
    >
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
          phx-value-id={@book.id}
          phx-click="edit"
        >
          <.icon name="hero-pencil-square" />
        </button>

        <button
          title={gettext("Delete")}
          class="font-medium text-red-600 dark:text-red-500 hover:underline ms-3"
          phx-click={
            JS.push("delete", value: %{id: @book.id})
            |> JS.hide(to: "#{@id}", transition: "ease duration-500 scale-50")
          }
          phx-value-id={@book.id}
          data-confirm={gettext("Are you sure?")}
        >
          <.icon name="hero-trash" />
        </button>
      </td>
    </tr>
    """
  end

  def book_form(assigns) do
    ~H"""
    <.form :if={@form} phx-value-id={@form.data.id} for={@form} phx-submit="save" id="book-form">
      <div class="flex space-x-5">
        <div class="flex-1">
          <.input field={@form[:title]} placeholder="Title" />
        </div>
        <div class="flex-1">
          <.input field={@form[:isbn]} placeholder="ISBN" />
        </div>

        <div class="flex-1">
          <.input field={@form[:year_published]} type="number" placeholder="Year published" />
        </div>

        <div class="flex-1">
          <.input field={@form[:price]} type="number" placeholder="Price" />
        </div>

        <div class="flex-1">
          <.input field={@form[:author_id]} options={@authors_options} type="select" prompt="Author" />
        </div>

        <div class="flex-1 flex">
          <div class="flex items-center">
            <.button type="submit" phx-disable-with="Saving...">
              Save
            </.button>

            <button
              phx-click="hide-form"
              type="button"
              class="ms-2 text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 dark:bg-gray-800 dark:text-white dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </.form>
    """
  end

  def filter_form(assigns) do
    ~H"""
    <form phx-change="filter">
      <div class="flex space-x-5 items-center">
        <div>
          <input
            type="text"
            name="filters[title]"
            placeholder="Search by title"
            value={@filters[:title]}
            class="shadow-sm bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-500 focus:border-primary-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500 dark:shadow-sm-light"
          />
        </div>
        <div>
          <select
            name="filters[author_id]"
            class="shadow-sm bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-500 focus:border-primary-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500 dark:shadow-sm-light"
          >
            <%= Phoenix.HTML.Form.options_for_select(
              @authors_options,
              @filters[:author_id]
            ) %>
          </select>
        </div>
      </div>
    </form>
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

  def handle_event("new", _, socket) do
    {:noreply, assign_form(socket, Books.change_book(%Book{}))}
  end

  def handle_event("hide-form", _, socket) do
    {:noreply, assign(socket, form: nil)}
  end

  def handle_event("save", %{"id" => id, "book" => book_params}, socket) do
    book = Books.get_book!(id)

    case Books.update_book(book, book_params) do
      {:ok, book} ->
        book = Repo.preload(book, :author)
        socket = stream_insert(socket, :books, book)
        socket = put_flash(socket, :info, "Book updated successfully.")
        {:noreply, assign(socket, form: nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("save", %{"book" => book_params}, socket) do
    case Books.create_book(book_params) do
      {:ok, book} ->
        book = Repo.preload(book, :author)
        socket = stream_insert(socket, :books, book, at: 0)
        socket = put_flash(socket, :info, "Book created successfully.")
        book = Books.change_book(%Book{})
        {:noreply, assign_form(socket, book)}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign_form(socket, changeset)
        socket = put_flash(socket, :error, "Error creating book.")
        {:noreply, socket}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    book = Books.get_book!(id)
    {:noreply, assign_form(socket, Books.change_book(book))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    book = Books.get_book!(id)
    {:ok, _book} = Books.delete_book(book)

    socket = stream_delete(socket, :books, book)
    socket = put_flash(socket, :info, "Book deleted successfully.")

    {:noreply, socket}
  end

  def handle_event(
        "filter",
        %{"filters" => %{"title" => title, "author_id" => author_id}},
        socket
      ) do
    filters = %{socket.assigns.filters | title: title, author_id: author_id}
    socket = push_patch(socket, to: ~p"/books?#{%{filters: filters}}")
    {:noreply, socket}
  end

  def handle_info({:book_created, book}, socket) do
    socket = update(socket, :count, &(&1 + 1))
    socket = stream_insert(socket, :books, with_author(book), at: 0)
    {:noreply, socket}
  end

  def handle_info({:book_updated, book}, socket) do
    {:noreply, stream_insert(socket, :books, with_author(book))}
  end

  def handle_info({:book_deleted, book}, socket) do
    {:noreply, stream_delete(socket, :books, book)}
  end

  def with_author(book) do
    Repo.preload(book, :author)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(id title isbn year_published price) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id
end
