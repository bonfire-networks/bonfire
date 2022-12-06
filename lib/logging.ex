defmodule Bonfire.Logging do
  require Logger

  def setup(env, repo_module) do
    setup_opentelemetry(env, repo_module)

    EctoSparkles.Log.setup(repo_module)
    # Ecto.DevLogger.install(repo_module)

    setup_oban()
  end

  def setup_opentelemetry(env, repo_module) do
    if System.get_env("ECTO_IPV6") do
      # should we attempt to use ipv6 to connect to telemetry remotes?
      :httpc.set_option(:ipfamily, :inet6fb4)
    end

    if Application.get_env(:opentelemetry, :disabled, true) != true do
      IO.puts("NOTE: OTLP (open telemetry) data is being collected")

      if Application.get_env(:bonfire, Bonfire.Web.Endpoint, [])[:adapter] in [
           Phoenix.Endpoint.Cowboy2Adapter,
           nil
         ] do
        :ok = :opentelemetry_cowboy.setup()
      end

      :ok = OpentelemetryPhoenix.setup()
      :ok = OpentelemetryLiveView.setup()
      # Only trace Oban jobs to minimize noise
      :ok = OpentelemetryOban.setup(trace: [:jobs])

      :ok =
        repo_module.config()
        |> Keyword.fetch!(:telemetry_prefix)
        |> OpentelemetryEcto.setup()
    else
      IO.puts("NOTE: OTLP (open telemetry) data will NOT be collected")
    end
  end

  def setup_oban do
    :telemetry.attach(
      "bonfire-oban-errors",
      [:oban, :job, :exception],
      &Bonfire.Logging.handle_event/4,
      []
    )

    Oban.Telemetry.attach_default_logger()
  end

  def handle_event([:oban, :job, :exception], measure, meta, _) do
    extra =
      meta.job
      |> Map.take([:id, :args, :meta, :queue, :worker])
      |> Map.merge(measure)

    Bonfire.Common.Utils.debug_log(extra, meta.error, meta.stacktrace, :error)
  end
end
