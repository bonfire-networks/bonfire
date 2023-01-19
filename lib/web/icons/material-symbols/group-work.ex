defmodule Iconify.MaterialSymbols.GroupWork do
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
        d="M8 16q.825 0 1.413-.588Q10 14.825 10 14t-.587-1.413Q8.825 12 8 12q-.825 0-1.412.587Q6 13.175 6 14q0 .825.588 1.412Q7.175 16 8 16Zm8 0q.825 0 1.413-.588Q18 14.825 18 14t-.587-1.413Q16.825 12 16 12q-.825 0-1.412.587Q14 13.175 14 14q0 .825.588 1.412Q15.175 16 16 16Zm-4-6q.825 0 1.413-.588Q14 8.825 14 8t-.587-1.412Q12.825 6 12 6q-.825 0-1.412.588Q10 7.175 10 8t.588 1.412Q11.175 10 12 10Zm0 12q-2.075 0-3.9-.788q-1.825-.787-3.175-2.137q-1.35-1.35-2.137-3.175Q2 14.075 2 12t.788-3.9q.787-1.825 2.137-3.175q1.35-1.35 3.175-2.138Q9.925 2 12 2t3.9.787q1.825.788 3.175 2.138q1.35 1.35 2.137 3.175Q22 9.925 22 12t-.788 3.9q-.787 1.825-2.137 3.175q-1.35 1.35-3.175 2.137Q14.075 22 12 22Z"
      />
    </svg>
    """
  end
end
