defmodule Bonfire.Web.TermsLive do
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
       nav_items: Bonfire.Common.ExtensionModule.default_nav(:bonfire_ui_social),
       page_title: l("Privacy policy"),
       without_sidebar: false,
       terms: Config.get([:terms, :privacy])
     )}
  end
end
