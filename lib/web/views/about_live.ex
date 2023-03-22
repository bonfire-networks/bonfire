defmodule Bonfire.Web.AboutLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page: "Instance defaults",
       nav_items: Bonfire.Common.ExtensionModule.default_nav(:bonfire_ui_social),
       page_title:
         l("About ") <> Config.get([:ui, :theme, :instance_name], Bonfire.Application.name()),
       sidebar_widgets: [
         guests: [
           secondary: [
             {Bonfire.Tag.Web.WidgetTagsLive, []},
             {Bonfire.UI.Me.WidgetAdminsLive, []}
           ]
         ],
         users: [
           secondary: [
             {Bonfire.Tag.Web.WidgetTagsLive, []},
             {Bonfire.UI.Me.WidgetAdminsLive, []}
           ]
         ]
       ]
     )}
  end
end
