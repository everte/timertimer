defmodule Timertimer.Repo.Migrations.AddMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :round, :string
      add :position, :integer

      add :athlete1_id, references(:athletes, on_delete: :nothing)
      add :athlete2_id, references(:athletes, on_delete: :nothing)
      add :winner_id, references(:athletes, on_delete: :nothing)

      timestamps()
    end
  end
end
