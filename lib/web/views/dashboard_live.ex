defmodule Bonfire.Web.DashboardLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.UserRequired]}

  def mount(_params, _session, socket) do
    is_guest? = is_nil(current_user_id(socket.assigns))

    {:ok,
     socket
     |> assign(
       page: "about",
       selected_tab: :about,
       nav_items: Bonfire.Common.ExtensionModule.default_nav(),
       page_header: false,
       is_guest?: is_guest?,
       without_sidebar: is_guest?,
       without_secondary_widgets: is_guest?,
       no_header: is_guest?,
       page_title: l("Dashboard "),
       sidebar_widgets: [
         users: [
           secondary: [
             #  {Bonfire.Tag.Web.WidgetTagsLive, []},
             {Bonfire.UI.Me.WidgetAdminsLive, []}
           ]
         ]
       ]
     )}
  end
end
