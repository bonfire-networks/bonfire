Code.eval_file("mess.exs", (if File.exists?("../../lib/mix/mess.exs"), do: "../../lib/mix/"))

defmodule Bonfire.Spark.MixProject do
  use Mix.Project

  @config_path "../../config/"

  def project do
    if System.get_env("AS_UMBRELLA") == "1" do
      [
        build_path: "../../_build",
        config_path: "#{@config_path}config.exs",
        deps_path: "../../deps",
        lockfile: "../../mix.lock"
      ]
    else
      []
    end
    ++
    [
      app: :bonfire,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Bonfire.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :os_mon,
        :ssl,
        :bamboo,
        :bamboo_smtp
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    Mess.deps((if System.get_env("WITH_FORKS", "1")=="1", do: [path: "#{@config_path}deps.path", git: "#{@config_path}deps.git", hex: "#{@config_path}deps.hex"], else: [git: "#{@config_path}deps.git", hex: "#{@config_path}deps.hex"]), [
      # error reporting
      {:sentry, "~> 8.0"}, #only: [:dev, :prod]},

      ## dev conveniences
      {:phoenix_live_reload, "~> 1.3"}
    ])
    |> Enum.reject(& elem(&1, 0)==:bonfire)
    # |> IO.inspect
  end
end
