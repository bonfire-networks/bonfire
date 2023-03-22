defmodule Bonfire.Web.CodeOfConductLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page: "conduct",
       page_title: l("Code of conduct"),
       without_sidebar: false,
       nav_items: Bonfire.Common.ExtensionModule.default_nav(:bonfire_ui_social),
       terms: Config.get([:terms, :conduct])
     )}
  end
end
