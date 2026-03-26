defmodule Timertimer.Repo.Migrations.CreateTimes do
  use Ecto.Migration

  def change do
    create table(:times) do
      add :time, :integer
      add :athlete_id, references(:athletes, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:times, [:athlete_id])
  end
end
