defmodule Bonfire.Application do
  @moduledoc false
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  use Application
  require Cachex.Spec

  @sup_name Bonfire.Supervisor
  @top_otp_app Bonfire.Common.Config.get!(:otp_app)
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

  @default_cache_in_hours 3
  @default_cache_ttl 1_000 * 60 * 60 * @default_cache_in_hours

  @apps_before [
    # Metrics
    Bonfire.Web.Telemetry,
    # Database
    @repo_module,
    EctoSparkles.AutoMigrator,
    # behaviour modules are already prepared as part of `Bonfire.Common.Config.LoadExtensionsConfig`
    # Bonfire.Common.ExtensionBehaviour,
    # Bonfire.Common.Config.LoadExtensionsConfig,
    # load instance Settings from DB into Config
    Bonfire.Me.Settings.LoadInstanceConfig,
    # PubSub
    {Phoenix.PubSub, [name: Bonfire.Common.PubSub, adapter: Phoenix.PubSub.PG2]},
    Bonfire.UI.Common.Presence,
    # Persistent Data Services
    Pointers.Tables,
    # Bonfire.Data.AccessControl.Accesses,
    ## these populate on first call, so no need to run on startup:
    # Bonfire.Common.ContextModule,
    # Bonfire.Common.QueryModule,
    # Bonfire.Federate.ActivityPub.FederationModules
    # {PhoenixProfiler, name: Bonfire.Web.Profiler},
    {Finch, name: Bonfire.Finch, pools: Bonfire.RuntimeConfig.finch_pool_config()}
  ]

  # Stuff that depends on the Endpoint and/or the above
  @apps_after [
    # Job Queue
    {Oban, Application.compile_env!(:bonfire, Oban)},
    %{
      id: :bonfire_cache,
      start:
        {Cachex, :start_link,
         [
           :bonfire_cache,
           [
             expiration: Cachex.Spec.expiration(default: @default_cache_ttl),
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
  ]

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

    # Application.get_env(:bonfire, Bonfire.Web.Endpoint, [])
    # |> IO.inspect()

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

  def applications(:test, true = _test_instance?, _any) do
    @apps_before ++
      [Bonfire.Common.TestInstanceRepo] ++
      [@endpoint_module, Bonfire.Web.FakeRemoteEndpoint] ++
      @apps_after
  end

  def applications(:dev, _test_instance?, _any) do
    [
      {Bonfire.Telemetry.Storage, Bonfire.Web.Telemetry.metrics()}, # simple ETS based storage for non-prod
    {PlugAttack.Storage.Ets, name: Bonfire.UI.Common.PlugAttack.Storage, clean_period: 60_000}
    ] ++ applications(nil, nil, nil)
  end

  # default apps
  def applications(_env, _test_instance?, _any) do
    @apps_before ++
      Bonfire.Social.Graph.maybe_applications() ++
      [@endpoint_module] ++
      @apps_after
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    @endpoint_module.config_change(changed, removed)
    :ok
  end
end
