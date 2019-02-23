defmodule Match.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :string, primary_key: true
      add :username, :string
      add :hash, :string
      add :icon, :string

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
