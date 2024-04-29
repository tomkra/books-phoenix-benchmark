defmodule BenchWeb.SharedComponents do
  use Phoenix.Component

  # alias Phoenix.LiveView.JS
  import BenchWeb.Gettext

  slot :inner_block, required: true

  def title(assigns) do
    ~H"""
    <h2 class="mb-4 text-3xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl dark:text-white">
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end
end
