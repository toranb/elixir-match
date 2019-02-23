defmodule Match.Generator do

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
