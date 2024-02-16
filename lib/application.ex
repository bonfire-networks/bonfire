defmodule Bonfire.Application do
  @moduledoc false
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  use Application
  require Cachex.Spec
  alias Bonfire.Common.Config

  @sup_name Bonfire.Supervisor
  @top_otp_app Config.get!(:otp_app)
  @env Application.compile_env!(@top_otp_app, :env)
  @endpoint_module Application.compile_env!(@top_otp_app, :endpoint_module)
  @repo_module Application.compile_env!(@top_otp_app, :repo_module)
  @project if Code.ensure_loaded?(Bonfire.Umbrella.MixProject),
             do: Bonfire.Umbrella.MixProject.project()
  @config if Code.ensure_loaded?(Bonfire.Umbrella.MixProject),
            do: Bonfire.Umbrella.MixProject.config(),
            else: Mix.Project.config()
  @deps_loaded Bonfire.Common.Extensions.loaded_deps(:nested)
  @deps_loaded_flat Bonfire.Common.Extensions.loaded_deps(deps_loaded: @deps_loaded)

  def default_cache_hours, do: Config.get(:default_cache_hours) || 3

  def apps_before,
    do:
      [
        # Metrics
        Bonfire.Web.Telemetry,
        # Database
        @repo_module,
        EctoSparkles.AutoMigrator,
        # behaviour modules are already prepared as part of `Config.LoadExtensionsConfig`
        # Bonfire.Common.ExtensionBehaviour,
        # Config.LoadExtensionsConfig,
        # load instance Settings from DB into Config
        Bonfire.Common.Settings.LoadInstanceConfig,
        # PubSub
        {Phoenix.PubSub, [name: Bonfire.Common.PubSub, adapter: Phoenix.PubSub.PG2]},
        Bonfire.UI.Common.Presence,
        # Persistent Data Services
        Needle.Tables,
        # Bonfire.Data.AccessControl.Accesses,
        ## these populate on first call, so no need to run on startup:
        # Bonfire.Common.ContextModule,
        # Bonfire.Common.QueryModule,
        # Bonfire.Federate.ActivityPub.FederationModules
        # {PhoenixProfiler, name: Bonfire.Web.Profiler},
        {Finch, name: Bonfire.Finch, pools: finch_pool_config()},
        %{
          id: :bonfire_cache,
          start:
            {Cachex, :start_link,
             [
               :bonfire_cache,
               [
                 expiration: Cachex.Spec.expiration(default: :timer.hours(default_cache_hours())),
                 # increase for instances with more users (at least num. of users*2+1)
                 limit:
                   Cachex.Spec.limit(
                     # max number of entries
                     size: 2_500,
                     # the policy to use for eviction
                     policy: Cachex.Policy.LRW,
                     # what % to reclaim when limit is reached
                     reclaim: 0.1
                   )
               ]
             ]}
        }
      ] ++ Bonfire.Common.Utils.maybe_apply(Bonfire.Social.Graph, :maybe_applications, [], fallback_return: [])

  # Stuff that depends on the Endpoint and/or the above
  def apps_after,
    do: [
      {Tz.UpdatePeriodically, [interval_in_days: 10]}
    ] ++ maybe_oban()

  def maybe_oban do
   case Application.get_env(:bonfire, Oban, []) do
    [] -> [] 
    config -> [
        # Job Queue
        {Oban, config}
      ]
    end
  end

  @plug_protect {PlugAttack.Storage.Ets,
                 name: Bonfire.UI.Common.PlugProtect.Storage, clean_period: 60_000}

  def project, do: @project
  def config, do: @config
  def name, do: Application.get_env(:bonfire, :app_name) || config()[:name]
  def version, do: config()[:version]
  def named_version, do: "#{name()} #{version()}"
  def repository, do: project()[:sources_url] || project()[:source_url]
  def required_deps, do: project()[:required_deps]
  def deps(opt \\ nil)
  # as loaded at compile time, nested
  def deps(:nested), do: @deps_loaded
  #  as loaded at compile time, flat
  def deps(:flat), do: @deps_loaded_flat
  # as defined in the top-level app's mix.exs / deps.hex / etc
  def deps(_), do: config()[:deps]

  def start(_type, _args) do
    Bonfire.Logging.setup(@env, @repo_module)

    :gen_event.swap_handler(
      :alarm_handler,
      {:alarm_handler, :swap},
      {Bonfire.System.OS.Monitor, :ok}
    )
    |> IO.inspect(label: "Bonfire.System.OS.Monitor")

    Application.get_env(:bonfire, Bonfire.Web.Endpoint, [])
    |> IO.inspect()

    applications(
      @env,
      System.get_env("TEST_INSTANCE") == "yes",
      Bonfire.Common.Extend.module_enabled?(Bonfire.API.GraphQL) and
        Bonfire.Common.Extend.module_enabled?(Bonfire.API.GraphQL.Schema)
    )
    # |> IO.inspect(label: "apps tree")
    |> Supervisor.start_link(strategy: :one_for_one, name: @sup_name)
  end

  # include GraphQL API
  def applications(env, test_instance?, true = _with_graphql?) do
    IO.puts("Enabling the GraphQL API...")

    [
      # use persistent_term backend for Absinthe
      {Absinthe.Schema, Bonfire.API.GraphQL.Schema}
    ] ++
      applications(env, test_instance?, nil) ++
      [
        {Absinthe.Subscription, @endpoint_module}
      ]
  end

  def applications(_, true = _test_instance?, _any) do
    apps_before() ++
      [Bonfire.Common.TestInstanceRepo] ++
      [@plug_protect, @endpoint_module, Bonfire.Web.FakeRemoteEndpoint] ++
      maybe_pages_beacon() ++
      apps_after()
  end

  # def applications(:test, _, _any) do
  #   applications(nil, nil, nil)
  # end

  def applications(:dev, _, _any) do
    [
      # simple ETS based storage for non-prod
      {Bonfire.Telemetry.Storage, Bonfire.Web.Telemetry.metrics()}
    ] ++ applications(nil, nil, nil)
  end

  # default apps
  def applications(_env, _, _any) do
    apps_before() ++
      [@plug_protect, @endpoint_module] ++
      maybe_pages_beacon() ++
      apps_after()
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    @endpoint_module.config_change(changed, removed)
    :ok
  end

  def recompile do
    Phoenix.CodeReloader.reload(@endpoint_module)
  end

  def recompile! do
    Application.stop(:bonfire)
    IEx.Helpers.recompile()
    Application.ensure_all_started(:bonfire)
  end

  # @doc "The system is restarted inside the running Erlang node, which means that the emulator is not restarted. All applications are taken down smoothly, all code is unloaded, and all ports are closed before the system is booted again in the same way as initially started."
  # def restart() do
  #   :init.restart()
  # end

  defp maybe_pages_beacon do
    if Bonfire.Common.Extend.module_enabled?(Beacon),
      do: [
        {Beacon,
         sites: [
           [
             site: :instance_site,
             endpoint: @endpoint_module,
             data_source: Bonfire.Pages.Beacon.DataSource
           ]
         ]}
      ],
      else: []
  end

  def finch_pool_config() do
    %{
      :default => [size: 42, count: 2],
      "https://icons.duckduckgo.com" => [
        conn_opts: [transport_opts: [size: 8, timeout: 3_000]]
      ],
      "https://www.google.com/s2/favicons" => [
        conn_opts: [transport_opts: [size: 8, timeout: 3_000]]
      ]
    }
    |> maybe_add_sentry_pool()
  end

  def maybe_add_sentry_pool(pool_config) do
    case Code.ensure_loaded?(Sentry.Config) and Sentry.Config.dsn() do
      dsn when is_binary(dsn) ->
        Map.put(pool_config, dsn, size: 50)

      _ ->
        pool_config
    end
  end
end
