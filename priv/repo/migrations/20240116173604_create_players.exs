defmodule YourApp.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string
      add :chips, :integer, default: 3
      timestamps()
    end
  end
end
