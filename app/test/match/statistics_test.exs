defmodule Match.StatisticsTest do
  use Match.DataCase, async: true

  alias Match.Repo
  alias Match.Statistic
  alias Match.Statistics

  @user_one "A4E3400CF711E76BBD86C57CA"
  @user_two "EBDA4E3FDECD8F2759D96250A"
  @user_three "D3DFFDC4AFE0172529ED3CFA5"

  @valid_attrs %{user: @user_one, wins: 1, flips: 9}

  test "get_by user will return Statistic or nil" do
    result = Statistics.get_by(%{user: @user_one})
    assert result == nil

    Statistic
      |> struct(@valid_attrs)
      |> Repo.insert()

    result = Statistics.get_by(%{user: @user_one})
    %Match.Statistic{user: user, wins: wins, flips: flips} = result
    assert user == @user_one
    assert wins == 1
    assert flips == 9
  end

  test "all will return Statistics" do
    results = Statistics.all()
    assert results == []

    Statistic
      |> struct(@valid_attrs)
      |> Repo.insert()

    Statistic
      |> struct(%{user: @user_two, wins: 3, flips: 1})
      |> Repo.insert()

    results = Statistics.all()
    [ one, two ] = results

    %Match.Statistic{user: user, wins: wins, flips: flips} = one
    assert user == @user_one
    assert wins == 1
    assert flips == 9

    %Match.Statistic{user: user, wins: wins, flips: flips} = two
    assert user == @user_two
    assert wins == 3
    assert flips == 1
  end

  test "upsert_by will insert when no data present" do
    {:ok, result} = Statistics.upsert_by(@user_one, @valid_attrs)
    %Match.Statistic{user: user, wins: wins, flips: flips} = result
    assert user == @user_one
    assert wins == 1
    assert flips == 9
  end

  test "upsert_by will update when data present" do
    Statistic
      |> struct(@valid_attrs)
      |> Repo.insert()

    {:ok, result} = Statistics.upsert_by(@user_one, %{user: @user_one, wins: 2, flips: 18})
    %Match.Statistic{user: user, wins: wins, flips: flips} = result
    assert user == @user_one
    assert wins == 2
    assert flips == 18
  end

  test "parse will return 2 insert friendly maps in a list" do
    winner = @user_two
    scores = %{@user_one => 1, @user_two => 2}

    results = Statistic.parse(scores, winner)
    assert Enum.count(results) == 2
    [one, two] = results

    [{user, value}] = Map.to_list(one)
    %{wins: wins, flips: flips} = value
    assert user == @user_one
    assert wins == 0
    assert flips == 1

    [{user, value}] = Map.to_list(two)
    %{wins: wins, flips: flips} = value
    assert user == @user_two
    assert wins == 1
    assert flips == 2
  end

  test "transform_previous will return map with user as key" do
    Statistic
      |> struct(@valid_attrs)
      |> Repo.insert()

    Statistic
      |> struct(%{user: @user_two, wins: 3, flips: 1})
      |> Repo.insert()

    results = Statistics.all()
    [ one, two ] = Statistic.transform_previous(results)

    [{user, value}] = Map.to_list(one)
    %{wins: wins, flips: flips} = value
    assert user == @user_one
    assert wins == 1
    assert flips == 9

    [{user, value}] = Map.to_list(two)
    %{wins: wins, flips: flips} = value
    assert user == @user_two
    assert wins == 3
    assert flips == 1
  end

  test "get_persisted_stats will return Statistic for each in the database" do
    statistics = [%{@user_one => %{wins: 1, flips: 9}}, %{@user_three => %{wins: 2, flips: 25}}]

    scores = %{@user_one => 1, @user_two => 2}
    results = Statistic.get_persisted_stats(scores, statistics)
    assert Enum.count(results) == 1
    [ one ] = results

    [{user, value}] = Map.to_list(one)
    %{wins: wins, flips: flips} = value
    assert user == @user_one
    assert wins == 1
    assert flips == 9
  end

  test "merge_stats will correctly sum previous and new stats" do
    statistics = [%{@user_one => %{wins: 1, flips: 9}}, %{@user_two => %{wins: 0, flips: 2}}]

    stat_one = %{@user_two => %{wins: 1, flips: 0}}
    stat_two = %{@user_one => %{wins: 0, flips: 3}}
    stats = [ stat_one, stat_two ]

    results = Statistic.merge_stats(statistics, stats)

    assert Enum.count(results) == 2

    one = Map.get(results, @user_one)
    %{wins: wins, flips: flips} = one
    assert wins == 1
    assert flips == 12

    two = Map.get(results, @user_two)
    %{wins: wins, flips: flips} = two
    assert wins == 1
    assert flips == 2
  end

  test "insert_statistics will merge database with new stats data and insert" do
    Statistic
      |> struct(@valid_attrs)
      |> Repo.insert()

    data = Statistics.all()
    statistics = Statistic.transform_previous(data)
    winner = @user_two
    scores = %{@user_one => 1, @user_two => 2}
    results = Statistic.insert_statistics(scores, winner, statistics)

    assert Enum.count(results) == 2
    assert results == [
      %{@user_one => %{flips: 10, wins: 1}},
      %{@user_two => %{flips: 2, wins: 1}}
    ]

    inserted_one = Statistics.get_by(%{user: @user_one})
    %Match.Statistic{user: user, wins: wins, flips: flips} = inserted_one
    assert user == @user_one
    assert wins == 1
    assert flips == 10

    inserted_two = Statistics.get_by(%{user: @user_two})
    %Match.Statistic{user: user, wins: wins, flips: flips} = inserted_two
    assert user == @user_two
    assert wins == 1
    assert flips == 2
  end

  test "insert_statistics will properly calc wins and flips for both users" do
    Statistic
      |> struct(%{user: @user_one, wins: 1, flips: 10})
      |> Repo.insert()
    Statistic
      |> struct(%{user: @user_two, wins: 1, flips: 2})
      |> Repo.insert()

    data = Statistics.all()
    statistics = Statistic.transform_previous(data)
    winner = @user_one
    scores = %{@user_one => 2, @user_two => 1}
    results = Statistic.insert_statistics(scores, winner, statistics)

    assert Enum.count(results) == 2
    assert results == [
      %{@user_one => %{flips: 12, wins: 2}},
      %{@user_two => %{flips: 3, wins: 1}}
    ]

    inserted_one = Statistics.get_by(%{user: @user_one})
    %Match.Statistic{user: user, wins: wins, flips: flips} = inserted_one
    assert user == @user_one
    assert wins == 2
    assert flips == 12

    inserted_two = Statistics.get_by(%{user: @user_two})
    %Match.Statistic{user: user, wins: wins, flips: flips} = inserted_two
    assert user == @user_two
    assert wins == 1
    assert flips == 3
  end

  test "insert_statistics will continue to include previous stats even if user has 0 new flips" do
    Statistic
      |> struct(%{user: @user_one, wins: 2, flips: 12})
      |> Repo.insert()
    Statistic
      |> struct(%{user: @user_two, wins: 1, flips: 3})
      |> Repo.insert()

    data = Statistics.all()
    statistics = Statistic.transform_previous(data)
    winner = @user_one
    scores = %{@user_one => 3}
    results = Statistic.insert_statistics(scores, winner, statistics)

    assert Enum.count(results) == 2
    assert results == [
      %{@user_one => %{flips: 15, wins: 3}},
      %{@user_two => %{flips: 3, wins: 1}}
    ]

    inserted_one = Statistics.get_by(%{user: @user_one})
    %Match.Statistic{user: user, wins: wins, flips: flips} = inserted_one
    assert user == @user_one
    assert wins == 3
    assert flips == 15

    inserted_two = Statistics.get_by(%{user: @user_two})
    %Match.Statistic{user: user, wins: wins, flips: flips} = inserted_two
    assert user == @user_two
    assert wins == 1
    assert flips == 3
  end

  test "insert_statistics will not calc wins 0 during merge for existing stats that do not win" do
    Statistic
      |> struct(%{user: @user_one, wins: 3, flips: 15})
      |> Repo.insert()
    Statistic
      |> struct(%{user: @user_two, wins: 1, flips: 3})
      |> Repo.insert()

    data = Statistics.all()
    statistics = Statistic.transform_previous(data)
    winner = @user_one
    scores = %{@user_one => 2, @user_two => 1}
    results = Statistic.insert_statistics(scores, winner, statistics)

    assert Enum.count(results) == 2
    assert results == [
      %{@user_one => %{flips: 17, wins: 4}},
      %{@user_two => %{flips: 4, wins: 1}}
    ]

    inserted_one = Statistics.get_by(%{user: @user_one})
    %Match.Statistic{user: user, wins: wins, flips: flips} = inserted_one
    assert user == @user_one
    assert wins == 4
    assert flips == 17

    inserted_two = Statistics.get_by(%{user: @user_two})
    %Match.Statistic{user: user, wins: wins, flips: flips} = inserted_two
    assert user == @user_two
    assert wins == 1
    assert flips == 4
  end

end
