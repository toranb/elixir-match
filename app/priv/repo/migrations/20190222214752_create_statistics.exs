defmodule Match.Repo.Migrations.CreateStatistics do
  use Ecto.Migration

  def change do
    create table(:statistics, primary_key: false) do
      add :user, :string, primary_key: true
      add :wins, :integer
      add :flips, :integer

      timestamps()
    end

    create unique_index(:statistics, [:user])
  end
end
