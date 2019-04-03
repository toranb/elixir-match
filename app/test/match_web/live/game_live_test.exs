defmodule MatchWeb.GameLiveTest do
  use MatchWeb.ConnCase, async: false

  alias MatchWeb.Endpoint
  alias MatchWeb.GameLive
  alias Match.Generator
  alias Phoenix.LiveViewTest

  @size 2
  @one "/images/cards/one.png"
  @two "/images/cards/two.png"
  @id_one_a "24CEDF1"
  @id_one_b "24CEDF2"
  @id_two_a "3079821"
  @id_two_b "3079822"
  @toran "toran"
  @brandon "brandon"
  @user_one %{id: "A4E3400CF711E76BBD86C57CA", username: @toran, icon: "one"}
  @user_two %{id: "30B39549ACC60EAC0F81CA755", username: @brandon, icon: "two"}

  setup do
    patch_random()
    patch_process()
    patch_repo()

    game_name = Generator.haiku()
    {:ok, pid} = Match.GameSupervisor.start_game(game_name, @user_one, :public, @size)

    on_exit fn ->
      Process.exit(pid, :kill)
      purge(Match.Repo)
      purge(Match.Game)
      purge(Match.Process)
    end

    %{game_name: game_name}
  end

  test "each card will be rendered with correct click handler, value and background image", %{game_name: game_name} do
    {:ok, _} = Match.Session.join(game_name, @user_one.id)
    {:ok, _view, html_one} = LiveViewTest.mount(Endpoint, GameLive, session: session(@user_one, game_name))

    cards = Floki.find(html_one, ".card")
    assert Enum.count(cards) == 4

    assert ["card", "card", "card", "card"] == card_classes(cards)
    assert [@id_one_a, @id_one_b, @id_two_a, @id_two_b] == click_values(cards)
    assert ["flip", "flip", "flip", "flip"] == click_handlers(cards)
    assert ["background-image: url(#{@one})", "background-image: url(#{@one})", "background-image: url(#{@two})", "background-image: url(#{@two})"] == child_styles(cards)
  end

  test "flipping 2 incorrect matches will unflip after a brief pause in both clients", %{game_name: game_name} do
    {:ok, _} = Match.Session.join(game_name, @user_one.id)
    {:ok, view_one, html_one} = LiveViewTest.mount(Endpoint, GameLive, session: session(@user_one, game_name))

    {:ok, _} = Match.Session.join(game_name, @user_two.id)
    {:ok, view_two, html_two} = LiveViewTest.mount(Endpoint, GameLive, session: session(@user_two, game_name))

    click_thru_joined_modal(view_one, view_two)

    cards = Floki.find(html_one, ".card")
    assert ["card", "card", "card", "card"] == card_classes(cards)

    cards = Floki.find(html_two, ".card")
    assert ["card", "card", "card", "card"] == card_classes(cards)

    html_one = LiveViewTest.render_click(view_one, :flip, @id_two_a)
    cards = Floki.find(html_one, ".card")
    assert ["card", "card", "card flipped", "card"] == card_classes(cards)

    html_two = LiveViewTest.render(view_two)
    cards = Floki.find(html_two, ".card")
    assert ["card", "card", "card flipped", "card"] == card_classes(cards)

    html_one = LiveViewTest.render_click(view_one, :flip, @id_one_b)
    cards = Floki.find(html_one, ".card")
    assert ["card", "card flipped", "card flipped", "card"] == card_classes(cards)

    html_two = LiveViewTest.render(view_two)
    cards = Floki.find(html_two, ".card")
    assert ["card", "card flipped", "card flipped", "card"] == card_classes(cards)

    Process.sleep(20)

    html_one = LiveViewTest.render(view_one)
    cards = Floki.find(html_one, ".card")
    assert ["card", "card", "card", "card"] == card_classes(cards)

    html_two = LiveViewTest.render(view_two)
    cards = Floki.find(html_two, ".card")
    assert ["card", "card", "card", "card"] == card_classes(cards)
  end

  test "flipping 2 correct matches will mark a pair in both clients", %{game_name: game_name} do
    {:ok, _} = Match.Session.join(game_name, @user_one.id)
    {:ok, view_one, html_one} = LiveViewTest.mount(Endpoint, GameLive, session: session(@user_one, game_name))

    {:ok, _} = Match.Session.join(game_name, @user_two.id)
    {:ok, view_two, html_two} = LiveViewTest.mount(Endpoint, GameLive, session: session(@user_two, game_name))

    click_thru_joined_modal(view_one, view_two)

    cards = Floki.find(html_one, ".card")
    assert ["card", "card", "card", "card"] == card_classes(cards)

    cards = Floki.find(html_two, ".card")
    assert ["card", "card", "card", "card"] == card_classes(cards)

    html_one = LiveViewTest.render_click(view_one, :flip, @id_two_a)
    cards = Floki.find(html_one, ".card")
    assert ["card", "card", "card flipped", "card"] == card_classes(cards)

    html_two = LiveViewTest.render(view_two)
    cards = Floki.find(html_two, ".card")
    assert ["card", "card", "card flipped", "card"] == card_classes(cards)

    html_one = LiveViewTest.render_click(view_one, :flip, @id_two_b)
    cards = Floki.find(html_one, ".card")
    assert ["card", "card", "card found", "card found"] == card_classes(cards)

    html_two = LiveViewTest.render(view_two)
    cards = Floki.find(html_two, ".card")
    assert ["card", "card", "card found", "card found"] == card_classes(cards)
  end

  test "players rotate between turns in both clients and winner shown in modal", %{game_name: game_name} do
    {:ok, _} = Match.Session.join(game_name, @user_one.id)
    {:ok, view_one, html_one} = LiveViewTest.mount(Endpoint, GameLive, session: session(@user_one, game_name))

    {:ok, _} = Match.Session.join(game_name, @user_two.id)
    {:ok, view_two, html_two} = LiveViewTest.mount(Endpoint, GameLive, session: session(@user_two, game_name))

    click_thru_joined_modal(view_one, view_two)

    {player, score} = active_player_score(html_one)
    assert player == @toran
    assert score == "0"

    {player, score} = active_player_score(html_two)
    assert player == @toran
    assert score == "0"

    LiveViewTest.render_click(view_one, :flip, @id_two_a)
    LiveViewTest.render_click(view_one, :flip, @id_one_b)

    Process.sleep(20)

    html_one = LiveViewTest.render(view_one)
    {player, score} = active_player_score(html_one)
    assert player == @brandon
    assert score == "0"

    html_two = LiveViewTest.render(view_two)
    {player, score} = active_player_score(html_two)
    assert player == @brandon
    assert score == "0"

    LiveViewTest.render_click(view_two, :flip, @id_one_a)
    LiveViewTest.render_click(view_two, :flip, @id_one_b)

    html_two = LiveViewTest.render(view_two)
    {player, score} = active_player_score(html_two)
    assert player == @brandon
    assert score == "1"

    html_one = LiveViewTest.render(view_one)
    {player, score} = active_player_score(html_one)
    assert player == @brandon
    assert score == "1"

    LiveViewTest.render_click(view_two, :flip, @id_two_a)
    LiveViewTest.render_click(view_two, :flip, @id_two_b)

    html_two = LiveViewTest.render(view_two)
    {player, score} = active_player_score(html_two)
    assert player == @brandon
    assert score == "2"

    html_one = LiveViewTest.render(view_one)
    {player, score} = active_player_score(html_one)
    assert player == @brandon
    assert score == "2"

    assert Enum.count(modal(html_one)) == 1
    assert Enum.count(modal(html_two)) == 1
    assert winner(html_one) == "#{@brandon} won!"
    assert winner(html_two) == "#{@brandon} won!"

    LiveViewTest.render_click(view_two, :prepare_restart, "")
    Process.sleep(2)

    html_one = LiveViewTest.render(view_one)
    assert Enum.count(modal(html_one)) == 0
    html_two = LiveViewTest.render(view_two)
    assert Enum.count(modal(html_two)) == 0

    cards = Floki.find(html_one, ".card")
    assert ["card", "card", "card", "card"] == card_classes(cards)
    cards = Floki.find(html_two, ".card")
    assert ["card", "card", "card", "card"] == card_classes(cards)

    {player, score} = active_player_score(html_one)
    assert player == @brandon
    assert score == "0"

    {player, score} = active_player_score(html_two)
    assert player == @brandon
    assert score == "0"
  end

  test "error modal shows up when backing session killed", %{game_name: game_name} do
    {:ok, _} = Match.Session.join(game_name, @user_one.id)
    {:ok, view_one, _html_one} = LiveViewTest.mount(Endpoint, GameLive, session: session(@user_one, game_name))

    {:ok, _} = Match.Session.join(game_name, @user_two.id)
    {:ok, view_two, _html_two} = LiveViewTest.mount(Endpoint, GameLive, session: session(@user_two, game_name))

    click_thru_joined_modal(view_one, view_two)

    pid = Match.Session.session_pid(game_name)
    Process.exit(pid, :shutdown)

    html_one = LiveViewTest.render(view_one)
    assert Enum.count(modal(html_one)) == 0
    html_two = LiveViewTest.render(view_two)
    assert Enum.count(modal(html_two)) == 0

    LiveViewTest.render_click(view_one, :flip, @id_two_a)

    html_one = LiveViewTest.render(view_one)
    assert Enum.count(modal(html_one)) == 1
    assert error(html_one) == "an error occurred"

    html_two = LiveViewTest.render(view_two)
    assert Enum.count(modal(html_two)) == 0
  end

  defp modal(html) do
    Floki.find(html, ".splash")
  end

  defp winner(html) do
    Floki.find(html, ".content h1") |> Floki.text
  end

  defp joined(html) do
    Floki.find(html, ".content h1") |> Floki.text
  end

  defp error(html) do
    Floki.find(html, ".content h1") |> Floki.text
  end

  defp click_thru_joined_modal(view_one, view_two) do
    html_one = LiveViewTest.render(view_one)
    html_two = LiveViewTest.render(view_two)

    assert Enum.count(modal(html_one)) == 1
    assert Enum.count(modal(html_two)) == 0

    assert joined(html_one) == "brandon joined!"

    LiveViewTest.render_click(view_one, :continue, "")

    html_one = LiveViewTest.render(view_one)
    html_two = LiveViewTest.render(view_two)

    assert Enum.count(modal(html_one)) == 0
    assert Enum.count(modal(html_two)) == 0
  end

  defp card_classes(cards) do
    cards
      |> Floki.attribute("class")
      |> Enum.map(&(String.trim(&1)))
  end

  defp click_handlers(cards) do
    cards
      |> Floki.attribute("phx-click")
  end

  defp click_values(cards) do
    cards
      |> Floki.attribute("phx-value")
  end

  defp child_styles(cards) do
    cards
      |> Enum.map(fn({_tag, _attr, child}) ->
        [_, front] = child
        [attribute] = Floki.attribute(front, "style")
        attribute
      end)
  end

  defp active_player_score(html) do
    player = Floki.find(html, ".active-player") |> Floki.text
    score = Floki.find(html, ".active-player-score") |> Floki.text
    {player, score}
  end

  defp session(current_user, game_name) do
    %{:id => id, :username => username} = current_user
    %{
      game_name: game_name,
      player_id: id,
      username: username,
      joined_id: nil,
      error: nil
    }
  end

  defp patch_random do
    Code.eval_string """
      defmodule Match.Random do
        def take_random(cards, number) do
          Enum.take(cards, number)
        end
      end
    """
  end

  defp patch_process do
    Code.eval_string """
      defmodule Match.Process do
        def sleep(t) do
          Process.sleep(t)
        end
      end
    """
  end

  defp patch_repo do
    Code.eval_string """
      defmodule Match.Repo do
        def all(_), do: nil
        def get_by(_, _), do: nil
        def get_by(_, _, _), do: nil
        def insert_or_update(_), do: nil
      end
    """
  end

  defp purge(module) do
    :code.purge(module)
    :code.delete(module)
  end
end
