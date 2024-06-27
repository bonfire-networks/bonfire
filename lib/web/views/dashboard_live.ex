defmodule Bonfire.Web.DashboardLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  declare_nav_link(l("Dashboard"), page: "dashboard", icon: "carbon:home")

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
       no_header: is_guest?,
       page_title: l("Dashboard"),
       sidebar_widgets: [
         users: [
           secondary: [
             #  {Bonfire.Tag.Web.WidgetTagsLive, []},
             {Bonfire.UI.Me.WidgetAdminsLive, []}
           ]
         ]
       ],
       loading: true,
       feed: nil,
       feed_id: nil,
       feed_ids: nil,
       feed_component_id: nil,
       page_info: nil
     )}
  end

  # @decorate time()
  # def handle_params(params, _url, socket) do
  #   # debug(params, "param")

  #   context = socket.assigns[:__context__]

  #   feed_name =
  #     if module_enabled?(Bonfire.Social.Pins, context) and
  #          Settings.get(
  #            [Bonfire.UI.Social.FeedsLive, :curated],
  #            false,
  #            context
  #          ) do
  #       :curated
  #     else
  #       e(socket, :assigns, :live_action, nil) ||
  #         Settings.get(
  #           [Bonfire.UI.Social.FeedLive, :default_feed],
  #           :my,
  #           context
  #         )
  #     end

  #   {
  #     :noreply,
  #     socket
  #     |> assign(
  #       Bonfire.Social.Feeds.LiveHandler.feed_default_assigns(
  #         {
  #           feed_name,
  #           params
  #         },
  #         socket
  #       )
  #     )
  #   }
  # end
end
