# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :example_app, ecto_repos: [ExampleApp.Repo]

config :example_app, ExampleApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "basemodel_example_1",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  port: "5432",
  loggers: []


import_config "secrets.exs"
