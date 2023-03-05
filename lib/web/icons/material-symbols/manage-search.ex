defmodule Iconify.MaterialSymbols.ManageSearch do
  @moduledoc false
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      data-icon="manage-search"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M2 19v-2h10v2Zm0-5v-2h5v2Zm0-5V7h5v2Zm18.6 10l-3.85-3.85q-.6.425-1.312.637Q14.725 16 14 16q-2.075 0-3.537-1.463Q9 13.075 9 11t1.463-3.538Q11.925 6 14 6t3.538 1.462Q19 8.925 19 11q0 .725-.212 1.438q-.213.712-.638 1.312L22 17.6ZM14 14q1.25 0 2.125-.875T17 11q0-1.25-.875-2.125T14 8q-1.25 0-2.125.875T11 11q0 1.25.875 2.125T14 14Z"
      >
      </path>
    </svg>
    """
  end
end
