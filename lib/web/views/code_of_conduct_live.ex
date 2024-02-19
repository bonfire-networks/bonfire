defmodule Bonfire.Web.CodeOfConductLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    is_guest? = is_nil(current_user_id(socket.assigns))

    {:ok,
     socket
     |> assign(
       page: "conduct",
       selected_tab: :conduct,
       page_title: l("Code of conduct"),
       is_guest?: is_guest?,
       without_sidebar: is_guest?,
       without_secondary_widgets: is_guest?,
       no_header: is_guest?,
       nav_items: Bonfire.Common.ExtensionModule.default_nav(),
       terms: Config.get([:terms, :conduct])
     )}
  end

  def handle_params(params, uri, socket),
    do:
      Bonfire.UI.Common.LiveHandlers.handle_params(
        params,
        uri,
        socket,
        __MODULE__
        # &do_handle_params/3
      )

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

  def handle_event(
        action,
        attrs,
        socket
      ),
      do:
        Bonfire.UI.Common.LiveHandlers.handle_event(
          action,
          attrs,
          socket,
          __MODULE__
          # &do_handle_event/3
        )
end
