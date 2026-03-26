defmodule Timertimer.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create_if_not_exists index(:athletes, [:gender])
    create_if_not_exists index(:athletes, [:country])
    create_if_not_exists index(:times, [:athlete_id])
    create_if_not_exists index(:times, [:round])
    create_if_not_exists index(:times, [:athlete_id, :round])

    create_if_not_exists index(:times, [:athlete_id])

    create_if_not_exists index(:matches, [:athlete1_id])
    create_if_not_exists index(:matches, [:athlete2_id])
    create_if_not_exists index(:matches, [:winner_id])

    create_if_not_exists index(:matches, [:athlete1_id, :athlete2_id])

    create_if_not_exists index(:athletes, [:id])

    create_if_not_exists index(:times, [:athlete_id, :round])

    create_if_not_exists index(:matches, [:round, :position])
  end
end
