defmodule Match.HashTest do
  use ExUnit.Case, async: true

  alias Match.Hash

  @user_one "A4E3400CF711E76BBD86C57CA"
  @user_two "EBDA4E3FDECD8F2759D96250A"

  test "hmac will generate the same value for key consistently" do
    one = Hash.hmac("type:user", "toran")
    assert one == @user_one

    two = Hash.hmac("type:user", "toran")
    assert two == @user_one

    unknown = Hash.hmac("type:unknown", "toran")
    assert unknown != @user_one

    joel = Hash.hmac("type:user", "joel")
    assert joel == @user_two
  end

  test "hmac will generate hash with specified length" do
    bird = Hash.hmac("type:card", "bird", 6)
    assert bird == "6F0108"
    bird_again = Hash.hmac("type:card", "bird", 6)
    assert bird_again == "6F0108"
  end
end
