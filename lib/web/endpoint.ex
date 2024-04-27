defmodule Bonfire.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :bonfire
  use Bonfire.UI.Common.EndpointTemplate
  alias Bonfire.Common.Utils
  alias Bonfire.Common.Types
  alias Bonfire.Common.Extend

  def halt_live_reload(%{request_path: "/phoenix/live_reload/socket/websocket"} = conn, _),
    do: conn |> resp(404, "Not enabled") |> halt()

  def halt_live_reload(conn, _), do: conn

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if Application.compile_env(:bonfire, :hot_code_reload) && code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)

    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :bonfire_umbrella)

    # FIXME
    # socket "/admin/system/wobserver", Wobserver.Web.PhoenixSocket

    # plug(PhoenixProfiler)
  else
    plug(:halt_live_reload)
  end

  # NOTE: putting it here (after Plug.Static which is EndpointTemplate) means it does not apply to static assets
  plug Bonfire.Web.Router.CORS

  @decorate time()
  defp router(conn, _), do: Bonfire.Web.Router.call(conn, [])
  plug :router
  # plug(Bonfire.Web.Router)

  def include_assets(conn) do
    include_assets(conn, :top)
    include_assets(conn, :bottom)
  end

  def include_assets(conn, :top) do
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
    <link rel="icon" type="image/svg+xml" href='#{static_path("/images/bonfire-icon.svg")}'>
    <link rel="icon" type="image/svg+xml" data-dynamic-href="{svg}">

    <link phx-track-static rel='stylesheet' href='#{static_path("/assets/bonfire_basic.css")}'/>
    <link phx-track-static rel='stylesheet' href='#{static_path("/fonts/#{font_family}.css")}'/>

    <script phx-track-static crossorigin='anonymous' src='#{static_path("/images/icons/svg-inject.min.js")}'></script>

    #{if Extend.module_enabled?(PhoenixGon.View), do: PhoenixGon.View.render_gon_script(conn) |> Phoenix.HTML.safe_to_string()}

    <link rel="manifest" href="/pwa/manifest.json" />
    <script type="module">
      import 'https://cdn.jsdelivr.net/npm/@pwabuilder/pwaupdate';
      const el = document.createElement('pwa-update');
      document.body.appendChild(el);
    </script>
    """
  end

  def include_assets(%{assigns: assigns} = _conn, :bottom) do
    js =
      if Utils.current_user(assigns) do
        # || Utils.current_account(assigns)
        static_path("/assets/bonfire_live.js")
      else
        static_path("/assets/bonfire_basic.js")
      end

    """
    <script defer phx-track-static crossorigin='anonymous' src='#{js}'></script>
    <link phx-track-static rel='stylesheet' href='#{static_path("/images/icons/icons.css")}'/>
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
