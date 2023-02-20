defmodule Iconify.MaterialSymbols.EditNote do
  @moduledoc false
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M12 21v-2.125l5.3-5.3l2.125 2.125l-5.3 5.3Zm-9-5v-2h7v2Zm17.125-1L18 12.875l.725-.725q.275-.275.7-.275q.425 0 .7.275l.725.725q.275.275.275.7q0 .425-.275.7ZM3 12v-2h11v2Zm0-4V6h11v2Z"
      >
      </path>
    </svg>
    """
  end
end
