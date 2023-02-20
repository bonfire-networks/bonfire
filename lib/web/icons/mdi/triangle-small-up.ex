defmodule Iconify.Mdi.TriangleSmallUp do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M8 15h8l-4-7"/></svg>
    """
  end
end
