defmodule Iconify.Twemoji.WorldMap do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      role="img"
      class={@class}
      viewBox="0 0 36 36"
      aria-hidden="true"
    >
      <path
        fill="#CCD6DD"
        d="M12 7.607L3 5.196c-1.657-.444-3 .539-3 2.197v20c0 1.656 1.343 3.359 3 3.804l9 2.411V7.607zm12 22.786l9 2.411c1.656.443 3-.54 3-2.196v-20c0-1.657-1.344-3.36-3-3.804l-9-2.411v26z"
      /><path fill="#E1E8ED" d="m24 30.392l-12 3.215v-26l12-3.215z" /><path
        fill="#55ACEE"
        d="M12 9.607L4 7.463c-1.104-.296-2 .36-2 1.464v18c0 1.104.896 2.24 2 2.535l8 2.145v-22zm20-1.072l-8-2.144v22l8 2.144c1.104.296 2-.359 2-1.465v-18c0-1.103-.896-2.239-2-2.535z"
      /><path fill="#88C9F9" d="m24 28.392l-12 3.215v-22l12-3.215z" /><path
        fill="#5C913B"
        d="M12 21.506c-.268.006-.595.104-.845.145c-.436.073-.329.517-.463.443a2.844 2.844 0 0 1-.812-.658c-.337-.394.25-.477.418-.622c.168-.145-.316-.172-.485-.332c-.169-.159-.471.104-.739-.276c-.27-.376-.101-.79-.133-1.18c-.034-.39.436-.341.739-.334c.303.003.538.144.538.602c0 .456.37.708.269.146c-.101-.561.101-.657.235-.89c.134-.23.37-.55.672-1.04c.221-.358.389-.283.606-.164v-3.345c-.055-.044-.11-.09-.165-.113c-.303-.132.096.753-.139 1.109c-.237.356-.598.193-.97.094c-.369-.099-.713-.545-.443-1.007c.268-.462.782-.268 1.051-.653c.269-.385-.957-.672-1.394-.941c-.438-.271-.963-.409-1.4-.146c-.437.264-1.373.133-1.743.186c-.37.054-.436-.369-.503-.693c-.067-.322-.653-.329-1.257-.338c-.606-.01-1.741.281-1.547 1.759c.068.514.605.124.707.036c.101-.088.605.2.671.637c.068.439.035.887-.099 1.232c-.137.345.336 1.006.604 1.612c.269.605.573.686.707.723c.135.036.908.587.875.996c-.033.411.706.991 1.009 1.34c.303.35.494.662.887.846c.393.183.852 1.035 1.054 1.165c.155.1.418.451.576.58c-.208.242-.612.748-.612 1.029c0 .383.44 1.103.608 1.3c.167.196.65.442.751.85c.101.407-.07 1.646-.372 1.907c-.304.262-.414 1.043-.414 1.043s.107.293.465.124c.309-.144.776-.566 1.094-.801v-6.371z"
      /><path
        fill="#77B255"
        d="M12.268 17.413c-.1.016-.187.012-.268.011v-3.345c.254.065.512.317.707.736c.234.509.604.066.739.374c.134.308.875.758.505.742c-.371-.015-.741.008-.841.454c-.102.448.168.794-.102.828c-.27.033-.37.142-.74.2zm2.59 5.558c-.436-.074-.359-.023-.628-.599c-.268-.577-.431-.743-1.036-.656c-.605.087-.583.136-.751-.163c-.072-.128-.241-.082-.443.031v6.37c.09-.114.17-.211.228-.267a13.37 13.37 0 0 0 1.466-1.646c.47-.621.3-.924.535-1.481c.236-.558.541-.617.944-1.145c.405-.53.122-.368-.315-.444zM24 15.731V9.417c-.04.004-.068.012-.11.015c-.209.011-.482.135-.779.32c-.024-.005-.046-.016-.07-.021c-.896-.175-1.312 1.205-2.039 1.152c-.729-.053-1.7-.344-2.332.514c-.631.857-.777 1.53 0 1.294s1.312-1.425 1.7-1.089c.388.336.29.721-.632 1.105c-.922.385-1.918.817-2.452.96c-.534.143-.655.534-.292.822c.364.288-.219.471-.826 1.02c-.607.547.146.512.656.705c.51.193.898-.323 1.117-.932c.217-.608 1.158-1.521 1.55-1.544c.392-.023.392.197.318.602c-.013.071.001.103.011.138c-.17.54-.31 1.03-.365 1.306a3.332 3.332 0 0 0-.027.595c-.086.004-.183.021-.248.001c-.438-.129-1.434-.22-1.701.043c-.267.265-.412.502-.728.723c-.317.219-1.603 1.224-1.627 2.084c-.025.859-.049 1.83.461 1.721c.51-.109 1.749-.826 2.137-1.288c.387-.463.921-.522 1.092-.156c.17.369.048.649-.12 1.354c-.171.708.11.963.381 1.468c.273.504.491.775.491 1.189c0 .412.389.723.97-.123a7.14 7.14 0 0 0 .536-.957c.409-.469.768-.923.758-1.096a13.53 13.53 0 0 1-.024-.624l.091-.22c.127-.293.241-.746.362-1.155a.17.17 0 0 1 .02-.024c.237-.337.185-.353.58-.756c.264-.27.254-.512.214-.678c.105-.175.134-.28-.033-.235l-.016.004c-.002 0-.005.019-.006.014c-.023-.149-.206.003-.501.148c-.284.008-.566-.066-.668-.368c-.133-.396-.602-.996-.639-1.336c.003-.041.005-.077.01-.124a.165.165 0 0 1 .069-.088a.29.29 0 0 1 .112-.035c.041.111.075.279.086.464c.026.477.394.196.394.498c0 .303.53.492.661.548c.037.016.094-.027.159-.098c.031.011.06.033.093.037c.292.031.922-.984 1.117-1.164c.102-.095.104-.269.033-.394l.056-.025z"
      /><path
        fill="#5C913B"
        d="M27.634 20.221c-.053.44.184.201.606.705c.423.508-.104.394-.289.316c-.185-.08-.37-.131-.579-.518c-.213-.391 0-.695 0-1.027c0 0 .316.084.262.524zm.362-.901c.389.166.114-.482.244-.841c.132-.356.316-.368.555-.363c.236.002.422-.191.581-.389c.157-.199.448-.454.422-.733c-.026-.279-.104-.482-.212-.843c-.105-.36.316-.368.502-.711c.184-.343 0 0 .421-.008c.422-.008.238-.058.316-.218c.08-.159.133-.327.054-.68c-.078-.353-.37-.1-.66-.177c-.289-.077.106-.425.132-.78c.026-.356.397-.165.661-.125c.263.039.342.484.421.597c.081.112.895-.365 1.108-.641c.211-.275-.186-.291-.079-.403c.106-.111-.632-.337-.925-.469c-.289-.133-1.028-.367-1.318-.649c-.289-.283-1.396-.426-1.688-.337c-.291.086-.476-.143-.606-.406c-.131-.262-.686-.297-.844-.467c-.158-.17-.316.127-.529.16c-.21.035-.289.043-.554-.209c-.263-.252.08-.371-.288-.621c-.355-.238-.813-.182-1.71-.591v6.314c.157.014.309.036.364.051c.131.035.448.573.448.784c0 .211.158.828.291 1.195c.131.366.42.506.686.818c.264.312.394.137.394.137s-.105-.544-.105-.965c0-.424.316-.701.316-.701s.5.558.528.685c.026.128.421.656.449.876c.026.219.237.546.625.71zm2.092-2.068c.184.08.976.171.554-.334c-.423-.506-.106-.299-.053-.738c.053-.44-.264-.524-.264-.524c0 .332-.211.638 0 1.026c.21.39-.423.49-.237.57zm2.004 5.371c-.131-.217-.421-.385-.738-.461c-.315-.076-.29-.48-.606-.533c-.316-.055-.544-.389-.686-.512c-.312-.266-.106.209 0 .699c.106.488.501.246.869.586c.369.34.397.016.74.229c.342.211.475.52.804.578c.329.059-.25-.369-.383-.586zm-3.088-1.432c.262.402.159.043.504-.016c.343-.059-.291-.561-.502-.799c-.211-.238-.42-.301-.605.049c-.21.399.342.364.603.766zm2.403 2.579c-.133-.338-.518-.713-.675-.91c-.159-.193-.407-.312-.618-.279c-.212.031-.343-.092-.448-.361c-.106-.266-.29-.233-.449-.244c-.157-.012-.791.119-1.161.23c-.368.113-.537.252-.778.457c-.382.32-.17.105 0 .424c.168.318-.187 1.066-.213 1.543c-.027.477.676.031.939.039c.264.012.186-.189.396-.314c.212-.125.349-.129.579.172c.233.305.537.611.537.883c0 .27.834.947 1.151.852c.316-.098.501-.408.791-.635c.291-.225.186-.824.264-1.168c.081-.344-.185-.354-.315-.689z"
      />
    </svg>
    """
  end
end
