defmodule BenchWeb.SharedComponents do
  use Phoenix.Component

  # alias Phoenix.LiveView.JS
  # import BenchWeb.Gettext

  slot :inner_block, required: true

  def title(assigns) do
    ~H"""
    <h2 class="mb-4 text-3xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl dark:text-white">
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end

  attr(:path, :string, required: true)
  attr(:filters, :map, required: true)
  attr(:sort_by, :atom, required: true)
  slot(:inner_block, required: true)

  def sort_link_shared(assigns) do
    ~H"""
    <.link
      patch={@path}
      class="flex items-center space-x-1 text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300"
    >
      <%= render_slot(@inner_block) %>
      <.sort_indicator :if={@filters.sort_by == @sort_by} sort_order={@filters.sort_order} />
    </.link>
    """
  end

  def sort_indicator(assigns) do
    ~H"""
    <BenchWeb.CoreComponents.icon :if={@sort_order == :asc} name="hero-chevron-down-mini" />
    <BenchWeb.CoreComponents.icon :if={@sort_order == :desc} name="hero-chevron-up-mini" />
    """
  end
end
