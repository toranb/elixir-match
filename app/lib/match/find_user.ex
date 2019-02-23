defmodule Match.FindUser do
  alias Match.Password

  def with_username_and_password(users, username, password) do
    case Enum.filter(users, fn {_, {k, _, _}} -> k == username end) do
      [{id, {_username, _icon, hash}}] ->
        if Password.verify(password, hash) do
          id
        end
      [] ->
        Password.dummy_verify()
        nil
    end
  end

end
