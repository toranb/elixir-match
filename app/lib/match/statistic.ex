defmodule Match.Statistic do
  use Ecto.Schema

  alias Match.Statistics

  import Ecto.Changeset

  @primary_key {:user, :string, []}
  schema "statistics" do
    field :wins, :integer
    field :flips, :integer

    timestamps()
  end

  def changeset(stat, params \\ %{}) do
    stat
      |> cast(params, [:user, :wins, :flips])
  end

  def transform_previous(statistics) do
    Enum.map(statistics, fn(stat) ->
      %Match.Statistic{user: user, wins: wins, flips: flips} = stat
      %{user => %{wins: wins, flips: flips}}
    end)
  end

  def insert_statistics(scores, winner, statistics) do
    stats = parse(scores, winner)
    previous = get_persisted_stats(scores, statistics)
    results = merge_stats(previous, stats)
    map = insert(results)
    net_new = pull_out_any_net_new_stats(map, statistics)
    new_state = merge_any_existing_stats(map, statistics)
    new_state ++ net_new
  end

  def insert(results) do
    for {user, map} <- results do
      attrs = map |> Map.put(:user, user)
      Statistics.upsert_by(user, attrs)
      %{user => map}
    end
  end

  def parse(scores, winner) do
    Enum.map(scores, &transform_score(&1, winner))
  end

  def get_persisted_stats(scores, statistics) do
    Enum.map(scores, &pull_scores_from_previous(&1, statistics))
      |> Enum.filter(fn(s) -> !Enum.empty?(s) end)
  end

  def merge_stats(previous, stats) do
    statistics = previous ++ stats
    Enum.reduce(statistics, &sum_statistics(&1, &2))
  end

  def pull_out_any_net_new_stats(map, statistics) do
    Enum.filter(map, fn(s) ->
      [{k, _}] = Map.to_list(s)
      !Enum.find(statistics, nil, fn(m) ->
        [{user, _}] = Map.to_list(m)
        k == user
      end)
    end)
  end

  def merge_any_existing_stats(map, statistics) do
    Enum.map(statistics, fn(stat) ->
      [{k, _}] = Map.to_list(stat)
      case Enum.find(map, nil, fn(m) ->
        [{user, _}] = Map.to_list(m)
        k == user
      end) do
        nil -> stat
        s ->
          Map.put(stat, k, s[k])
      end
    end)
  end

  defp sum_statistics(stat, next) do
    Map.merge(stat, next, fn _key, map1, map2 ->
      for {k, v1} <- map1, into: %{}, do: {k, v1 + map2[k]}
    end)
  end

  defp pull_scores_from_previous(score, statistics) do
    {user, _flips} = score
    case Enum.find(statistics, nil, fn(map) ->
      [{k, _}] = Map.to_list(map)
      k == user
    end) do
      nil -> %{}
      stat -> stat
    end
  end

  defp transform_score(score, winner) do
    {user, flips} = score
    case user == winner do
      true ->
        %{user => %{wins: 1, flips: flips}}
      false ->
        %{user => %{wins: 0, flips: flips}}
    end
  end
end
