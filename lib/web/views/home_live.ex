defmodule Bonfire.Web.HomeLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  alias Bonfire.Me.Accounts

  @changelog File.read!("#{Config.get(:project_path, "../..")}/docs/CHANGELOG.md")

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
       page_title: l("Bonfire"),
       links: links,
       changelog: @changelog,
       error: nil,
       form: login_form(params),
       loading: true,
       feed: nil,
       feed_id: nil,
       feed_ids: nil,
       feed_component_id: nil,
       page_info: nil,
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
             {Bonfire.Tag.Web.WidgetTagsLive, []}
           ]
         ]
       ]
     )
     |> assign(
       Bonfire.Social.Feeds.LiveHandler.feed_assigns_maybe_async({:default, params}, socket)
     )}
  end

  defp login_form(params), do: Accounts.changeset(:login, params)

  # def do_handle_params(%{"tab" => tab} = _params, _url, socket) do
  #   debug(tab)
  #   {:noreply, assign(socket, selected_tab: tab)}
  # end

  def do_handle_params(_params, _url, socket) do
    # debug(params, "param")

    app = String.capitalize(Bonfire.Application.name())

    # instance_name =
    #   Config.get([:ui, :theme, :instance_name]) || l("An instance of %{app}", app: app)

    show_about_instance? = !current_user(socket) or current_url(socket) == "/about"

    {:noreply,
     socket
     |> assign(
       show_about_instance?: show_about_instance?,
       page_title:
         if(show_about_instance?,
           do: l("%{app}", app: app),
           else: l("%{app} dashboard", app: app)
         )
     )}
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
end
