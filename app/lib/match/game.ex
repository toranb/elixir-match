defmodule Match.Game do
  defstruct cards: [], winner: nil, animating: false, active_player_id: nil, players: [], scores: %{}

  import Match.Random, only: [take_random: 2]
  import Match.Hash, only: [hmac: 3]

  def new(size) do
    cards = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen"]
      |> take_random(size)
      |> generate_cards()
    %Match.Game{cards: cards}
  end

  def prepare_restart(old_game) do
    %Match.Game{winner: winner, cards: cards} = old_game
    case winner != nil do
      true ->
        unpaired =
          cards
          |> Enum.map(fn(card) -> %Match.Card{card | paired: false} end)
        %{ old_game | cards: unpaired}
      false -> old_game
    end
  end

  def restart(old_game) do
    %Match.Game{players: players, active_player_id: active_player_id, cards: cards} = old_game
    size = div(Enum.count(cards), 2)
    game = new(size)
    %{ game | active_player_id: active_player_id, players: players}
  end

  def unflip(game) do
    %Match.Game{cards: cards, players: players, active_player_id: active_player_id} = game
    exclude_active_player = Enum.filter(players, fn(p) -> p !== active_player_id end)
    next_player =
      case Enum.count(exclude_active_player) == 0 do
        true ->
          active_player_id
        false ->
          [ next_player ] = Enum.take(exclude_active_player, 1)
          next_player
      end
    new_players = exclude_active_player ++ [ active_player_id ]
    new_cards =
      cards
      |> Enum.map(fn(card) -> %Match.Card{card | flipped: false} end)
    %{ game | cards: new_cards, animating: false, active_player_id: next_player, players: new_players}
  end

  def join(game, player_id) do
    %Match.Game{players: players} = game
    case Enum.count(players) == 2 do
      true ->
        {:error, "join failed: game was full"}
      false ->
        new_game = join_game(game, player_id)
        {:ok, new_game}
    end
  end

  def leave(game, player_id) do
    %Match.Game{players: players, active_player_id: active_player_id} = game
    new_players = Enum.filter(players, fn(p) -> p !== player_id end)
    active =
      case active_player_id == player_id do
        true ->
          case Enum.take(new_players, 1) do
            [ next_player ] -> next_player
            [] -> nil
          end
        false ->
          active_player_id
      end
    %{ game | players: new_players, active_player_id: active}
  end

  def flip(game, id, player_id) do
    %Match.Game{cards: cards, winner: winner, animating: animating, active_player_id: active_player_id} = game
    cond do
      animating == true or winner == true ->
        game
      player_id != active_player_id ->
        game
      true ->
        cards
        |> Enum.map(&flip_card(&1, id))
        |> attempt_match(game)
        |> calculate_scores()
        |> declare_winner()
    end
  end

  defp attempt_match(cards, game) do
    flipped_cards = Enum.filter(cards, fn (card) -> card.flipped end)
    case Enum.count(flipped_cards) == 2 do
      true ->
        [
          %Match.Card{:name => first},
          %Match.Card{:name => last},
        ] = flipped_cards
        case first === last do
          true -> %{game | cards: Enum.map(cards, &pair_card(&1))}
          false -> %{game | cards: cards, animating: true}
        end
      false -> %{game | cards: cards}
    end
  end

  defp calculate_scores(game) do
    %Match.Game{cards: cards, scores: scores, active_player_id: active_player_id} = game
    new_scores =
      case Enum.count(cards, fn(card) -> card.score == true end) > 0 do
        true ->
          score = Map.get(scores, active_player_id, 0) + 1
          Map.put(scores, active_player_id, score)
        false -> scores
      end
    %{game | scores: new_scores, cards: Enum.map(cards, fn(card) -> %Match.Card{card | score: false} end)}
  end

  defp declare_winner(game) do
    %Match.Game{cards: cards, scores: scores} = game
    total = Enum.count(cards)
    paired = Enum.count(cards, fn(card) -> card.paired == true end)
    case total == paired do
      true ->
        {player_id, _} = Enum.max_by(scores, fn({_,v}) -> v end)
        %{game | winner: player_id}
      false ->
        %{game | winner: nil}
    end
  end

  defp pair_card(card) do
    case card.flipped == true do
      true -> %Match.Card{card | paired: true, flipped: false, score: true}
      false -> card
    end
  end

  defp flip_card(card, id) do
    case card.id == id do
      true -> %Match.Card{card | flipped: true}
      false -> card
    end
  end

  defp join_game(game, player_id) do
    %Match.Game{players: players, active_player_id: active_player_id} = game
    active =
      case active_player_id == nil do
        true ->
          player_id
        false ->
          active_player_id
      end
    new_players =
      case player_id in players do
        true -> players
        false -> [player_id | players]
      end
    %{ game | players: new_players, active_player_id: active}

  end

  defp generate_cards(cards) do
    length = 6
    total = Enum.count(cards)
    Enum.map(cards, fn (name) ->
      hash = hmac("type:card", name, length)
      one = %Match.Card{id: "#{hash}1", name: name, image: "/images/cards/#{name}.png" }
      two = %Match.Card{id: "#{hash}2", name: name, image: "/images/cards/#{name}.png" }
      [one, two]
    end)
    |> List.flatten()
    |> take_random(total * 2)
  end
end
