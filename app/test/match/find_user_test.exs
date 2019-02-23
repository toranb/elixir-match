defmodule Match.FindUserTest do
  use ExUnit.Case, async: true

  alias Match.Password
  alias Match.FindUser

  @user_one "A4E3400CF711E76BBD86C57CA"
  @user_two "EBDA4E3FDECD8F2759D96250A"

  test "find with username and password" do
    state = %{}
    icon = "one"
    username = "toranb"
    password = "abc123"
    password_hash = Password.hash(password)

    assert FindUser.with_username_and_password(state, username, password) === nil

    new_state = Map.put(state, @user_one, {username, icon, password_hash})
    assert FindUser.with_username_and_password(new_state, username, password) === @user_one
    assert FindUser.with_username_and_password(new_state, username, "abc12") === nil

    icon_two = "two"
    username_two = "jarrod"
    password_two = "def456"
    password_hash_two = Password.hash(password_two)
    last_state = Map.put(new_state, @user_two, {username_two, icon_two, password_hash_two})
    assert FindUser.with_username_and_password(last_state, username, password) === @user_one
    assert FindUser.with_username_and_password(last_state, username_two, password_two) === @user_two
    assert FindUser.with_username_and_password(last_state, username_two, "") === nil
    assert FindUser.with_username_and_password(last_state, username, password_two) === nil
  end
end
