Code.eval_file("mess.exs", (if File.exists?("../../lib/mix/mess.exs"), do: "../../lib/mix/"))

defmodule Bonfire.Spark.MixProject do
  use Mix.Project

  @in_umbrella? File.exists?("../../lib/mix/mess.exs")
  @config_path "../../config/"
  @umbrella_mess_defs if @in_umbrella?, do: "#{@config_path}deps.flavour", else: "../../deps.flavour"

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
    spark_sources = [path: "deps.path", git: "deps.git", hex: "deps.hex"]
    Mess.deps((if System.get_env("WITH_FORKS", "1")=="1", do: spark_sources ++ [path: "#{@umbrella_mess_defs}.path", git: "#{@umbrella_mess_defs}.git", hex: "#{@umbrella_mess_defs}.hex"], else: spark_sources ++ [git: "#{@umbrella_mess_defs}.git", hex: "#{@umbrella_mess_defs}.hex"]), [

      {:voodoo, git: "https://github.com/bonfire-networks/voodoo"},
      {:finch, "~> 0.16"},
      {:tz, "~> 0.26.2"},
      {:bonfire_ui_me, git: "https://github.com/bonfire-networks/bonfire_ui_me", optional: true},
      
      # tests
      {:mneme, ">= 0.0.0", only: [:dev, :test]},

      # error reporting
      {:sentry, "~> 10.0", optional: true},
      {:orion, "~> 1.0"},
      {:live_admin, #"~> 0.9.0"
      git: "https://github.com/bonfire-networks/live_admin"
      },

      # API
      # {:exonerate, "~> 1.1.3", runtime: Mix.env() != :prod},
      # {:yaml_elixir, "~> 2.9"},

      ## dev conveniences
      {:phoenix_live_reload, "~> 1.3", optional: true},
      {:pbkdf2_elixir, "~> 2.0", optional: true}

    ])
    |> Enum.reject(& elem(&1, 0)==:bonfire)
    # |> IO.inspect
  end
end
