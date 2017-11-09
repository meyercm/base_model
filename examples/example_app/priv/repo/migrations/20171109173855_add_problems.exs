defmodule ExampleApp.Repo.Migrations.AddProblems do
  use Ecto.Migration

  def change do
    create table :problems do
      add :description, :text
      add :severity, :integer
      add :user_id, references(:users), null: false
      timestamps()
    end
  end
end
