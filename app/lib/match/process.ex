defmodule Match.Process do

  def sleep(t) do
    Process.sleep(t * 100)
  end

end
