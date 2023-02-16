defmodule Bonfire.Web.TermsLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view
  alias Bonfire.UI.Me.LivePlugs

  def mount(params, session, socket) do
    live_plug(params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3
    ])
  end

  defp mounted(_params, _session, socket) do
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
