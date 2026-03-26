defmodule Timertimer.Repo.Migrations.AddStartTimeToTimes do
  use Ecto.Migration

  def up do
    alter table(:times) do
      add :start_time, :utc_datetime
    end

    flush()

    execute "UPDATE times SET start_time = inserted_at WHERE start_time IS NULL"
  end

  def down do
    alter table(:times) do
      remove :start_time
    end
  end
end
