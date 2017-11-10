defmodule BaseModel.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/meyercm/base_model"

  def project do
    [
      app: :base_model,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      # Hex
      package: hex_package(),
      description: "ActiveRecord for Ecto",
      # Docs
      name: "BaseModel",
      # Testing
      preferred_cli_env: [espec: :test],
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp hex_package do
    [maintainers: ["Chris Meyer"],
     licenses: ["MIT"],
     links: %{"GitHub" => @repo_url}]
  end

  defp deps do
    [
      {:espec, "~> 1.4", only: :test},
      {:ecto, "~> 2.1"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
    ]
  end
end
