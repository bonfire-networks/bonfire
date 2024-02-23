import Config

import_config "config_basics.exs"

yes? = ~w(true yes 1)
test_instance = System.get_env("TEST_INSTANCE")

fake_secret =
  "5KKj74dda6cEocScv+Q2zTu40/oEgQvvhcNSpTytN0AzV3o9eX7Lf9nDlcDYD2RRrOvia/Q3D0W/7u+CNoQZr+fO/93OVKUT31YBVEFuK+rAbbpoiuwXL+nFrrLTQj/H"

config :bonfire_common, :otp_app, :bonfire

config :bonfire,
  otp_app: :bonfire,
  env: config_env(),
  signing_salt: fake_secret,
  encryption_salt: fake_secret

config :bonfire, Bonfire.Web.Endpoint,
  server: false,
  http: [port: 4000],
  adapter: Bandit.PhoenixAdapter,
  secret_key_base: fake_secret,
  live_view: [signing_salt: fake_secret],
  render_errors: [
    # view: Bonfire.UI.Common.ErrorView,
    accepts: ~w(html json),
    # layout: false,
    layout: [html: {Bonfire.UI.Common.BasicView, :error}],
    # root_layout: [html: {Bonfire.UI.Common.BasicView, :error}],
    formats: [html: Bonfire.UI.Common.ErrorView, json: Bonfire.UI.Common.ErrorView]
  ]

maybe_repo_ipv6 = if System.get_env("ECTO_IPV6") in yes?, do: [:inet6], else: []
repo_connection_config = cond do
   db_url = System.get_env("DATABASE_URL") ->
    [
      url: db_url,
      socket_options: maybe_repo_ipv6
    ]
  db_pw = System.get_env("POSTGRES_PASSWORD") ->
    [
      username: System.get_env("POSTGRES_USER", "postgres"),
      password: db_pw,
      hostname: System.get_env("POSTGRES_HOST", "localhost"),
      database: "bonfire_test_#{test_instance}_#{System.get_env("MIX_TEST_PARTITION")}",
      socket_options: maybe_repo_ipv6
    ]
    true -> 
      nil
  end
  
# Choose password hashing backend
config :bonfire_data_identity, Bonfire.Data.Identity.Credential, hasher_module: Bonfire.Testing.InsecurePW

#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.

config :needle, :search_path, []

config :bonfire, :endpoint_module, Bonfire.Web.Endpoint
config :phoenix_test, :endpoint, Bonfire.Web.Endpoint

if repo_connection_config do
  config :bonfire, :repo_module, Bonfire.Common.Repo
  config :bonfire_umbrella, Bonfire.Common.Repo, repo_connection_config
  config :bonfire_umbrella, Bonfire.Common.TestInstanceRepo, repo_connection_config
  config :bonfire, ecto_repos: [Bonfire.Common.Repo]
  config :bonfire_umbrella, ecto_repos: [Bonfire.Common.Repo]
  config :paginator, ecto_repos: [Bonfire.Common.Repo]
  config :activity_pub, ecto_repos: [Bonfire.Common.Repo]
end

config :ecto_sparkles, :otp_app, :bonfire
config :ecto_sparkles, :env, config_env()

config :phoenix, :json_library, Jason

config :live_admin, :modularity, :disabled
config :orion, :modularity, :disabled

config :logger,
  handle_sasl_reports: true,
  handle_otp_reports: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mime, :types, %{
  "application/activity+json" => ["activity+json"]
}

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

config :opentelemetry,
  modularity: :disabled
