Code.eval_file("mess.exs", (if File.exists?("../../lib/mix/mess.exs"), do: "../../lib/mix/"))

defmodule Bonfire.Spark.MixProject do
  use Mix.Project

  @in_umbrella? File.exists?("../../lib/mix/mess.exs")
  @config_path "../../config/"
  @mess_defs_path if @in_umbrella?, do: @config_path, else: "../../"

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
      version: "0.1.0-beta.3",
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
    Mess.deps((if System.get_env("WITH_FORKS", "1")=="1", do: [path: "#{@mess_defs_path}deps.path", git: "#{@mess_defs_path}deps.git", hex: "#{@mess_defs_path}deps.hex"], else: [git: "#{@mess_defs_path}deps.git", hex: "#{@mess_defs_path}deps.hex"]), [

      {:voodoo, git: "https://github.com/bonfire-networks/voodoo"},
      {:finch, "~> 0.16"},
      {:tz, "~> 0.26.2"},

      # error reporting
      {:sentry, "~> 9.0", optional: true},
      {:orion, "~> 1.0"},
      {:live_admin, #"~> 0.9.0"
      git: "https://github.com/bonfire-networks/live_admin"
      },

      ## dev conveniences
      {:phoenix_live_reload, "~> 1.3", optional: true}

    ])
    |> Enum.reject(& elem(&1, 0)==:bonfire)
    # |> IO.inspect
  end
end
