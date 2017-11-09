defmodule ExampleApp.Models.User do
  use BaseModel, repo: ExampleApp.Repo
  alias ExampleApp.Models.Problem

  schema "users" do
    field :name, :string
    field :age, :integer
    has_many :problems, Problem
    timestamps()
  end
end
