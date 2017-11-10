defmodule ExampleApp.Mixfile do
  use Mix.Project

  def project do
    [
      app: :example_app,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      preferred_cli_env: [espec: :test],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExampleApp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.1"},
      {:base_model, path: "../.."},
      {:shorter_maps, "~> 2.1"},
      #{:espec, "~> 1.4"},
      {:espec, github: "antonmi/espec", branch: "master"},
    ]
  end
end
