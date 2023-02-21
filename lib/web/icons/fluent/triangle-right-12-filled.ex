defmodule Iconify.Fluent.TriangleRight12Filled do
  @moduledoc false
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      data-icon="triangle-right-12-filled"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 12 12"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M10.541 6.786a.903.903 0 0 0 0-1.572L3.372 1.122C2.762.774 2 1.211 2 1.91v8.18c0 .698.762 1.135 1.372.787l7.17-4.092Z"
      >
      </path>
    </svg>
    """
  end
end
