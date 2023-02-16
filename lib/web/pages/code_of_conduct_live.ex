defmodule Bonfire.Web.CodeOfConductLive do
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
       page_title: l("Code of conduct"),
       without_sidebar: false,
       nav_items: Bonfire.Common.ExtensionModule.default_nav(:bonfire_ui_social),
       terms: Config.get([:terms, :conduct])
     )}
  end
end
