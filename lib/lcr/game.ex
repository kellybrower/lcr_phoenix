defmodule Lcr.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :current_turn, :integer
    field :center_pot, :integer, default: 0
    # Add other fields as necessary
    timestamps()
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:current_turn, :center_pot])
  end
end
