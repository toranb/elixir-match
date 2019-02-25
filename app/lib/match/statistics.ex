defmodule Match.Statistics do
  import Ecto.Query, warn: false

  alias Match.Repo
  alias Match.Statistic

  def all do
    Repo.all(Statistic)
  end

  def get_by(attrs \\ %{}) do
    Repo.get_by(Statistic, attrs, log: false)
  end

  def upsert_by(user_id, stats) do
    case Repo.get_by(Statistic, %{:user => user_id}) do
      nil -> %Statistic{}
      stat -> stat
    end
    |> Statistic.changeset(stats)
    |> Repo.insert_or_update
  end
end
