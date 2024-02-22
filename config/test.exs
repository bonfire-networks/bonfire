import Config

import_config "config_basics.exs"

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

# Choose password hashing backend
# Note that this corresponds with our dependencies in mix.exs
hasher = if config_env() in [:dev, :test], do: Pbkdf2, else: Argon2

config :bonfire_data_identity, Bonfire.Data.Identity.Credential, hasher_module: hasher

#### Basic configuration

# You probably won't want to touch these. You might override some in
# other config files.

config :needle, :search_path, []

config :bonfire, :endpoint_module, Bonfire.Web.Endpoint
config :phoenix_test, :endpoint, Bonfire.Web.Endpoint

# config :bonfire, :repo_module, Bonfire.Common.Repo

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
