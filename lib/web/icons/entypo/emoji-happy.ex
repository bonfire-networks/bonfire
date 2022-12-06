defmodule Iconify.Entypo.EmojiHappy do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 20 20"
      aria-hidden="true"
    >
      <path
        fill="currentColor"
        d="M10 .4A9.6 9.6 0 0 0 .4 10a9.6 9.6 0 1 0 19.2-.001C19.6 4.698 15.301.4 10 .4zm0 17.199A7.6 7.6 0 1 1 10 2.4a7.6 7.6 0 1 1 0 15.199zM7.501 9.75C8.329 9.75 9 8.967 9 8s-.672-1.75-1.5-1.75S6 7.033 6 8s.672 1.75 1.501 1.75zm4.999 0c.829 0 1.5-.783 1.5-1.75s-.672-1.75-1.5-1.75S11 7.034 11 8s.672 1.75 1.5 1.75zm1.841 1.586a.756.756 0 0 0-1.008.32c-.034.066-.869 1.593-3.332 1.593c-2.451 0-3.291-1.513-3.333-1.592a.75.75 0 0 0-1.339.678c.05.099 1.248 2.414 4.672 2.414c3.425 0 4.621-2.316 4.67-2.415a.745.745 0 0 0-.33-.998z"
      >
      </path>
    </svg>
    """
  end
end
