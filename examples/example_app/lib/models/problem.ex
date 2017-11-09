defmodule ExampleApp.Models.Problem do
  use BaseModel, repo: ExampleApp.Repo
  alias ExampleApp.Models.User

  schema "problems" do
    field :description, :string
    field :severity, :integer
    belongs_to :user, User
    timestamps()
  end
end
