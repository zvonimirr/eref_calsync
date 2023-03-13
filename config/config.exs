import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :eref_calsync,
  ecto_repos: [ErefCalsync.Repo]

config :eref_calsync, ErefCalsync.Repo, database: "database.db"

import_config "secret.exs"
