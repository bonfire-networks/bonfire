defmodule Iconify.Mingcute.GhostFill do
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
      <g fill="none" fill-rule="evenodd">
        <path d="M0 0h24v24H0z" /><path
          fill="currentColor"
          d="M12 2a9 9 0 0 1 9 9v8.62c0 1.83-1.966 2.987-3.566 2.099l-.362-.195c-1-.512-1.784-.68-2.889-.114l-.198.108a4 4 0 0 1-3.762.11l-.208-.11c-1.277-.73-2.166-.512-3.45.2c-1.6.89-3.565-.267-3.565-2.097V11a9 9 0 0 1 9-9ZM8.5 9a1.5 1.5 0 1 0 0 3a1.5 1.5 0 0 0 0-3Zm7 0a1.5 1.5 0 1 0 0 3a1.5 1.5 0 0 0 0-3Z"
        />
      </g>
    </svg>
    """
  end
end
