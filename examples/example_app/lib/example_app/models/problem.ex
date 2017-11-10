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

  @allowed_severities 1..5

  # These override the defaults provided in BaseModel, allowing us to specify
  # custom validation or param scubbing.

  # Both of these do the same thing, but are separate so that updates can have
  # logic separate from create: for instance, it might not make sense to allow
  # updates on a foreign key.
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:description, :severity, :user_id])
    |> validate_inclusion(:severity, @severities)
  end

  def update_changeset(model, params) do
    model
    |> cast(params, [:description, :severity, :user_id])
    |> validate_inclusion(:severity, @allowed_severities)
  end

end
