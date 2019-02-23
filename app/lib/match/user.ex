defmodule Match.User do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :string, []}
  schema "users" do
    field :username, :string
    field :hash, :string
    field :icon, :string
    field :invite, :string, virtual: true
    field :password, :string, virtual: true

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
      |> cast(params, [:id, :username, :password, :icon, :invite, :hash])
      |> validate_required([:username, :password])
      |> unique_constraint(:id, name: :users_pkey, message: "username already exists")
      |> validate_length(:username, min: 4, max: 12, message: "username must be 4-12 characters")
      |> validate_length(:password, min: 8, max: 20, message: "password must be 8-20 characters")
      |> validate_invite
  end

  defp validate_invite(%Ecto.Changeset{} = changeset) do
    value = Map.get(changeset.changes, :invite)
    case value == "elixir2019" do
      true -> changeset
      false -> add_error(changeset, :invite, "invalid invite code")
    end
  end
end
