defmodule BenchWeb.AuthorsLive do
  use BenchWeb, :live_view
  alias Bench.Authors
  alias Bench.Authors.Author
  alias Bench.Filter

  @default_page "1"
  @default_per_page "25"

  def mount(_params, _session, socket) do
    socket = socket |> assign(:authors_count, Authors.authors_count())
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    page = param_to_integer(params["filters"]["page"], @default_page)
    per_page = param_to_integer(params["filters"]["per_page"], @default_per_page)

    filters = %{
      page: page,
      per_page: per_page,
      sort_by: valid_sort_by(params["filters"]),
      sort_order: valid_sort_order(params["filters"])
    }

    socket =
      socket
      |> assign(:filters, filters)
      |> stream(:authors, Authors.list_authors(filters), reset: true)
      |> assign(:form, nil)

    {:noreply, socket}
  end

  def author(assigns) do
    ~H"""
    <tr
      id={@id}
      class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
    >
      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @author.id %>
      </td>

      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @author.name %>
      </td>

      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @author.birth %>
      </td>

      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @author.death %>
      </td>

      <td class="px-6 py-4 whitespace-nowrap dark:text-white">
        <%= @author.books_count %>
      </td>

      <td class="flex items-center px-6 py-4">
        <button
          title={gettext("Edit")}
          class="font-medium text-blue-600 dark:text-blue-500 hover:underline ms-3"
          phx-value-id={@author.id}
          phx-click="edit"
        >
          <.icon name="hero-pencil-square" />
        </button>

        <button
          title={gettext("Delete")}
          class="font-medium text-red-600 dark:text-red-500 hover:underline ms-3"
          phx-click={
            JS.push("delete", value: %{id: @author.id})
            |> JS.hide(to: "#{@id}", transition: "ease duration-500 scale-50")
          }
          phx-value-id={@author.id}
          data-confirm={gettext("Are you sure?")}
        >
          <.icon name="hero-trash" />
        </button>
      </td>
    </tr>
    """
  end

  def author_form(assigns) do
    ~H"""
    <.form :if={@form} phx-value-id={@form.data.id} for={@form} phx-submit="save" id="author-form">
      <div class="flex space-x-5">
        <div class="flex-1">
          <.input field={@form[:name]} placeholder="Name" />
        </div>
        <div class="flex-1">
          <.input field={@form[:birth]} type="date" placeholder="Birth" />
        </div>
        <div class="flex-1">
          <.input field={@form[:death]} type="date" placeholder="Death" />
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
    <.sort_link_shared path={~p"/authors?#{@params}"} filters={@filters} sort_by={@sort_by}>
      <%= render_slot(@inner_block) %>
    </.sort_link_shared>
    """
  end

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(id name birth death books_count) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order}) when sort_order in ~w(asc desc) do
    String.to_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :desc

  def handle_event("new", _, socket) do
    {:noreply, assign_form(socket, Authors.change_author(%Author{}))}
  end

  def handle_event("hide-form", _, socket) do
    {:noreply, assign(socket, form: nil)}
  end

  def handle_event("save", %{"id" => id, "author" => author_params}, socket) do
    author = Authors.get_author!(id)

    case Authors.update_author(author, author_params) do
      {:ok, author} ->
        socket = stream_insert(socket, :authors, author)
        socket = put_flash(socket, :info, "Author updated successfully.")
        {:noreply, assign(socket, form: nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("save", %{"author" => author_params}, socket) do
    case Authors.create_author(author_params) do
      {:ok, author} ->
        socket = stream_insert(socket, :authors, author, at: 0)
        socket = put_flash(socket, :info, "Author created successfully.")
        author = Authors.change_author(%Author{})
        {:noreply, assign_form(socket, author)}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign_form(socket, changeset)
        socket = put_flash(socket, :error, "Error creating author.")
        {:noreply, socket}
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    author = Authors.get_author!(id)
    {:noreply, assign_form(socket, Authors.change_author(author))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    author = Authors.get_author!(id)
    {:ok, _author} = Authors.delete_author(author)

    socket = stream_delete(socket, :authors, author)
    socket = put_flash(socket, :info, "Author deleted successfully.")

    {:noreply, socket}
  end

  defp more_pages?(filters, authors_count) do
    authors_count > filters.page * filters.per_page
  end

  defp pages(filters, authors_count) do
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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end
end
