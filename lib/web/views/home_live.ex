defmodule Bonfire.Web.HomeLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view

  alias Bonfire.Me.Accounts
  alias Bonfire.UI.Social.FeedLive

  # @changelog File.read!("#{Config.get(:project_path, "../..")}/docs/CHANGELOG.md")

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, session, socket) do
    current_user = current_user(socket.assigns)

    case Settings.get([:ui, :homepage_redirect_to], nil, current_user) do
      url when is_binary(url) ->
        # redirect to configured homepage
        {:ok,
         socket
         |> redirect_to(url, fallback: "/dashboard", replace: false)}

      _ ->
        if is_nil(current_user) do
          # show guest homepage
          do_mount(params, session, socket)
        else
          # redirect to user dashboard
          {:ok,
           socket
           |> redirect_to("/dashboard", replace: false)}
        end
    end
  end

  defp do_mount(params, _session, socket) do
    links =
      Config.get([:ui, :theme, :instance_welcome, :links], %{
        l("About Bonfire") => "https://bonfirenetworks.org/",
        l("Contribute") => "https://bonfirenetworks.org/contribute/"
      })

    app = String.capitalize(Bonfire.Application.name())

    # instance_name =
    #   Config.get([:ui, :theme, :instance_name]) || l("An instance of %{app}", app: app)

    {:ok,
     socket
     |> assign(
       page: "home",
       is_guest?: true,
       without_sidebar: true,
       without_secondary_widgets: true,
       no_header: true,
       selected_tab: :home,
       page_title: app,
       links: links,
       #  changelog: @changelog,
       error: nil,
       #  form: login_form(params),
       loading: true,
       feed: nil,
       feed_id: nil,
       feed_ids: nil,
       feed_component_id: nil,
       page_info: nil
       #  nav_items: Bonfire.Common.ExtensionModule.default_nav()
     )}
  end

  defp login_form(params), do: Accounts.changeset(:login, params)

  # def handle_params(%{"tab" => _tab} = params, url, socket) do
  #   Bonfire.UI.Social.FeedsLive.handle_params(params, url, socket)
  # end

  @decorate time()
  def handle_params(params, _url, socket) do
    # debug(params, "param")

    feed_name =
      if module_enabled?(Bonfire.Social.Pins, socket) and
           Bonfire.Common.Settings.get(
             [Bonfire.UI.Social.FeedsLive, :curated],
             false,
             socket.assigns
           ) do
        :curated
      else
        # e(socket, :assigns, :live_action, nil) ||
        # Config.get(
        #   [Bonfire.UI.Social.FeedLive, :default_feed]
        # ) ||
        :local
      end

    {
      :noreply,
      socket
      |> assign(
        Bonfire.Social.Feeds.LiveHandler.feed_default_assigns(
          {
            feed_name,
            params
          },
          socket
        )
      )
    }
  end

  render_sface_or_native()
end
