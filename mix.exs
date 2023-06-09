defmodule ErefCalsync.MixProject do
  use Mix.Project

  def project do
    [
      app: :eref_calsync,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ErefCalsync.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:ecto_sqlite3, "~> 0.9.1"},
      {:httpoison, "~> 2.1"},
      {:floki, "~> 0.34.2"},
      {:jason, "~> 1.4"},
      {:goth, "~> 1.3"},
      {:google_api_calendar, "~> 0.21.8"},
      {:tzdata, "~> 1.1"},
      {:timex, "~> 3.7"},
      {:icalendar, "~> 1.1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
