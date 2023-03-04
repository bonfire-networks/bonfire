defmodule Iconify.Ph.BellFill do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 256 256"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M220.8 175.9c-5.9-10.2-13-29.6-13-63.9v-7.1c0-44.3-35.5-80.6-79.2-80.9h-.6a79.9 79.9 0 0 0-79.8 80v8c0 34.3-7.1 53.7-13 63.9A16 16 0 0 0 49 200h39a40 40 0 0 0 80 0h39a15.9 15.9 0 0 0 13.9-8a16.2 16.2 0 0 0-.1-16.1ZM128 224a24.1 24.1 0 0 1-24-24h48a24.1 24.1 0 0 1-24 24Z"
      />
    </svg>
    """
  end
end