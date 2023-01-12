defmodule Iconify.Twemoji.Envelope do
  use Phoenix.Component
  def render(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" role="img" class={@class} viewBox="0 0 36 36" aria-hidden="true"><path fill="#CCD6DD" d="M36 27a4 4 0 0 1-4 4H4a4 4 0 0 1-4-4V9a4 4 0 0 1 4-4h28a4 4 0 0 1 4 4v18z"/><path fill="#99AAB5" d="M11.95 17.636L.637 28.949c-.027.028-.037.063-.06.091c.34.57.814 1.043 1.384 1.384c.029-.023.063-.033.09-.06L13.365 19.05a1 1 0 0 0-1.415-1.414M35.423 29.04c-.021-.028-.033-.063-.06-.09L24.051 17.636a1 1 0 1 0-1.415 1.414l11.313 11.314c.026.026.062.037.09.06a3.978 3.978 0 0 0 1.384-1.384"/><path fill="#99AAB5" d="M32 5H4a4 4 0 0 0-4 4v1.03l14.528 14.496a4.882 4.882 0 0 0 6.884 0L36 10.009V9a4 4 0 0 0-4-4z"/><path fill="#E1E8ED" d="M32 5H4A3.992 3.992 0 0 0 .405 7.275l14.766 14.767a4 4 0 0 0 5.657 0L35.595 7.275A3.991 3.991 0 0 0 32 5z"/></svg>
    """
  end
end
