defmodule Lcr.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :name, :string
    field :chips, :integer, default: 3
    timestamps()
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :chips])
    |> validate_required([:name])
  end

  def add_chip(player) do
    %Lcr.Player{player | chips: player.chips + 1}
  end

  def remove_chip(player) do
    %Lcr.Player{player | chips: player.chips - 1}
  end
end
