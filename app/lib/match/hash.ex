defmodule Match.Hash do
  def hmac(key, value, length \\ 25) do
    :crypto.hmac(:sha256, key, value)
      |> Base.encode16
      |> String.slice(0, length)
  end
end
