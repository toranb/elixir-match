defmodule Match.GameTest do
  use ExUnit.Case, async: true

  test "new returns game struct with list of cards in random order" do
    state = Match.Game.new(2)

    %Match.Game{cards: cards, winner: winner, active_player_id: active_player_id, players: players} = state

    possible = [
      %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false},
      %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false},
      %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      %Match.Card{:id => "3F9A231", :name => "three", :image => "/images/cards/three.png", :flipped => false},
      %Match.Card{:id => "3F9A232", :name => "three", :image => "/images/cards/three.png", :flipped => false},
      %Match.Card{:id => "3F9AC51", :name => "four", :image => "/images/cards/four.png", :flipped => false},
      %Match.Card{:id => "3F9AC52", :name => "four", :image => "/images/cards/four.png", :flipped => false},
      %Match.Card{:id => "DA320E1", :name => "five", :image => "/images/cards/five.png", :flipped => false},
      %Match.Card{:id => "DA320E2", :name => "five", :image => "/images/cards/five.png", :flipped => false},
      %Match.Card{:id => "145AEF1", :name => "six", :image => "/images/cards/six.png", :flipped => false},
      %Match.Card{:id => "145AEF2", :name => "six", :image => "/images/cards/six.png", :flipped => false},
      %Match.Card{:id => "8808BC1", :name => "seven", :image => "/images/cards/seven.png", :flipped => false},
      %Match.Card{:id => "8808BC2", :name => "seven", :image => "/images/cards/seven.png", :flipped => false},
      %Match.Card{:id => "7720B41", :name => "eight", :image => "/images/cards/eight.png", :flipped => false},
      %Match.Card{:id => "7720B42", :name => "eight", :image => "/images/cards/eight.png", :flipped => false},
      %Match.Card{:id => "0073F91", :name => "nine", :image => "/images/cards/nine.png", :flipped => false},
      %Match.Card{:id => "0073F92", :name => "nine", :image => "/images/cards/nine.png", :flipped => false},
      %Match.Card{:id => "E6AAE31", :name => "ten", :image => "/images/cards/ten.png", :flipped => false},
      %Match.Card{:id => "E6AAE32", :name => "ten", :image => "/images/cards/ten.png", :flipped => false},
      %Match.Card{:id => "85C9871", :name => "eleven", :image => "/images/cards/eleven.png", :flipped => false},
      %Match.Card{:id => "85C9872", :name => "eleven", :image => "/images/cards/eleven.png", :flipped => false},
      %Match.Card{:id => "32252B1", :name => "twelve", :image => "/images/cards/twelve.png", :flipped => false},
      %Match.Card{:id => "32252B2", :name => "twelve", :image => "/images/cards/twelve.png", :flipped => false},
      %Match.Card{:id => "B9B1C01", :name => "thirteen", :image => "/images/cards/thirteen.png", :flipped => false},
      %Match.Card{:id => "B9B1C02", :name => "thirteen", :image => "/images/cards/thirteen.png", :flipped => false},
      %Match.Card{:id => "C4D0AD1", :name => "fourteen", :image => "/images/cards/fourteen.png", :flipped => false},
      %Match.Card{:id => "C4D0AD2", :name => "fourteen", :image => "/images/cards/fourteen.png", :flipped => false},
      %Match.Card{:id => "8F7E371", :name => "fifteen", :image => "/images/cards/fifteen.png", :flipped => false},
      %Match.Card{:id => "8F7E372", :name => "fifteen", :image => "/images/cards/fifteen.png", :flipped => false},
    ]

    [
      %Match.Card{id: id_one, name: name_one, image: image_one, flipped: flipped_one},
      %Match.Card{id: id_two, name: name_two, image: image_two, flipped: flipped_two},
      %Match.Card{id: id_three, name: name_three, image: image_three, flipped: flipped_three},
      %Match.Card{id: id_four, name: name_four, image: image_four, flipped: flipped_four}
    ] = cards

    assert Enum.count(cards) == 4

    %Match.Card{:name => name, :image => image, :flipped => flipped} = Enum.find(possible, fn(card) -> card.id === id_one end)
    assert name == name_one
    assert image == image_one
    assert flipped == flipped_one

    %Match.Card{:name => name, :image => image, :flipped => flipped} = Enum.find(possible, fn(card) -> card.id === id_two end)
    assert name == name_two
    assert image == image_two
    assert flipped == flipped_two

    %Match.Card{:name => name, :image => image, :flipped => flipped} = Enum.find(possible, fn(card) -> card.id === id_three end)
    assert name == name_three
    assert image == image_three
    assert flipped == flipped_three

    %Match.Card{:name => name, :image => image, :flipped => flipped} = Enum.find(possible, fn(card) -> card.id === id_four end)
    assert name == name_four
    assert image == image_four
    assert flipped == flipped_four

    assert winner == nil
    assert active_player_id == nil
    assert players == []

    another_state = Match.Game.new(2)
    %Match.Game{cards: another_cards} = another_state
    assert cards != another_cards
  end

  test "restart will keep active player along with players and unpair all cards" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true, :paired => false},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false, :paired => false},
        %Match.Card{:id => "3F9A231", :name => "three", :image => "/images/cards/three.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3F9A232", :name => "three", :image => "/images/cards/three.png", :flipped => false, :paired => true},
      ],
      winner: nil,
      players: [
        "EBDA4E",
        "01D3CC"
      ],
      active_player_id: "01D3CC",
      scores: %{"EBDA4E" => 1, "01D3CC" => 1}
    }

    state = Match.Game.flip(state, "3079822", "01D3CC")

    %Match.Game{cards: cards, winner: winner, active_player_id: active_player_id, players: players, scores: scores} = state

    assert Enum.count(cards) == 6
    assert winner == "01D3CC"
    assert active_player_id == "01D3CC"
    assert players == ["EBDA4E", "01D3CC"]
    assert scores == %{"EBDA4E" => 1, "01D3CC" => 2}
    Enum.each(cards, fn (card) -> assert card.paired == true end)

    restarted = Match.Game.restart(state)

    %Match.Game{cards: cards, winner: winner, active_player_id: active_player_id, players: players, scores: scores} = restarted

    assert Enum.count(cards) == 6
    assert winner == nil
    assert active_player_id == "01D3CC"
    assert players == ["EBDA4E", "01D3CC"]
    assert scores == %{}

    Enum.each(cards, fn (card) -> assert card.paired == false end)
  end

  test "flip will mark a given card with flipped attribute" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => false},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      ],
      winner: nil,
      players: [
        "EBDA4E",
        "01D3CC"
      ],
      active_player_id: "01D3CC"
    }

    new_state = Match.Game.flip(state, "3079821", "01D3CC")

    %Match.Game{cards: cards, winner: winner, scores: scores} = new_state
    [
      %Match.Card{flipped: flip_one},
      %Match.Card{flipped: flip_two},
      %Match.Card{flipped: flip_three},
      %Match.Card{flipped: flip_four}
    ] = cards

    assert flip_one == false
    assert flip_two == true
    assert flip_three == false
    assert flip_four == false

    assert winner == nil
    assert scores == %{}
  end

  test "flipping the 2nd card in a match will mark the cards as paired and revert flipped to false" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      ],
      winner: nil,
      players: [
        "EBDA4E",
        "01D3CC"
      ],
      active_player_id: "01D3CC"
    }

    new_state = Match.Game.flip(state, "3079822", "01D3CC")

    %Match.Game{cards: cards, winner: winner, scores: scores} = new_state
    [
      %Match.Card{flipped: flip_one, paired: paired_one},
      %Match.Card{flipped: flip_two, paired: paired_two},
      %Match.Card{flipped: flip_three, paired: paired_three},
      %Match.Card{flipped: flip_four, paired: paired_four},
    ] = cards

    assert flip_one == false
    assert flip_two == false
    assert flip_three == false
    assert flip_four == false

    assert paired_one == false
    assert paired_two == true
    assert paired_three == false
    assert paired_four == true

    assert winner == nil
    assert scores == %{"01D3CC" => 1}
  end

  test "flipping the 2nd card that is NOT a match will mark the cards as flipped but not paired" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      ],
      winner: nil,
      animating: false,
      players: [
        "EBDA4E",
        "01D3CC"
      ],
      active_player_id: "01D3CC"
    }

    new_state = Match.Game.flip(state, "24CEDF1", "01D3CC")

    %Match.Game{cards: cards, winner: winner, animating: animating} = new_state
    [
      %Match.Card{flipped: flip_one, paired: paired_one},
      %Match.Card{flipped: flip_two, paired: paired_two},
      %Match.Card{flipped: flip_three, paired: paired_three},
      %Match.Card{flipped: flip_four, paired: paired_four},
    ] = cards

    assert flip_one == true
    assert flip_two == true
    assert flip_three == false
    assert flip_four == false

    assert paired_one == false
    assert paired_two == false
    assert paired_three == false
    assert paired_four == false

    assert winner == nil
    assert animating == true
  end

  test "unflip will reset animating to false and revert any flipped cards" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => true},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      ],
      winner: nil,
      animating: true,
      players: [
        "EBDA4E",
        "01D3CC"
      ],
      active_player_id: "01D3CC"
    }

    new_state = Match.Game.unflip(state)

    %Match.Game{cards: cards, winner: winner, animating: animating, active_player_id: active_player_id, players: players} = new_state
    [
      %Match.Card{flipped: flip_one, paired: paired_one},
      %Match.Card{flipped: flip_two, paired: paired_two},
      %Match.Card{flipped: flip_three, paired: paired_three},
      %Match.Card{flipped: flip_four, paired: paired_four},
    ] = cards

    [player_one, player_two] = players

    assert flip_one == false
    assert flip_two == false
    assert flip_three == false
    assert flip_four == false

    assert paired_one == false
    assert paired_two == false
    assert paired_three == false
    assert paired_four == false

    assert winner == nil
    assert animating == false
    assert active_player_id == "EBDA4E"
    assert player_one == "EBDA4E"
    assert player_two == "01D3CC"
  end

  test "flipping the last match will mark the winner as truthy and prepare restart will unflip/unpair each card" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true, :paired => false},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false, :paired => false},
      ],
      winner: nil,
      players: [
        "EBDA4E",
        "01D3CC"
      ],
      active_player_id: "01D3CC",
      scores: %{"EBDA4E" => 1, "01D3CC" => 1}
    }

    new_state = Match.Game.flip(state, "3079822", "01D3CC")

    %Match.Game{cards: cards, winner: winner, scores: scores} = new_state
    [
      %Match.Card{flipped: flip_one, paired: paired_one},
      %Match.Card{flipped: flip_two, paired: paired_two},
      %Match.Card{flipped: flip_three, paired: paired_three},
      %Match.Card{flipped: flip_four, paired: paired_four},
    ] = cards

    assert flip_one == false
    assert flip_two == false
    assert flip_three == false
    assert flip_four == false

    assert paired_one == true
    assert paired_two == true
    assert paired_three == true
    assert paired_four == true

    assert winner == "01D3CC"
    assert scores == %{"EBDA4E" => 1, "01D3CC" => 2}

    prepare_state = Match.Game.prepare_restart(new_state)

    %Match.Game{cards: cards, winner: winner, scores: scores} = prepare_state
    [
      %Match.Card{flipped: flip_one, paired: paired_one},
      %Match.Card{flipped: flip_two, paired: paired_two},
      %Match.Card{flipped: flip_three, paired: paired_three},
      %Match.Card{flipped: flip_four, paired: paired_four},
    ] = cards

    assert flip_one == false
    assert flip_two == false
    assert flip_three == false
    assert flip_four == false

    assert paired_one == false
    assert paired_two == false
    assert paired_three == false
    assert paired_four == false

    assert winner == "01D3CC"
    assert scores == %{"EBDA4E" => 1, "01D3CC" => 2}
  end

  test "prepare restart does nothing if winner is nil" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true, :paired => false},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false, :paired => false},
      ],
      winner: nil,
      players: [
        "EBDA4E",
        "01D3CC"
      ],
      active_player_id: "01D3CC",
      scores: %{"EBDA4E" => 1, "01D3CC" => 1}
    }

    new_state = Match.Game.prepare_restart(state)

    %Match.Game{cards: cards, winner: winner, scores: scores} = new_state
    [
      %Match.Card{flipped: flip_one, paired: paired_one},
      %Match.Card{flipped: flip_two, paired: paired_two},
      %Match.Card{flipped: flip_three, paired: paired_three},
      %Match.Card{flipped: flip_four, paired: paired_four},
    ] = cards

    assert flip_one == false
    assert flip_two == true
    assert flip_three == false
    assert flip_four == false

    assert paired_one == true
    assert paired_two == false
    assert paired_three == true
    assert paired_four == false

    assert winner == nil
    assert scores == %{"EBDA4E" => 1, "01D3CC" => 1}
  end

  test "flipping will append score when user id already in the scores map" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true, :paired => false},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false, :paired => false},
      ],
      winner: nil,
      players: [
        "EBDA4E",
        "01D3CC"
      ],
      active_player_id: "01D3CC",
      scores: %{"01D3CC" => 1}
    }

    new_state = Match.Game.flip(state, "3079822", "01D3CC")

    %Match.Game{winner: winner, scores: scores} = new_state

    assert winner == "01D3CC"
    assert scores == %{"01D3CC" => 2}
  end

  test "flipping when animating is marked as true flip does nothing" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => false},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true, :paired => false},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => true, :paired => false},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false, :paired => false},
      ],
      winner: nil,
      animating: true
    }

    new_state = Match.Game.flip(state, "3079822", "01D3CC")

    %Match.Game{cards: cards, winner: winner, animating: animating} = new_state
    [
      %Match.Card{flipped: flip_one, paired: paired_one},
      %Match.Card{flipped: flip_two, paired: paired_two},
      %Match.Card{flipped: flip_three, paired: paired_three},
      %Match.Card{flipped: flip_four, paired: paired_four},
    ] = cards

    assert flip_one == false
    assert flip_two == true
    assert flip_three == true
    assert flip_four == false

    assert paired_one == false
    assert paired_two == false
    assert paired_three == false
    assert paired_four == false

    assert winner == nil
    assert animating == true
  end

  test "flipping when winner is marked as true flip does nothing" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => false, :paired => true},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false, :paired => true},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false, :paired => true},
      ],
      winner: true,
      animating: false
    }

    new_state = Match.Game.flip(state, "3079822", "01D3CC")

    %Match.Game{cards: cards, winner: winner, animating: animating} = new_state
    [
      %Match.Card{flipped: flip_one, paired: paired_one},
      %Match.Card{flipped: flip_two, paired: paired_two},
      %Match.Card{flipped: flip_three, paired: paired_three},
      %Match.Card{flipped: flip_four, paired: paired_four},
    ] = cards

    assert flip_one == false
    assert flip_two == false
    assert flip_three == false
    assert flip_four == false

    assert paired_one == true
    assert paired_two == true
    assert paired_three == true
    assert paired_four == true

    assert winner == true
    assert animating == false
  end

  test "join will add player_id to players list and leave will remove player_id from players list" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => false},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      ]
    }

    {:ok, new_state} = Match.Game.join(state, "01D3CC")

    %Match.Game{active_player_id: active_player_id, players: players} = new_state
    [ player ] = players

    assert Enum.count(players) == 1
    assert active_player_id == "01D3CC"
    assert player == "01D3CC"

    leave_state = Match.Game.leave(new_state, "01D3CC")

    %Match.Game{active_player_id: active_player_id, players: players} = leave_state

    assert Enum.count(players) == 0
    assert active_player_id == nil

    {:ok, joined_again} = Match.Game.join(leave_state, "01D3CC")

    %Match.Game{active_player_id: active_player_id, players: players} = joined_again
    [ player ] = players

    assert Enum.count(players) == 1
    assert active_player_id == "01D3CC"
    assert player == "01D3CC"

    {:ok, another_join} = Match.Game.join(joined_again, "EBDA4E")

    %Match.Game{active_player_id: active_player_id, players: players} = another_join
    [ player_one, player_two ] = players

    assert Enum.count(players) == 2
    assert active_player_id == "01D3CC"
    assert player_one == "EBDA4E"
    assert player_two == "01D3CC"

    {:error, message} = Match.Game.join(another_join, "01D3CC")
    assert message == "join failed: game was full"

    {:error, message} = Match.Game.join(another_join, "EBDA4E")
    assert message == "join failed: game was full"

    leave_again_state = Match.Game.leave(another_join, "01D3CC")

    %Match.Game{active_player_id: active_player_id, players: players} = leave_again_state
    [ player ] = players

    assert Enum.count(players) == 1
    assert active_player_id == "EBDA4E"
    assert player == "EBDA4E"

    leave_duplicate = Match.Game.leave(leave_again_state, "01D3CC")

    %Match.Game{active_player_id: active_player_id, players: players} = leave_duplicate
    [ player ] = players

    assert Enum.count(players) == 1
    assert active_player_id == "EBDA4E"
    assert player == "EBDA4E"
  end

  test "flipping the 2nd card in a match will NOT mark the cards as flipped when player_id is not active" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      ],
      winner: nil,
      players: [
        "EBDA4E",
        "01D3CC"
      ],
      active_player_id: "EBDA4E"
    }

    new_state = Match.Game.flip(state, "3079822", "01D3CC")

    %Match.Game{cards: cards, winner: winner} = new_state
    [
      %Match.Card{flipped: flip_one},
      %Match.Card{flipped: flip_two},
      %Match.Card{flipped: flip_three},
      %Match.Card{flipped: flip_four},
    ] = cards

    assert flip_one == false
    assert flip_two == true
    assert flip_three == false
    assert flip_four == false

    assert winner == nil
  end

  test "unflip will not explode with only 1 active player" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => true},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      ],
      winner: nil,
      animating: true,
      players: [
        "01D3CC"
      ],
      active_player_id: "01D3CC"
    }

    new_state = Match.Game.unflip(state)
    %Match.Game{players: players, active_player_id: active_player_id} = new_state

    [player] = players

    assert player == "01D3CC"
    assert active_player_id == "01D3CC"
  end

  test "flip and unflip will rotate between players correctly" do
    state = %Match.Game{
      cards: [
        %Match.Card{:id => "24CEDF1", :name => "one", :image => "/images/cards/one.png", :flipped => true},
        %Match.Card{:id => "3079821", :name => "two", :image => "/images/cards/two.png", :flipped => true},
        %Match.Card{:id => "24CEDF2", :name => "one", :image => "/images/cards/one.png", :flipped => false},
        %Match.Card{:id => "3079822", :name => "two", :image => "/images/cards/two.png", :flipped => false},
      ],
      winner: nil,
      animating: true,
      players: [
        "01D3CC",
        "EBDA4E",
        "ADDE47"
      ],
      active_player_id: "01D3CC"
    }

    state_two = Match.Game.unflip(state)
    %Match.Game{active_player_id: active_player_id} = state_two

    assert active_player_id == "EBDA4E"

    state_three = Match.Game.flip(state_two, "3079821", "EBDA4E")
    state_four = Match.Game.flip(state_three, "24CEDF1", "EBDA4E")

    state_five = Match.Game.unflip(state_four)
    %Match.Game{active_player_id: active_player_id} = state_five

    assert active_player_id == "ADDE47"
  end
end
