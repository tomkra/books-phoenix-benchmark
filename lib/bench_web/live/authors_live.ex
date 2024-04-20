defmodule BenchWeb.AuthorsLive do
  use BenchWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
