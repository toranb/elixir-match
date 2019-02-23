defmodule Match.LogonTest do
  use Match.DataCase, async: false

  alias Match.Logon

  @invite "elixir2019"
  @user_one "A4E3400CF711E76BBD86C57CA"
  @user_two "EBDA4E3FDECD8F2759D96250A"

  test "get and put work" do
    {:ok, _} = GenServer.start_link(Logon, :ok)

    {:ok, result} = Logon.put(:logon, "toran", "abcd1234", @invite)
    {id, username, _icon} = result
    assert id == @user_one
    assert username == "toran"

    {username, _icon} = Logon.get(:logon, @user_one)
    assert username === "toran"
    assert Logon.get_by_username_and_password(:logon, "toran", "abcd1234") === @user_one
    assert Logon.get_by_username_and_password(:logon, "joel", "defg4567") === nil

    {:ok, result} = Logon.put(:logon, "joel", "defg4567", @invite)
    {id, username, _icon} = result
    assert id == @user_two
    assert username == "joel"

    {username, _icon} = Logon.get(:logon, @user_one)
    assert username === "toran"
    {username, _icon} = Logon.get(:logon, @user_two)
    assert username === "joel"

    assert Logon.get_by_username_and_password(:logon, "toran", "abcd1234") === @user_one
    assert Logon.get_by_username_and_password(:logon, "joel", "defg4567") === @user_two
    assert Logon.get_by_username_and_password(:logon, "joel", "def4577") === nil
  end
end
