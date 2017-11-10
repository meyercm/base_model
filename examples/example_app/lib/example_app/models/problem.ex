defmodule ExampleApp.Models.Problem do
  use BaseModel, repo: ExampleApp.Repo
  import Ecto.Changeset
  alias ExampleApp.Models.User

  schema "problems" do
    field :description, :string
    field :severity, :integer
    belongs_to :user, User
    timestamps()
  end

  @severities 1..5

  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:description, :severity, :user_id])
    |> validate_inclusion(:severity, @severities)
  end

  def update_changeset(model, params) do
    model
    |> cast(params, [:description, :severity, :user_id])
    |> validate_inclusion(:severity, @severities)
  end

end
