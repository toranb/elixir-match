defmodule Match.Logon do
  use GenServer

  alias Match.Hash
  alias Match.User
  alias Match.Users
  alias Match.FindUser
  alias Match.Password
  alias Match.Generator

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: via(:logon))
  end

  defp via(name), do: Match.Registry.via(name)

  @impl GenServer
  def init(:ok) do
    state = for %User{id: id, username: username, icon: icon, hash: hash} <- Users.all(), into: %{}, do: {id, {username, icon, hash}}
    {:ok, state, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, state) do
    {:noreply, state}
  end

  def get(name, id) do
    GenServer.call(via(name), {:get, id})
  end

  def get_by_username_and_password(name, username, password) do
    GenServer.call(via(name), {:get, username, password})
  end

  def put(name, username, password, invite) do
    GenServer.call(via(name), {:put, username, password, invite})
  end

  @impl GenServer
  def handle_call({:get, id}, _timeout, state) do
    {username, icon, _} = Map.get(state, id)
    {:reply, {username, icon}, state}
  end

  @impl GenServer
  def handle_call({:get, username, password}, _timeout, state) do
    id = FindUser.with_username_and_password(state, username, password)
    {:reply, id, state}
  end

  @impl GenServer
  def handle_call({:put, username, password, invite}, _timeout, state) do
    icon = Generator.icon()
    hash = Password.hash(password)
    id = Hash.hmac("type:user", username)
    changeset = User.changeset(%User{}, %{id: id, username: username, password: password, icon: icon, invite: invite, hash: hash})
    case Users.insert(changeset) do
      {:ok, _result} ->
        new_state = Map.put(state, id, {username, icon, hash})
        {:reply, {:ok, {id, username, icon}}, new_state}
      {:error, changeset} ->
        {_key, {message, _}} = Enum.find(changeset.errors, fn(i) -> i end)
        {:reply, {:error, {id, message}}, state}
    end
  end
end
