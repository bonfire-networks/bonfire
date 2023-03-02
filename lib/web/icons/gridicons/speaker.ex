defmodule Iconify.Gridicons.Speaker do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M19 8v6c1.7 0 3-1.3 3-3s-1.3-3-3-3zm-8-1H4c-1.1 0-2 .9-2 2v4c0 1.1.9 2 2 2h1v3c0 1.1.9 2 2 2h2v-5h2l4 4h2V3h-2l-4 4z"/></svg>
    """
  end
end
