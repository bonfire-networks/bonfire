defmodule Bonfire.Web.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @millis {:native, :millisecond}

  def metrics do
    [
      # Phoenix
      summary("phoenix.endpoint.stop.duration", unit: @millis),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:method, :route],
        tag_values: &get_and_put_http_method/1,
        unit: @millis
      ),
      summary("phoenix.error_rendered.duration", unit: @millis),
      summary("phoenix.socket_connected.duration", unit: @millis),
      summary("phoenix.channel_joined.duration", unit: @millis),
      summary("phoenix.channel_joined.duration", unit: @millis),

      # Phoenix LiveView
      summary("phoenix.live_view.mount.stop.duration",
        unit: @millis,
        tags: [:view, :connected?],
        tag_values: &live_view_metric_tag_values/1
      ),
      summary("phoenix.live_view.mount.exception.duration",
        unit: @millis,
        tags: [:view, :connected?],
        tag_values: &live_view_metric_tag_values/1
      ),
      summary("phoenix.live_view.handle_params.stop.duration",
        unit: @millis,
        tags: [:view, :connected?],
        tag_values: &live_view_metric_tag_values/1
      ),
      summary("phoenix.live_view.handle_params.exception.duration",
        unit: @millis,
        tags: [:view, :connected?],
        tag_values: &live_view_metric_tag_values/1
      ),
      summary("phoenix.live_view.handle_event.stop.duration",
        unit: @millis,
        tags: [:view, :event],
        tag_values: fn metadata ->
          Map.put(metadata, :view, "#{inspect(metadata.socket.view)}")
        end
      ),
      summary("phoenix.live_view.handle_event.exception.duration",
        unit: @millis,
        tags: [:view, :event],
        tag_values: fn metadata ->
          Map.put(metadata, :view, "#{inspect(metadata.socket.view)}")
        end
      ),
      summary("phoenix.live_component.handle_event.stop.duration",
        unit: @millis,
        tags: [:view, :event],
        tag_values: fn metadata ->
          Map.put(metadata, :view, "#{inspect(metadata.socket.view)}")
        end
      ),
      summary("phoenix.live_component.handle_event.exception.duration",
        unit: @millis,
        tags: [:view, :event],
        tag_values: fn metadata ->
          Map.put(metadata, :view, "#{inspect(metadata.socket.view)}")
        end
      ),

      # Database Metrics
      summary("bonfire.repo.query.total_time", unit: @millis),
      summary("bonfire.repo.query.decode_time", unit: @millis),
      summary("bonfire.repo.query.query_time", unit: @millis),
      summary("bonfire.repo.query.queue_time", unit: @millis),
      summary("bonfire.repo.query.idle_time", unit: @millis),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :megabyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {Bonfire.UI.Common.Web, :count_users, []}
    ]
  end

  defp get_and_put_http_method(%{conn: %{method: method}} = metadata) do
    Map.put(metadata, :method, method)
  end

  defp live_view_metric_tag_values(metadata) do
    metadata
    |> Map.put(:view, inspect(metadata.socket.view))
    |> Map.put(:connected?, get_connection_status(Phoenix.LiveView.connected?(metadata.socket)))
  end

  defp get_connection_status(true), do: "Connected"
  defp get_connection_status(_), do: "Disconnected"
end
