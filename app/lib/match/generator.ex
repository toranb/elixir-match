defmodule Match.Generator do

  def haiku do
    [
      Enum.random(foods()),
      :rand.uniform(9999)
    ]
    |> Enum.join("-")
  end

  defp foods do
    ~w(
      apple banana orange
      grape kiwi mango
      pear pineapple strawberry
      tomato watermelon cantaloupe
    )
  end

  def icon do
    Enum.random(numbers())
  end

  defp numbers do
    ~w(
      one two three
      four five six
      seven eight nine
      ten eleven twelve
      thirteen fourteen
    )
  end
end
