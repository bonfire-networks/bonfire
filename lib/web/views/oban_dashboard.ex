defmodule Bonfire.Web.ObanDashboard do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder
  import Ecto.Query
  alias Bonfire.Common.Utils

  @impl true
  def menu_link(_, _) do
    {:ok, "Oban Jobs"}
  end

  @impl true
  def render_page(_assigns) do
    live_table(
      columns: table_columns(),
      id: :oban,
      #   row_attrs: &row_attrs/1,
      row_fetcher: &fetch/2,
      rows_name: "tables",
      title: "Oban Jobs"
    )
  end

  defp fetch(params, node) do
    # %{search: search, sort_by: sort_by, sort_dir: sort_dir, limit: limit} = params
    # |> IO.inspect(label: "params")

    # [
    #     ActivityPub.Federator.Workers.RemoteFetcherWorker,
    #     ActivityPub.Federator.Workers.ReceiverWorker,
    #     ActivityPub.Federator.Workers.PublisherWorker
    # ]
    # list(worker: ActivityPub.Federator.Workers.RemoteFetcherWorker)

    list =
      Bonfire.Common.Config.repo()
      |> list([])
      |> Enum.map(
        &(&1
          # "#{&1.args["module"]}.#{&1.args["op"]}"
          |> Map.merge(%{
            job: &1.args["op"],
            scheduled_at: DateTime.to_string(&1.scheduled_at),
            data: Utils.e(&1.args, "params", "json", nil),
            params: inspect(Map.drop(&1.args["params"] || %{}, ["json"])),
            errors: inspect(&1.errors)
          })
          |> Map.take([:id, :state, :job, :data, :params, :errors, :attempt, :scheduled_at]))
      )

    # |> IO.inspect(label: "all")

    # %Oban.Job{id: 841, state: "executing", queue: "federator_outgoing", worker: "ActivityPub.Federator.Workers.PublisherWorker", args: %{"module" => "Elixir.ActivityPub.Federator.APPublisher", "op" => "publish_one", "params" => %{"actor_username" => "mayel", "id" => "http://localhost:4000/pub/objects/5f4777c5-7f3e-43e9-8d65-469a7d8a3342", "inbox" => "https://piaille.fr/inbox", "json" => "{\"@context\":[],\"actor\":\"http://localhost:4000/pub/actors/mayel\",\"cc\":[\"http://localhost:4000/pub/actors/mayel/followers\"],\"context\":null,\"id\":\"http://localhost:4000/pub/objects/5f4777c5-7f3e-43e9-8d65-469a7d8a3342\",\"object\":{\"actor\":\"http://localhost:4000/pub/actors/mayel\",\"attributedTo\":\"http://localhost:4000/pub/actors/mayel\",\"cc\":[\"http://localhost:4000/pub/actors/mayel/followers\"],\"content\":\"<p>\\nfdsdsf</p>\\n<ul>\\n <li>\\nsadsdfa </li>\\n <li>\\nsfdfgds </li>\\n</ul>\\n\",\"id\":\"http://localhost:4000/pub/objects/01GT6D7SXSG8J580XEAM76VH66\",\"published\":\"2023-02-26T08:25:50.746385Z\",\"tag\":[],\"to\":[\"https://www.w3.org/ns/activitystreams#Public\"],\"type\":\"Note\"},\"published\":\"2023-02-26T08:25:50.280277Z\",\"to\":[\"https://www.w3.org/ns/activitystreams#Public\"],\"type\":\"Create\"}", "unreachable_since" => "2023-02-25T22:14:16.105641"}, "repo" => "Elixir.Bonfire.Common.Repo"}, meta: %{}, tags: [], errors: [], attempt: 1, attempted_by: ["dev@MBP"], max_attempts: 1, priority: 0, attempted_at: ~U[2023-02-26 08:26:19.647706Z], cancelled_at: nil, completed_at: nil, discarded_at: nil, inserted_at: ~U[2023-02-26 08:26:18.444758Z], scheduled_at: ~U[2023-02-26 08:26:18.444758Z], conf: nil, conflict?: false, replace: nil, unique: nil, unsaved_error: nil}

    {list, Enum.count(list)}
  end

  defp table_columns() do
    [
      %{
        field: :id,
        header: "ID",
        cell_attrs: [style: "font-size: 0.7rem"]
      },
      %{
        field: :job,
        # sortable: :desc,
        cell_attrs: [style: "font-size: 0.7rem"]
      },
      %{
        field: :state,
        # sortable: :desc,
        cell_attrs: [style: "font-size: 0.7rem"]
      },
      %{
        field: :attempt,
        cell_attrs: [class: "text-right"]
      },
      %{
        field: :params,
        cell_attrs: [
          style: "font-size: 0.8rem; font-family: ui-monospace, monospace; max-width: 240px"
        ]
      },
      %{
        field: :data,
        cell_attrs: [
          style: "font-size: 0.7rem; font-family: ui-monospace, monospace; max-width: 580px"
        ]
      },
      %{
        field: :errors,
        cell_attrs: [style: "font-size: 0.7rem"]
      },
      %{
        field: :scheduled_at,
        sortable: :desc,
        cell_attrs: [style: "font-size: 0.7rem"]
      }
    ]
  end

  def list(repo, opts) when is_list(opts) do
    {conf, opts} = extract_conf(repo, opts)

    Oban.Repo.all(conf, base_query(opts))
  end

  defp query_states(opts, states \\ ["available", "scheduled"]) do
    base_query(opts)
    |> where([j], j.state in ^states)
  end

  defp base_query(opts) do
    fields_with_opts = normalize_fields(opts)

    Oban.Job
    |> apply_where_clauses(fields_with_opts)
    |> order_by(desc: :id)
  end

  @timestamp_fields ~W(attempted_at completed_at inserted_at scheduled_at)a
  @timestamp_default_delta_seconds 1

  defp apply_where_clauses(query, []), do: query

  defp apply_where_clauses(query, [{key, value, opts} | rest]) when key in @timestamp_fields do
    delta = Keyword.get(opts, :delta, @timestamp_default_delta_seconds)

    window_start = DateTime.add(value, -delta, :second)
    window_end = DateTime.add(value, delta, :second)

    query
    |> where([j], fragment("? BETWEEN ? AND ?", field(j, ^key), ^window_start, ^window_end))
    |> apply_where_clauses(rest)
  end

  defp apply_where_clauses(query, [{key, value, _opts} | rest]) do
    query
    |> where(^[{key, value}])
    |> apply_where_clauses(rest)
  end

  defp extract_conf(repo, opts) do
    {conf_opts, opts} = Keyword.split(opts, [:prefix])

    conf =
      conf_opts
      |> Keyword.put(:repo, repo)
      |> Oban.Config.new()

    {conf, opts}
  end

  defp extract_field_opts({key, {value, field_opts}}, field_opts_acc) do
    {{key, value}, [{key, field_opts} | field_opts_acc]}
  end

  defp extract_field_opts({key, value}, field_opts_acc) do
    {{key, value}, field_opts_acc}
  end

  defp normalize_fields(opts) do
    {fields, field_opts} = Enum.map_reduce(opts, [], &extract_field_opts/2)

    args = Keyword.get(fields, :args, %{})
    keys = Keyword.keys(fields)

    args
    |> Oban.Job.new(fields)
    |> Ecto.Changeset.apply_changes()
    |> Map.from_struct()
    |> Map.take(keys)
    |> Enum.map(fn {key, value} -> {key, value, Keyword.get(field_opts, key, [])} end)
  end
end
