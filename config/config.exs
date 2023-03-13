import Config

config :eref_calsync,
  ecto_repos: [ErefCalsync.Repo]

config :eref_calsync, ErefCalsync.Repo, database: "database.db"
