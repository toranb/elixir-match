defmodule Match.Users do
  import Ecto.Query, warn: false

  alias Match.Repo
  alias Match.User

  def all do
    Repo.all(User)
  end

  def insert(changeset) do
    Repo.insert(changeset)
  end
end
