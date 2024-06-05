defmodule Bonfire.Web.AboutLive do
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
       page: "about",
       selected_tab: :about,
       nav_items: Bonfire.Common.ExtensionModule.default_nav(),
       page_header: false,
       is_guest?: is_guest?,
       without_sidebar: is_guest?,
       without_secondary_widgets: is_guest?,
       no_header: is_guest?,
       page_title: l("About "),
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

  # catch if the :section id is "privacy"
  def handle_params(%{"section" => "privacy"}, _url, socket) do
    {:noreply, socket |> assign(selected_tab: :privacy)}
  end

  def handle_params(%{"section" => "configuration"}, _url, socket) do
    {:noreply, socket |> assign(selected_tab: :configuration)}
  end

  def handle_params(tab, _url, socket) do
    {:noreply, socket |> assign(selected_tab: :about)}
  end
end
