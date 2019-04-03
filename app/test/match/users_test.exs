defmodule Match.UsersTest do
  use Match.DataCase, async: true

  alias Match.Repo
  alias Match.User

  @id "A4E3400CF711E76BBD86C57CA"
  @valid_attrs %{id: @id, username: "toran", password: "abcd1234", invite: "elixir2019", icon: "one"}

  test "changeset is invalid if invite is wrong" do
    attrs = @valid_attrs |> Map.put(:invite, "foo")
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?
    assert Map.get(changeset, :errors) == [invite: {"invalid invite code", []}]
  end

  test "changeset is fine with correct invite code" do
    attrs = @valid_attrs |> Map.put(:invite, "elixir2019")
    changeset = User.changeset(%User{}, attrs)
    assert changeset.valid?
    assert Map.get(changeset, :errors) == []
  end

  test "changeset is invalid if username is too short" do
    attrs = @valid_attrs |> Map.put(:username, "abc")
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?
    assert Map.get(changeset, :errors) == [username: {"username must be 4-12 characters", [count: 4, validation: :length, kind: :min, type: :string]}]
  end

  test "changeset is invalid if username is too long" do
    attrs = @valid_attrs |> Map.put(:username, "abcdefghijklm")
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?
    assert Map.get(changeset, :errors) == [username: {"username must be 4-12 characters", [count: 12, validation: :length, kind: :max, type: :string]}]
  end

  test "changeset is fine with 4 char username" do
    attrs = @valid_attrs |> Map.put(:username, "abcd")
    changeset = User.changeset(%User{}, attrs)
    assert changeset.valid?
    assert Map.get(changeset, :errors) == []
  end

  test "changeset is fine with 12 char username" do
    attrs = @valid_attrs |> Map.put(:username, "abcdefghijkl")
    changeset = User.changeset(%User{}, attrs)
    assert changeset.valid?
    assert Map.get(changeset, :errors) == []
  end

  test "changeset is invalid if password is too short" do
    attrs = @valid_attrs |> Map.put(:password, "abcdefg")
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?
    assert Map.get(changeset, :errors) == [password: {"password must be 8-20 characters", [count: 8, validation: :length, kind: :min, type: :string]}]
  end

  test "changeset is invalid if password is too long" do
    attrs = @valid_attrs |> Map.put(:password, "abcdefghijklmnopqrstu")
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?
    assert Map.get(changeset, :errors) == [password: {"password must be 8-20 characters", [count: 20, validation: :length, kind: :max, type: :string]}]
  end

  test "changeset is fine with 20 char password" do
    attrs = @valid_attrs |> Map.put(:password, "abcdefghijklmnopqrst")
    changeset = User.changeset(%User{}, attrs)
    assert changeset.valid?
    assert Map.get(changeset, :errors) == []
  end

  test "changeset is fine with 8 char password" do
    attrs = @valid_attrs |> Map.put(:password, "abcdefgh")
    changeset = User.changeset(%User{}, attrs)
    assert changeset.valid?
    assert Map.get(changeset, :errors) == []
  end

  test "changeset is invalid if username is used already" do
    %User{}
      |> User.changeset(@valid_attrs)
      |> Repo.insert

    duplicate =
      %User{}
      |> User.changeset(@valid_attrs)
    assert {:error, changeset} = Repo.insert(duplicate)
    assert Map.get(changeset, :errors) == [id: {"username already exists", [constraint: :unique, constraint_name: "users_pkey"]}]
  end
end
