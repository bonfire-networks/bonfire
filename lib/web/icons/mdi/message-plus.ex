defmodule Iconify.Mdi.MessagePlus do
  @moduledoc false
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      data-icon="message-plus"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M20 2a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H6l-4 4V4a2 2 0 0 1 2-2h16m-9 4v3H8v2h3v3h2v-3h3V9h-3V6h-2Z"
      >
      </path>
    </svg>
    """
  end
end
