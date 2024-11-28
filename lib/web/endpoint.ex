defmodule Bonfire.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :bonfire
  use Bonfire.UI.Common.EndpointTemplate
  alias Bonfire.Common.Utils
  alias Bonfire.Common.Types
  alias Bonfire.Common.Extend

  use Bonfire.UI.Common.Endpoint.LiveReload, code_reloading?

  # NOTE: putting it here (after Plug.Static which is EndpointTemplate) means it does not apply to static assets
  plug Bonfire.Web.Router.CORS

  # NOTE: can use the following to time the router
  # @decorate time()
  # defp router(conn, _), do: Bonfire.Web.Router.call(conn, [])
  # plug :router
  plug(Bonfire.Web.Router)

  def include_assets(conn) do
    include_assets(conn, :top)
    include_assets(conn, :bottom)
  end

  def include_assets(conn, :top) do
    endpoint_module = Bonfire.Common.Config.endpoint_module()

    font_family =
      Bonfire.Common.Settings.get([:ui, :font_family], "Inter (Latin Languages)", conn)
      |> Types.maybe_to_string()
      |> String.trim_trailing(" Languages)")
      |> String.replace([" ", "-", "(", ")"], "-")
      |> String.replace("--", "-")
      |> String.downcase()

    # unused?
    # <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/choices.js/public/assets/styles/choices.min.css" />
    # <script src="https://cdn.jsdelivr.net/npm/choices.js/public/assets/scripts/choices.min.js"></script>

    # imported into main CSS already
    # <link href="https://unpkg.com/@yaireo/tagify/dist/tagify.css" rel="stylesheet" type="text/css" />

    """
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <link rel="icon" type="image/svg+xml" href='#{endpoint_module.static_path("/images/bonfire-icon.svg")}'>
    <link rel="icon" type="image/svg+xml" data-dynamic-href="{svg}">

    <link phx-track-static rel='stylesheet' href='#{endpoint_module.static_path("/assets/bonfire_basic.css")}'/>
    <link phx-track-static rel='stylesheet' href='#{endpoint_module.static_path("/fonts/#{font_family}.css")}'/>

    <script defer phx-track-static crossorigin='anonymous' src='#{endpoint_module.static_path("/images/icons/svg-inject.min.js")}'></script>

    #{if Extend.module_enabled?(PhoenixGon.View), do: PhoenixGon.View.render_gon_script(conn) |> Phoenix.HTML.safe_to_string()}

    <link rel="manifest" href="/pwa/manifest.json" /> 
    <!-- TODO: move to JS hook?
    <script type="module">
      import '@pwabuilder/pwaupdate';
      const el = document.createElement('pwa-update');
      document.body.appendChild(el);
    </script>
    -->
    """
  end

  def include_assets(%{assigns: assigns} = _conn, :bottom) do
    endpoint_module = Bonfire.Common.Config.endpoint_module()

    js =
      if Utils.current_user(assigns) do
        # || Utils.current_account(assigns)
        endpoint_module.static_path("/assets/bonfire_live.js")
      else
        endpoint_module.static_path("/assets/bonfire_basic.js")
      end

    """
    <script defer phx-track-static crossorigin='anonymous' src='#{js}'></script>
    <link phx-track-static rel='stylesheet' href='#{endpoint_module.static_path("/images/icons/icons.css")}'/>
    """
  end

  def reload!(opts \\ ["--no-all-warnings"]), do: Phoenix.CodeReloader.reload!(__MODULE__, opts)

  @doc "(re)generates the reverse router (useful so it can be re-generated when extensions are enabled/disabled)"
  def generate_reverse_router!(app \\ :bonfire) do
    # IO.puts(:code.priv_dir(app))
    Code.put_compiler_option(:ignore_module_conflict, true)
    Code.eval_file(Path.join(:code.priv_dir(app), "extras/router_reverse.ex"))
    Code.put_compiler_option(:ignore_module_conflict, false)
  end
end
