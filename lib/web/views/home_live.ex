defmodule Bonfire.Web.HomeLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  alias Bonfire.Me.Accounts
  alias Bonfire.UI.Social.FeedLive

  # @changelog File.read!("#{Config.get(:project_path, "../..")}/docs/CHANGELOG.md")

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(%{"dashboard" => _} = params, session, socket) do
    mounted(params, session, socket)
  end

  def mount(params, session, socket) do
    case Config.get([:ui, :homepage_redirect_to]) do
      url when is_binary(url) ->
        {:ok,
         socket
         |> redirect_to(url, fallback: "/dashboard", replace: false)}

      _ ->
        mounted(params, session, socket)
    end
  end

  defp mounted(params, _session, socket) do
    links =
      Config.get([:ui, :theme, :instance_welcome, :links], %{
        l("About Bonfire") => "https://bonfirenetworks.org/",
        l("Contribute") => "https://bonfirenetworks.org/contribute/"
      })

    {:ok,
     socket
     |> assign(
       page: "home",
       selected_tab: nil,
       no_header: current_user_id(socket.assigns),
       links: links,
       #  changelog: @changelog,
       error: nil,
       form: login_form(params),
       loading: true,
       feed: nil,
       feed_id: nil,
       feed_ids: nil,
       feed_component_id: nil,
       page_info: nil,
       show_about_instance?: nil,
       nav_items: Bonfire.Common.ExtensionModule.default_nav(:bonfire_ui_social),
       #  without_sidebar: true,
       sidebar_widgets: [
         guests: [
           secondary: [
             {Bonfire.Tag.Web.WidgetTagsLive, []},
             {Bonfire.UI.Me.WidgetAdminsLive, []}
           ]
         ],
         users: [
           secondary: [
             #  {Bonfire.UI.Social.WidgetFeedLive, []},
             {Bonfire.Tag.Web.WidgetTagsLive, []}
           ]
         ]
       ]
     )}
  end

  defp login_form(params), do: Accounts.changeset(:login, params)

  def do_handle_params(%{"tab" => _tab} = params, url, socket) do
    Bonfire.UI.Social.FeedsLive.do_handle_params(params, url, socket)
  end

  def do_handle_params(params, _url, socket) do
    # debug(params, "param")

    app = String.capitalize(Bonfire.Application.name())

    # instance_name =
    #   Config.get([:ui, :theme, :instance_name]) || l("An instance of %{app}", app: app)

    show_about_instance? = !current_user_id(socket.assigns) or current_url(socket) == "/about"

    feed_name =
      if Bonfire.Common.Config.get(
           [Bonfire.UI.Social.FeedsLive, :curated],
           false
         ) do
        :curated
      else
        e(socket, :assigns, :live_action, nil) ||
          Settings.get(
            [Bonfire.UI.Social.FeedLive, :default_feed],
            :default,
            socket.assigns[:__context__]
          )
      end

    {:noreply,
     socket
     |> assign(
       show_about_instance?: show_about_instance?,
       page_title:
         if(show_about_instance?,
           do: l("%{app}", app: app),
           else: l("%{app} dashboard", app: app)
         )
     )
     |> assign(
       Bonfire.Social.Feeds.LiveHandler.feed_default_assigns(
         {
           feed_name,
           params
         },
         socket
       )
     )
     |> assign(..., FeedLive.maybe_widgets(e(..., :assigns, nil), feed_name))}
  end

  def handle_params(params, uri, socket),
    do:
      Bonfire.UI.Common.LiveHandlers.handle_params(
        params,
        uri,
        socket,
        __MODULE__,
        &do_handle_params/3
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

  # def render(%{platform_id: :swiftui} = assigns) do
  #   # This UI renders on the iOS/Mac app
  #   ~SWIFTUI"""
  #   <VStack>

  #     <%= case Config.get([:ui, :theme, :instance_icon], "/images/bonfire-icon.png") do %>
  #       <% "/images/bonfire-icon.png" -> %>
  #         <Image name="bonfire-icon" />
  #       <% custom_image -> %>
  #         <AsyncImage url={"#{Bonfire.Web.Endpoint.url()}#{custom_image}" |> debug("imgg")} />
  #     <% end %>

  #     <Text>
  #       Hello Bonfire native!
  #     </Text>

  #   </VStack>
  #   """
  # end

  def render(assigns) do
    assigns
    |> render_sface()
  end
end
