defmodule Bonfire.System.OS.Monitor do
  import Untangle
  alias Bonfire.Common.Config

  def init({_args, {:alarm_handler, alarms}}) do
    debug("Custom alarm handler init!")
    for {alarm_name, alarm_description} <- alarms, do: handle_alarm(alarm_name, alarm_description)
    {:ok, []}
  end

  def handle_event({:set_alarm, {alarm_name, alarm_description}}, state) do
    handle_alarm(alarm_name, alarm_description)
    {:ok, state}
  end

  def handle_event({:clear_alarm, {alarm_name, _alarm_description}}, state) do
    state
    |> debug("Clearing the alarm  #{alarm_name}")

    {:ok, state}
  end

  def handle_event({:clear_alarm, alarm_name}, state) do
    state
    |> debug("Clearing the alarm  #{alarm_name}")

    {:ok, state}
  end

  def handle_alarm({alarm_name, alarm_description}, []),
    do: handle_alarm(alarm_name, alarm_description)

  def handle_alarm(:disk_almost_full = alarm_name, alarm_description) do
    handle_alarm(
      "#{alarm_name} : #{alarm_description}",
      :disksup.get_disk_data()
      |> Enum.map(fn {mountpoint, kbytes, percent} ->
        "#{mountpoint} is at #{format_percent(percent)} of #{format_bytes(kbytes * 1024)}"
      end)
      |> Enum.join("\n")
    )
  end

  def handle_alarm(alarm_name, alarm_description) when not is_binary(alarm_description),
    do: handle_alarm(alarm_name, inspect(alarm_description))

  def handle_alarm(alarm_name, alarm_description) do
    warn(alarm_name, "System monitor alarm")
    info(alarm_description, "Alarm details")

    case Config.get(:env) == :prod and Config.get([Bonfire.Mailer, :reply_to]) do
      false ->
        :skip

      nil ->
        warn("You need to configure an email")

      to ->
        title = "Alert: #{alarm_name}"

        Bamboo.Email.new_email(
          subject: "[System alert from Bonfire] " <> title,
          html_body:
            title <>
              "<p><pre>" <> String.replace(alarm_description, "\n", "<br/>") <> "</pre></p>",
          text_body: title <> " " <> alarm_description
        )
        |> Bonfire.Mailer.send_async(to)
    end
  end

  @doc """
  Formats percent.
  """
  def format_percent(percent) when is_float(percent), do: "#{Float.round(percent, 1)}%"
  def format_percent(nil), do: "0%"
  def format_percent(percent), do: "#{percent}%"

  @doc """
  Formats bytes.
  """
  def format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= memory_unit(:TB) -> format_bytes(bytes, :TB)
      bytes >= memory_unit(:GB) -> format_bytes(bytes, :GB)
      bytes >= memory_unit(:MB) -> format_bytes(bytes, :MB)
      bytes >= memory_unit(:KB) -> format_bytes(bytes, :KB)
      true -> format_bytes(bytes, :B)
    end
  end

  defp format_bytes(bytes, :B) when is_integer(bytes), do: "#{bytes} B"

  defp format_bytes(bytes, unit) when is_integer(bytes) do
    value = bytes / memory_unit(unit)
    "#{:erlang.float_to_binary(value, decimals: 1)} #{unit}"
  end

  defp memory_unit(:TB), do: 1024 * 1024 * 1024 * 1024
  defp memory_unit(:GB), do: 1024 * 1024 * 1024
  defp memory_unit(:MB), do: 1024 * 1024
  defp memory_unit(:KB), do: 1024
end
